# SetupX Testing Suite

Comprehensive testing for all SetupX components.

## Test Files

### 1. test-runner.ps1
**Main test suite** - Tests all components one by one

**Usage:**
```powershell
# Test all components
.\test\test-runner.ps1

# Test specific module
.\test\test-runner.ps1 -ModuleName web-development

# Test specific component
.\test\test-runner.ps1 -ComponentName nodejs

# Quick test (no delays)
.\test\test-runner.ps1 -Quick
```

**Features:**
- Tests all component properties
- Checks installation status
- Verifies commands exist
- Generates detailed report
- Exports results to JSON

### 2. test-module.ps1
**Module-specific testing** - Tests all components in a module

**Usage:**
```powershell
# Test package managers module
.\test\test-module.ps1 -ModuleName package-managers

# Test web development module
.\test\test-module.ps1 -ModuleName web-development

# Test cloud development module
.\test\test-module.ps1 -ModuleName cloud-development
```

**Features:**
- Shows module information
- Tests each component in module
- Shows installation status
- Displays version information

### 3. test-component.ps1
**Detailed component testing** - Deep dive into a single component

**Usage:**
```powershell
# Test chocolatey
.\test\test-component.ps1 -ComponentName chocolatey

# Test nodejs
.\test\test-component.ps1 -ComponentName nodejs

# Test docker
.\test\test-component.ps1 -ComponentName docker
```

**Features:**
- Complete component information
- All available commands
- Installation status
- Version information
- Verification results

### 4. test-install.ps1
**Installation testing** - Test actual installation of components

**⚠️ WARNING: This will actually install software!**

**Usage:**
```powershell
# Dry run (no actual installation)
.\test\test-install.ps1 -ComponentName chocolatey -DryRun

# Actual installation test
.\test\test-install.ps1 -ComponentName nodejs

# Test with confirmation
.\test\test-install.ps1 -ComponentName git
```

**Features:**
- Pre-installation status check
- Dry run mode
- Confirmation prompt
- Installation execution
- Post-installation verification

## Quick Examples

### Test Everything
```powershell
# Run complete test suite
.\test\test-runner.ps1

# Results saved to: test/test-results-TIMESTAMP.json
```

### Test Package Managers
```powershell
# Test all package manager components
.\test\test-runner.ps1 -ModuleName package-managers

# Or use module-specific test
.\test\test-module.ps1 -ModuleName package-managers
```

### Test Specific Component
```powershell
# Get detailed info
.\test\test-component.ps1 -ComponentName nodejs

# Test installation (dry run)
.\test\test-install.ps1 -ComponentName nodejs -DryRun
```

### Test Web Development Tools
```powershell
# Test all web dev components
.\test\test-module.ps1 -ModuleName web-development

# Test specific tool
.\test\test-component.ps1 -ComponentName react-tools
```

## Test Workflow

### 1. Check All Components
```powershell
.\test\test-runner.ps1 -Quick
```

### 2. Test Specific Module
```powershell
.\test\test-module.ps1 -ModuleName package-managers
```

### 3. Detailed Component Check
```powershell
.\test\test-component.ps1 -ComponentName chocolatey
```

### 4. Test Installation (if needed)
```powershell
# Dry run first
.\test\test-install.ps1 -ComponentName chocolatey -DryRun

# Then actual install
.\test\test-install.ps1 -ComponentName chocolatey
```

## Test Reports

### JSON Reports
Test runner generates JSON reports with timestamps:
```
test/test-results-20251001_123456.json
```

**Report Structure:**
```json
{
  "Timestamp": "2025-10-01T12:34:56",
  "TotalTests": 150,
  "PassedTests": 145,
  "FailedTests": 5,
  "Results": [...]
}
```

## Available Modules to Test

1. **package-managers** - Chocolatey, Scoop, WinGet
2. **web-development** - Node.js, Yarn, Browsers, React, Vue, Angular, Vite
3. **common-development** - Git, VS Code, PowerShell, Terminal
4. **backend-development** - Python, Docker, PostgreSQL, MongoDB
5. **cloud-development** - AWS CLI, Azure CLI, GCloud, kubectl, Terraform
6. **mobile-development** - Flutter, React Native, Android Studio
7. **data-science** - Jupyter, TensorFlow, PyTorch, Pandas
8. **devops** - Terraform, Ansible, Jenkins
9. **wsl-linux** - WSL 2, Ubuntu, Docker Desktop

## Test Parameters

### -ModuleName
Filter tests by module name
```powershell
.\test\test-runner.ps1 -ModuleName web-development
```

### -ComponentName
Test specific component
```powershell
.\test\test-runner.ps1 -ComponentName nodejs
.\test\test-component.ps1 -ComponentName docker
```

### -Quick
Skip delays between tests
```powershell
.\test\test-runner.ps1 -Quick
```

### -DryRun
Simulate installation without executing
```powershell
.\test\test-install.ps1 -ComponentName git -DryRun
```

## Interpreting Results

### Test Output Colors:
- 🟢 **Green** - Test passed
- 🔴 **Red** - Test failed
- 🟡 **Yellow** - Warning or info
- ⚪ **Gray** - Additional details

### Status Indicators:
- `[PASS]` - Test passed
- `[FAIL]` - Test failed
- `[+]` - Component installed
- `[-]` - Component not installed

## Best Practices

1. **Run tests regularly** to verify component configurations
2. **Use -DryRun** before actual installations
3. **Check test reports** for detailed information
4. **Test by module** for organized testing
5. **Verify installations** after running install tests

## Troubleshooting

### Test Fails to Find Component
```powershell
# List all components first
.\setupx.ps1 list-all

# Then test with exact name
.\test\test-component.ps1 -ComponentName exact-name
```

### Module Not Found
```powershell
# List all modules
.\setupx.ps1 list

# Use exact module name
.\test\test-module.ps1 -ModuleName package-managers
```

### Installation Test Fails
```powershell
# Check component details first
.\test\test-component.ps1 -ComponentName component-name

# Verify command exists
.\setupx.ps1 check component-name
```

## Example Test Session

```powershell
# 1. Full system test
.\test\test-runner.ps1

# 2. Test package managers (most important)
.\test\test-module.ps1 -ModuleName package-managers

# 3. Test Chocolatey in detail
.\test\test-component.ps1 -ComponentName chocolatey

# 4. If not installed, test installation
.\test\test-install.ps1 -ComponentName chocolatey -DryRun
.\test\test-install.ps1 -ComponentName chocolatey

# 5. Verify it works
.\setupx.ps1 check chocolatey
```

## CI/CD Integration

Tests can be integrated into CI/CD pipelines:

```powershell
# Run all tests and exit with error code if failures
.\test\test-runner.ps1
if ($LASTEXITCODE -ne 0) {
    exit 1
}
```

## Contributing

When adding new components:
1. Run test-runner to ensure structure is correct
2. Test the specific component with test-component.ps1
3. Verify installation works with test-install.ps1
4. Check test reports for any issues

---

**Happy Testing! 🧪**

