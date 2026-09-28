#ifndef SAFETY_CONTROLLER_H
#define SAFETY_CONTROLLER_H

// independent safety cotnroller (max-dose limiter + fail-safe command handling), per PEMS architecture option A
// see docs/certifications/IEC-60601-1-4/pems_architecture/00-pems-architecture.md

// mirrors the SPARK reference model in ada/src/safety_controller_ref -- that model is the oracle 
// this C implementation is checked against 

// REQ-SC-001: clamp any requested dose to the ceiling 
// REQ-SC-002: reject (never pass through) anything but a valid command

#include <stdbool.h>
#include <stdint.h>

// mirrors Ada Dose_Units (0 .. 1_000_000); abstract unit, real clinical scale is TBD (REQ-SC-001)
typedef uint32_t sc_dose_units_t;
#define SC_DOSE_UNITS_MAX 1000000u

// mirrors Ada Command_Status 
typedef enum {
    SC_CMD_VALID = 0,
    SC_CMD_MALFORMED,
    SC_CMD_STALE,
    SC_CMD_UNRECOGNIZED 
} sc_command_status_t;

// returns min(requested, SC_MAX_DOSE_PER_CYCLE
sc_dose_units_t sc_clamp_dose(sc_dose_units_t requested);

// returns true only for SC_CMD_VALID; any other value, including an out-of-range enum value from a corrupted message, is rejected 
bool sc_accept_command(sc_command_status_t status);

#endif