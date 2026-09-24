# Software Safety Classification — IEC 62304 §4.3

> **Status: initial classification.** Based on
> [[../../ISO-14971/hazard_analysis/00-hazard-analysis.md]]. Per §4.3,
> classification is decided per software item/segment, using the worst
> credible severity that item could contribute to *if it fails*, before
> crediting any risk control that isn't itself part of that software item.

## Classification rule (recap)

- **Class A** — no injury or damage to health possible.
- **Class B** — non-serious injury possible.
- **Class C** — death or serious injury possible.

A software item is classified by the most severe harm it could
contribute to, **not reduced by a risk control implemented in that same
software item** — only an *independent* control (e.g. a separate
hardware limiter, or a separate software item) can justify a lower class
for the item it protects.

## Decision: overall system — Class C

From the hazard analysis, HAZ-004, HAZ-005, HAZ-006 (decide-stage) and
the interpretation logic behind HAZ-001/002/003 (monitor-stage) all show
software directly contributing to S4/S5 harms (severe
hypo/hyperglycemia, DKA, death). Per §4.3, that puts the software that
computes and commands the insulin dose at **Class C**.

This is a conservative, whole-system default. It is expected to
**narrow to per-item classification** once the architecture is broken
into items — see below.

## Why not B, and what would change that

The open question from the hazard analysis — whether a
**hardware-independent max-dose limiter** exists on the pump, separate
from the dosing algorithm — is exactly the thing that determines this.

- **If it exists and is independent** (own circuit/firmware, not
  reachable by a bug in the dosing algorithm): the *dosing algorithm's*
  contribution to HAZ-004/007/009 is capped by that limiter, and the
  algorithm item's class could potentially be argued down to **B** —
  the limiter itself then inherits the **C** classification, since it's
  now the thing standing between a software error and death.
- **If it does not exist, or shares any code/hardware path with the
  dosing algorithm**: no credit is available, the algorithm stays
  **C**, full stop.

This is a real design decision, not a paperwork one — building that
limiter is a hardware/firmware scoping question for the pump module, not
something resolved by writing more docs. Flagging it here as the
**highest-leverage open item** in the whole project: it determines how
much of the codebase needs Class C rigor (full IEC 62304 §5–§9: detailed
design docs, unit AND integration testing with coverage, formal
problem-resolution process) versus Class B (lighter documentation,
integration+system test focus, problem-resolution still required but
less formal).

## Per-item breakdown (preliminary — items not yet defined in code)

| Software item (anticipated)                  | Contributes to      | Class (pending limiter decision) |
|------------------------------------------------|----------------------|-----------------------------------|
| CGM signal acquisition/interpretation           | HAZ-001, 002, 003    | C |
| Dosing/control algorithm                        | HAZ-004, 005, 006    | C (→ possibly B if independent hardware limiter exists) |
| Pump command interface                          | HAZ-007, 009         | C |
| Host-side Ada reference model / oracle          | (verification tool, not on-device) | N/A — not a deployed software item; still worth SPARK-proving given what it's checking, but 62304 classification doesn't apply to a tool that never runs on the device |
| Alarm/notification path                         | HAZ-010 (and as a control for others) | To be determined once alarm design exists — an independent, battery-backed alarm could itself be a risk-reducing item for the others |

This table replaces `example_module` with real anticipated items once
the architecture is designed — that's the next natural point to rename
`src/device/example_module/` and `ada/src/example_module/` to something
real (e.g. `dosing_algorithm`).

## Consequence for process rigor (what Class C actually requires)

Per IEC 62304 for Class C items:
- Full software development plan, detailed design docs, source-level
  traceability (`python/data/requirements.yaml` already set up for this)
- Unit **and** integration test evidence, with coverage rationale
- Formal problem-resolution process is mandatory (not optional the way
  it can be soft-pedaled at Class B) — `docs/certifications/IEC-62304/problem_resolution/`
  needs real content before any Class C item ships
- SOUP (software of unknown provenance) evaluation for any third-party
  code/libraries pulled in

## Open questions

- Hardware max-dose limiter: exists / doesn't / TBD — **the** decision
  that determines whether this whole project runs at uniform Class C or
  splits B/C by item.
- Once items are named for real, each needs this same worst-case-harm
  walk-through individually, not just inherited from this preliminary
  table.