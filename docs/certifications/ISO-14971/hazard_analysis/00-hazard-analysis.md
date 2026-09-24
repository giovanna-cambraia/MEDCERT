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
| HAZ-010 | Loss of power / battery depletion mid-operation | No insulin delivery, no monitoring, no alarm if alarm is also unpowered | Hyperglycemia over time; missed hypoglycemia detection | S3/S4 | P3 | Alarm power path must be independent or battery-backed |
| HAZ-011 | Software update / config change introduces regression | Any of the above, freshly | Varies | Varies | This is a IEC 62304 config-management + revalidation concern, not just initial design |

## Reading this against the classification question

For IEC 62304 §4.3: **does software contribute to a hazardous situation,
and how severe is the resulting harm if it does?** Looking at the table —
HAZ-004, HAZ-005, HAZ-006 (decide-stage) and the software-adjacent parts
of HAZ-001/002/003 (monitor-stage interpretation logic) all show software
directly in the causal chain, at S4/S5. That's a strong signal this
project is **not** going to land at Class A. Whether it's B or C depends
on whether a non-software risk control exists that independently prevents
the S4/S5 outcome (e.g. a hardware max-dose limiter on the pump
independent of software, which would pull HAZ-007/HAZ-009 down). That's
the next real decision point, but it's for the classification doc, not
this one.

## Open questions

- Severity ranges given as "S4/S5" need to be pinned to one value once
  a specific worst-case scenario is chosen per hazard.
- Whether a hardware-independent max-dose limiter exists is unknown —
  this single design decision swings the classification call.
- This list has not been checked for completeness against a systematic
  method (e.g. FMEA per component, fault tree) — it's a first pass by
  inspection. The FMEA worksheet (next artifact) is where that
  systematic pass happens.