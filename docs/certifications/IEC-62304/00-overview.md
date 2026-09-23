# IEC 62304 — Medical Device Software Lifecycle

Software safety classification (A/B/C) for this project is TBD once the
first hazard analysis pass (ISO 14971) identifies whether software
contributes to a hazardous situation and the severity of resulting harm.
Classification drives which of these folders are mandatory:

- planning/            — Software Development Plan, SCMP, SQAP references
- requirements/         — Software Requirements Specification (SRS)
- design/               — Software Architecture + Detailed Design (SDD)
- verification/         — unit/integration/system test plans, results, coverage
- config_management/    — SCM plan, baselines, release records
- problem_resolution/   — anomaly/defect tracking (Class B/C mandatory)
- maintenance/          — Software Maintenance Plan

Cross-reference: [[../ISO-14971/00-overview.md]] for the risk analysis that
determines the class, and [[../IEC-60601-1-4/00-overview.md]] for how this
software fits into the overall PEMS architecture.
