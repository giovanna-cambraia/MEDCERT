# Safety Requirements — IEC 60601-1

> **Status: derived requirements, pre-numeric.** These turn
> [[../essential_performance/00-essential-performance.md]] items and the
> risk controls implied by
> [[../../ISO-14971/hazard_analysis/00-hazard-analysis.md]] into
> requirement-shaped statements. Each one is a candidate for
> `python/data/requirements.yaml` once ready to formalize — written here
> first so the *shape* of the requirement gets reviewed before it's
> locked into the traceability tool.

Numbering follows `SR-0xx`, distinct from `EP-xxx` (essential
performance defines *what must hold*; a safety requirement defines *what
the device must do* to make that hold — sometimes 1:1, sometimes a
safety requirement covers part of an EP item or spans several).

## Signal acquisition / monitor

- **SR-001** — The device shall detect loss of CGM signal within
  [dropout detection time — TBD] and transition to a defined safe state
  rather than dosing on a stale reading. (← EP-002, HAZ-002)
- **SR-002** — The device shall reject or flag glucose readings outside
  a physiologically plausible range rather than acting on them as valid.
  (← EP-001, HAZ-001, HAZ-003)

## Dosing algorithm / decide

- **SR-003** — The dosing algorithm shall compute a dose only from the
  current validated glucose reading and a bounded recent history; it
  shall not dose on data older than [staleness bound — TBD]. (← EP-003,
  EP-004, HAZ-004, HAZ-006)
- **SR-004** — The dosing algorithm shall include a self-check (e.g.
  plausibility bound on its own output, or state-integrity check) before
  emitting a dose command, and shall fail to a no-dose / alarm state
  rather than emit an unchecked value. (← EP-004, HAZ-006)
- **SR-005** — The dosing algorithm shall re-evaluate its computed dose
  against the most recent glucose trend at a bounded cycle time [cycle
  time — TBD] so that a rapidly changing glucose level is corrected
  within a bounded delay. (← EP-003, HAZ-005)

## Delivery / pump

- **SR-006** — Insulin delivered per unit time shall never exceed
  [max dose rate — TBD], enforced independent of whether the dosing
  algorithm's output is correct. (← EP-008, HAZ-007, HAZ-009 — this is
  the requirement Option A/B in the PEMS architecture doc exists to
  satisfy)
- **SR-007** — The pump shall not act on a dose command older than
  [command freshness bound — TBD] or on a command it has already
  executed (no duplicate delivery from a single decision). (← EP-006,
  HAZ-009)
- **SR-008** — Delivered dose shall be within [delivery tolerance — TBD]
  of the commanded dose across the specified operating conditions.
  (← EP-005, HAZ-007, HAZ-008)

## Alarms / power

- **SR-009** — Hypoglycemia, hyperglycemia, and system-fault alarms
  shall remain functional for at least [minimum duration — TBD] after
  loss of main system power. (← EP-007, HAZ-010)
- **SR-010** — Loss of main power shall itself trigger an alarm
  (distinct from the physiological alarms), not just silently stop
  dosing/monitoring. (← HAZ-010)

## Change control

- **SR-011** — A software or configuration change shall not be deployed
  without re-running the verification evidence covering every SR-xxx
  item it could plausibly affect. (← HAZ-011 — this one is a process
  requirement, not a device-behavior requirement; it belongs equally to
  `docs/certifications/IEC-62304/config_management/`, cross-referenced
  here rather than duplicated)

## Notes on the TBD values

Every bracketed `[... — TBD]` above needs a real number before this
requirement is testable, and every one of those numbers is a design
decision that depends on the CGM/pump/MCU components chosen — same
dependency called out in the essential performance doc. Writing SR-xxx
now, with the numbers open, is useful anyway: it pins down *what kind*
of number is needed (a time bound, a rate, a tolerance) so hardware
selection can be evaluated against a known requirement shape rather than
picked first and rationalized after.

## What happens next

Once numeric values exist, each SR-xxx becomes one entry in
`python/data/requirements.yaml`, with `standard: IEC-60601-1`,
`module:` pointing at whichever `src/device/<module>` or
`ada/src/<module>` it lands on once modules are named for real, and
`status: draft`.

## Open questions

- All bracketed TBD values (dropout time, staleness bound, cycle time,
  max dose rate, command freshness bound, delivery tolerance, alarm
  minimum duration) — blocked on component selection, same as prior
  docs.
- Whether SR-011 needs its own ID space shared with the config
  management doc once that's written, or stays a cross-reference as
  drafted here.