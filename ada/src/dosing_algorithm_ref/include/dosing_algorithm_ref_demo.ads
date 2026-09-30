with Dosing_Algorithm_Ref;

-- throwaway instantiation for proof purposes; every value here is arbitrary, real target glucose and PID gains are a clinical tuning question,
-- not something to invent; chosen only to be modest enough that gnatprive can confirm no arithmetic overflow 
package Dosing_Algorithm_Ref_Demo is new Dosing_Algorithm_Ref
   (Target_Glucose   => 5_000,
    Kp               => 500,
    Ki               => 50,
    Kd               => 100, 
    Integral_Min     => -50_000, 
    Integral_Max     => 50_000, 
    Output_Min       => 0, 
    Output_Max       => 1_000);