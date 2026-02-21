# Istockhomes-public
Public overview of the Istockhomes platform, architecture philosophy, and developer participation model.
# Istockhomes — Public Overview

This repository provides a **public-facing overview** of the Istockhomes platform.

It exists to explain *how we think*, *what we are building*, and *how developers may participate* — without exposing proprietary systems or implementation details.

---

## What Istockhomes is

Istockhomes is a long-term platform designed to surface **real value in the physical world**.

That includes:
- homes and real estate
- artwork and one-of-a-kind creations
- businesses and inventory
- trades and services
- high-value assets (marine, aviation, equipment)

The platform is mobile-first, AI-assisted, and built to feel calm and human — even when the infrastructure behind it is complex.

---

## How the platform works (high level)

At its simplest, a listing can begin with a photo.

From there, the system handles:
- intelligent categorization
- guided listing creation
- trust and identity enforcement
- automated revenue distribution
- long-term durability of content

Modern phone capabilities (camera, location, biometrics) are used naturally rather than forced.

---

## Economic model (intentionally simple)

All transactions on Istockhomes follow a **90 / 10 rule**.

- 90% goes to the people who create and surface value
- 10% supports the Istockhomes ecosystem

Splits inside the 90% follow familiar industry norms and are chosen at the listing level.

Developers who help build revenue-generating systems may participate through **automatic revenue sharing**, not billing or time tracking.

---

## Entities, not jobs

Istockhomes is built around **entities**, not employment.

Entities are branded digital portals that can be:
- developed
- operated
- leased
- renewed
- sold

Developers may support one or more entities behind the scenes.
Others operate them forward-facing as trust anchors.

Participation grows through alignment and trust, not contracts alone.

---

## What this repository is not

This repository does not contain:
- production code
- payment logic
- identity systems
- AI orchestration
- proprietary infrastructure

Those systems are intentionally protected.

---

## How to learn more

If this resonates, the next step is not a pull request.

Start here:
https://istockhomes.ca/pages/inside-istockhomes-developers

That page explains what we are building and how participation works.

---

## 📜 The Istockhomes Constitution

This project is governed by the **Istockhomes Constitution**.

- No sign-ups
- No gatekeepers
- No secrecy
- Fork freely
- Build businesses, not platforms

👉 Read it here: [CONSTITUTION.md](./CONSTITUTION.md)

## API Structure (Public Read-Only vs Private Write)

Istockhomes uses a **two-surface API model**:

### 1) Public Read-Only API (documented)
These endpoints are intended for:
- viewer apps
- search/browse
- public discovery
- read-only dashboards

**No write access is granted through the read-only surface.**

Reference: **API-READONLY.md (API-RO v1.0)**

Typical examples:
- `GET /App/api/get-listings.php`
- `GET /App/api/Listings.php`
- `GET /App/api/get-branding.php`

---

### 2) Private Write API (restricted / not publicly documented)
These endpoints are intended for:
- authenticated users
- listing creation/editing
- identity verification steps
- enforcement + permissions

Write access requires:
- authenticated session tokens
- server validation
- eligibility rules (trust / verified state)

Examples (restricted):
- `POST /App/api/auth.php`
- `POST /App/api/create-listing.php`
- any endpoint using `middleware.php` (Bearer token required)

---

## IMPORTANT
Only endpoints explicitly described in **API-READONLY.md** should be treated as public.
Everything else is considered internal, restricted, and subject to change.## Final note

Istockhomes is being built deliberately, quietly, and for the long term.

We value clarity over speed, trust over access, and systems that compound over time.
