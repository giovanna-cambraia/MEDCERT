# Risk Management Plan (RMP) — ISO 14971

> **Status: draft, scoped to the placeholder device** ([[00-intended-use.md]]).
> Scales and acceptability criteria below are illustrative starting points,
> not yet reviewed/approved — treat as "enough to unblock hazard analysis,"
> not as final.

## 1. Scope

Applies to the full device life cycle for the closed-loop insulin delivery
system described in `00-intended-use.md`: CGM sensor input, control
algorithm (dosing decision), and insulin infusion pump — hardware,
software (C device-side + Ada host-side reference models), and their
interfaces. Excludes the manufacturing process itself (production risk
management, if needed, is a separate plan).

## 2. Roles

Single-person project at this stage — Gi holds all RM roles (risk
management, review, approval). Formal role separation is a later
concern (relevant once IEC 62304 process rigor requires independent
review — see [[../../IEC-62304/00-overview.md]]).

## 3. Severity scale

| Level | Label        | Definition (harm to patient)                          |
|-------|--------------|---------------------------------------------------------|
| S1    | Negligible   | No injury, or inconvenience with no clinical impact      |
| S2    | Minor        | Temporary, self-resolving injury (e.g. transient hypo/hyperglycemia, no intervention needed) |
| S3    | Serious      | Injury requiring intervention (e.g. severe hypoglycemia requiring assistance/glucagon) |
| S4    | Critical     | Life-threatening injury (e.g. diabetic ketoacidosis, severe hypoglycemia with loss of consciousness) |
| S5    | Catastrophic | Death                                                    |

## 4. Probability scale

| Level | Label          | Qualitative definition (per patient per year of use) |
|-------|----------------|--------------------------------------------------------|
| P1    | Improbable     | Not expected to occur                                   |
| P2    | Remote         | Unlikely but possible                                   |
| P3    | Occasional     | Could occur a few times                                 |
| P4    | Probable       | Likely to occur repeatedly                              |
| P5    | Frequent       | Expected to occur regularly                             |

Quantitative bands (e.g. events per patient-year) are TBD — need either
epidemiological/field data or a defensible engineering estimate per
failure mode before these can be more than ordinal.

## 5. Risk acceptability matrix

Severity (rows) × Probability (columns). `A` = acceptable as-is,
`ALARP` = acceptable only if reduced As Low As Reasonably Practicable
and justified, `U` = unacceptable, must reduce.

|          | P1 | P2 | P3 | P4 | P5 |
|----------|----|----|----|----|----|
| **S5**   | ALARP | U | U | U | U |
| **S4**   | ALARP | ALARP | U | U | U |
| **S3**   | A | ALARP | ALARP | U | U |
| **S2**   | A | A | ALARP | ALARP | U |
| **S1**   | A | A | A | ALARP | ALARP |

This matrix is what `severity` × `probability` in `python/data/fmea.yaml`
will be evaluated against once populated — `residual_risk` should record
the resulting A/ALARP/U verdict per row after risk controls are applied.

## 6. Risk control approach

Per ISO 14971 §7, controls are applied in this priority order:
1. Inherent safety by design
2. Protective measures (in the device or manufacturing process)
3. Information for safety (labeling, alarms, training)

Where a control is a software function, it becomes an IEC 62304
requirement (traced via `python/data/requirements.yaml`) and its
criticality feeds back into the software safety classification.

## 7. Overall residual risk evaluation

Deferred until the hazard analysis + FMEA pass has enough rows to
evaluate — see next step.

## Open questions

- Quantitative probability bands (needs data or engineering estimate).
- Whether S3/P2 should be `A` or `ALARP` — borderline judgment call,
  revisit once real hazards are scored against it.
- Independent review process, once this stops being solo work.