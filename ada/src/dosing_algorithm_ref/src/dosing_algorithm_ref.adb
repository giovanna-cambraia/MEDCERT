package body Dosing_Algorithm_Ref
   with SPARK_Mode => On  
is

   function Clamp_LLI (Value, Lo, Hi : Long_Long_Integer)
         return Long_Long_Integer is
      begin
         if Value < Lo then
            return Lo;
         elsif Value > Hi then
            return Hi;
         else
            return Value;
         end if;
   end Clamp_LLI;

   function Compute (S : Algo_State; Reading : Glucose_Units; Now : Tick_Count)
      return Output
   is
         Error             : constant Long_Long_Integer  := Long_Long_Integer (Reading) - Long_Long_Integer (Target_Glucose);
         Derivative        : Long_Long_Integer           := 0;
         Raw_Integral      : Long_Long_Integer;
         Clamped_Integral  : Long_Long_Integer;
         P, I, D           : Long_Long_Integer;
         Raw_Dose          : Long_Long_Integer;
         Clamped_Dose      : Long_Long_Integer;
   begin 
      if S.Has_Previous then 
         Derivative := Error - S.Last_Error;
      end if;

      Raw_Integral         := S.Integral + Error;
      Clamped_Integral     := Clamp_LLI (Raw_Integral, Integral_Min, Integral_Max);

      P := Kp * Error;
      I := Ki * Clamped_Integral;
      D := Kd * Derivative;

      Raw_Dose             := P + I + D;
      Clamped_Dose         := Clamp_LLI (Raw_Dose, Long_Long_Integer (Output_Min), Long_Long_Integer (Output_Max));

      return (Emit => True, Dose => Dose_Output (Clamped_Dose));
   end Compute;

end Dosing_Algorithm_Ref;