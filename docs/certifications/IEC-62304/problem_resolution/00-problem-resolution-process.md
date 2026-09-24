# Problem Resolution Process — IEC 62304 §9

> **Status: initial process.** Mandatory given the current Class C
> default (see
> [[../planning/01-software-safety-classification.md]]) — this isn't
> optional documentation, it's a required process even before the
> Class B/C split resolves per-item.

## Scope

Covers any anomaly found in: device C code (`src/device/`), Ada
host-side code (`ada/`), and — because a wrong FMEA/requirement entry
is itself a process defect — the data files
(`python/data/requirements.yaml`, `python/data/fmea.yaml`) and the docs
tree, when the defect is in the *analysis* rather than the code.

## Problem log

A single append-only log, `docs/certifications/IEC-62304/problem_resolution/log.yaml`,
records every problem found from first test onward. Not created yet —
deliberately deferred until the first real problem needs logging (see
"Open questions"), but the process below assumes it exists from that
point forward, i.e. before testing starts producing anomalies to log,
not added retroactively after some accumulate untracked.

## Process

1. **Detect** — anomaly found via test failure, review, SPARK proof
   failure, code review, or a hazard/FMEA row revealing a gap (like
   FMEA-008's currently-unaddressed occlusion detection).
2. **Log** — new entry in `log.yaml`: id, description, where found,
   severity of the *problem* (is this itself safety-relevant, i.e. does
   it correspond to one of the HAZ-xxx/FMEA-xxx entries, or is it a
   lower-stakes defect like a build warning).
3. **Assess** — does this problem indicate a gap in the risk analysis
   itself (new hazard, like HAZ-012 was)? If so, it feeds back into
   `python/data/fmea.yaml` before being closed here, not instead of
   being logged here.
4. **Resolve** — fix implemented, traced to the requirement(s) it
   affects in `requirements.yaml`.
5. **Verify** — re-run affected verification evidence (same step as
   SCMP's change-control step 4 — problem resolution and change control
   share this step rather than duplicating it).
6. **Close** — entry marked resolved with a reference to the fix
   (commit/branch) and the verification evidence that confirms it.

## Severity triage (problems, not hazards)

Reuses the RMP's severity scale (S1-S5) for consistency, but this is
asking a different question: not "how bad is the harm," but "how bad
is *this specific problem* given what it touches." A build warning in
`example_module` is not S-anything meaningful; a defect found in code
implementing SR-006 (max-dose limiter) is treated as safety-relevant
regardless of whether it manifested yet, because of what it protects
against.

| Problem severity | Meaning | Response time expectation |
|-------------------|---------|------------------------------|
| Safety-relevant | Touches a Class C item or an SR-xxx/HAZ-xxx-linked requirement | Blocks merge/baseline until resolved |
| Functional | Affects behavior but not a safety requirement | Logged, scheduled, doesn't block baseline |
| Cosmetic/process | Docs, build warnings, non-functional | Logged, low priority |

## Relationship to config management

Problem resolution and change control (SCMP) intentionally share step
5/4 (re-verify affected evidence) rather than each defining their own —
a problem fix *is* a change, so it goes through the same gate.

## Open questions

- `log.yaml`'s schema isn't written yet — deliberately deferred until
  the first real problem needs logging, so the schema is shaped by an
  actual case rather than guessed in the abstract.
- Whether safety-relevant problems need any escalation beyond "blocks
  merge" once this stops being solo work (same team-size trigger noted
  in the RMP and SCMP).