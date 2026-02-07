
-- =============================================
-- OPN4.001 Schema Migration
-- Enums, Tables, Triggers, RLS, RPCs
-- =============================================

-- 1. ENUMS
CREATE TYPE public.card_form_type AS ENUM ('entity', 'data', 'use');
CREATE TYPE public.card_form_status AS ENUM ('draft', 'registered');
CREATE TYPE public.issuance_status AS ENUM ('issued', 'accepted', 'rejected');

-- 2. TABLES

-- card_forms: type-level definitions (eligible structures)
CREATE TABLE public.card_forms (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  form_type public.card_form_type NOT NULL,
  name text NOT NULL,
  schema_definition jsonb NOT NULL,
  status public.card_form_status NOT NULL DEFAULT 'draft',
  registered_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- card_instances: member-local CARD instances
CREATE TABLE public.card_instances (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  form_id uuid NOT NULL REFERENCES public.card_forms(id),
  member_id uuid NOT NULL REFERENCES auth.users(id),
  payload jsonb NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- card_issuances: directional issuance state
CREATE TABLE public.card_issuances (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  instance_id uuid NOT NULL REFERENCES public.card_instances(id),
  issuer_id uuid NOT NULL REFERENCES auth.users(id),
  recipient_member_id uuid REFERENCES auth.users(id),
  invitee_locator text,
  status public.issuance_status NOT NULL DEFAULT 'issued',
  issued_at timestamptz NOT NULL DEFAULT now(),
  resolved_at timestamptz,
  CONSTRAINT exactly_one_recipient CHECK (
    (recipient_member_id IS NOT NULL AND invitee_locator IS NULL)
    OR (recipient_member_id IS NULL AND invitee_locator IS NOT NULL)
  )
);

-- audit_log: intent-based lifecycle audit
CREATE TABLE public.audit_log (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  actor_id uuid REFERENCES auth.users(id),  -- nullable for system actions (UT1/form_registered)
  action text NOT NULL,
  entity_type text NOT NULL,
  entity_id uuid NOT NULL,
  lifecycle_context jsonb,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- 3. TRIGGER: Enforce registered-form constraint on card_instances INSERT (Tightening #2)
CREATE OR REPLACE FUNCTION public.enforce_registered_form()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  form_status public.card_form_status;
BEGIN
  SELECT status INTO form_status
  FROM public.card_forms
  WHERE id = NEW.form_id;

  IF form_status IS NULL THEN
    RAISE EXCEPTION 'Form does not exist: %', NEW.form_id;
  END IF;

  IF form_status != 'registered' THEN
    RAISE EXCEPTION 'Cannot create instance from unregistered form (status: %)', form_status;
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_enforce_registered_form
  BEFORE INSERT ON public.card_instances
  FOR EACH ROW
  EXECUTE FUNCTION public.enforce_registered_form();

-- 4. RLS POLICIES

-- card_forms: authenticated-only, registered forms only (Tightening #1)
ALTER TABLE public.card_forms ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can view registered forms"
  ON public.card_forms
  FOR SELECT
  TO authenticated
  USING (status = 'registered');

-- card_instances: owner-only (UT3)
ALTER TABLE public.card_instances ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Members can view own instances"
  ON public.card_instances
  FOR SELECT
  TO authenticated
  USING (member_id = auth.uid());

CREATE POLICY "Members can create own instances"
  ON public.card_instances
  FOR INSERT
  TO authenticated
  WITH CHECK (member_id = auth.uid());

-- card_issuances: issuer or recipient
ALTER TABLE public.card_issuances ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Parties can view their issuances"
  ON public.card_issuances
  FOR SELECT
  TO authenticated
  USING (issuer_id = auth.uid() OR recipient_member_id = auth.uid());

CREATE POLICY "Issuer can create issuances"
  ON public.card_issuances
  FOR INSERT
  TO authenticated
  WITH CHECK (issuer_id = auth.uid());

CREATE POLICY "Recipient can update issuance status"
  ON public.card_issuances
  FOR UPDATE
  TO authenticated
  USING (recipient_member_id = auth.uid());

-- audit_log: insert only (reads via RPC)
ALTER TABLE public.audit_log ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Actors can insert audit entries"
  ON public.audit_log
  FOR INSERT
  TO authenticated
  WITH CHECK (actor_id = auth.uid() OR actor_id IS NULL);

-- 5. SECURITY-DEFINER RPCs

-- RPC: get_issued_card_instance (Correction #1 — UT4 recipient review)
CREATE OR REPLACE FUNCTION public.get_issued_card_instance(p_issuance_id uuid)
RETURNS TABLE (
  instance_id uuid,
  form_id uuid,
  payload jsonb,
  created_at timestamptz
)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT ci.id, ci.form_id, ci.payload, ci.created_at
  FROM public.card_instances ci
  INNER JOIN public.card_issuances cis ON cis.instance_id = ci.id
  WHERE cis.id = p_issuance_id
    AND cis.recipient_member_id = auth.uid()
    AND cis.status IN ('issued', 'accepted');
$$;

-- RPC: get_audit_trail (Correction #2 — UT6 party-based audit)
CREATE OR REPLACE FUNCTION public.get_audit_trail(p_entity_type text, p_entity_id uuid)
RETURNS TABLE (
  id uuid,
  actor_id uuid,
  action text,
  entity_type text,
  entity_id uuid,
  lifecycle_context jsonb,
  created_at timestamptz
)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT al.id, al.actor_id, al.action, al.entity_type, al.entity_id, al.lifecycle_context, al.created_at
  FROM public.audit_log al
  WHERE al.entity_type = p_entity_type
    AND al.entity_id = p_entity_id
    AND (
      al.actor_id = auth.uid()
      OR al.lifecycle_context->>'issuer_id' = auth.uid()::text
      OR al.lifecycle_context->>'recipient_member_id' = auth.uid()::text
    )
  ORDER BY al.created_at ASC;
$$;
