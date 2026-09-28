package body Signal_Acquisition_Ref
   with SPARK_Mode => On 
is 

   function Signal_Lost (S : Acq_State; Now : Tick_Count) return Boolean is
   begin
      return not S.Has_Previous
         or else Elapsed (S, Now) > Long_Long_Integer (Dropout_Timeout);
   end Signal_Lost;

   function Classify 
         (S : Acq_State; Reading : Glucose_Units; Now : Tick_Count)
         return Reading_Status
      is
      begin
         if Reading < Plausible_Min or else Reading > Plausible_Max then
            return Out_Of_Range;
         elsif S.Has_Previous
            and then Elapsed (S, Now) <= Long_Long_Integer (Dropout_Timeout)
            and then Abs_Diff (Reading, S.Last_Value) > Allowed_Delta (Elapsed (S, Now))
         then
            return Implausible_Rate;
         else
            return Valid;
         end if;
   end Classify;

   function Process (S : Acq_State; Reading : Glucose_Units; Now : Tick_Count)
         return Output
      is 
      begin
         if Classify (S, Reading, Now) = Valid then
            return (Present => True, Value => 0);
         else
            return (Present => False, Value => 0);
         end if;
   end Process;

end Signal_Acquisition_Ref;