# Software Maintenance Plan — IEC 62304 §6

> **Status: initial plan.** Covers the post-release lifecycle; since
> nothing has shipped yet, this is establishing the process now so it's
> not invented under pressure after the first real deployment.

## Scope

What happens after a version of the device software has been verified
and released, when a new problem, feedback item, or improvement request
comes in.

## Relationship to problem resolution and change control

Maintenance is not a separate process from
[[../problem_resolution/00-problem-resolution-process.md]] and
[[../config_management/00-scmp.md]] — it's those same processes, applied
to a *released* baseline instead of in-progress work. The distinction
that matters: a maintenance change requires re-evaluating risk
management (does this change affect any HAZ-xxx/FMEA-xxx row?), not just
re-running tests, because a released baseline is one real patients may
already depend on.

## Maintenance triggers

1. **Problem report** — anomaly found post-release (field report, or
   found during work on the next version). Enters via the problem
   resolution log.
2. **Component change** — a change forced externally, e.g. the CGM or
   pump hardware vendor revises a part (common in real closed-loop
   insulin systems — sensor/pump components get revised on their own
   schedule). Not a defect in this project's software, but still
   requires re-verification of anything that assumed the old component's
   behavior.
3. **Requirement change** — new clinical/regulatory requirement, or a
   design improvement (e.g. tightening SR-006's dose rate ceiling based
   on field data).

## Maintenance process

1. Trigger identified (one of the three above), logged same as any
   problem-resolution entry.
2. **Risk re-evaluation first** — before any code change, check whether
   this trigger affects `python/data/fmea.yaml`: does it introduce a new
   hazard (like HAZ-012 did), change a severity/probability estimate, or
   invalidate a `risk_controls` assumption. This step exists precisely
   because HAZ-011 (regression via config change) is already identified
   as a hazard — maintenance is where that hazard becomes concrete.
3. Change implemented via the normal SCMP change-control flow.
4. Verification re-run for every requirement the change or the updated
   risk analysis touches.
5. New baseline tagged; release notes reference which HAZ-xxx/SR-xxx
   entries were affected, not just what code changed.

## Field data feedback loop

Once real deployment exists, field problem reports should feed back
into `python/data/fmea.yaml`'s `probability` estimates (currently
ordinal placeholders per the RMP, pending real data — see
[[../../ISO-14971/risk_management_plan/01-risk-management-plan.md]] §4).
This is the mechanism that eventually replaces those placeholder P1-P5
judgment calls with real frequency data.

## Open questions

- No release has happened yet, so this plan is unexercised — expect
  revision once the first real maintenance cycle runs.
- End-of-life / decommissioning process isn't addressed here — not
  urgent pre-first-release, but IEC 62304 §6 technically expects it
  eventually.