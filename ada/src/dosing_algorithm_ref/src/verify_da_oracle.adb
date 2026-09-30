with Dosing_Algorithm_Types;    use Dosing_Algorithm_Types;
with Dosing_Algorithm_Ref_Demo; use Dosing_Algorithm_Ref_Demo;

procedure Verify_DA_Oracle with SPARK_Mode => On is
   No_Prev : constant Algo_State := (others => <>);
   High    : constant Output := Compute (No_Prev, 100_000, 0); -- extreme high
   Low     : constant Output := Compute (No_Prev, 0, 0); -- extremely low
begin
   pragma Assert (High.Dose in 0 .. 1_000);  --  REQ-DA-002 boundedness
   pragma Assert (Low.Dose in 0 .. 1_000);
end Verify_DA_Oracle;
