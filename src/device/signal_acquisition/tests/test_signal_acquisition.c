#include <stdio.h>
#include "signal_acquisition.h"

static int failures = 0;

#define CHECK(cond)                                                  \
    do {                                                             \
        if (!(cond)) {                                               \
            printf("FAIL line %d: %s\n", __LINE__, #cond);           \
            failures++;                                              \
        }                                                            \
    } while (0)

int main (void)
{
    sa_state_t no_prev = { .has_previous = false, .last_value = 0, .last_tick = 0 };
    sa_state_t s = { .has_previous = true, .last_value = 100, .last_tick = 10 };

    // REQ-SA-001: signal loss
    CHECK(sa_signal_lost(&no_prev, 0) == true);
    CHECK(sa_signal_lost(&s, 50) == false); // elapsed 40 <= timeout 100
    CHECK(sa_signal_lost(&s, 500) == true); // elapsed 490 > timeout 100
    CHECK(sa_signal_lost(&s, 10) == false); // elapsed 0

    // REQ-SA-002: plausible range 
    CHECK(sa_classify(&no_prev, 19, 0) == SA_READING_OUT_OF_RANGE);
    CHECK(sa_classify(&no_prev, 501, 0) == SA_READING_OUT_OF_RANGE);
    CHECK(sa_classify(&no_prev, 20, 0) == SA_READING_VALID);
    CHECK(sa_classify(&no_prev, 500, 0) == SA_READING_VALID);

    // REQ-SA-003: rate of change (elapsed 1 tick, allowed delta = 2)
    CHECK(sa_classify(&s, 101, 11) == SA_READING_VALID); // delta 1
    CHECK(sa_classify(&s, 103, 11) == SA_READING_IMPLAUSIBLE_RATE); // delta 3
    CHECK(sa_classify(&s, 97, 11) == SA_READING_IMPLAUSIBLE_RATE); // delta 3, falling

    // out of range wins over rate: reading 600 is out of range even through the state comparison below would also flag it as a jump 
    CHECK(sa_classify(&s, 600, 11) == SA_READING_OUT_OF_RANGE);

    // rate check does not apply past a dropout: elapsed 200 > timeout 100
    {
        sa_output_t out = sa_process(&s, 300, 210);
        CHECK(out.present == true);
        CHECK(out.value == 100);
    } 

    // the gate: only valid ever yields present == true
    {
        sa_output_t out = sa_process(&s, 300, 210);
        CHECK(out.present == true);
        CHECK(out.value == 300);
    }

    // the gate: only valid ever yields present = true
    {
        sa_output_t out = sa_process(&s, 103, 11); // implausible rate
        CHECK(out.present == false);
    }

    if (failures == 0) {
        printf("all signal_acquisition tests passed\n");
        return 0;
    }
    printf("%d failures(s)\n", failures);
    return 1;
}