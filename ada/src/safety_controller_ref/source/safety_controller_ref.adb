package body Safety_Controller_Ref
   with SPARK_Mode => On 
is

   function Clamp_Dose (Requested : Dose_Units) return Dose_Units is
   begin
      if Requested <= Max_Dose_Per_Cycle then
         return Requested;
      else 
         return Max_Dose_Per_Cycle;
      end if;
   end Clamp_Dose;

   function Accept_Command (Status : Command_Status) return Boolean is
   begin 
      return Status = Valid;
   end Accept_Command;

end Safety_Controller_Ref;