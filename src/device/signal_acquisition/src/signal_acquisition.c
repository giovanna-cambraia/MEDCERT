#include "signal_acquisition.h"

#ifndef SA_DROPOUT_TIMEOUT 
#error "SA_DROPOUT_TIMEOUT must be defined at build time (TBD, see REQ-SA-001)"
#endif
#ifndef SA_PLAUSIBLE_MIN
#error "SA_PLAUSIBLE_MIN must be defined at build time (TBD, see REQ-SA-002)"
#endif
#ifndef SA_PLAUSIBLE_MAX
#error "SA_PLAUSIBLE_MAX must be defined at build time (TBD, see REQ-SA-002)"
#endif
#ifndef SA_MAX_DELTA_PER_TICK
#error "SA_MAX_DELTA_PER_TICK must be defined at build time (TBD, see REQ-SA-003)"
#endif

static uint64_t sa_elapsed(const sa_state_t *state, sa_tick_count_t now)
{
    // caller guarantees now >= state->last_tick when has_previous, same condition the Ada Elapsed function carries
    return (uint64_t)now - (uint64_t)state->last_tick;
}


static uint64_t sa_allowed_delta(uint64_t elapsed_ticks)
{
    return (uint64_t)SA_MAX_DELTA_PER_TICK * elapsed_ticks;
}

static uint64_t sa_abs_diff(sa_glucose_units_t a, sa_glucose_units_t b)
{
    return (a >= b) ? ((uint64_t)a - (uint64_t)b) : ((uint64_t)b - (uint64_t)a);
}

bool sa_signal_lost(const sa_state_t *state, sa_tick_count_t now)
{
    if (!state->has_previous) {
        return true;
    }
    return sa_elapsed(state, now) > (uint64_t)SA_DROPOUT_TIMEOUT;
}

sa_reading_status_t sa_classify(const sa_state_t *state,
                                 sa_glucose_units_t reading,
                                 sa_tick_count_t now)
{
    if (reading < SA_PLAUSIBLE_MIN || reading > SA_PLAUSIBLE_MAX) {
        return SA_READING_OUT_OF_RANGE;
    }
    if (state->has_previous
        && sa_elapsed(state, now) <= (uint64_t)SA_DROPOUT_TIMEOUT
        && sa_abs_diff(reading, state->last_value)
               > sa_allowed_delta(sa_elapsed(state, now))) {
        return SA_READING_IMPLAUSIBLE_RATE;
    }
    return SA_READING_VALID;
}

sa_output_t sa_process(const sa_state_t *state,
                        sa_glucose_units_t reading,
                        sa_tick_count_t now)
{
    sa_output_t out;
    if (sa_classify(state, reading, now) == SA_READING_VALID) {
        out.present = true;
        out.value = reading;
    } else {
        out.present = false;
        out.value = 0;
    }
    return out;
}