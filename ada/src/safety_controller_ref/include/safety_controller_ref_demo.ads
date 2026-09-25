with Safety_Controller_Types; use Safety_Controller_Types;
with Safety_Controller_Ref;

--  throwaway instantiation, for proof purposes only; generic packages
--  are not analyzed by gnatprove on their own -- it needs at least one
--  concrete instantiation to check the contracts against; the value
--  100 here is arbitrary and unrelated to the real dose ceiling
--  (still TBD, see REQ-SC-001) -- this instance exists purely so
--  Clamp_Dose/Accept_Command's postconditions have something concrete
--  to be proved for/; once a real instantiation exists elsewhere in the
--  codebase (e.g. wired to the actual device build), this file can be
--  deleted; until then it's what "alr exec -- gnatprove ..." checks
package Safety_Controller_Ref_Demo is new
  Safety_Controller_Ref (Max_Dose_Per_Cycle => 100);