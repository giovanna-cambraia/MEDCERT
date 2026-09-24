# Software Safety Classification — IEC 62304 §4.3

> **Status: classification decision updated — Option A (independent
> safety controller) chosen in
> [[../../IEC-60601-1-4/pems_architecture/00-pems-architecture.md]]. See
> "Update" section below for what that does and does not change yet.**
> Based on
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

The open question from the hazard analysis has been resolved
architecturally: **Option A (independent safety controller MCU) is
chosen.** That satisfies the independence bar in principle — but §4.3
credit for an independent risk control requires the control to actually
*exist and be verified*, not just be architecturally decided. See
"Update" section below for what that means right now versus once the
safety controller is built.

- **Once built and verified**: the *dosing algorithm's* contribution to
  HAZ-004/007/009 is capped by the safety controller, and the algorithm
  item's class can be argued down to **B** — the safety-controller
  firmware itself then inherits **C**, since it's now the thing standing
  between a software error and death.
- **Until then**: no credit is available yet. The dosing algorithm stays
  **C** as the honest current state, same discipline as the FMEA
  worksheet's `residual_risk: null` rows — a chosen architecture is not
  a built-and-verified one.

## Update — Option A chosen: current state vs. eventual state

| Item | Class today (safety controller not yet built) | Class once safety controller is built + verified |
|------|--------------------------------------------------|------------------------------------------------------|
| Dosing algorithm | **C** (no credit yet) | Candidate **B** |
| Safety controller firmware (new item, doesn't exist yet in per-item table below) | N/A — not built | **C** |
| Pump command interface | **C** | Likely still **C** — it's downstream of the limiter, still needs to correctly apply the clamped command |
| CGM signal acquisition | **C** | Unaffected by this decision — HAZ-001/002/003 aren't addressed by a dose limiter |

Nothing in the per-item table below is changed by this yet — it still
lists the pre-decision state, since the safety controller isn't a real
item in the codebase until it's designed. Update that table when it is.

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

- Whether the dosing algorithm's classification actually drops to B once
  the safety controller exists, or whether review at that time finds a
  residual path that keeps it at C (e.g. if the pump command interface
  turns out not to be fully downstream of the limiter) — don't assume B
  is guaranteed just because the architecture was chosen.
- Once items are named for real, each needs this same worst-case-harm
  walk-through individually, not just inherited from this preliminary
  table.