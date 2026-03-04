
-- ============================================================================
-- Fix: Recreate all RLS policies as PERMISSIVE (drop RESTRICTIVE versions)
-- ============================================================================

-- ── card_forms ──────────────────────────────────────────────────────────────
DROP POLICY IF EXISTS "Authenticated users can view registered forms" ON public.card_forms;
CREATE POLICY "Authenticated users can view registered forms"
  ON public.card_forms FOR SELECT TO authenticated
  USING (status = 'registered'::card_form_status);

-- ── card_instances ──────────────────────────────────────────────────────────
DROP POLICY IF EXISTS "Members can view own instances" ON public.card_instances;
CREATE POLICY "Members can view own instances"
  ON public.card_instances FOR SELECT TO authenticated
  USING (member_id = auth.uid());

DROP POLICY IF EXISTS "Members can create own instances" ON public.card_instances;
CREATE POLICY "Members can create own instances"
  ON public.card_instances FOR INSERT TO authenticated
  WITH CHECK (member_id = auth.uid());

-- ── card_issuances ──────────────────────────────────────────────────────────
DROP POLICY IF EXISTS "Parties can view their issuances" ON public.card_issuances;
CREATE POLICY "Parties can view their issuances"
  ON public.card_issuances FOR SELECT TO authenticated
  USING (issuer_id = auth.uid() OR recipient_member_id = auth.uid());

DROP POLICY IF EXISTS "Issuer can create issuances" ON public.card_issuances;
CREATE POLICY "Issuer can create issuances"
  ON public.card_issuances FOR INSERT TO authenticated
  WITH CHECK (issuer_id = auth.uid());

DROP POLICY IF EXISTS "Recipient can update issuance status" ON public.card_issuances;
CREATE POLICY "Recipient can update issuance status"
  ON public.card_issuances FOR UPDATE TO authenticated
  USING (recipient_member_id = auth.uid());

-- ── card_deliveries ─────────────────────────────────────────────────────────
DROP POLICY IF EXISTS "Issuers can view deliveries for own issuances" ON public.card_deliveries;
CREATE POLICY "Issuers can view deliveries for own issuances"
  ON public.card_deliveries FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM card_issuances ci
      WHERE ci.id = card_deliveries.issuance_id
        AND ci.issuer_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Recipients can view own deliveries" ON public.card_deliveries;
CREATE POLICY "Recipients can view own deliveries"
  ON public.card_deliveries FOR SELECT TO authenticated
  USING (recipient_member_id = auth.uid());

DROP POLICY IF EXISTS "Authenticated users can insert deliveries" ON public.card_deliveries;
CREATE POLICY "Authenticated users can insert deliveries"
  ON public.card_deliveries FOR INSERT TO authenticated
  WITH CHECK (true);

DROP POLICY IF EXISTS "Recipients can update own deliveries" ON public.card_deliveries;
CREATE POLICY "Recipients can update own deliveries"
  ON public.card_deliveries FOR UPDATE TO authenticated
  USING (recipient_member_id = auth.uid());

-- ── audit_log ───────────────────────────────────────────────────────────────
DROP POLICY IF EXISTS "Actors can insert audit entries" ON public.audit_log;
CREATE POLICY "Actors can insert audit entries"
  ON public.audit_log FOR INSERT TO authenticated
  WITH CHECK (actor_id = auth.uid());

DROP POLICY IF EXISTS "Members can view own audit events" ON public.audit_log;
CREATE POLICY "Members can view own audit events"
  ON public.audit_log FOR SELECT TO authenticated
  USING (
    actor_id = auth.uid()
    OR (lifecycle_context->>'issuer_id' = auth.uid()::text)
    OR (lifecycle_context->>'recipient_member_id' = auth.uid()::text)
    OR (
      actor_id IS NULL
      AND (lifecycle_context->>'issuer_id') IS NOT NULL
      AND (lifecycle_context->>'issuer_id' = auth.uid()::text)
    )
  );
