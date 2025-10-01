# SetupX Core Engine
# Executes commands from JSON configuration

function Invoke-ComponentCommand {
    <#
    .SYNOPSIS
    Executes a component command from JSON configuration
    #>
    param(
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$Component,
        [Parameter(Mandatory=$true)]
        [ValidateSet("install", "remove", "update", "check", "verify", "test")]
        [string]$Action
    )
    
    if (-not $Component.commands.$Action) {
        Write-Host "Action '$Action' not available for $($Component.displayName)" -ForegroundColor Yellow
        return $false
    }
    
    $command = $Component.commands.$Action
    
    Write-Host "`nExecuting: $($Component.displayName) - $Action" -ForegroundColor Cyan
    Write-Host "Command: $command" -ForegroundColor DarkGray
    Write-Host ""
    
    try {
        # Execute the command
        $result = Invoke-Expression $command
        
        # Check if command was successful
        if ($LASTEXITCODE -eq 0 -or $null -eq $LASTEXITCODE) {
            Write-Host "$($Component.displayName) - $Action completed successfully" -ForegroundColor Green
            
            # Execute path refresh if specified
            if ($Component.commands.path) {
                try {
                    Invoke-Expression $Component.commands.path
                }
                catch {
                    Write-Host "Warning: Path refresh failed: $_" -ForegroundColor Yellow
                }
            }
            
            # Refresh environment variables using PowerShell-only methods
            try {
                # Refresh PATH from registry without external commands
                $machinePath = [System.Environment]::GetEnvironmentVariable("PATH", "Machine")
                $userPath = [System.Environment]::GetEnvironmentVariable("PATH", "User")
                if ($machinePath -and $userPath) {
                    $env:PATH = $machinePath + ";" + $userPath
                } elseif ($machinePath) {
                    $env:PATH = $machinePath
                } elseif ($userPath) {
                    $env:PATH = $userPath
                }
                
                # Refresh other common environment variables
                $pythonPathMachine = [System.Environment]::GetEnvironmentVariable("PYTHONPATH", "Machine")
                $pythonPathUser = [System.Environment]::GetEnvironmentVariable("PYTHONPATH", "User")
                if ($pythonPathMachine -or $pythonPathUser) {
                    $env:PYTHONPATH = ($pythonPathMachine + ";" + $pythonPathUser).TrimStart(';').TrimEnd(';')
                }
            }
            catch {
                Write-Host "Warning: Could not refresh environment variables: $_" -ForegroundColor Yellow
            }
            
            return $true
        }
        else {
            Write-Host "$($Component.displayName) - $Action failed with exit code: $LASTEXITCODE" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "Error executing $Action for $($Component.displayName): $_" -ForegroundColor Red
        return $false
    }
}

function Get-AllComponents {
    <#
    .SYNOPSIS
    Gets all components from all module JSON files
    #>
    
    $allComponents = @()
    $modulesPath = Join-Path $PSScriptRoot "..\config\modules"
    
    if (Test-Path $modulesPath) {
        $jsonFiles = Get-ChildItem -Path $modulesPath -Filter "*.json"
        
        foreach ($file in $jsonFiles) {
            try {
                $moduleData = Get-Content $file.FullName -Raw | ConvertFrom-Json
                
                foreach ($componentName in $moduleData.components.PSObject.Properties.Name) {
                    $component = $moduleData.components.$componentName
                    $component | Add-Member -NotePropertyName "moduleName" -NotePropertyValue $moduleData.name -Force
                    $component | Add-Member -NotePropertyName "moduleFile" -NotePropertyValue $file.Name -Force
                    $allComponents += $component
                }
            }
            catch {
                Write-Host "Warning: Could not load $($file.Name): $_" -ForegroundColor Yellow
            }
        }
    }
    
    # Also check main config file
    $mainConfigPath = Join-Path $PSScriptRoot "..\config\setupx.json"
    if (Test-Path $mainConfigPath) {
        try {
            $mainConfig = Get-Content $mainConfigPath -Raw | ConvertFrom-Json
            
            if ($mainConfig.components) {
                foreach ($componentName in $mainConfig.components.PSObject.Properties.Name) {
                    $component = $mainConfig.components.$componentName
                    $component | Add-Member -NotePropertyName "moduleName" -NotePropertyValue "main" -Force
                    $component | Add-Member -NotePropertyName "moduleFile" -NotePropertyValue "setupx.json" -Force
                    $allComponents += $component
                }
            }
        }
        catch {
            Write-Host "Warning: Could not load main config: $_" -ForegroundColor Yellow
        }
    }
    
    return $allComponents
}

function Get-ComponentByName {
    <#
    .SYNOPSIS
    Gets a specific component by name
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$ComponentName
    )
    
    $allComponents = Get-AllComponents
    $component = $allComponents | Where-Object { $_.name -eq $ComponentName } | Select-Object -First 1
    
    if (-not $component) {
        # Try fuzzy match
        $component = $allComponents | Where-Object { 
            $_.name -like "*$ComponentName*" -or 
            $_.displayName -like "*$ComponentName*" 
        } | Select-Object -First 1
    }
    
    return $component
}

function Get-ComponentsByCategory {
    <#
    .SYNOPSIS
    Gets all components in a specific category
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$Category
    )
    
    $allComponents = Get-AllComponents
    return $allComponents | Where-Object { $_.category -eq $Category }
}

function Get-ComponentsByModule {
    <#
    .SYNOPSIS
    Gets all components from a specific module file
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$ModuleName
    )
    
    $allComponents = Get-AllComponents
    return $allComponents | Where-Object { $_.moduleName -eq $ModuleName }
}

function Get-ModuleConfig {
    <#
    .SYNOPSIS
    Gets module configuration from JSON file
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$ModuleName
    )
    
    $modulePath = Join-Path $PSScriptRoot "..\config\modules\$ModuleName.json"
    
    if (Test-Path $modulePath) {
        try {
            $moduleData = Get-Content $modulePath -Raw | ConvertFrom-Json
            return $moduleData
        }
        catch {
            Write-Host "Warning: Could not load module $ModuleName`: $_" -ForegroundColor Yellow
            return $null
        }
    }
    
    return $null
}

function Get-AllModuleConfigs {
    <#
    .SYNOPSIS
    Gets all module configurations
    #>
    $allModules = @()
    $modulesPath = Join-Path $PSScriptRoot "..\config\modules"
    
    if (Test-Path $modulesPath) {
        $jsonFiles = Get-ChildItem -Path $modulesPath -Filter "*.json"
        
        foreach ($file in $jsonFiles) {
            try {
                $moduleData = Get-Content $file.FullName -Raw | ConvertFrom-Json
                $allModules += $moduleData
            }
            catch {
                Write-Host "Warning: Could not load $($file.Name): $_" -ForegroundColor Yellow
            }
        }
    }
    
    return $allModules
}

function Get-DynamicPaths {
    <#
    .SYNOPSIS
    Gets dynamic installation paths for various tools
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$ToolType
    )
    
    $paths = @()
    
    switch ($ToolType) {
        "Python" {
            # Dynamic Python detection
            $pythonVersions = @("313", "312", "311", "310", "39", "38")
            foreach ($version in $pythonVersions) {
                $paths += "C:\Python$version\python.exe"
                $paths += "$env:USERPROFILE\AppData\Local\Programs\Python\Python$version\python.exe"
                $paths += "$env:USERPROFILE\AppData\Local\Programs\Python\Python$version-32\python.exe"
            }
            # Check PATH for python
            $pathDirs = $env:PATH -split ";"
            foreach ($dir in $pathDirs) {
                if ($dir -and (Test-Path $dir)) {
                    $pythonExe = Join-Path $dir "python.exe"
                    if (Test-Path $pythonExe) {
                        $paths += $pythonExe
                    }
                }
            }
        }
        "PythonSitePackages" {
            # Dynamic Python site-packages detection
            $pythonVersions = @("313", "312", "311", "310", "39", "38")
            foreach ($version in $pythonVersions) {
                $paths += "C:\Python$version\Lib\site-packages"
                $paths += "$env:USERPROFILE\AppData\Local\Programs\Python\Python$version\Lib\site-packages"
                $paths += "$env:USERPROFILE\AppData\Local\Programs\Python\Python$version-32\Lib\site-packages"
            }
        }
        "Chocolatey" {
            # Dynamic Chocolatey detection
            $chocoInstall = $env:ChocolateyInstall
            if ($chocoInstall) {
                $paths += Join-Path $chocoInstall "bin\choco.exe"
                $paths += Join-Path $chocoInstall "lib"
            }
            $paths += "C:\ProgramData\chocolatey\bin\choco.exe"
            $paths += "C:\ProgramData\chocolatey\lib"
        }
        "NodeJS" {
            # Dynamic Node.js detection
            $paths += "C:\Program Files\nodejs\node.exe"
            $paths += "C:\Program Files (x86)\nodejs\node.exe"
            $paths += "$env:USERPROFILE\AppData\Local\Programs\nodejs\node.exe"
            $paths += "$env:USERPROFILE\AppData\Roaming\npm\node.exe"
            # Check PATH for node
            $pathDirs = $env:PATH -split ";"
            foreach ($dir in $pathDirs) {
                try {
                    if ($dir -and (Test-Path -LiteralPath $dir -ErrorAction SilentlyContinue)) {
                        $nodeExe = Join-Path $dir "node.exe"
                        if (Test-Path -LiteralPath $nodeExe -ErrorAction SilentlyContinue) {
                            $paths += $nodeExe
                        }
                    }
                }
                catch {}
            }
        }
        "NPM" {
            # Dynamic npm detection
            $paths += "$env:USERPROFILE\AppData\Roaming\npm"
            $paths += "$env:USERPROFILE\AppData\Local\Programs\nodejs\node_modules\npm"
            # Check PATH for npm
            $pathDirs = $env:PATH -split ";"
            foreach ($dir in $pathDirs) {
                try {
                    if ($dir -and (Test-Path -LiteralPath $dir -ErrorAction SilentlyContinue)) {
                        $npmCmd = Join-Path $dir "npm.cmd"
                        if (Test-Path -LiteralPath $npmCmd -ErrorAction SilentlyContinue) {
                            $paths += $dir
                        }
                    }
                }
                catch {}
            }
        }
        "Scoop" {
            # Dynamic Scoop detection
            $scoopRoot = $env:SCOOP
            if ($scoopRoot) {
                $paths += Join-Path $scoopRoot "apps\scoop\current\bin\scoop.ps1"
                $paths += Join-Path $scoopRoot "apps"
            }
            $paths += "$env:USERPROFILE\scoop\apps\scoop\current\bin\scoop.ps1"
            $paths += "$env:USERPROFILE\scoop\apps"
        }
        "WinGet" {
            # Dynamic WinGet detection
            $paths += "C:\Program Files\Microsoft\WindowsApps\winget.exe"
            $paths += "C:\Program Files (x86)\Microsoft\WindowsApps\winget.exe"
            $paths += "$env:USERPROFILE\AppData\Local\Microsoft\WindowsApps\winget.exe"
        }
    }
    
    return $paths | Where-Object { $_ -ne $null -and $_ -ne "" }
}

function Test-ComponentInstalled {
    <#
    .SYNOPSIS
    Tests if a component is installed using dynamic path detection
    #>
    param(
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$Component
    )
    
    if ($Component.commands.check) {
        try {
            # Try the check command
            $result = Invoke-Expression $Component.commands.check 2>&1
            if ($LASTEXITCODE -eq 0 -or $null -eq $LASTEXITCODE) {
                return $true
            }
        }
        catch {
            # If check command fails, try alternative detection methods
            Write-Host "Check command failed for $($Component.displayName), trying alternative detection..." -ForegroundColor Yellow
        }
    }
    
    # Dynamic detection methods for common tools
    $componentName = $Component.name.ToLower()
    
    # Check for Python
    if ($componentName -eq "python") {
        $pythonPaths = Get-DynamicPaths -ToolType "Python"
        foreach ($path in $pythonPaths) {
            if (Test-Path $path) {
                return $true
            }
        }
    }
    
    # Check for pip-based tools using dynamic detection
    if ($componentName -in @("jupyter", "tensorflow", "pytorch", "pandas", "ansible")) {
        $sitePackagesPaths = Get-DynamicPaths -ToolType "PythonSitePackages"
        foreach ($pythonPath in $sitePackagesPaths) {
            if (Test-Path $pythonPath) {
                $packagePath = Join-Path $pythonPath $componentName
                if (Test-Path $packagePath) {
                    return $true
                }
            }
        }
    }
    
    # Check for Chocolatey packages using dynamic detection
    if ($componentName -in @("docker", "mongodb", "jenkins", "terraform", "aws-cli", "azure-cli")) {
        $chocoPaths = Get-DynamicPaths -ToolType "Chocolatey"
        foreach ($chocoPath in $chocoPaths) {
            if ($chocoPath -like "*\lib") {
                $packagePath = Join-Path $chocoPath $componentName
                if (Test-Path $packagePath) {
                    return $true
                }
            }
        }
    }
    
    # Check for Node.js tools using dynamic detection
    if ($componentName -in @("nodejs", "yarn", "react-tools", "vue-tools", "angular-tools", "vite")) {
        if ($componentName -eq "nodejs") {
            $nodePaths = Get-DynamicPaths -ToolType "NodeJS"
            foreach ($path in $nodePaths) {
                if (Test-Path $path) {
                    return $true
                }
            }
        } elseif ($componentName -eq "yarn") {
            $yarnPaths = @(
                "$env:USERPROFILE\AppData\Roaming\npm\yarn.cmd",
                "$env:USERPROFILE\AppData\Local\Yarn\bin\yarn.cmd"
            )
            foreach ($yarnPath in $yarnPaths) {
                if (Test-Path $yarnPath) {
                    return $true
                }
            }
        } else {
            $npmPaths = Get-DynamicPaths -ToolType "NPM"
            foreach ($npmPath in $npmPaths) {
                if (Test-Path $npmPath) {
                    $packagePath = Join-Path $npmPath "node_modules\$componentName"
                    if (Test-Path $packagePath) {
                        return $true
                    }
                }
            }
        }
    }
    
    # Check for common development tools
    if ($componentName -eq "chocolatey") {
        $chocoPaths = Get-DynamicPaths -ToolType "Chocolatey"
        foreach ($path in $chocoPaths) {
            if (Test-Path $path) { return $true }
        }
    }
    
    # Cloud CLIs and common global CLIs
    if ($componentName -eq "aws-cli") {
        $candidatePaths = @(
            "$env:USERPROFILE\.local\bin\aws.exe",
            "$env:USERPROFILE\.local\pipx\venvs\awscli\Scripts\aws.exe",
            "$env:USERPROFILE\scoop\shims\aws.exe"
        )
        foreach ($p in $candidatePaths) { if (Test-Path -LiteralPath $p -ErrorAction SilentlyContinue) { return $true } }
        if (Get-Command aws -ErrorAction SilentlyContinue) { return $true }
    }
    if ($componentName -eq "azure-cli") {
        $candidatePaths = @(
            "$env:USERPROFILE\scoop\apps\azure-cli\current\wbin\az.cmd",
            "$env:USERPROFILE\scoop\shims\az.cmd"
        )
        foreach ($p in $candidatePaths) { if (Test-Path -LiteralPath $p -ErrorAction SilentlyContinue) { return $true } }
        if (Get-Command az -ErrorAction SilentlyContinue) { return $true }
    }
    if ($componentName -eq "gcloud-cli") {
        $candidatePaths = @(
            "$env:LOCALAPPDATA\Google\Cloud SDK\google-cloud-sdk\bin\gcloud.cmd",
            "$env:PROGRAMFILES\Google\Cloud SDK\google-cloud-sdk\bin\gcloud.cmd",
            "$env:USERPROFILE\scoop\shims\gcloud.cmd"
        )
        foreach ($p in $candidatePaths) { if (Test-Path -LiteralPath $p -ErrorAction SilentlyContinue) { return $true } }
        if (Get-Command gcloud -ErrorAction SilentlyContinue) { return $true }
    }
    if ($componentName -eq "vercel-cli") {
        $npmBin = Join-Path $env:APPDATA "npm"
        $vercelCmd = Join-Path $npmBin "vercel.cmd"
        if (Test-Path -LiteralPath $vercelCmd -ErrorAction SilentlyContinue) { return $true }
        if (Get-Command vercel -ErrorAction SilentlyContinue) { return $true }
    }
    if ($componentName -eq "netlify-cli") {
        $npmBin = Join-Path $env:APPDATA "npm"
        $netlifyCmd = Join-Path $npmBin "netlify.cmd"
        if (Test-Path -LiteralPath $netlifyCmd -ErrorAction SilentlyContinue) { return $true }
        if (Get-Command netlify -ErrorAction SilentlyContinue) { return $true }
    }
    if ($componentName -eq "grok-cli") {
        $npmBin = Join-Path $env:APPDATA "npm"
        $grokCmd = Join-Path $npmBin "grok.cmd"
        if (Test-Path -LiteralPath $grokCmd -ErrorAction SilentlyContinue) { return $true }
        if (Get-Command grok -ErrorAction SilentlyContinue) { return $true }
    }
    if ($componentName -eq "scoop") {
        $scoopPaths = Get-DynamicPaths -ToolType "Scoop"
        foreach ($path in $scoopPaths) {
            if ($path -like "*scoop.ps1" -and (Test-Path $path)) { return $true }
        }
        if (Get-Command scoop -ErrorAction SilentlyContinue) { return $true }
    }
    if ($componentName -eq "winget") {
        $wingetPaths = Get-DynamicPaths -ToolType "WinGet"
        foreach ($path in $wingetPaths) {
            if (Test-Path $path) { return $true }
        }
        if (Get-Command winget -ErrorAction SilentlyContinue) { return $true }
    }

    if ($componentName -eq "git") {
        $gitPaths = @(
            "C:\Program Files\Git\bin\git.exe",
            "C:\Program Files (x86)\Git\bin\git.exe",
            "$env:USERPROFILE\AppData\Local\Programs\Git\bin\git.exe"
        )
        foreach ($gitPath in $gitPaths) {
            if (Test-Path $gitPath) {
                return $true
            }
        }
    }
    
    # Check for VS Code
    if ($componentName -eq "vscode") {
        $vscodePaths = @(
            "C:\Program Files\Microsoft VS Code\Code.exe",
            "C:\Program Files (x86)\Microsoft VS Code\Code.exe",
            "$env:USERPROFILE\AppData\Local\Programs\Microsoft VS Code\Code.exe"
        )
        foreach ($vscodePath in $vscodePaths) {
            if (Test-Path $vscodePath) {
                return $true
            }
        }
    }
    
    # Check for PowerShell
    if ($componentName -eq "powershell") {
        $pwshPaths = @(
            "C:\Program Files\PowerShell\7\pwsh.exe",
            "C:\Program Files (x86)\PowerShell\7\pwsh.exe"
        )
        foreach ($pwshPath in $pwshPaths) {
            if (Test-Path $pwshPath) {
                return $true
            }
        }
    }
    
    return $false
}

# Functions are available when dot-sourced

