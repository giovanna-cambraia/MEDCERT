with Dosing_Algorithm_Types; use Dosing_Algorithm_Types;

-- host-side: oracle for the dosing algorithm's core control law (PID-style: proportional + integral + derivative on glucose error)

-- REQ-DA-001 (staleness bound) is not enforced here, it's satisfied jointly with signal_acquisition (which already gatekeeps stale readings before they arrive)
-- and this module's own Now/Last_Tick bookkeeping for this derivative term; no separate staleness check is duplicated in this function 

-- REQ-DA-002 (self-check / fail-to-no-dose) is INTENTIONALLY NOT fully modeled in this first version; see Output.Emit below

-- REQ-DA-003 (bounded cycle time) is a scheduling property of the *caller* (how often Compute gets invoked), not something this pure function can enforce on itself

-- REQ-DA-004 (no direct pump path) is architectural, not something a single function's contract expresses, it's enforced by simply never giving
-- this module a pump-facing interface at all
generic 
   Target_Glucose    : Glucose_Units;
   Kp                : Long_Long_Integer; -- proportional gain, scaled 
   Ki                : Long_Long_Integer; -- integral gain, scaled
   Kd                : Long_Long_Integer; -- derivative gain, scaled
   Integral_Min      : Long_Long_Integer; -- anti-windup clamp 
   Integral_Max      : Long_Long_Integer; 
   Output_Min        : Dose_Output;
   Output_Max        : Dose_Output;
package Dosing_Algorithm_Ref
   with SPARK_Mode => On 
is

   type Algo_State is record
      Has_Previous   : Boolean            := False;
      Integral       : Long_Long_Integer  := 0;
      Last_Error     : Long_Long_Integer  := 0;
      Last_Tick      : Tick_Count         := 0;
   end record;

   type Output is record
      -- always true in this version, see file header note on REQ-DA-002; kept as a field now so callers and later revisions
      -- don't need an interface change when a real self-check lands
      Emit           : Boolean;
      Dose           : Dose_Output;
   end record;

   function Clamp_LLI (Value, Lo, Hi : Long_Long_Integer)
      return Long_Long_Integer
   is (if Value < Lo then Lo elsif Value > Hi then Hi else Value)
   with Pre => Lo <= Hi,
        Post => Clamp_LLI'Result in Lo .. Hi;

   -- the one property genuinely proved here: whatever comes in, whatever the accumulated state is, the emitted dose is always within
   -- [Output_Min, Output_Max]; that's the boundedness guarantee REQ-DA-002 needs from the algorithm side, independent of the safety controller's
   -- own independent clamp (REQ-SC-001); belt and suspenders, not a substitute for it
   function Compute
      (S : Algo_State; Reading : Glucose_Units; Now : Tick_Count)
         return Output
      with Pre  => (if S.Has_Previous then Now >= S.Last_Tick)
                   and then Integral_Min <= Integral_Max
                   and then Output_Min <= Output_Max,
           Post => Compute'Result.Dose in Output_Min .. Output_Max;
      
end Dosing_Algorithm_Ref;