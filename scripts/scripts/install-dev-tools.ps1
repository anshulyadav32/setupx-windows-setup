# Install common developer tools on Windows: Chocolatey, winget, terminals,
# PowerToys, Git, GitHub CLI, Python, Node.js LTS 24, AI CLIs, Warp, and Scoop

# In PowerShell 7+, non-zero native exits can become terminating errors.
# Disable that behavior for this installer so we can handle fallbacks explicitly.
if (Get-Variable PSNativeCommandUseErrorActionPreference -ErrorAction SilentlyContinue) {
    $global:PSNativeCommandUseErrorActionPreference = $false
}

# Run as Administrator (required for Chocolatey package installs)
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)

if (-not $isAdmin) {
    Write-Error "Please run this script as Administrator."
    exit 1
}

function Install-Chocolatey {
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-Host "Chocolatey is already installed."
        return
    }

    Write-Host "Installing Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Host "Chocolatey installation failed."
        exit 1
    }
}

function Install-WithChocolatey {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PackageName,
        [string]$DisplayName = $PackageName,
        [string]$Version
    )

    Write-Host "Installing $DisplayName with Chocolatey..."
    $chocoArgs = @('install', $PackageName, '-y', '--no-progress')
    if ($Version) {
        $chocoArgs += "--version=$Version"
    }

    $output = & choco @chocoArgs 2>&1
    $exitCode = $LASTEXITCODE

    if ($output) {
        $output | ForEach-Object { Write-Host $_ }
    }

    if ($exitCode -ne 0 -and -not ($output -match 'already installed')) {
        Write-Host "Failed to install $DisplayName (package: $PackageName)."
        exit 1
    }
}

function Install-WithChocolateyOptional {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PackageName,
        [string]$DisplayName = $PackageName
    )

    Write-Host "Installing $DisplayName with Chocolatey (optional)..."
    $output = choco install $PackageName -y --no-progress 2>&1
    $exitCode = $LASTEXITCODE

    if ($output) {
        $output | ForEach-Object { Write-Host $_ }
    }

    if ($exitCode -ne 0 -and -not ($output -match 'already installed')) {
        Write-Host "$DisplayName install failed; continuing."
    }
}

function Install-Winget {
    $os = Get-CimInstance Win32_OperatingSystem
    $buildNumber = [int]$os.BuildNumber
    if ($buildNumber -lt 18362) {
        Write-Host "winget requires Windows build 18362+ in practice. Skipping winget on this machine."
        return
    }

    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "winget is already installed."
        return
    }

    Write-Host "Installing winget with Chocolatey..."

    $output = choco install winget-cli -y --no-progress 2>&1
    $exitCode = $LASTEXITCODE

    if ($output) {
        $output | ForEach-Object { Write-Host $_ }
    }

    if ($exitCode -ne 0) {
        Write-Host "winget-cli package failed, trying microsoft-winget package..."
        $output = choco install microsoft-winget -y --no-progress 2>&1
        $exitCode = $LASTEXITCODE

        if ($output) {
            $output | ForEach-Object { Write-Host $_ }
        }
    }

    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Host "winget installation did not complete. Continuing with remaining tools."
    }
}

function Install-Warp {
    $os = Get-CimInstance Win32_OperatingSystem
    $buildNumber = [int]$os.BuildNumber
    if ($buildNumber -lt 18363) {
        Write-Host "Warp requires Windows 10/11 build 1909+ (18363+). Skipping Warp on this machine."
        return
    }

    Write-Host "Installing Warp terminal..."

    # Prefer Chocolatey package when available
    $output = choco install warp-terminal -y --no-progress 2>&1
    $exitCode = $LASTEXITCODE

    if ($output) {
        $output | ForEach-Object { Write-Host $_ }
    }

    if ($exitCode -eq 0 -or ($output -match 'already installed')) {
        Write-Host "Warp installed using Chocolatey package warp-terminal."
        return
    }

    # Fallback to winget if Chocolatey package is unavailable in this environment
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "Chocolatey Warp package failed, trying winget..."
        winget install -e --id Warp.Warp --accept-source-agreements --accept-package-agreements 2>&1 | ForEach-Object { Write-Host $_ }
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Warp installed using winget."
            return
        }
    }

    Write-Host "Warp installation failed using both Chocolatey and winget. Continuing with remaining tools."
}

function Install-WindowsTerminal {
    $os = Get-CimInstance Win32_OperatingSystem
    $buildNumber = [int]$os.BuildNumber
    if ($buildNumber -lt 18362) {
        Write-Host "Windows Terminal requires Windows 10 version 1903 / build 18362+. Skipping."
        return
    }

    Install-WithChocolatey -PackageName "microsoft-windows-terminal" -DisplayName "Windows Terminal"
}

function Install-ExtraTerminal {
    # WezTerm is a good fallback terminal on Server/older builds.
    Install-WithChocolateyOptional -PackageName "wezterm" -DisplayName "WezTerm"
}

function Install-PowerToys {
    Install-WithChocolateyOptional -PackageName "powertoys" -DisplayName "Microsoft PowerToys"
}

function Install-NodeLts24 {
    $resolvedVersion = $null
    $searchOutput = choco search nodejs-lts --exact --all-versions 2>&1

    if ($searchOutput) {
        $match = $searchOutput | Select-String -Pattern '^nodejs-lts 24\.' | Select-Object -First 1
        if ($match) {
            $parts = ($match.ToString() -split '\s+')
            if ($parts.Length -ge 2) {
                $resolvedVersion = $parts[1]
            }
        }
    }

    if ($resolvedVersion) {
        Write-Host "Resolved Node.js LTS 24 version: $resolvedVersion"
        Install-WithChocolatey -PackageName "nodejs-lts" -DisplayName "Node.js LTS 24" -Version $resolvedVersion
    } else {
        Write-Host "Could not resolve a specific 24.x version; installing latest nodejs-lts package."
        Install-WithChocolatey -PackageName "nodejs-lts" -DisplayName "Node.js LTS"
    }

    if (Get-Command node -ErrorAction SilentlyContinue) {
        $nodeVersionRaw = node --version
        $major = ($nodeVersionRaw.TrimStart('v').Split('.')[0])
        if ($major -ne '24') {
            Write-Host "Expected Node major version 24, but found $nodeVersionRaw"
            exit 1
        }
        Write-Host "Node.js LTS 24 is installed: $nodeVersionRaw"
    } else {
        Write-Host "Node.js command not found after installation."
        exit 1
    }
}

function Install-Scoop {
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        Write-Host "Scoop is already installed."
        return
    }

    Write-Host "Installing Scoop..."
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    iwr -useb get.scoop.sh | iex

    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        Write-Host "Scoop installation may require a new terminal session."
        Write-Host "Reopen PowerShell and run: scoop --version"
    } else {
        Write-Host "Scoop installed successfully."
    }
}

function Install-Python {
    Install-WithChocolatey -PackageName "python" -DisplayName "Python"
}

function Install-NpmCliTools {
    if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
        Write-Host "npm is not available; skipping npm CLI tools."
        return
    }

    $cliPackages = @(
        @{ Name = "Gemini CLI"; Package = "@google/gemini-cli" },
        @{ Name = "Codex CLI"; Package = "@openai/codex" },
        @{ Name = "Claude CLI"; Package = "@anthropic-ai/claude-code" },
        @{ Name = "Vercel CLI"; Package = "vercel" }
    )

    foreach ($cli in $cliPackages) {
        Write-Host "Installing $($cli.Name) via npm..."
        npm install -g $cli.Package 2>&1 | ForEach-Object { Write-Host $_ }
        if ($LASTEXITCODE -ne 0) {
            Write-Host "$($cli.Name) install failed; continuing."
        }
    }
}

Install-Chocolatey
Install-Winget
Install-WindowsTerminal
Install-ExtraTerminal
Install-PowerToys
Install-WithChocolatey -PackageName "git" -DisplayName "Git"
Install-WithChocolatey -PackageName "gh" -DisplayName "GitHub CLI"
Install-Python
Install-NodeLts24
Install-NpmCliTools
Install-Warp
Install-Scoop

Write-Host "All requested tool installations completed."
Write-Host "If any command is not recognized yet, restart your terminal."
