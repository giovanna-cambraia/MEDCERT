# Hazard Analysis — First Pass

> **Status: draft, first pass.** Goal here is coverage, not precision —
> enough hazards identified per functional stage to unblock software
> classification (IEC 62304 §4.3). Scoring (severity/probability) uses
> the scales from [[../risk_management_plan/01-risk-management-plan.md]].
> Expect this list to grow/split as design gets concrete.

Organized by the three functional stages from
[[../risk_management_plan/00-intended-use.md]]: Monitor (CGM) → Decide
(control algorithm) → Deliver (insulin pump).

## Monitor (CGM sensor input)

| ID    | Hazard                              | Hazardous situation                                              | Harm                                  | Sev | Prob | Notes |
|-------|--------------------------------------|--------------------------------------------------------------------|-----------------------------------------|-----|------|-------|
| HAZ-001 | Sensor reads glucose level inaccurately (drift, calibration error) | Control algorithm receives false-low reading, over-doses insulin | Severe hypoglycemia | S4 | P3 | Most likely single point of failure in the whole loop |
| HAZ-002 | Sensor signal loss / dropout | Control algorithm has no current data, doses on stale/last-known value | Hypo- or hyperglycemia depending on trend at dropout | S3 | P3 | Needs a "no signal" detection + safe-state behavior, not yet defined |
| HAZ-003 | Sensor reads falsely high | Control algorithm over-doses believing glucose is high | Severe hypoglycemia | S4 | P2 | |

## Decide (control algorithm)

| ID    | Hazard                              | Hazardous situation                                              | Harm                                  | Sev | Prob | Notes |
|-------|--------------------------------------|--------------------------------------------------------------------|-----------------------------------------|-----|------|-------|
| HAZ-004 | Dosing algorithm computes incorrect dose (logic error, edge case in control loop) | Wrong insulin amount commanded to pump | Severe hypo- or hyperglycemia, DKA | S4/S5 | P2 | Highest-value target for SPARK proof on the Ada host-side reference model (`ada/`) |
| HAZ-005 | Algorithm fails to detect/react to rapid glucose trend (e.g. exercise-induced drop) | Delayed correction, hypoglycemia progresses unchecked | Severe hypoglycemia | S4 | P3 | |
| HAZ-006 | Algorithm state corruption (e.g. memory fault, race condition) | Unpredictable dosing behavior | S4/S5 (unpredictable) | P2 | Runtime integrity checks / watchdog needed — same pattern as the [[do178c-demo]] BTC liveness watchdog |

## Deliver (insulin pump)

| ID    | Hazard                              | Hazardous situation                                              | Harm                                  | Sev | Prob | Notes |
|-------|--------------------------------------|--------------------------------------------------------------------|-----------------------------------------|-----|------|-------|
| HAZ-007 | Pump over-delivers (mechanical or command fault) | Excess insulin delivered regardless of correct algorithm output | Severe hypoglycemia | S4 | P2 | Needs a max-dose-per-interval hard limit independent of the algorithm |
| HAZ-008 | Pump under-delivers / occludes | Insufficient insulin delivered | Hyperglycemia, DKA over time | S3/S4 | P3 | Occlusion detection is a known hard problem in real pump designs |
| HAZ-009 | Pump delivers on stale/duplicate command | Double-dosing from a single decision | Severe hypoglycemia | S4 | P2 | Command acknowledgment / idempotency needed at the decide→deliver interface |

## Cross-cutting (spans stages)

| ID    | Hazard                              | Hazardous situation                                              | Harm                                  | Sev | Prob | Notes |
|-------|--------------------------------------|--------------------------------------------------------------------|-----------------------------------------|-----|------|-------|
| HAZ-010 | Loss of power / battery depletion mid-operation | No insulin delivery, no monitoring, no alarm if alarm is also unpowered | Hyperglycemia over time; missed hypoglycemia detection | S3/S4 | P3 | Resolved by PEMS architecture Option A (independent power domain for safety controller) — see [[../../IEC-60601-1-4/pems_architecture/00-pems-architecture.md]]; not yet built/verified |
| HAZ-011 | Software update / config change introduces regression | Any of the above, freshly | Varies | Varies | This is a IEC 62304 config-management + revalidation concern, not just initial design |
| HAZ-012 | Main controller ↔ safety controller interface fails (message corrupted, dropped, or spoofed) | Safety controller either blocks a legitimate dose (fail-safe, less severe) or fails to catch a bad one (fail-unsafe, severe) | Depends on failure direction: fail-safe → delayed/missed dose (S3); fail-unsafe → same as HAZ-004/007/009 (S4/S5) | P2 | New hazard, introduced by choosing PEMS architecture Option A — didn't exist when the safety controller didn't exist. Interface should be designed so failure defaults fail-safe (e.g. safety controller blocks dose on any communication anomaly, never blindly passes it through) |

## Reading this against the classification question

For IEC 62304 §4.3: **does software contribute to a hazardous situation,
and how severe is the resulting harm if it does?** Looking at the table —
HAZ-004, HAZ-005, HAZ-006 (decide-stage) and the software-adjacent parts
of HAZ-001/002/003 (monitor-stage interpretation logic) all show software
directly in the causal chain, at S4/S5. That's a strong signal this
project is **not** going to land at Class A. The B-vs-C question was
resolved architecturally by choosing PEMS Option A (independent safety
controller) — see
[[../../IEC-60601-1-4/pems_architecture/00-pems-architecture.md]] — but
classification credit doesn't apply until that controller is actually
built and verified; see
[[../../IEC-62304/planning/01-software-safety-classification.md]] for
the current-state-vs-eventual-state breakdown.

## Open questions

- Severity ranges given as "S4/S5" (and HAZ-012's split by failure
  direction) need to be pinned to one worst-case value once specific
  scenarios are designed out.
- HAZ-012's fail-safe design intent (block on any comms anomaly) needs
  to become a real requirement once the safety controller's interface is
  designed — not yet in `python/data/requirements.yaml`.
- FMEA-008 (pump occlusion/under-delivery) has no risk control identified
  at all in the FMEA worksheet, independent of the Option A/B decision —
  flagged there as needing its own design attention.
- This list has not been checked for completeness against a systematic
  method beyond the one FMEA pass already done — expect it to keep
  growing as design gets concrete (HAZ-012 itself is an example: it
  didn't exist until an architecture decision created it).