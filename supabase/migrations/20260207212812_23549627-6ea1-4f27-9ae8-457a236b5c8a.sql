-- Minimal RPC: fetch recent audit entries where actor_id = auth.uid()
-- Supports UT2 proof: verifying blocked attempts are auditable by the actor
CREATE OR REPLACE FUNCTION public.get_my_recent_audit(p_limit integer DEFAULT 20)
RETURNS TABLE(
  id uuid,
  actor_id uuid,
  action text,
  entity_type text,
  entity_id uuid,
  lifecycle_context jsonb,
  created_at timestamp with time zone
)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = 'public'
AS $$
  SELECT al.id, al.actor_id, al.action, al.entity_type, al.entity_id, al.lifecycle_context, al.created_at
  FROM public.audit_log al
  WHERE al.actor_id = auth.uid()
  ORDER BY al.created_at DESC
  LIMIT p_limit;
$$;

REVOKE ALL ON FUNCTION public.get_my_recent_audit(integer) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.get_my_recent_audit(integer) TO authenticated;
