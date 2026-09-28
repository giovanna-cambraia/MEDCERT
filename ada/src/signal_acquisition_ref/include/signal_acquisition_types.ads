package Signal_Acquisition_Types is
   pragma Pure;

   -- abstract units; real glucose scale and tick length are TBD (blocked on CGM selection); the proofs don't depend on them
   type Glucose_Units   is range 0 .. 100_000;
   type Tick_Count      is range 0 .. 1_000_000_000;

   -- REQ-SA-002 / REQ=SA-003; signal loss (REQ-SA-001) is a separate predicate, Signal_Lost, because it's about the absence pf a reading, while 
   -- status classifies one that arrived 
   type Reading_Status is (Valid, Out_Of_Range, Implausible_Rate);

   type Output (Present : Boolean := False) is record
      case Present is
         when True =>
            Value : Glucose_Units;
         when False =>
            null;
      end case;
   end record;

end Signal_Acquisition_Types;
