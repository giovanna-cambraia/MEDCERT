# Intended Use — PLACEHOLDER DEVICE

> **Status: placeholder.** This describes a stand-in device concept chosen
> to give the process something concrete to run against while the real
> device is undefined. Swap this file's content for the real device when
> known; nothing else in the project structure needs to change to do that
> — module names, hazard IDs, and requirement IDs will need updating, but
> the folder layout stays as-is.

## Device concept

A closed-loop insulin delivery system: continuous glucose monitoring (CGM)
feeding a control algorithm that computes insulin dosing, driving an
insulin infusion pump. Three functional stages:

1. **Monitor** — subcutaneous glucose level via CGM sensor input.
2. **Decide** — control algorithm computes an insulin dosing
   recommendation from the glucose signal (current level + trend).
3. **Deliver** — insulin infusion pump administers the computed dose.

## Intended use (draft)

To provide automated, continuous regulation of blood glucose in patients
with diabetes mellitus requiring insulin therapy, by monitoring
subcutaneous glucose levels and delivering insulin doses computed by an
onboard control algorithm, reducing the need for manual dosing decisions.

## Indications for use (draft)

For use by patients diagnosed with insulin-dependent diabetes mellitus,
under the direction of a healthcare provider, for continuous closed-loop
management of blood glucose levels.

## Intended patient population (draft)

Adults with insulin-dependent diabetes mellitus. (Pediatric use,
age floor, and any exclusion criteria — e.g. pregnancy, renal impairment,
hypoglycemia unawareness — are open questions; narrowing this affects the
hazard list, since patient population drives severity/probability
judgments in the FMEA.)

## Open questions this raises for later steps

- Exact CGM sensor technology / interface (affects PEMS architecture,
  IEC 60601-1-4).
- Delivery mechanism specifics — pump type, max dose/rate limits (affects
  essential performance definition, IEC 60601-1).
- Algorithm scope — full closed-loop (fully automated dosing) vs.
  hybrid closed-loop (patient confirms/adjusts) — this materially changes
  the hazard list and likely the IEC 62304 software class, since a fully
  automated loop removes a human check between a software error and
  patient harm.
- Patient population boundaries (see above).

None of these need answers before the next step (first hazard analysis
pass) starts — they can be resolved as specific hazards force the
question.