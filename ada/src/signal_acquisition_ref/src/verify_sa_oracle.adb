with Signal_Acquisition_Types;    use Signal_Acquisition_Types;
with Signal_Acquisition_Ref_Demo; use Signal_Acquisition_Ref_Demo;

procedure Verify_SA_Oracle with SPARK_Mode => On is 
   S  : constant Acq_State := (Has_Previous => True, Last_Value => 100, Last_Tick => 10);
   R1 : constant Output    := Process (S, 600, 11); -- above plausible max
   R2 : constant Output    := Process (S, 300, 11); -- in range, jumps too fast
begin
   pragma Assert (not R1.Present);          -- REQ-SA-002
   pragma Assert (not R2.Present);          -- REQ-SA-003
   pragma Assert (Signal_Lost (S, 500));    -- gap 490 > timeout 100
   pragma Assert (not Signal_Lost (S, 50)); -- REQ-SA-001
end Verify_SA_Oracle;