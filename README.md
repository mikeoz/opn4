# Opn.li Agent Safe

**The trust layer for AI agents.**

> My data + Your AI + My control = Living Intelligence

Every AI agent that wants to reach data protected by this system must check at the front door first. No permission slip — no access. Every action logged. Every permission revocable. Immediately.

---

## The Two Controls

**Control 1 — The Front Door (Verification Endpoint)**
Every agent checks here before reaching your data. Registered? Permission slip? If no — locked out.

**Control 2 — The Permission Slip (CARD)**
You write it. You choose the agent, the data, the action, the duration, the rules. You revoke it any time.

Together: [docs/two-controls.md](docs/two-controls.md)

---

## What's in this repo

| Directory | What it is | Status |
|-----------|-----------|--------|
| `src/` | Agent Safe UI — five screens, full trust layer frontend | Live |
| `endpoint/` | Verification Endpoint — Control 1, the front door | Live (see README) |
| `supabase/` | Database schema, RPCs, RLS policies | Live |
| `docs/` | Two Controls explainer, demo flow, position paper | Live |
| `schema/` | Migration SQL, CARD JSON Schema | March 8 |

---

## Quick start

You need: a [Supabase](https://supabase.com) account (free tier works) and [Node.js](https://nodejs.org).

```bash
# 1. Clone
git clone https://github.com/mikeoz/opn4.git
cd opn4

# 2. Configure
cp .env.example .env
# Edit .env with your Supabase project URL and keys

# 3. Install
npm install

# 4. Push database schema
npx supabase db push

# 5. Run
npm run dev
```

The Verification Endpoint is already live and running:
`https://biejnguqnejzwmypotez.supabase.co/functions/v1/verify-card`

Full schema SQL and seed data published **March 8, 2026** after provisional patent filing.

---

## The demo

Bob has his health records protected by Agent Safe.
His AI health assistant wants to help him understand his vital signs.
Right now, the door is closed.

In 3 minutes: Bob writes a permission slip. His AI gets exactly what the slip says — Vital Signs only, read only, 24 hours. Bob closes the door. One tap. Immediate.

Full demo walkthrough: [docs/demo-flow.md](docs/demo-flow.md)

---

## For OpenClaw developers

If you're building AI agents and your clients handle sensitive data — this is your trust infrastructure.

Your agent registers an Entity CARD. Your client writes a Use CARD (the permission slip). Your agent calls the Verification Endpoint before every data access. Everything is logged. The client can revoke access any time.

That's the pitch: *"Your data never leaves your system. You control who sees it. You can revoke access any time."*

---

## Agent Safe certification

Opn.li Agent Safe is also the name of the certification standard. This repo is the reference implementation.

An agent that integrates with this system — registers an Entity CARD, requests a Use CARD, respects the Verification Endpoint response — is operating as an Agent Safe participant.

Formal certification tiers (CARD Ready, Agent Safe, Trust Node Operator) are defined at [opn.li/certification](https://opn.li/certification).

---

## Status

| Component | Status |
|-----------|--------|
| Verification Endpoint | ✅ Live |
| CARD lifecycle (issue, accept, revoke) | ✅ Live |
| Audit trail | ✅ Live |
| Five-screen UI | ✅ Live |
| Schema SQL (public) | March 8 |
| CARD JSON Schema v0.1 | March 8 |
| Demo seed SQL | March 8 |
| Provisional patent | March 7 |

---

## About

Built by [Opn.li](https://opn.li) — Openly Trusted Services.

*My data. Your AI. My control.*

Apache 2.0 License
