# Enhanced Visual Studio Code Installation Script
# Installs VS Code with essential extensions and configurations

#Requires -RunAsAdministrator

param([switch]$Verbose)

$ErrorActionPreference = "Continue"
$Green = "Green"
$Red = "Red"
$Yellow = "Yellow"
$Cyan = "Cyan"

function Write-ColorOutput($Message, $Color = "White") {
    Write-Host $Message -ForegroundColor $Color
}

function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Install-VSCodeEnhanced {
    Write-ColorOutput "`n=== Installing Visual Studio Code (Enhanced) ===" $Cyan

    if (-not (Test-Administrator)) {
        Write-ColorOutput "✗ This script requires Administrator privileges." $Red
        exit 1
    }

    # Check if already installed
    if (Get-Command "code" -ErrorAction SilentlyContinue) {
        $version = code --version | Select-Object -First 1
        Write-ColorOutput "✓ Visual Studio Code is already installed: $version" $Green

        $update = Read-Host "Do you want to update VS Code and install extensions? (y/n)"
        if ($update -ne "y" -and $update -ne "Y") {
            return
        }
    } else {
        Write-ColorOutput "Installing Visual Studio Code..." $Yellow

        # Try WinGet first
        if (Get-Command "winget" -ErrorAction SilentlyContinue) {
            try {
                winget install --id Microsoft.VisualStudioCode --silent --accept-source-agreements --accept-package-agreements
                Write-ColorOutput "✓ Visual Studio Code installed via WinGet" $Green
            } catch {
                Write-ColorOutput "! WinGet installation failed, trying Chocolatey..." $Yellow

                # Fallback to Chocolatey
                if (Get-Command "choco" -ErrorAction SilentlyContinue) {
                    choco install vscode -y
                    Write-ColorOutput "✓ Visual Studio Code installed via Chocolatey" $Green
                } else {
                    Write-ColorOutput "✗ Failed to install Visual Studio Code" $Red
                    return
                }
            }
        } elseif (Get-Command "choco" -ErrorAction SilentlyContinue) {
            choco install vscode -y
            Write-ColorOutput "✓ Visual Studio Code installed via Chocolatey" $Green
        } else {
            Write-ColorOutput "✗ No package manager available. Please install Chocolatey or WinGet first." $Red
            return
        }

        # Refresh environment
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

        # Wait for installation to complete
        Start-Sleep -Seconds 10
    }

    # Verify VS Code is available
    if (-not (Get-Command "code" -ErrorAction SilentlyContinue)) {
        Write-ColorOutput "✗ VS Code installation verification failed" $Red
        return
    }

    # Install essential extensions
    Write-ColorOutput "`n=== Installing Essential Extensions ===" $Cyan

    $essentialExtensions = @(
        "ms-python.python",                    # Python
        "ms-vscode.cpptools",                  # C/C++
        "ms-dotnettools.csharp",               # C#
        "golang.go",                           # Go
        "rust-lang.rust-analyzer",            # Rust
        "bradlc.vscode-tailwindcss",           # Tailwind CSS
        "esbenp.prettier-vscode",              # Prettier
        "ms-vscode.vscode-eslint",             # ESLint
        "formulahendry.auto-rename-tag",       # Auto Rename Tag
        "ms-vscode.vscode-json",               # JSON
        "redhat.vscode-yaml",                  # YAML
        "ms-vscode.powershell",                # PowerShell
        "ms-vscode-remote.remote-wsl"          # WSL
    )

    $webExtensions = @(
        "ms-vscode.vscode-typescript-next",    # TypeScript
        "ms-vscode.vscode-js-debug",           # JavaScript Debugger
        "formulahendry.auto-close-tag",        # Auto Close Tag
        "christian-kohler.path-intellisense",  # Path IntelliSense
        "htmltagwrap.htmltagwrap",             # HTML Tag Wrap
        "ms-vscode.vscode-css-peek",           # CSS Peek
        "bradlc.vscode-tailwindcss"            # Tailwind CSS IntelliSense
    )

    $mobileDevelopmentExtensions = @(
        "dart-code.dart-code",                 # Dart
        "dart-code.flutter",                   # Flutter
        "ms-vscode.vscode-react-native",       # React Native Tools
        "msjsdiag.vscode-react-native"         # React Native Tools (Alternative)
    )

    $utilityExtensions = @(
        "ms-vsliveshare.vsliveshare",          # Live Share
        "gitpod.gitpod-desktop",               # Gitpod
        "ms-vscode-remote.remote-containers",  # Dev Containers
        "ms-vscode-remote.remote-ssh",         # Remote SSH
        "ms-vscode.hexeditor",                 # Hex Editor
        "ms-vscode.live-server",               # Live Server
        "ritwickdey.liveserver"                # Live Server (Alternative)
    )

    $themeExtensions = @(
        "monokai.theme-monokai-pro-vscode",    # Monokai Pro
        "github.github-vscode-theme",          # GitHub Theme
        "dracula-theme.theme-dracula",         # Dracula
        "pkief.material-icon-theme",           # Material Icon Theme
        "ms-vscode.theme-predawn"              # Predawn Theme
    )

    Write-ColorOutput "Installing essential programming extensions..." $Yellow
    foreach ($extension in $essentialExtensions) {
        try {
            code --install-extension $extension --force
            Write-ColorOutput "✓ Installed: $extension" $Green
        } catch {
            Write-ColorOutput "! Failed to install: $extension" $Red
        }
    }

    Write-ColorOutput "`nInstalling web development extensions..." $Yellow
    foreach ($extension in $webExtensions) {
        try {
            code --install-extension $extension --force
            Write-ColorOutput "✓ Installed: $extension" $Green
        } catch {
            Write-ColorOutput "! Failed to install: $extension" $Red
        }
    }

    Write-ColorOutput "`nInstalling mobile development extensions..." $Yellow
    foreach ($extension in $mobileDevelopmentExtensions) {
        try {
            code --install-extension $extension --force
            Write-ColorOutput "✓ Installed: $extension" $Green
        } catch {
            Write-ColorOutput "! Failed to install: $extension" $Red
        }
    }

    Write-ColorOutput "`nInstalling utility extensions..." $Yellow
    foreach ($extension in $utilityExtensions) {
        try {
            code --install-extension $extension --force
            Write-ColorOutput "✓ Installed: $extension" $Green
        } catch {
            Write-ColorOutput "! Failed to install: $extension" $Red
        }
    }

    Write-ColorOutput "`nInstalling theme extensions..." $Yellow
    foreach ($extension in $themeExtensions) {
        try {
            code --install-extension $extension --force
            Write-ColorOutput "✓ Installed: $extension" $Green
        } catch {
            Write-ColorOutput "! Failed to install: $extension" $Red
        }
    }

    # Create enhanced settings.json
    Write-ColorOutput "`n=== Configuring VS Code Settings ===" $Cyan

    $settingsPath = "$env:APPDATA\Code\User"
    if (-not (Test-Path $settingsPath)) {
        New-Item -Path $settingsPath -ItemType Directory -Force | Out-Null
    }

    $settingsFile = "$settingsPath\settings.json"
    $enhancedSettings = @'
{
    "workbench.colorTheme": "GitHub Dark",
    "workbench.iconTheme": "material-icon-theme",
    "editor.fontSize": 14,
    "editor.fontFamily": "'Cascadia Code', 'Fira Code', Consolas, 'Courier New', monospace",
    "editor.fontLigatures": true,
    "editor.tabSize": 2,
    "editor.insertSpaces": true,
    "editor.wordWrap": "on",
    "editor.minimap.enabled": true,
    "editor.rulers": [80, 120],
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
        "source.organizeImports": true
    },
    "files.autoSave": "afterDelay",
    "files.autoSaveDelay": 1000,
    "explorer.confirmDelete": false,
    "explorer.confirmDragAndDrop": false,
    "terminal.integrated.fontSize": 12,
    "terminal.integrated.fontFamily": "'Cascadia Code'",
    "git.autofetch": true,
    "git.confirmSync": false,
    "emmet.includeLanguages": {
        "javascript": "javascriptreact",
        "typescript": "typescriptreact"
    },
    "prettier.singleQuote": true,
    "prettier.trailingComma": "es5",
    "python.defaultInterpreterPath": "python",
    "python.formatting.provider": "black",
    "python.linting.enabled": true,
    "python.linting.pylintEnabled": true,
    "[python]": {
        "editor.formatOnSave": true,
        "editor.tabSize": 4
    },
    "[javascript]": {
        "editor.formatOnSave": true,
        "editor.defaultFormatter": "esbenp.prettier-vscode"
    },
    "[typescript]": {
        "editor.formatOnSave": true,
        "editor.defaultFormatter": "esbenp.prettier-vscode"
    },
    "[html]": {
        "editor.formatOnSave": true,
        "editor.defaultFormatter": "esbenp.prettier-vscode"
    },
    "[css]": {
        "editor.formatOnSave": true,
        "editor.defaultFormatter": "esbenp.prettier-vscode"
    },
    "[json]": {
        "editor.formatOnSave": true,
        "editor.defaultFormatter": "esbenp.prettier-vscode"
    }
}
'@

    try {
        $enhancedSettings | Out-File -FilePath $settingsFile -Encoding UTF8 -Force
        Write-ColorOutput "✓ Enhanced settings.json configured" $Green
    } catch {
        Write-ColorOutput "! Failed to configure settings.json" $Yellow
    }

    Write-ColorOutput "`n=== Installation Complete ===" $Green
    Write-ColorOutput "Visual Studio Code has been enhanced with:" $Green

    Write-ColorOutput "`nExtensions installed:" $Cyan
    Write-ColorOutput "• Programming languages (Python, C/C++, C#, Go, Rust)" $White
    Write-ColorOutput "• Web development (TypeScript, HTML, CSS, React)" $White
    Write-ColorOutput "• Mobile development (Flutter, Dart, React Native)" $White
    Write-ColorOutput "• Utilities (Live Share, Remote Development, Git)" $White
    Write-ColorOutput "• Themes and icons for better visual experience" $White

    Write-ColorOutput "`nSettings configured:" $Cyan
    Write-ColorOutput "• GitHub Dark theme with Material Icon Theme" $White
    Write-ColorOutput "• Cascadia Code font with ligatures" $White
    Write-ColorOutput "• Auto-save and format on save enabled" $White
    Write-ColorOutput "• Enhanced terminal and editor settings" $White

    Write-ColorOutput "`n=== Next Steps ===" $Cyan
    Write-ColorOutput "• Restart VS Code to see all changes" $White
    Write-ColorOutput "• Customize settings further in File > Preferences > Settings" $White
    Write-ColorOutput "• Install additional extensions as needed" $White
    Write-ColorOutput "• Configure Git user name and email if not already done" $White
}

Install-VSCodeEnhanced
Write-ColorOutput "`nPress any key to exit..." $Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")