
-- Create card_deliveries table
CREATE TABLE public.card_deliveries (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  issuance_id uuid NOT NULL REFERENCES public.card_issuances(id),
  recipient_member_id uuid,
  invitee_locator text,
  status text NOT NULL DEFAULT 'pending',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT exactly_one_recipient CHECK (
    (recipient_member_id IS NOT NULL AND invitee_locator IS NULL)
    OR (recipient_member_id IS NULL AND invitee_locator IS NOT NULL)
  )
);

-- Indexes
CREATE INDEX idx_card_deliveries_issuance ON public.card_deliveries(issuance_id);
CREATE INDEX idx_card_deliveries_recipient ON public.card_deliveries(recipient_member_id);

-- Enable RLS
ALTER TABLE public.card_deliveries ENABLE ROW LEVEL SECURITY;

-- Recipients can view their own deliveries
CREATE POLICY "Recipients can view own deliveries"
  ON public.card_deliveries FOR SELECT
  USING (recipient_member_id = auth.uid());

-- Recipients can update their own deliveries (accept/reject)
CREATE POLICY "Recipients can update own deliveries"
  ON public.card_deliveries FOR UPDATE
  USING (recipient_member_id = auth.uid());

-- Issuers can view deliveries for their issuances
CREATE POLICY "Issuers can view deliveries for own issuances"
  ON public.card_deliveries FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.card_issuances ci
      WHERE ci.id = issuance_id AND ci.issuer_id = auth.uid()
    )
  );

-- Insert policy for system/RPC use (security definer functions handle inserts)
CREATE POLICY "System can insert deliveries"
  ON public.card_deliveries FOR INSERT
  WITH CHECK (true);
