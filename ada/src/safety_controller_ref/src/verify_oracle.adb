with Safety_Controller_Types; use Safety_Controller_Types;
with Safety_Controller_Ref_Demo;

procedure Verify_Oracle with SPARK_Mode => On is
   D_In  : constant Dose_Units := 50;
   D_Out : Dose_Units;
   Ok    : Boolean;
begin
   D_Out := Safety_Controller_Ref_Demo.Clamp_Dose (D_In);
   Ok    := Safety_Controller_Ref_Demo.Accept_Command (Valid);
   pragma Assert (D_Out <= 100);
   pragma Assert (Ok);
end Verify_Oracle;