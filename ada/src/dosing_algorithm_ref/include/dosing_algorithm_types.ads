package Dosing_Algorithm_Types is
   pragma Pure;

   -- abstract units, same reasoning as the other two modules: real scale is TBD, proofs don't depend on it
   type Glucose_Units   is range 0 .. 100_000;
   type Dose_Output     is range 0 .. 1_000_000;
   type Tick_Count      is range 0 .. 1_000_000_000;

end Dosing_Algorithm_Types;