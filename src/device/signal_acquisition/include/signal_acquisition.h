#ifndef SIGNAL_ACQUISITION_H
#define SIGNAL_ACQUISITION_H

// mirrors ada/src/signal_acquisition_ref/ -- that model is the oracle this C implementation is checked against 

// REQ-SA-001: signal loss detection
// REQ-SA-002: plausible range rejection 
// REQ-SA-003: rate of change rejection

#include <stdbool.h>
#include <stdint.h>

typedef uint32_t sa_glucose_units_t;
typedef uint64_t sa_tick_count_t;

typedef enum {
    SA_READING_VALID = 0,
    SA_READING_OUT_OF_RANGE,
    SA_READING_IMPLAUSIBLE_RATE
} sa_reading_status_t;

typedef struct {
    bool has_previous;
    sa_glucose_units_t last_value;
    sa_tick_count_t last_tick;
} sa_state_t;

typedef struct {
    bool present;
    sa_glucose_units_t value;
} sa_output_t;

// mirrors Ada Signal_Lost: true if there is no previous reading, or if `now` is further from the last reading SA_DROPOUT_TIMEOUT
bool sa_signal_lost(const sa_state_t *state, sa_tick_count_t now);

// mirrors Ada classify 
sa_reading_status_t sa_classify(const sa_state_t *state, sa_glucose_units_t reading, sa_tick_count_t now);

// mirrors Ada Process: the gate; only SA_READING_VALID ever yields present == true
sa_output_t sa_process(const sa_state_t *state, sa_glucose_units_t reading, sa_tick_count_t now);

#endif