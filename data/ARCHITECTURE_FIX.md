# Architecture Compatibility Fix

## Issue
Scripts were failing with: `Bad CPU type in executable` when calling other scripts.

## Root Cause
The scripts were using `bash` from PATH, which resolved to `/opt/homebrew/bin/bash` (ARM64), but the shell was running in x86_64 mode (Rosetta).

## Solution
All scripts now use `/bin/bash` explicitly, which is a universal binary that works on both architectures.

## Fixed Scripts
- ✅ `complete-external-tools-integration.sh` - Now uses `/bin/bash` for all sub-script calls

## How to Run
Always use `/bin/bash` explicitly or run from the script directory:

```bash
# Recommended
/bin/bash scripts/complete-external-tools-integration.sh

# Or
cd scripts && /bin/bash complete-external-tools-integration.sh
```

## Verification
The script should now work without architecture errors. Test with:

```bash
/bin/bash scripts/complete-external-tools-integration.sh
```

