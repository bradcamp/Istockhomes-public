# Istockhomes Platform Architecture (ARCH v1.0)

Copyright © 2026 Istockhomes®  
All rights reserved.

---

## 1. Purpose

This document defines the architectural boundaries of the Istockhomes platform.

It explains:
- what client applications are responsible for
- what the platform (server-side) is responsible for
- where authority lives
- why client code is intentionally open
- how trust, payments, and reputation are enforced

This architecture is designed to support:
- real assets
- real people
- real transactions
- real consequences

---

## 2. Core Architectural Principle

**Client applications are non-authoritative.**

All authority lives server-side.

Client apps:
- display data
- collect intent
- submit requests
- present outcomes

Client apps do NOT:
- decide trust
- decide payments
- decide reputation
- decide verification
- decide consequences

---

## 3. System Layers

The Istockhomes platform consists of three distinct layers.

---

### 3.1 Client Layer (Open)

Examples:
- iOS apps (Swift / SwiftUI)
- Android apps
- Web frontends
- Branded / white-labeled portals
- Viewer-only apps (e.g., Paruse)

Responsibilities:
- UI / UX
- Branding and skinning
- Image capture
- Location capture
- User interaction
- Biometric intent submission (Face ID direction)

Characteristics:
- Open source
- Modifiable
- Redistributable
- Non-authoritative
- No secrets
- No keys
- No enforcement logic

---

### 3.2 Platform Layer (Protected)

Examples:
- Istockhomes APIs
- Verification services
- Reputation engine
- Payment routing
- Split logic
- Enforcement rules
- AI moderation and filtering

Responsibilities:
- Identity continuity
- Verification
- Trust enforcement
- Listing validation
- Transaction orchestration
- Buyer confirmation
- Reputation state
- Blocking and reinstatement

Characteristics:
- Closed source
- Centralized
- Server-side only
- Controlled by Istockhomes
- Never embedded in client code

---

### 3.3 Infrastructure Layer (Secure)

Examples:
- Databases
- Payment processors (PayPal split payments)
- AI services
- Logging and audit trails
- Fraud detection
- Backup and recovery

Responsibilities:
- Data persistence
- Payment settlement
- Auditability
- Security
- Compliance

Characteristics:
- Private
- Restricted access
- Not exposed to developers
- Not accessible via client apps

---

## 4. Why Client Code Is Open

Client applications are open because:

- Software should not be the gate
- Trust should be the gate
- Identity should be the gate
- Reputation should be the gate

Open clients:
- encourage experimentation
- allow branding and vertical specialization
- eliminate vendor lock-in
- increase distribution

Security does NOT come from hiding UI code.  
Security comes from **server-side authority and memory**.

---

## 5. Identity Model

Istockhomes does not treat accounts as identity.

Identity is defined by:
- biometric confirmation (Face ID direction)
- device continuity
- behavior history
- transaction outcomes

Emails, usernames, and passwords are secondary.

Identity is:
- persistent
- non-transferable
- reputation-bearing

---

## 6. Listing Model

Listings represent **real-world assets**.

Examples:
- homes
- vehicles
- yachts
- aircraft
- artwork
- events
- rentals
- services

Rules:
- Listings are free to create
- Listings must represent real availability
- AI and metadata are used to detect abuse
- Fake or dead listings are removed
- One real asset may be represented by multiple Pyramidions
- Only one transaction may be active at a time

Authority over listings lives server-side.

---

## 7. Transaction Model

Transactions follow a strict sequence:

1. Listing is selected
2. Buyer expresses intent
3. Payment is initiated
4. Asset or service is delivered
5. Buyer confirms completion (biometric intent)
6. Payment is released
7. Reputation states update

No confirmation → no payout.

---

## 8. Payment Architecture

Payments are:
- routed through Istockhomes-approved infrastructure
- split automatically server-side

Participants may include:
- asset owner / creator
- Pyramidion (sales operator)
- developer
- marketing or SEO partner
- Istockhomes (platform share)

Client apps never:
- hold payment keys
- calculate splits
- decide recipients
- release funds

---

## 9. Reputation & Enforcement

Reputation is:
- platform-wide
- persistent
- consequence-based

States may include:
- Verified
- Limited
- Blocked

Enforcement actions apply across:
- all apps
- all brands
- all devices

Reputation cannot be reset by:
- new emails
- new devices
- new apps
- rebranding

---

## 10. Developer Responsibilities

Developers are responsible for:

- respecting architectural boundaries
- keeping client apps non-authoritative
- displaying verification correctly
- not handling secrets
- not bypassing platform rules

Developers are not responsible for:
- trust enforcement
- payment settlement
- reputation decisions

---

## 11. Failure Model

If a client app:
- is modified maliciously
- attempts to bypass rules
- misrepresents trust

The platform:
- rejects requests
- freezes payouts
- updates reputation
- revokes access

Client apps cannot override platform outcomes.

---

## 12. Summary

- Clients are open
- Authority is centralized
- Trust is enforced
- Payments follow confirmation
- Reputation has memory
- Consequences are real

This separation is intentional.

It is what allows Istockhomes to scale safely while remaining open.

---

## 13. Related Documents

- LICENSE.md  
- DEVELOPERS.md  
- Verification & Consequences  
- Platform Economics  

---

**Open clients.  
Central authority.  
Real outcomes.**
