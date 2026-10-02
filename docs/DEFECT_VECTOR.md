# Repository Defect Vector

**Total Detected Defects:** 14

### DEF_000001: CASE_MISMATCH
- **Severity:** CRITICAL
- **Evidence:** `Case-mismatch files coexist: ChronoFold.lean and Chronofold.lean`
- **Repair Operator:** `O_rename`
- **Status:** OPEN
- **Notes:** Coexistence of different cases causes severe confusion and import errors under Lean 4.

### DEF_000002: BROKEN_IMPORT
- **Severity:** HIGH
- **Evidence:** `File Chronofold.lean imports Chronofold.T1_Operator which does not exist in the workspace.`
- **Repair Operator:** `O_import_repair`
- **Status:** OPEN
- **Notes:** Imports of non-existent module Chronofold.T1_Operator prevents compilation.

### DEF_000003: BROKEN_IMPORT
- **Severity:** HIGH
- **Evidence:** `File Chronofold.lean imports Chronofold.T2_Curvature which does not exist in the workspace.`
- **Repair Operator:** `O_import_repair`
- **Status:** OPEN
- **Notes:** Imports of non-existent module Chronofold.T2_Curvature prevents compilation.

### DEF_000004: BROKEN_IMPORT
- **Severity:** HIGH
- **Evidence:** `File Chronofold.lean imports Chronofold.SNAP which does not exist in the workspace.`
- **Repair Operator:** `O_import_repair`
- **Status:** OPEN
- **Notes:** Imports of non-existent module Chronofold.SNAP prevents compilation.

### DEF_000005: BROKEN_IMPORT
- **Severity:** HIGH
- **Evidence:** `File Chronofold.lean imports Chronofold.Pipeline which does not exist in the workspace.`
- **Repair Operator:** `O_import_repair`
- **Status:** OPEN
- **Notes:** Imports of non-existent module Chronofold.Pipeline prevents compilation.

### DEF_000006: MISSING_DEPENDENCY
- **Severity:** CRITICAL
- **Evidence:** `File disabled/Auto.lean imports Mathlib.Data.Nat.GCD.Basic, but Mathlib is not registered in lakefile.lean or lake-manifest.json.`
- **Repair Operator:** `O_package_add`
- **Status:** OPEN
- **Notes:** Causes 'unknown module prefix Mathlib' error.

### DEF_000007: MISSING_DEPENDENCY
- **Severity:** CRITICAL
- **Evidence:** `File disabled/Auto.lean imports Mathlib.Data.Nat.Basic, but Mathlib is not registered in lakefile.lean or lake-manifest.json.`
- **Repair Operator:** `O_package_add`
- **Status:** OPEN
- **Notes:** Causes 'unknown module prefix Mathlib' error.

### DEF_000008: BROKEN_IMPORT
- **Severity:** HIGH
- **Evidence:** `File disabled/Theorems.lean imports Chronofold.Operators which does not exist in the workspace.`
- **Repair Operator:** `O_import_repair`
- **Status:** OPEN
- **Notes:** Imports of non-existent module Chronofold.Operators prevents compilation.

### DEF_000009: BROKEN_IMPORT
- **Severity:** HIGH
- **Evidence:** `File disabled/Operators.lean imports Chronofold.Base which does not exist in the workspace.`
- **Repair Operator:** `O_import_repair`
- **Status:** OPEN
- **Notes:** Imports of non-existent module Chronofold.Base prevents compilation.

### DEF_000010: MISSING_DEPENDENCY
- **Severity:** CRITICAL
- **Evidence:** `File templates/theorem_candidate.lean imports Mathlib, but Mathlib is not registered in lakefile.lean or lake-manifest.json.`
- **Repair Operator:** `O_package_add`
- **Status:** OPEN
- **Notes:** Causes 'unknown module prefix Mathlib' error.

### DEF_000011: MISSING_DEPENDENCY
- **Severity:** CRITICAL
- **Evidence:** `File theorems_rejected/THM_000001__nat_add_zero_right.lean imports Mathlib, but Mathlib is not registered in lakefile.lean or lake-manifest.json.`
- **Repair Operator:** `O_package_add`
- **Status:** OPEN
- **Notes:** Causes 'unknown module prefix Mathlib' error.

### DEF_000012: MISSING_DEPENDENCY
- **Severity:** CRITICAL
- **Evidence:** `File ChronoFold/Auto.lean imports Mathlib.Data.Nat.GCD.Basic, but Mathlib is not registered in lakefile.lean or lake-manifest.json.`
- **Repair Operator:** `O_package_add`
- **Status:** OPEN
- **Notes:** Causes 'unknown module prefix Mathlib' error.

### DEF_000013: MISSING_DEPENDENCY
- **Severity:** CRITICAL
- **Evidence:** `File ChronoFold/Auto.lean imports Mathlib.Data.Nat.Basic, but Mathlib is not registered in lakefile.lean or lake-manifest.json.`
- **Repair Operator:** `O_package_add`
- **Status:** OPEN
- **Notes:** Causes 'unknown module prefix Mathlib' error.

### DEF_000014: MISSING_DEPENDENCY
- **Severity:** CRITICAL
- **Evidence:** `File ChronoFold/Auto/T1.lean imports Mathlib, but Mathlib is not registered in lakefile.lean or lake-manifest.json.`
- **Repair Operator:** `O_package_add`
- **Status:** OPEN
- **Notes:** Causes 'unknown module prefix Mathlib' error.
