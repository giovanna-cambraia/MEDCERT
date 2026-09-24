# Essential Performance — IEC 60601-1

> **Status: initial definition.** Built from
> [[../../ISO-14971/hazard_analysis/00-hazard-analysis.md]] and
> [[../../IEC-62304/planning/01-software-safety-classification.md]].

## Definition (recap)

IEC 60601-1 defines essential performance as performance necessary to
achieve freedom from unacceptable risk — i.e. the performance whose
loss or degradation would directly produce one of the hazardous
situations already identified, not "performance the device is supposed
to have" in general. The test for whether something belongs on this
list: **if this function silently failed or drifted, would that alone
create an unacceptable (ALARP-or-worse) risk per the RMP's
matrix?** If yes, it's essential performance; if a failure would just be
inconvenient or is already caught by another control, it isn't.

## Essential performance items

| ID | Function | What must hold | Loss/degradation maps to | Class-C? |
|----|----------|------------------|-----------------------------|----------|
| EP-001 | Glucose measurement accuracy | Reported glucose value stays within a defined error bound of true blood glucose across the specified range | HAZ-001, HAZ-003 (false reading → wrong dose) | Yes |
| EP-002 | Glucose signal continuity / dropout detection | Loss of sensor signal is detected and flagged within a bounded time, not silently treated as a valid reading | HAZ-002 | Yes |
| EP-003 | Dosing computation correctness | Computed dose stays within the bounds the control algorithm's own model justifies for the current glucose state and trend | HAZ-004, HAZ-005 | Yes |
| EP-004 | Dosing computation integrity | Algorithm state (glucose history, trend, prior doses) is not corrupted between computation cycles | HAZ-006 | Yes |
| EP-005 | Delivered dose accuracy | Pump delivers the commanded dose within a defined tolerance — no meaningful over- or under-delivery | HAZ-007, HAZ-008 | Yes |
| EP-006 | Command freshness / no duplicate delivery | Pump does not act on a stale or duplicate dosing command | HAZ-009 | Yes |
| EP-007 | Alarm availability under power loss | Hypo/hyperglycemia and system-fault alarms remain functional independent of main system power state | HAZ-010 | Depends on whether alarm path is its own item (see classification doc) |
| EP-008 | Max dose rate limiting | Insulin delivered per unit time never exceeds an absolute, independently-enforced ceiling | HAZ-007, HAZ-009 | This *is* the hardware-independent-limiter question from the classification doc — if built in hardware, its correctness is still essential performance even though the enforcing item isn't a Class C *software* item |

## Notes

- EP-001 through EP-006 line up one-to-one with the Class C software
  items from the classification doc — that's expected, since essential
  performance and "what forced the Class C call" are looking at the same
  underlying hazards from two different standards.
- EP-008 is written now specifically to *not* prejudge the
  hardware-vs-software question still open in the classification doc —
  essential performance is about the *requirement* (a ceiling exists and
  holds), independent of which layer enforces it.
- Numeric tolerances (accuracy bounds, dropout detection time, max dose
  rate) are deliberately left unfilled — those depend on real CGM/pump
  component specs this project doesn't have yet. Filling them in is
  design work, not documentation work; do it once specific
  hardware/algorithm choices are made, not before.

## What this feeds

Each EP-xxx item above should become one or more entries in
`python/data/requirements.yaml` once real requirement text is written —
essential performance items are exactly the kind of thing IEC 62304's
SRS (`docs/certifications/IEC-62304/requirements/`) needs to state as
testable requirements, and IEC 60601-1's `test_reports/` folder is where
their verification evidence eventually lives.

## Open questions

- Numeric tolerances for EP-001, EP-002, EP-005, EP-006, EP-008 (needs
  real component specs).
- Whether the alarm path (EP-007) is architected as its own independent
  item — same open question as the hardware limiter, and arguably the
  same piece of hardware could serve both purposes (an independent
  safety controller enforcing both max-dose and alarm-on-fault).