# Deterministic EMV Audit Engine

## Purpose

This project is a UI-independent deterministic synthetic transaction laboratory.

It provides a complete synthetic transaction lifecycle:

    card definition
        ↓
    canonical request
        ↓
    card derivation & real BIN issuer metadata mapping
        ↓
    EMV/APDU representation
        ↓
    transformation registry
        ↓
    authorization simulation
        ↓
    transaction state
        ↓
    immutable audit chain
        ↓
    restate
        ↓
    exact replay
        ↓
    differential experiment
        ↓
    evidence

---

# Synthetic Card Laboratory

Card data in this system is strictly **synthetic**.
Numbers are deterministically completed to 16-digit Luhn-valid PANs anchored in real Visa, Mastercard, and AmEx BIN ranges and regional issuer metadata for protocol analysis.

It does **not** query live payment networks or process real payment credentials.
