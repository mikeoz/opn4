-- ============================================================================
-- Opn.li Agent Safe — Bob Bethany Demo Seed
-- Creates the complete demo state against a clean Supabase instance
-- (with migrations 001–006 already applied).
--
-- Prerequisites:
--   1. A Supabase Auth user with UUID 24c370ca-517a-4a18-99b3-3c99581f2a62
--      (email: bob@bethany.demo or equivalent)
--   2. All migrations 001–006 applied
--
-- This script registers the three CARD form types, creates the canonical
-- agent Entity CARD, and creates three Data CARDs. After running, the
-- demo account is ready for the 3-minute walkthrough.
-- ============================================================================

BEGIN;

-- ════════════════════════════════════════════════════════════════════════════
-- STEP 1: Register the three CARD form types
-- These form IDs are immutable constants. Do not change them.
-- ════════════════════════════════════════════════════════════════════════════

INSERT INTO public.card_forms (id, form_type, name, schema_definition, status, registered_at)
VALUES
  -- Entity CARD form
  (
    '96583b62-2ee5-40e3-a633-fb14e88e888b',
    'entity',
    'Entity CARD',
    '{
      "allowed_types": ["https://opn.li/types/card/entity"],
      "required_paths": [
        "card.type",
        "card.title",
        "parties.holder",
        "parties.subject",
        "claims.items",
        "lifecycle.status"
      ]
    }'::jsonb,
    'registered',
    now()
  ),
  -- Data CARD form
  (
    '147a8e87-46f6-4145-b27e-87abbf8cdb77',
    'data',
    'Data CARD',
    '{
      "allowed_types": ["https://opn.li/types/card/data"],
      "required_paths": [
        "card.type",
        "card.title",
        "parties.holder",
        "claims.items",
        "lifecycle.status"
      ]
    }'::jsonb,
    'registered',
    now()
  ),
  -- Use CARD form
  (
    '72d0ae00-091e-4c20-a183-0090bc12a888',
    'use',
    'Use CARD',
    '{
      "allowed_types": ["https://opn.li/types/card/use"],
      "required_paths": [
        "card.type",
        "card.title",
        "parties.holder",
        "parties.agents",
        "claims.items",
        "lifecycle.status",
        "policy.consent"
      ]
    }'::jsonb,
    'registered',
    now()
  )
ON CONFLICT (id) DO NOTHING;

-- ════════════════════════════════════════════════════════════════════════════
-- STEP 2: Create the canonical agent Entity CARD
-- Instance ID: b3434fd2-b242-410b-b71a-cee453604c2d
-- Stable agent URI: urn:uuid:5b3a4df1-d71b-4e8c-9c6d-22f12a95c358
-- ════════════════════════════════════════════════════════════════════════════

INSERT INTO public.card_instances (id, form_id, member_id, payload, is_current)
VALUES (
  'b3434fd2-b242-410b-b71a-cee453604c2d',
  '96583b62-2ee5-40e3-a633-fb14e88e888b',
  '24c370ca-517a-4a18-99b3-3c99581f2a62',
  '{
    "card": {
      "id": "urn:uuid:5b3a4df1-d71b-4e8c-9c6d-22f12a95c358",
      "type": "https://opn.li/types/card/entity",
      "title": "My Health Assistant",
      "schema_version": "0.1",
      "spec_version": "0.1",
      "created_at": "2026-02-24T00:00:00Z"
    },
    "parties": {
      "holder": {
        "id": "urn:uuid:24c370ca-517a-4a18-99b3-3c99581f2a62",
        "kind": "person",
        "display_name": "Bob Bethany"
      },
      "subject": {
        "id": "urn:uuid:5b3a4df1-d71b-4e8c-9c6d-22f12a95c358",
        "kind": "agent",
        "display_name": "My Health Assistant"
      },
      "operator": {
        "id": "https://opn.li",
        "kind": "org",
        "display_name": "Opn.li"
      }
    },
    "claims": {
      "items": [
        {
          "id": "urn:uuid:claim-agent-001",
          "category": "attestation",
          "resource": {
            "uri": "urn:uuid:5b3a4df1-d71b-4e8c-9c6d-22f12a95c358",
            "display_name": "My Health Assistant — Agent Registration",
            "storage": "tno_registry"
          },
          "sensitivity": {
            "level": "moderate",
            "labels": ["agent_identity"]
          },
          "agent_metadata": {
            "kind": "ai_assistant",
            "capabilities": ["read", "derive"],
            "model": {
              "provider": "Anthropic",
              "name": "claude-sonnet"
            }
          }
        }
      ]
    },
    "lifecycle": {
      "status": "active"
    },
    "policy": {
      "consent": {
        "basis": "explicit",
        "grants": []
      },
      "prohibitions": [
        { "code": "no_onward_sharing", "enforcement_tier": "architectural" },
        { "code": "no_training", "enforcement_tier": "contractual" }
      ],
      "retention": {
        "mode": "indefinite"
      },
      "revocation": {
        "supported": true,
        "mechanism": "tno_registry"
      }
    },
    "provenance": {
      "sources": [
        {
          "type": "user",
          "ref": {
            "uri": "urn:uuid:24c370ca-517a-4a18-99b3-3c99581f2a62",
            "storage": "tno_registry"
          }
        }
      ]
    },
    "security": {
      "integrity": {
        "digest": {
          "alg": "sha-256",
          "value": "PLACEHOLDER"
        }
      }
    }
  }'::jsonb,
  true
)
ON CONFLICT (id) DO NOTHING;

-- ════════════════════════════════════════════════════════════════════════════
-- STEP 3: Create three Data CARDs
-- These represent Bob's health data resources.
-- ════════════════════════════════════════════════════════════════════════════

-- Data CARD 1: Vital Signs & Screening Results
INSERT INTO public.card_instances (id, form_id, member_id, payload, is_current)
VALUES (
  'c6899631-a5ba-47fe-b525-60e3f2770753',
  '147a8e87-46f6-4145-b27e-87abbf8cdb77',
  '24c370ca-517a-4a18-99b3-3c99581f2a62',
  '{
    "card": {
      "id": "",
      "type": "https://opn.li/types/card/data",
      "title": "Vital Signs & Screening Results",
      "version": "0.1"
    },
    "parties": {
      "holder": {
        "id": "urn:uuid:24c370ca-517a-4a18-99b3-3c99581f2a62",
        "display_name": "Bob Bethany"
      },
      "subject": { "display_name": "Bob Bethany" },
      "recipients": [{}]
    },
    "claims": {
      "items": [
        {
          "resource": {
            "uri": "file:///health/vital-signs.pdf",
            "display_name": "Vital Signs & Screening Results"
          },
          "allowed_actions": ["read"],
          "sensitivity": "high"
        }
      ]
    },
    "lifecycle": { "status": "active" },
    "policy": {
      "consent": {
        "basis": "explicit",
        "granted_at": "2026-02-23T00:00:00Z"
      },
      "prohibitions": [
        { "code": "no_retention", "enforcement_tier": "contractual" },
        { "code": "no_training", "enforcement_tier": "contractual" },
        { "code": "no_onward_sharing", "enforcement_tier": "contractual" }
      ],
      "purpose": "health_monitoring",
      "retention": { "duration": "P30D", "delete_on_expiry": true },
      "revocation": { "permitted": true, "immediate": true }
    }
  }'::jsonb,
  true
)
ON CONFLICT (id) DO NOTHING;

-- Data CARD 2: Medications & Immunizations
INSERT INTO public.card_instances (id, form_id, member_id, payload, is_current)
VALUES (
  '0258e421-2605-4a32-a635-d65aaea06954',
  '147a8e87-46f6-4145-b27e-87abbf8cdb77',
  '24c370ca-517a-4a18-99b3-3c99581f2a62',
  '{
    "card": {
      "id": "",
      "type": "https://opn.li/types/card/data",
      "title": "Medications & Immunizations",
      "version": "0.1"
    },
    "parties": {
      "holder": {
        "id": "urn:uuid:24c370ca-517a-4a18-99b3-3c99581f2a62",
        "display_name": "Bob Bethany"
      },
      "subject": { "display_name": "Bob Bethany" },
      "recipients": [{}]
    },
    "claims": {
      "items": [
        {
          "resource": {
            "uri": "file:///health/medications.pdf",
            "display_name": "Medications & Immunizations"
          },
          "allowed_actions": ["read"],
          "sensitivity": "high"
        }
      ]
    },
    "lifecycle": { "status": "active" },
    "policy": {
      "consent": {
        "basis": "explicit",
        "granted_at": "2026-02-23T00:00:00Z"
      },
      "prohibitions": [
        { "code": "no_retention", "enforcement_tier": "contractual" },
        { "code": "no_training", "enforcement_tier": "contractual" },
        { "code": "no_onward_sharing", "enforcement_tier": "contractual" }
      ],
      "purpose": "health_monitoring",
      "retention": { "duration": "P30D", "delete_on_expiry": true },
      "revocation": { "permitted": true, "immediate": true }
    }
  }'::jsonb,
  true
)
ON CONFLICT (id) DO NOTHING;

-- Data CARD 3: Cardiac Monitor Report
INSERT INTO public.card_instances (id, form_id, member_id, payload, is_current)
VALUES (
  '5ccf8aa3-c4b6-4692-829f-d9aca52738c4',
  '147a8e87-46f6-4145-b27e-87abbf8cdb77',
  '24c370ca-517a-4a18-99b3-3c99581f2a62',
  '{
    "card": {
      "id": "",
      "type": "https://opn.li/types/card/data",
      "title": "Cardiac Monitor Report",
      "version": "0.1"
    },
    "parties": {
      "holder": {
        "id": "urn:uuid:24c370ca-517a-4a18-99b3-3c99581f2a62",
        "display_name": "Bob Bethany"
      },
      "subject": { "display_name": "Bob Bethany" },
      "recipients": [{}]
    },
    "claims": {
      "items": [
        {
          "resource": {
            "uri": "file:///health/cardiac-monitor.pdf",
            "display_name": "Cardiac Monitor Report"
          },
          "allowed_actions": ["read"],
          "sensitivity": "high"
        }
      ]
    },
    "lifecycle": { "status": "active" },
    "policy": {
      "consent": {
        "basis": "explicit",
        "granted_at": "2026-02-23T00:00:00Z"
      },
      "prohibitions": [
        { "code": "no_retention", "enforcement_tier": "contractual" },
        { "code": "no_training", "enforcement_tier": "contractual" },
        { "code": "no_onward_sharing", "enforcement_tier": "contractual" }
      ],
      "purpose": "health_monitoring",
      "retention": { "duration": "P30D", "delete_on_expiry": true },
      "revocation": { "permitted": true, "immediate": true }
    }
  }'::jsonb,
  true
)
ON CONFLICT (id) DO NOTHING;

-- ════════════════════════════════════════════════════════════════════════════
-- STEP 4: Seed audit entries for form registrations
-- (Normally created by register_card_form RPC, but we inserted directly)
-- ════════════════════════════════════════════════════════════════════════════

INSERT INTO public.audit_log (action, entity_type, entity_id, actor_id, lifecycle_context)
VALUES
  ('form_registered', 'card_form', '96583b62-2ee5-40e3-a633-fb14e88e888b',
   '24c370ca-517a-4a18-99b3-3c99581f2a62',
   '{"form_name": "Entity CARD", "form_type": "entity"}'::jsonb),
  ('form_registered', 'card_form', '147a8e87-46f6-4145-b27e-87abbf8cdb77',
   '24c370ca-517a-4a18-99b3-3c99581f2a62',
   '{"form_name": "Data CARD", "form_type": "data"}'::jsonb),
  ('form_registered', 'card_form', '72d0ae00-091e-4c20-a183-0090bc12a888',
   '24c370ca-517a-4a18-99b3-3c99581f2a62',
   '{"form_name": "Use CARD", "form_type": "use"}'::jsonb);

COMMIT;

-- ════════════════════════════════════════════════════════════════════════════
-- VERIFICATION: Run this query to confirm demo state is correct
-- ════════════════════════════════════════════════════════════════════════════
--
-- SELECT
--   (SELECT COUNT(*) FROM card_issuances
--    WHERE status = 'accepted'
--    AND issuer_id = '24c370ca-517a-4a18-99b3-3c99581f2a62') as active_permissions,
--   (SELECT COUNT(*) FROM card_instances ci
--    JOIN card_forms cf ON ci.form_id = cf.id
--    WHERE ci.member_id = '24c370ca-517a-4a18-99b3-3c99581f2a62'
--    AND cf.form_type = 'data') as data_cards,
--   (SELECT COUNT(*) FROM card_instances ci
--    JOIN card_forms cf ON ci.form_id = cf.id
--    WHERE ci.member_id = '24c370ca-517a-4a18-99b3-3c99581f2a62'
--    AND cf.form_type = 'entity'
--    AND ci.payload->'lifecycle'->>'status' = 'active'
--    AND ci.is_current = true) as active_agents;
--
-- Expected: active_permissions=0, data_cards=3, active_agents=1
