with Signal_Acquisition_Ref;

-- throwaway instantiation so gnatprove has something concrete; the values are arbitrary and unrelated to any real CGM
package Signal_Acquisition_Ref_Demo is new Signal_Acquisition_Ref
  (Dropout_Timeout    => 100,
   Plausible_Min      => 20,
   Plausible_Max      => 500,
   Max_Delta_Per_Tick => 2);