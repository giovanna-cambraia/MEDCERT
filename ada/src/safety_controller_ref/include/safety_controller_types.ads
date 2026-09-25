package Safety_Controller_Types is
   pragma Pure;

   -- abstract dose unit, deliberately not tied to a real clinical unit (e.g. "milliunits of insulin") yet, since the actual scale
   -- depends on pump component selection (see REQ-SC-001, still TBD); keeping it abstract lets the clamp logic be proved correct
   -- now and re-scaled later without touching the proof
   type Dose_Units is range 0 .. 1_000_000;

   -- REQ-SC-002: only a Valid command may result in a dose forwarded; every other status is a rejection, not a degraded pass-through 
   -- this is the fail-safe direction named in HAZ-012 / FMEA-012
   type Command_Status is (Valid, Malformed, Stale, Unrecognized);

end Safety_Controller_Types;