# Quick Start: Testing Guide

## Problem
Tests fail on macOS/Linux/Windows with:
```
ModuleNotFoundError: No module named 'ibm_db_dbi'
```

## Solution Summary

### ✅ Option 1: Run Tests Locally with Mocks (RECOMMENDED)

The `conftest.py` file automatically mocks IBM i dependencies.

```bash
cd ibmi-bob

# Run all unit tests (with mocks)
pytest tests/unit/ -v

# Run specific tests
pytest tests/unit/test_crtfrmstmf.py tests/unit/test_cvtsrcpf.py tests/unit/test_ibm_job.py -v

# Run with coverage
pytest tests/unit/ --cov=src/makei --cov-report=html
```

**What happens:**
- `conftest.py` mocks `ibm_db_dbi` before tests run
- Tests execute with fake database connections
- Fast feedback for development
- Works on any OS

---

### ✅ Option 2: Run Tests on IBM i System

Use the provided script to run tests on actual IBM i:

```bash
cd ibmi-bob/tests

# Make script executable (first time only)
chmod +x run_remote_tests.sh

# Run tests on IBM i
./run_remote_tests.sh -h your-ibmi-host.com -u your-username

# Run specific tests
./run_remote_tests.sh -h your-ibmi-host.com -u your-username -t "tests/unit/test_ibm_job.py"

# Sync code only (no tests)
./run_remote_tests.sh -h your-ibmi-host.com -u your-username --sync-only
```

**Prerequisites:**
1. SSH access to IBM i system
2. SSH keys configured: `ssh-copy-id user@ibmi-host.com`
3. Python 3.9+ installed on IBM i
4. pytest installed on IBM i: `pip3 install pytest`

---

## Files Created

### 1. `tests/unit/conftest.py`
- Mocks `ibm_db_dbi` module
- Provides test fixtures
- Enables local testing

### 2. `tests/run_remote_tests.sh`
- Syncs code to IBM i
- Runs tests remotely
- Handles SSH connection

### 3. `tests/REMOTE_TESTING_GUIDE.md`
- Comprehensive testing strategies
- Detailed setup instructions
- Troubleshooting guide

---

## Quick Commands

```bash
# Local testing (with mocks)
cd ibmi-bob
pytest tests/unit/ -v

# Remote testing (on IBM i)
cd ibmi-bob/tests
./run_remote_tests.sh -h ibmi.example.com -u testuser

# Run only unit tests (skip integration)
pytest tests/unit/ -v -m "not integration"

# Run only integration tests
pytest tests/unit/ -v -m integration
```

---

## Test Markers

Mark tests for different environments:

```python
import pytest

@pytest.mark.unit
def test_with_mocks():
    """Runs locally with mocks"""
    pass

@pytest.mark.integration
def test_real_ibmi():
    """Requires real IBM i system"""
    pass
```

Run specific markers:
```bash
pytest -m unit          # Only unit tests
pytest -m integration   # Only integration tests
pytest -m "not slow"    # Skip slow tests
```

---

## Troubleshooting

### Issue: Tests still fail with import error

**Solution**: Ensure `conftest.py` exists in `tests/unit/` directory:
```bash
ls -la ibmi-bob/tests/unit/conftest.py
```

### Issue: Remote script fails with "Permission denied"

**Solution**: Make script executable:
```bash
chmod +x ibmi-bob/tests/run_remote_tests.sh
```

### Issue: SSH connection fails

**Solution**: Setup SSH keys:
```bash
ssh-copy-id user@ibmi-host.com
ssh user@ibmi-host.com  # Test connection
```

---

## Recommended Workflow

### Daily Development
```bash
# 1. Write code
# 2. Run local tests with mocks
pytest tests/unit/ -v

# 3. Fix any failures
# 4. Commit changes
```

### Before Release
```bash
# 1. Run all local tests
pytest tests/unit/ -v

# 2. Run integration tests on IBM i
./tests/run_remote_tests.sh -h ibmi.example.com -u testuser

# 3. Verify all tests pass
# 4. Create release
```

---

## Need More Help?

See detailed documentation:
- **Comprehensive Guide**: `tests/REMOTE_TESTING_GUIDE.md`
- **Script Help**: `./tests/run_remote_tests.sh --help`

---

## Summary

| Environment | Command | Use Case |
|-------------|---------|----------|
| **Local (macOS/Linux/Windows)** | `pytest tests/unit/ -v` | Daily development |
| **Remote (IBM i)** | `./tests/run_remote_tests.sh -h HOST -u USER` | Integration testing |
| **CI/CD** | Configure GitHub Actions with self-hosted runner | Automated testing |

**Start with local testing, validate on IBM i before release.**