# Software Configuration Management Plan (SCMP) — IEC 62304 §8

> **Status: initial plan.** Solo-developer scope for now (see
> [[../../ISO-14971/risk_management_plan/01-risk-management-plan.md]]
> §2 on roles) — process is real but lighter than a multi-person team's
> would be. Directly implements SR-011
> ([[../../IEC-60601-1/safety_requirements/00-safety-requirements.md]])
> and addresses HAZ-011
> ([[../../ISO-14971/hazard_analysis/00-hazard-analysis.md]]).

## Scope

Covers all configuration items: source code (`src/device/`, `ada/`),
build/orchestration scripts (`tools/scripts/`), the FMEA/traceability
data (`python/data/*.yaml`), and this documentation tree itself
(`docs/`). All of it is under version control as a single repository —
no separate versioning scheme per subtree.

## Repository structure as configuration baseline

The project's own layout (device C, isolated Ada crate, Python tooling,
docs) is itself the configuration item boundary:

- `src/device/<module>/` — one module = one independently buildable/
  testable configuration item (own `.gpr`)
- `ada/src/<module>/` — same, but within the isolated Alire crate;
  never cross-referenced from `src/device/` (see `ada/alire.toml`)
- `python/` — versioned alongside, but changes here don't require
  re-verifying device code (it's tooling, not a deployed item)
- `docs/certifications/` — versioned in lock-step with the code changes
  that justify them; a code change without a corresponding doc update is
  incomplete, not "docs to follow later"

## Branching / baseline model

- `main` is always in a releasable state for whatever has been verified
  so far — not "always shippable to a patient," since this project is
  pre-verification, but always buildable and internally consistent.
- Feature work happens on short-lived branches per module or per
  requirement (e.g. one branch per SR-xxx being implemented), merged to
  `main` only once that requirement's verification evidence
  (traceability row + test result) exists.
- A **baseline** is tagged whenever a set of requirements reaches
  "verified" status together — e.g. `baseline/rmp-v1` once the current
  risk management plan's controls are all implemented and tested. Tags,
  not branches, since baselines are snapshots, not ongoing work.

## Change control process

1. Change is proposed (new requirement, fix, or design change) —
   recorded first in `python/data/requirements.yaml` (new/updated row)
   or `python/data/fmea.yaml` (if it changes risk analysis).
2. Impact is assessed: which SR-xxx / EP-xxx / HAZ-xxx entries does this
   touch? (This is what SR-011 requires before deploy — the same check
   applies during development, not just at release.)
3. Change is implemented on its branch.
4. Verification evidence for every touched requirement is (re-)run
   before merge — per SR-011, a change is not complete until this step,
   even mid-development.
5. Merge to `main`. Tag a new baseline if this completes a meaningful
   set of requirements.

## What's explicitly deferred

- Formal change-request forms / approval workflow — overkill for a
  solo project; revisit if/when this becomes a team effort (same
  trigger as the roles note in the RMP).
- Automated CI enforcement of step 4 above — currently a discipline,
  not a gate. Worth automating once `tools/scripts/test.sh` has real
  tests to run.

## Open questions

- Whether `ada/`'s Alire-managed versioning (its own `alire.toml`
  version field) needs its own baseline tagging independent of the
  outer repo's tags, given the crate is meant to build in isolation.
- SOUP inventory process (any third-party code/libraries) isn't
  addressed here yet — likely belongs here once a first dependency is
  actually pulled in, rather than speculatively now.