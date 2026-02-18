-- ============================================================
-- OPN4 Sprint 2 Migration: Supersession + Revocation
-- Applied manually in Supabase on Feb 11-18, 2026
-- This file documents the changes for version control
-- ============================================================

-- Add supersession columns to card_instances
ALTER TABLE public.card_instances
  ADD COLUMN IF NOT EXISTS superseded_by  uuid REFERENCES public.card_instances(id),
  ADD COLUMN IF NOT EXISTS superseded_at  timestamptz,
  ADD COLUMN IF NOT EXISTS is_current     boolean NOT NULL DEFAULT true;

CREATE INDEX IF NOT EXISTS idx_card_instances_current 
  ON public.card_instances(member_id, is_current) 
  WHERE is_current = true;

CREATE INDEX IF NOT EXISTS idx_card_instances_supersession 
  ON public.card_instances(superseded_by);

-- Extend issuance_status enum with 'revoked'
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_enum 
    WHERE enumlabel = 'revoked' 
    AND enumtypid = 'public.issuance_status'::regtype
  ) THEN
    ALTER TYPE public.issuance_status ADD VALUE 'revoked';
  END IF;
END $$;

-- NOTE: The following functions were created via Supabase SQL Editor:
-- - supersede_card_instance(uuid, jsonb)
-- - get_card_lineage(uuid)
-- - revoke_card_issuance(uuid)
-- See supabase/migrations/SPRINT2_FUNCTIONS.sql for full definitions
