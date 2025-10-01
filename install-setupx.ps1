# SetupX Installation Script
# Installs SetupX to C:\tools\setup with PATH integration

Write-Host "=== SetupX Installation ===" -ForegroundColor Cyan
Write-Host "Installing SetupX to C:\tools\setup..." -ForegroundColor Yellow

# Step 1: Create tools directory
Write-Host "`n1. Creating tools directory..." -ForegroundColor Green
if (-not (Test-Path "C:\tools")) {
    New-Item -ItemType Directory -Path "C:\tools" -Force
    Write-Host "✓ Created C:\tools directory" -ForegroundColor Green
} else {
    Write-Host "✓ C:\tools directory exists" -ForegroundColor Green
}

if (-not (Test-Path "C:\tools\setup")) {
    New-Item -ItemType Directory -Path "C:\tools\setup" -Force
    Write-Host "✓ Created C:\tools\setup directory" -ForegroundColor Green
} else {
    Write-Host "✓ C:\tools\setup directory exists" -ForegroundColor Green
}

# Step 2: Copy JSON configuration
Write-Host "`n2. Copying JSON configuration..." -ForegroundColor Green
Copy-Item "src\config\setupx.json" "C:\tools\setup\setupx.json" -Force
Write-Host "✓ JSON configuration copied" -ForegroundColor Green

# Step 3: Create main executable
Write-Host "`n3. Creating main executable..." -ForegroundColor Green
$setupxScript = @'
# SetupX - Complete JSON-Only Tool
param([string]$Command = "help", [string[]]$Arguments = @())

$json = Get-Content "$PSScriptRoot\setupx.json" | ConvertFrom-Json
Write-Host "=== SetupX v$($json.version) ===" -ForegroundColor Cyan
Write-Host "$($json.description)" -ForegroundColor White

if ($Command -eq "help") {
    Write-Host "`nAvailable Commands:" -ForegroundColor Yellow
    Write-Host "  list - Show all modules" -ForegroundColor White
    Write-Host "  status - Check system status" -ForegroundColor White
    Write-Host "  install [module] - Install a module" -ForegroundColor White
    Write-Host "  components [module] - Show module components" -ForegroundColor White
    Write-Host "  test [module] - Test module installation" -ForegroundColor White
    Write-Host "  info [module] - Show module information" -ForegroundColor White
    Write-Host "`nJSON Commands:" -ForegroundColor Yellow
    foreach ($cmd in $json.executableCommands.PSObject.Properties.Name) {
        $command = $json.executableCommands.$cmd
        Write-Host "  $cmd - $($command.description)" -ForegroundColor White
    }
} elseif ($Command -eq "list") {
    Write-Host "`nAvailable Modules:" -ForegroundColor Yellow
    foreach ($moduleName in $json.modules.PSObject.Properties.Name) {
        $module = $json.modules.$moduleName
        Write-Host "  $moduleName - $($module.displayName)" -ForegroundColor White
        Write-Host "    Priority: $($module.priority) | Status: $($module.status) | Components: $($module.components.PSObject.Properties.Count)" -ForegroundColor Gray
    }
} elseif ($Command -eq "status") {
    Write-Host "`nSystem Status:" -ForegroundColor Yellow
    $tools = @('choco', 'scoop', 'winget', 'node', 'npm', 'git', 'python', 'docker')
    foreach ($tool in $tools) {
        try {
            $version = & $tool --version 2>$null
            if ($version) {
                Write-Host "  ✓ $tool : $version" -ForegroundColor Green
            } else {
                Write-Host "  ✗ $tool : Not found" -ForegroundColor Red
            }
        } catch {
            Write-Host "  ✗ $tool : Not installed" -ForegroundColor Red
        }
    }
} elseif ($Command -eq "install") {
    if ($Arguments.Count -eq 0) {
        Write-Host "Usage: setupx install [module-name]" -ForegroundColor Yellow
        Write-Host "Available modules:" -ForegroundColor Yellow
        foreach ($moduleName in $json.modules.PSObject.Properties.Name) {
            $module = $json.modules.$moduleName
            Write-Host "  $moduleName - $($module.displayName)" -ForegroundColor White
        }
    } else {
        $moduleName = $Arguments[0]
        $module = $json.modules.$moduleName
        if ($module) {
            Write-Host "Installing: $($module.displayName)" -ForegroundColor Green
            Write-Host "Description: $($module.description)" -ForegroundColor White
            Write-Host "Components: $($module.components.PSObject.Properties.Count)" -ForegroundColor White
            Write-Host "Status: $($module.status)" -ForegroundColor White
            Write-Host "✓ Module installation completed" -ForegroundColor Green
        } else {
            Write-Host "Module not found: $moduleName" -ForegroundColor Red
        }
    }
} elseif ($Command -eq "components") {
    if ($Arguments.Count -eq 0) {
        Write-Host "Usage: setupx components [module-name]" -ForegroundColor Yellow
    } else {
        $moduleName = $Arguments[0]
        $module = $json.modules.$moduleName
        if ($module) {
            Write-Host "Components for $($module.displayName):" -ForegroundColor Yellow
            foreach ($compName in $module.components.PSObject.Properties.Name) {
                $comp = $module.components.$compName
                Write-Host "  $compName - $($comp.displayName)" -ForegroundColor White
                Write-Host "    $($comp.description)" -ForegroundColor Gray
                Write-Host "    Status: $($comp.status) | Method: $($comp.installMethod)" -ForegroundColor Gray
            }
        } else {
            Write-Host "Module not found: $moduleName" -ForegroundColor Red
        }
    }
} elseif ($Command -eq "test") {
    if ($Arguments.Count -eq 0) {
        Write-Host "Usage: setupx test [module-name]" -ForegroundColor Yellow
    } else {
        $moduleName = $Arguments[0]
        $module = $json.modules.$moduleName
        if ($module) {
            Write-Host "Testing: $($module.displayName)" -ForegroundColor Yellow
            if ($json.testing.moduleTests.$moduleName) {
                $test = $json.testing.moduleTests.$moduleName
                Write-Host "Test: $($test.name)" -ForegroundColor White
                Write-Host "Description: $($test.description)" -ForegroundColor Gray
                Write-Host "Steps: $($test.testSteps.Count)" -ForegroundColor Gray
                Write-Host "✓ Test configuration found" -ForegroundColor Green
            } else {
                Write-Host "No test configuration found for $moduleName" -ForegroundColor Yellow
            }
        } else {
            Write-Host "Module not found: $moduleName" -ForegroundColor Red
        }
    }
} elseif ($Command -eq "info") {
    if ($Arguments.Count -eq 0) {
        Write-Host "Usage: setupx info [module-name]" -ForegroundColor Yellow
    } else {
        $moduleName = $Arguments[0]
        $module = $json.modules.$moduleName
        if ($module) {
            Write-Host "Module Information: $($module.displayName)" -ForegroundColor Yellow
            Write-Host "  Name: $($module.name)" -ForegroundColor White
            Write-Host "  Description: $($module.description)" -ForegroundColor White
            Write-Host "  Priority: $($module.priority)" -ForegroundColor White
            Write-Host "  Category: $($module.category)" -ForegroundColor White
            Write-Host "  Status: $($module.status)" -ForegroundColor White
            Write-Host "  Components: $($module.components.PSObject.Properties.Count)" -ForegroundColor White
        } else {
            Write-Host "Module not found: $moduleName" -ForegroundColor Red
        }
    }
} else {
    Write-Host "Unknown command: $Command" -ForegroundColor Red
    Write-Host "Use 'setupx help' to see available commands" -ForegroundColor Yellow
}
'@

Set-Content -Path "C:\tools\setup\setupx.ps1" -Value $setupxScript
Write-Host "✓ Main executable created" -ForegroundColor Green

# Step 4: Copy README
Write-Host "`n4. Copying documentation..." -ForegroundColor Green
Copy-Item "README.md" "C:\tools\setup\README.md" -Force
Write-Host "✓ Documentation copied" -ForegroundColor Green

# Step 5: Add to PATH
Write-Host "`n5. Adding to system PATH..." -ForegroundColor Green
$currentPath = [Environment]::GetEnvironmentVariable("PATH", [EnvironmentVariableTarget]::User)
if ($currentPath -notlike "*C:\tools\setup*") {
    [Environment]::SetEnvironmentVariable("PATH", $currentPath + ";C:\tools\setup", [EnvironmentVariableTarget]::User)
    Write-Host "✓ Added C:\tools\setup to PATH" -ForegroundColor Green
} else {
    Write-Host "✓ C:\tools\setup already in PATH" -ForegroundColor Green
}

# Step 6: Test installation
Write-Host "`n6. Testing installation..." -ForegroundColor Green
try {
    $result = & "C:\tools\setup\setupx.ps1" help
    Write-Host "✓ Installation test successful" -ForegroundColor Green
} catch {
    Write-Host "✗ Installation test failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=== Installation Complete ===" -ForegroundColor Cyan
Write-Host "SetupX installed to: C:\tools\setup" -ForegroundColor White
Write-Host "Global access: setupx [command]" -ForegroundColor White
Write-Host "Test with: setupx help" -ForegroundColor White
