# PEMS Architecture — IEC 60601-1-4

> **Status: initial architecture, options not yet decided.** Purpose here
> is to draw out the hardware/software partitioning question concretely
> — including the still-open max-dose-limiter placement — not to settle
> it. See [[../../IEC-62304/planning/01-software-safety-classification.md]]
> and [[../essential_performance/00-essential-performance.md]] for what's
> driving these boxes.

## Block diagram

```mermaid
flowchart LR
    subgraph Monitor
        CGM[CGM Sensor]
    end

    subgraph Decide["Decide (main controller)"]
        ACQ[Signal acquisition /\ndropout detection]
        ALGO[Dosing algorithm]
        ACQ --> ALGO
    end

    subgraph Deliver
        PUMP[Pump actuator]
    end

    subgraph Safety["Independent safety layer (placement TBD)"]
        LIMIT[Max-dose limiter]
        ALARM[Alarm / power-independent]
    end

    CGM -->|glucose signal| ACQ
    ALGO -->|dose command| LIMIT
    LIMIT -->|clamped command| PUMP
    ALGO -.->|fault signal| ALARM
    LIMIT -.->|fault signal| ALARM
```

The `Safety` subgraph is drawn separately from `Decide` on purpose: this
is the box that the classification doc's open question is about. Whether
it's real, independent hardware or just another software module inside
the same controller is exactly what determines whether the dosing
algorithm can be argued down from Class C.

## Two architecture options

### Option A — Independent safety controller (separate MCU)

`LIMIT` and `ALARM` run on a second, physically separate
microcontroller with its own power domain, sitting between `ALGO`'s
output and `PUMP`. It has no path back into `Decide` other than reading
the commanded dose and the fault lines.

- Pro: genuinely independent per IEC 60601-1-4's PEMS-partitioning
  intent — a bug in the dosing algorithm's code cannot touch this
  MCU's logic. This is what would justify reclassifying the dosing
  algorithm down from Class C in the classification doc.
- Pro: separate power domain directly satisfies HAZ-010 (alarm survives
  main power loss) without extra argument.
- Con: real hardware cost — a second MCU, its own firmware (which is
  itself now a Class C item, since it's now the thing standing between
  a software error and death), its own verification burden.
- Con: adds a physical interface (main controller → safety MCU) that is
  itself a new failure mode to analyze (HAZ-012, not yet written).

### Option B — Software module within the main controller

`LIMIT` and `ALARM` are software running on the same MCU as `ACQ`/`ALGO`,
just architecturally separated (different module, maybe different memory
region if the MCU supports partitioning/MPU).

- Pro: no extra hardware, faster to build a first version.
- Con: **does not** satisfy IEC 62304's independence bar — a
  memory-corruption bug (HAZ-006) in `ALGO` could in principle reach
  `LIMIT` on the same chip, so no classification credit. Dosing
  algorithm stays Class C regardless.
- Con: shared power domain means HAZ-010 (power loss = alarm loss)
  isn't solved by this option; needs a separate answer (e.g. small
  battery-backed buzzer circuit, which starts looking like a slice of
  Option A anyway).

## Where this leaves things

Option A is the one that actually changes the classification outcome;
Option B is faster but doesn't buy anything against the two hazards
that matter most (HAZ-007/009 dose limiting, HAZ-010 alarm power
independence). This isn't a doc-writing decision — it's a real hardware
BOM and firmware-scope decision, and it's the same "highest-leverage
open item" flagged in the classification doc, now drawn as boxes instead
of described in prose.

## Interfaces (preliminary, both options)

| Interface | Direction | Carries | Notes |
|-----------|-----------|---------|-------|
| CGM → Signal acquisition | in | raw glucose signal | protocol/format TBD (depends on chosen CGM part) |
| Signal acquisition → Dosing algorithm | internal | interpreted glucose value + trend | |
| Dosing algorithm → Limiter | out | commanded dose | this link's trust boundary is the whole point of the architecture question above |
| Limiter → Pump | out | clamped dose command | |
| Algorithm/Limiter → Alarm | out | fault signal | needs to be a simple, hard-to-corrupt signal (e.g. dedicated GPIO line, not a shared bus message) precisely because it has to work even when the sender is misbehaving |

## Open questions

- Option A vs B — the central open decision, same one flagged in the
  classification doc.
- HAZ-012 (new): failure of the main-controller ↔ safety-layer interface
  itself, if Option A is chosen — needs adding to the hazard analysis
  once this is decided.
- CGM and pump component selection (protocol/format for the two
  external interfaces).