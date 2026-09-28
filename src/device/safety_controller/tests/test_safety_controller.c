#include <stdio.h>
#include <stdint.h>
#include "safety_controller.h"

// same as cases the Ada oracle proves (verify_oracle.adb), plus C-only cases the Ada type range made unrepresentable: values outside the dose ramge
// and corrupted enum values arriving from a bad message

static int failures = 0;

#define CHECK(cond)                                                  \
    do {                                                             \
        if (!(cond)) {                                               \
            printf("FAIL line %d: %s\n", __LINE__, #cond);           \
            failures++;                                              \
        }                                                            \
    } while (0)

int main(void)
{
    // REQ-SC-001: clamp
    CHECK(sc_clamp_dose(0u) == 0u);
    CHECK(sc_clamp_dose(50u) == 50u);
    CHECK(sc_clamp_dose(SC_MAX_DOSE_PER_CYCLE) == SC_MAX_DOSE_PER_CYCLE);
    CHECK(sc_clamp_dose(SC_MAX_DOSE_PER_CYCLE + 1u) == SC_MAX_DOSE_PER_CYCLE);
    CHECK(sc_clamp_dose(SC_DOSE_UNITS_MAX) == SC_MAX_DOSE_PER_CYCLE);
    CHECK(sc_clamp_dose(UINT32_MAX) == SC_MAX_DOSE_PER_CYCLE);
    CHECK(sc_clamp_dose(UINT32_MAX) <= SC_MAX_DOSE_PER_CYCLE);

    // REQ-SC-002: only VALID passes
    CHECK(sc_accept_command(SC_CMD_VALID) == true);
    CHECK(sc_accept_command(SC_CMD_MALFORMED) == false);
    CHECK(sc_accept_command(SC_CMD_STALE) == false);
    CHECK(sc_accept_command(SC_CMD_UNRECOGNIZED) == false);
    CHECK(sc_accept_command((sc_command_status_t)99) == false);

    if (failures == 0) {
        printf("all safety_controller tests passed\n");
        return 0;
    }
    printf("%d failures(s)\n", failures);
    return 1;
}