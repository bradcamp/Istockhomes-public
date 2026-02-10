# Istockhomes Read-Only API Specification (API-RO v1.0)

Copyright © 2026 Istockhomes®  
All rights reserved.

---

## 1. Purpose

This document defines the **read-only API surface** of the Istockhomes platform.

It exists to:
- enable open client applications
- support viewer-only and discovery apps
- allow developers to build safely without privileged access
- protect trust, payments, identity, and enforcement logic

This document describes **what may be read**, not what may be written.

---

## 2. Core API Principle

**Read access is open.  
Write access is restricted.  
Authority is centralized.**

Client applications may observe platform state.  
They may not modify platform truth.

---

## 3. Who This API Is For

This API is intended for:

- Viewer applications (e.g. Paruse)
- Discovery portals
- Search and browse interfaces
- Public storefronts
- Read-only analytics or dashboards
- Prototype or experimental frontends

This API is **not** intended for:
- listing submission
- payments
- identity creation
- verification
- reputation modification
- enforcement actions

---

## 4. Authentication Model

Read-only endpoints may be accessed using:

- unauthenticated requests, or
- lightweight public tokens (rate-limited)

No read-only endpoint requires:
- passwords
- Face ID
- biometric confirmation
- user accounts

Rate limits and abuse detection are enforced server-side.

---

## 5. Read-Only Resources

The following resources may be exposed via read-only endpoints.

---

### 5.1 Listings

Read-only listing data may include:

- listing ID
- category
- title
- description
- media URLs
- approximate location
- availability state
- pricing (if public)
- brand / Pyramidion association

Listings do NOT expose:
- private seller data
- contact details
- internal notes
- verification internals
- booking locks
- enforcement flags

---

### 5.2 Assets

Assets may include:

- homes
- vehicles
- yachts
- aircraft
- artwork
- rentals
- services
- events

Assets may appear across multiple brands or portals.

The platform ensures:
- a single authoritative availability state
- no double-booking
- no conflicting transactions

---

### 5.3 Brands & Entities

Read-only brand data may include:

- brand name
- logo
- public description
- verification state
- reputation state (verified / limited / blocked)

Brands do NOT expose:
- financial splits
- ownership structures
- internal agreements

---

### 5.4 Media

Media endpoints may include:

- images
- videos
- thumbnails

Media may be:
- watermarked
- resized
- rate-limited

Original uploads and metadata are protected.

---

### 5.5 Verification Status

Verification endpoints may return:

- verified / limited / blocked
- timestamp of last status change
- public reason codes (non-sensitive)

Verification does NOT expose:
- internal investigation data
- identity artifacts
- enforcement logic

---

## 6. What Is Explicitly NOT Exposed

The following are **never available** via read-only APIs:

- identity creation
- biometric verification
- listing submission
- listing modification
- payment initiation
- payment confirmation
- split configuration
- reputation scoring logic
- ban logic
- enforcement triggers
- AI moderation rules
- fraud detection systems

These systems live exclusively server-side.

---

## 7. Write Operations (Restricted)

Write operations require:

- authenticated identity
- biometric intent
- server-issued tokens
- reputation eligibility
- active verification state

Write APIs are:
- private
- rate-limited
- monitored
- not documented publicly

---

## 8. Abuse Prevention

The platform enforces:

- rate limiting
- anomaly detection
- scraping detection
- IP and device heuristics
- request pattern analysis

Abuse of read-only endpoints may result in:
- throttling
- blocking
- permanent exclusion

---

## 9. Versioning

Read-only APIs are versioned.

Clients should:
- specify API versions
- tolerate additive changes
- avoid reliance on undocumented fields

Breaking changes are minimized.

---

## 10. Developer Responsibilities

Developers consuming read-only APIs must:

- respect rate limits
- cache responsibly
- avoid scraping or mirroring
- present data honestly
- display verification status accurately

Misuse may result in access revocation.

---

## 11. Relationship to Other Documents

This document works in conjunction with:

- LICENSE.md
- DEVELOPERS.md
- ARCHITECTURE.md
- BADGE.md
- ECONOMICS.md

In the event of conflict, **platform enforcement prevails**.

---

## 12. Summary

- Read access is open
- Write access is restricted
- Clients observe, not decide
- Trust is enforced centrally
- Verification is authoritative
- Reputation has memory

---

**Open discovery.  
Central authority.  
One source of truth.**
