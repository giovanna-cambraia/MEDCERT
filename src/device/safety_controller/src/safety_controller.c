#include "safety_controller.h"

// the real dose is still TBD (blocked on pump/dose-model selection); it must be supplied at build time, never defaulted here
#ifndef SC_MAX_DOSE_PER_CYCLE
#error "SC_MAX_DOSE_PER_CYCLE must be defined at build time (real value is TBD, see REQ-SC-001)"
#endif

#if SC_MAX_DOSE_PER_CYCLE > SC_DOSE_UNITS_MAX
#error "SC_MAX_DOSE_PER_CYCLE exceeds SC_DOSE_UNITS_MAX"
#endif

sc_dose_units_t sc_clamp_dose(sc_dose_units_t requested)
{
    if (requested <= SC_MAX_DOSE_PER_CYCLE) {
        return requested;
    }
    return SC_MAX_DOSE_PER_CYCLE;
}

bool sc_accept_command(sc_command_status_t status)
{
    // compare against the one accepted value, not a list of rejected ones: any unknown or corrupted value falls to reject
    // (REQ-SC-002, fail-safe direction from HAZ-012)
    return status == SC_CMD_VALID;
}