with Signal_Acquisition_Types; use Signal_Acquisition_Types;

-- host-side oracle for the signal acquisition checks; 
-- REQ-SA-001: Signal_Lost (no reading within dropout timeout)
-- REQ-SA-002: readings outisde the plausible range never passed on
-- REQ-SA-003: readings that change too fast are never passed on every parameter is a generic formal because the real values are TBD

generic
   Dropout_Timeout    : Tick_Count;
   Plausible_Min      : Glucose_Units;
   Plausible_Max      : Glucose_Units;
   Max_Delta_Per_Tick : Glucose_Units;
package Signal_Acquisition_Ref
   with SPARK_Mode => On
is

   type Acq_State is record
      Has_Previous : Boolean       := False;
      Last_Value   : Glucose_Units := 0;
      Last_Tick    : Tick_Count    := 0; 
   end record;

   function Elapsed (S : Acq_State; Now : Tick_Count)
      return Long_Long_Integer
   is (Long_Long_Integer (Now) - Long_Long_Integer (S.Last_Tick))
   with Pre => Now >= S.Last_Tick;

   function Allowed_Delta (Elapsed_Ticks : Long_Long_Integer)
      return Long_Long_Integer
   is (Long_Long_Integer (Max_Delta_Per_Tick) * Elapsed_Ticks)
   with Pre => Elapsed_Ticks in 0 .. Long_Long_Integer (Tick_Count'Last);

   function Abs_Diff (A, B : Glucose_Units) return Long_Long_Integer
   is (abs (Long_Long_Integer (A) - Long_Long_Integer (B)));

   function Signal_Lost (S : Acq_State; Now : Tick_Count) return Boolean
      with Pre => (if S.Has_Previous then Now >= S.Last_Tick), 
           Post => Signal_Lost'Result =
                  (not S.Has_Previous
                   or else Elapsed (S, Now) > Long_Long_Integer (Dropout_Timeout)); 

   function Classify
      (S       : Acq_State;
       Reading : Glucose_Units;
       Now     : Tick_Count)
       return Reading_Status
      with Pre  => (if S.Has_Previous then Now >= S.Last_Tick),
           Post =>
             (if Reading < Plausible_Min or else Reading > Plausible_Max
              then Classify'Result = Out_Of_Range)
             and then
             (if Classify'Result = Valid then
                Reading >= Plausible_Min
                and then Reading <= Plausible_Max
                and then
                  (if S.Has_Previous
                      and then Elapsed (S, Now) <= Long_Long_Integer (Dropout_Timeout)
                   then Abs_Diff (Reading, S.Last_Value)
                          <= Allowed_Delta (Elapsed (S, Now))));

   function Process
      (S       : Acq_State;
       Reading : Glucose_Units;
       Now     : Tick_Count)
       return Output
      with Pre  => (if S.Has_Previous then Now >= S.Last_Tick),
           Post => Process'Result.Present = (Classify (S, Reading, Now) = Valid)
                   and then (if Process'Result.Present
                             then Process'Result.Value = Reading);

end Signal_Acquisition_Ref;