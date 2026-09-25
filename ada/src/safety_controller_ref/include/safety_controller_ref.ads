with Safety_Controller_Types; use Safety_Controller_Types;

-- host-side reference model / oracle for the safety controller (independent max-dose limiter + fail-safe command handling), 
-- per PEMS architecture option A; generic over the dose ceiling because the real numeric value is still TBD (blocked on
-- pump/dose-model selection, same open item tracked since the essential performance doc); the logic is provable today independent
-- of that number

-- REQ-SC-001: clamp any requested dose to the ceiling
-- REQ-SC-002: reject (never pass through) anything but a Valid command
generic
   Max_Dose_Per_Cycle : Dose_Units;
package Safety_Controller_Ref
   with SPARK_Mode => On 
is 

   function Clamp_Dose (Requested : Dose_Units) return Dose_Units
      with Post => Clamp_Dose'Result <= Max_Dose_Per_Cycle 
                  and then
                     (if Requested <= Max_Dose_Per_Cycle then Clamp_Dose'Result = Requested 
                     else Clamp_Dose'Result = Max_Dose_Per_Cycle);
            
   function Accept_Command (Status : Command_Status) return Boolean
      with Post => Accept_Command'Result = (Status = Valid);

end Safety_Controller_Ref;