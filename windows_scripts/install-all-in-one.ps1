# setupx All-in-One Installation Script
# Complete Windows development environment setup

#Requires -RunAsAdministrator

param(
    [switch]$Verbose,
    [switch]$NoConfirm,
    [switch]$MinimalInstall,
    [switch]$SkipAI
)

$ErrorActionPreference = "Continue"
$Green = "Green"
$Red = "Red"
$Yellow = "Yellow"
$Cyan = "Cyan"
$Magenta = "Magenta"

function Write-ColorOutput($Message, $Color = "White") {
    Write-Host $Message -ForegroundColor $Color
}

function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Show-Banner {
    Write-ColorOutput "`n" $White
    Write-ColorOutput " ███████╗███████╗████████╗██╗   ██╗██████╗ ██╗  ██╗" $Cyan
    Write-ColorOutput " ██╔════╝██╔════╝╚══██╔══╝██║   ██║██╔══██╗╚██╗██╔╝" $Cyan
    Write-ColorOutput " ███████╗█████╗     ██║   ██║   ██║██████╔╝ ╚███╔╝ " $Cyan
    Write-ColorOutput " ╚════██║██╔══╝     ██║   ██║   ██║██╔═══╝   ██╔██╗ " $Cyan
    Write-ColorOutput " ███████║███████╗   ██║   ╚██████╔╝██║      ██╔╝ ██╗" $Cyan
    Write-ColorOutput " ╚══════╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝      ╚═╝  ╚═╝" $Cyan
    Write-ColorOutput "`nWindows Development Environment Setup CLI" $White
    Write-ColorOutput "Transform your Windows machine into a complete development environment." $White
    Write-ColorOutput "`n"
}

function Install-PackageManagers {
    Write-ColorOutput "`n🔧 STEP 1: Installing Package Managers" $Magenta

    # Chocolatey
    if (-not (Get-Command "choco" -ErrorAction SilentlyContinue)) {
        Write-ColorOutput "Installing Chocolatey..." $Yellow
        try {
            Set-ExecutionPolicy Bypass -Scope Process -Force
            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
            iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
            Write-ColorOutput "✓ Chocolatey installed" $Green
        } catch {
            Write-ColorOutput "✗ Chocolatey installation failed" $Red
        }
    } else {
        Write-ColorOutput "✓ Chocolatey already installed" $Green
    }

    # Scoop
    if (-not (Get-Command "scoop" -ErrorAction SilentlyContinue)) {
        Write-ColorOutput "Installing Scoop..." $Yellow
        try {
            Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
            iwr -useb get.scoop.sh | iex
            scoop bucket add extras
            scoop bucket add versions
            Write-ColorOutput "✓ Scoop installed with extras bucket" $Green
        } catch {
            Write-ColorOutput "✗ Scoop installation failed" $Red
        }
    } else {
        Write-ColorOutput "✓ Scoop already installed" $Green
    }

    # Refresh environment
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
}

function Install-CoreTools {
    Write-ColorOutput "`n🛠️  STEP 2: Installing Core Development Tools" $Magenta

    $coreTools = @{
        "git" = @{ choco = "git"; winget = "Git.Git"; description = "Git Version Control" }
        "gh" = @{ choco = "gh"; winget = "GitHub.cli"; description = "GitHub CLI" }
        "vscode" = @{ choco = "vscode"; winget = "Microsoft.VisualStudioCode"; description = "Visual Studio Code" }
        "nodejs" = @{ choco = "nodejs"; winget = "OpenJS.NodeJS"; description = "Node.js & npm" }
        "python" = @{ choco = "python"; winget = "Python.Python.3.12"; description = "Python 3.12" }
        "7zip" = @{ choco = "7zip"; winget = "7zip.7zip"; description = "7-Zip Archive Tool" }
        "curl" = @{ choco = "curl"; winget = "cURL.cURL"; description = "cURL HTTP Client" }
        "wget" = @{ choco = "wget"; winget = "JernejSimoncic.Wget"; description = "Wget Download Tool" }
    }

    foreach ($tool in $coreTools.Keys) {
        Write-ColorOutput "Installing $($coreTools[$tool].description)..." $Yellow

        $installed = $false

        # Try WinGet first
        if ((Get-Command "winget" -ErrorAction SilentlyContinue) -and -not $installed) {
            try {
                winget install --id $coreTools[$tool].winget --silent --accept-source-agreements --accept-package-agreements
                $installed = $true
                Write-ColorOutput "✓ $($coreTools[$tool].description) installed via WinGet" $Green
            } catch {
                # Fallback to Chocolatey
            }
        }

        # Try Chocolatey if WinGet failed
        if ((Get-Command "choco" -ErrorAction SilentlyContinue) -and -not $installed) {
            try {
                choco install $coreTools[$tool].choco -y --no-progress
                $installed = $true
                Write-ColorOutput "✓ $($coreTools[$tool].description) installed via Chocolatey" $Green
            } catch {
                Write-ColorOutput "✗ Failed to install $($coreTools[$tool].description)" $Red
            }
        }
    }

    # Refresh environment
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    Start-Sleep -Seconds 5
}

function Install-WebDevelopment {
    Write-ColorOutput "`n🌐 STEP 3: Installing Web Development Tools" $Magenta

    # Global npm packages
    if (Get-Command "npm" -ErrorAction SilentlyContinue) {
        Write-ColorOutput "Installing global npm packages..." $Yellow

        $npmPackages = @(
            "yarn", "typescript", "ts-node", "@angular/cli", "create-react-app",
            "vue-cli", "nodemon", "live-server", "http-server", "webpack",
            "vite", "eslint", "prettier", "sass"
        )

        foreach ($package in $npmPackages) {
            try {
                npm install -g $package --silent
                Write-ColorOutput "✓ $package installed globally" $Green
            } catch {
                Write-ColorOutput "! Failed to install $package" $Red
            }
        }
    }

    # Browsers
    Write-ColorOutput "Installing modern browsers..." $Yellow

    $browsers = @{
        "googlechrome" = @{ winget = "Google.Chrome"; description = "Google Chrome" }
        "firefox" = @{ winget = "Mozilla.Firefox"; description = "Mozilla Firefox" }
    }

    foreach ($browser in $browsers.Keys) {
        try {
            if (Get-Command "winget" -ErrorAction SilentlyContinue) {
                winget install --id $browsers[$browser].winget --silent
            } elseif (Get-Command "choco" -ErrorAction SilentlyContinue) {
                choco install $browser -y --no-progress
            }
            Write-ColorOutput "✓ $($browsers[$browser].description) installed" $Green
        } catch {
            Write-ColorOutput "! Failed to install $($browsers[$browser].description)" $Red
        }
    }
}

function Install-MobileDevelopment {
    Write-ColorOutput "`n📱 STEP 4: Installing Mobile Development Tools" $Magenta

    # Flutter
    Write-ColorOutput "Installing Flutter..." $Yellow
    try {
        if (Get-Command "winget" -ErrorAction SilentlyContinue) {
            winget install --id Google.Flutter --silent
        } elseif (Get-Command "choco" -ErrorAction SilentlyContinue) {
            choco install flutter -y --no-progress
        }
        Write-ColorOutput "✓ Flutter installed" $Green
    } catch {
        Write-ColorOutput "! Flutter installation had issues" $Red
    }

    # Android Studio
    Write-ColorOutput "Installing Android Studio..." $Yellow
    try {
        if (Get-Command "winget" -ErrorAction SilentlyContinue) {
            winget install --id Google.AndroidStudio --silent
        } elseif (Get-Command "choco" -ErrorAction SilentlyContinue) {
            choco install androidstudio -y --no-progress
        }
        Write-ColorOutput "✓ Android Studio installed" $Green
    } catch {
        Write-ColorOutput "! Android Studio installation had issues" $Red
    }

    # React Native CLI
    if (Get-Command "npm" -ErrorAction SilentlyContinue) {
        try {
            npm install -g react-native-cli @react-native-community/cli
            Write-ColorOutput "✓ React Native CLI installed" $Green
        } catch {
            Write-ColorOutput "! React Native CLI installation failed" $Red
        }
    }
}

function Install-BackendDevelopment {
    Write-ColorOutput "`n🖥️  STEP 5: Installing Backend Development Tools" $Magenta

    # .NET SDK
    Write-ColorOutput "Installing .NET SDK..." $Yellow
    try {
        if (Get-Command "winget" -ErrorAction SilentlyContinue) {
            winget install --id Microsoft.DotNet.SDK.8 --silent
        } elseif (Get-Command "choco" -ErrorAction SilentlyContinue) {
            choco install dotnet -y --no-progress
        }
        Write-ColorOutput "✓ .NET SDK installed" $Green
    } catch {
        Write-ColorOutput "! .NET SDK installation had issues" $Red
    }

    # Java
    Write-ColorOutput "Installing Java JDK..." $Yellow
    try {
        if (Get-Command "winget" -ErrorAction SilentlyContinue) {
            winget install --id Oracle.JDK.19 --silent
        } elseif (Get-Command "choco" -ErrorAction SilentlyContinue) {
            choco install openjdk -y --no-progress
        }
        Write-ColorOutput "✓ Java JDK installed" $Green
    } catch {
        Write-ColorOutput "! Java JDK installation had issues" $Red
    }

    # Go
    if (-not $MinimalInstall) {
        Write-ColorOutput "Installing Go..." $Yellow
        try {
            if (Get-Command "winget" -ErrorAction SilentlyContinue) {
                winget install --id GoLang.Go --silent
            } elseif (Get-Command "choco" -ErrorAction SilentlyContinue) {
                choco install golang -y --no-progress
            }
            Write-ColorOutput "✓ Go installed" $Green
        } catch {
            Write-ColorOutput "! Go installation had issues" $Red
        }
    }

    # Rust
    if (-not $MinimalInstall) {
        Write-ColorOutput "Installing Rust..." $Yellow
        try {
            if (Get-Command "winget" -ErrorAction SilentlyContinue) {
                winget install --id Rustlang.Rust.MSVC --silent
            } elseif (Get-Command "choco" -ErrorAction SilentlyContinue) {
                choco install rust -y --no-progress
            }
            Write-ColorOutput "✓ Rust installed" $Green
        } catch {
            Write-ColorOutput "! Rust installation had issues" $Red
        }
    }
}

function Install-CloudTools {
    Write-ColorOutput "`n☁️  STEP 6: Installing Cloud Development Tools" $Magenta

    $cloudTools = @{
        "awscli" = @{ winget = "Amazon.AWSCLI"; description = "AWS CLI" }
        "azure-cli" = @{ winget = "Microsoft.AzureCLI"; description = "Azure CLI" }
        "gcloudsdk" = @{ winget = "Google.CloudSDK"; description = "Google Cloud SDK" }
        "kubernetes-cli" = @{ winget = "Kubernetes.kubectl"; description = "Kubernetes CLI" }
    }

    foreach ($tool in $cloudTools.Keys) {
        if ($MinimalInstall -and $tool -notin @("awscli", "azure-cli")) { continue }

        Write-ColorOutput "Installing $($cloudTools[$tool].description)..." $Yellow
        try {
            if (Get-Command "winget" -ErrorAction SilentlyContinue) {
                winget install --id $cloudTools[$tool].winget --silent
            } elseif (Get-Command "choco" -ErrorAction SilentlyContinue) {
                choco install $tool -y --no-progress
            }
            Write-ColorOutput "✓ $($cloudTools[$tool].description) installed" $Green
        } catch {
            Write-ColorOutput "! $($cloudTools[$tool].description) installation had issues" $Red
        }
    }
}

function Install-ContainerTools {
    Write-ColorOutput "`n🐳 STEP 7: Installing Container Development Tools" $Magenta

    # Docker Desktop
    Write-ColorOutput "Installing Docker Desktop..." $Yellow
    try {
        if (Get-Command "winget" -ErrorAction SilentlyContinue) {
            winget install --id Docker.DockerDesktop --silent
        } elseif (Get-Command "choco" -ErrorAction SilentlyContinue) {
            choco install docker-desktop -y --no-progress
        }
        Write-ColorOutput "✓ Docker Desktop installed" $Green
        Write-ColorOutput "  Note: You may need to restart after installation" $Yellow
    } catch {
        Write-ColorOutput "! Docker Desktop installation had issues" $Red
    }
}

function Install-DatabaseTools {
    if ($MinimalInstall) { return }

    Write-ColorOutput "`n🗄️  STEP 8: Installing Database Tools" $Magenta

    $dbTools = @{
        "mysql" = @{ winget = "Oracle.MySQL"; description = "MySQL Server" }
        "postgresql" = @{ winget = "PostgreSQL.PostgreSQL"; description = "PostgreSQL" }
        "mongodb" = @{ winget = "MongoDB.Server"; description = "MongoDB" }
    }

    foreach ($tool in $dbTools.Keys) {
        Write-ColorOutput "Installing $($dbTools[$tool].description)..." $Yellow
        try {
            if (Get-Command "winget" -ErrorAction SilentlyContinue) {
                winget install --id $dbTools[$tool].winget --silent
            } elseif (Get-Command "choco" -ErrorAction SilentlyContinue) {
                choco install $tool -y --no-progress
            }
            Write-ColorOutput "✓ $($dbTools[$tool].description) installed" $Green
        } catch {
            Write-ColorOutput "! $($dbTools[$tool].description) installation had issues" $Red
        }
    }
}

function Install-AITools {
    if ($SkipAI -or $MinimalInstall) { return }

    Write-ColorOutput "`n🤖 STEP 9: Installing AI/ML Development Tools" $Magenta

    # Python AI packages
    if (Get-Command "pip" -ErrorAction SilentlyContinue) {
        Write-ColorOutput "Installing AI/ML Python packages..." $Yellow

        $aiPackages = @(
            "jupyter", "jupyterlab", "numpy", "pandas", "matplotlib",
            "seaborn", "scikit-learn", "tensorflow", "torch", "transformers"
        )

        foreach ($package in $aiPackages) {
            try {
                pip install $package --upgrade --quiet
                Write-ColorOutput "✓ $package installed" $Green
            } catch {
                Write-ColorOutput "! Failed to install $package" $Red
            }
        }
    }
}

function Install-AdditionalTools {
    Write-ColorOutput "`n🔧 STEP 10: Installing Additional Development Tools" $Magenta

    $additionalTools = @{
        "postman" = @{ winget = "Postman.Postman"; description = "Postman API Client" }
        "insomnia" = @{ winget = "Insomnia.Insomnia"; description = "Insomnia REST Client" }
        "dbeaver" = @{ winget = "dbeaver.dbeaver"; description = "DBeaver Database Tool" }
        "filezilla" = @{ winget = "TimKosse.FileZilla.Client"; description = "FileZilla FTP Client" }
    }

    foreach ($tool in $additionalTools.Keys) {
        if ($MinimalInstall -and $tool -notin @("postman")) { continue }

        Write-ColorOutput "Installing $($additionalTools[$tool].description)..." $Yellow
        try {
            if (Get-Command "winget" -ErrorAction SilentlyContinue) {
                winget install --id $additionalTools[$tool].winget --silent
            } elseif (Get-Command "choco" -ErrorAction SilentlyContinue) {
                choco install $tool -y --no-progress
            }
            Write-ColorOutput "✓ $($additionalTools[$tool].description) installed" $Green
        } catch {
            Write-ColorOutput "! $($additionalTools[$tool].description) installation had issues" $Red
        }
    }
}

function Show-CompletionSummary {
    Write-ColorOutput "`n" $White
    Write-ColorOutput "🎉 INSTALLATION COMPLETE! 🎉" $Green
    Write-ColorOutput "`nYour Windows machine has been transformed into a complete development environment!" $Green

    Write-ColorOutput "`n=== INSTALLED COMPONENTS ===" $Cyan
    Write-ColorOutput "📦 Package Managers: Chocolatey, Scoop, WinGet" $White
    Write-ColorOutput "🛠️  Core Tools: Git, VS Code, Node.js, Python" $White
    Write-ColorOutput "🌐 Web Development: npm packages, modern browsers" $White
    Write-ColorOutput "📱 Mobile Development: Flutter, Android Studio, React Native" $White
    Write-ColorOutput "🖥️  Backend: .NET, Java" $White
    Write-ColorOutput "☁️  Cloud Tools: AWS CLI, Azure CLI, Google Cloud SDK" $White
    Write-ColorOutput "🐳 Container Tools: Docker Desktop" $White

    if (-not $MinimalInstall) {
        Write-ColorOutput "🗄️  Database Tools: MySQL, PostgreSQL, MongoDB" $White
        Write-ColorOutput "🔧 Additional Tools: Postman, DBeaver, FileZilla" $White
    }

    if (-not $SkipAI -and -not $MinimalInstall) {
        Write-ColorOutput "🤖 AI/ML Tools: Jupyter, TensorFlow, PyTorch" $White
    }

    Write-ColorOutput "`n=== NEXT STEPS ===" $Cyan
    Write-ColorOutput "1. 🔄 Restart your computer to ensure all tools work properly" $White
    Write-ColorOutput "2. 🖥️  Open VS Code and install additional extensions as needed" $White
    Write-ColorOutput "3. 🐳 Configure Docker Desktop after restart" $White
    Write-ColorOutput "4. 📱 Open Android Studio and complete setup wizard" $White
    Write-ColorOutput "5. ☁️  Configure cloud CLIs with your credentials" $White
    Write-ColorOutput "6. 🧪 Test your setup by creating a sample project" $White

    Write-ColorOutput "`n=== USEFUL COMMANDS ===" $Cyan
    Write-ColorOutput "🔍 Check installed tools:" $White
    Write-ColorOutput "  git --version && node --version && python --version" $Yellow
    Write-ColorOutput "  flutter doctor" $Yellow
    Write-ColorOutput "  docker --version" $Yellow

    Write-ColorOutput "`n💡 Pro Tips:" $White
    Write-ColorOutput "• Use 'winget search <tool>' to find and install more software" $White
    Write-ColorOutput "• Use 'choco search <tool>' for Chocolatey packages" $White
    Write-ColorOutput "• Keep tools updated with 'winget upgrade --all'" $White
    Write-ColorOutput "• Join developer communities and keep learning!" $White
}

function Main {
    Show-Banner

    if (-not (Test-Administrator)) {
        Write-ColorOutput "✗ This script requires Administrator privileges. Please run as Administrator." $Red
        Write-ColorOutput "Right-click on PowerShell and select 'Run as Administrator'" $Yellow
        exit 1
    }

    if (-not $NoConfirm) {
        Write-ColorOutput "This will install a complete development environment on your Windows machine." $White
        Write-ColorOutput "The installation may take 30-60 minutes depending on your internet connection." $White
        Write-ColorOutput "`nOptions:" $Cyan
        Write-ColorOutput "• Use -MinimalInstall for basic tools only" $White
        Write-ColorOutput "• Use -SkipAI to skip AI/ML packages" $White

        $continue = Read-Host "`nDo you want to continue? (y/N)"
        if ($continue -ne "y" -and $continue -ne "Y") {
            Write-ColorOutput "Installation cancelled." $Yellow
            exit 0
        }
    }

    $startTime = Get-Date

    try {
        Install-PackageManagers
        Install-CoreTools
        Install-WebDevelopment
        Install-MobileDevelopment
        Install-BackendDevelopment
        Install-CloudTools
        Install-ContainerTools
        Install-DatabaseTools
        Install-AITools
        Install-AdditionalTools

        $endTime = Get-Date
        $duration = $endTime - $startTime

        Show-CompletionSummary
        Write-ColorOutput "`n⏱️  Total installation time: $($duration.ToString('hh\:mm\:ss'))" $Cyan

    } catch {
        Write-ColorOutput "`n✗ Installation failed: $($_.Exception.Message)" $Red
        Write-ColorOutput "Please check the error message above and try again." $Yellow
        exit 1
    }
}

# Run the main installation
Main

Write-ColorOutput "`nPress any key to exit..." $Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")