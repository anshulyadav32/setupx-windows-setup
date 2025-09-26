# SetupX - Modular Windows Development Setup

A clean, modular PowerShell tool for setting up Windows development environments.

## 🚀 Quick Start

### One-Command Installation
```powershell
Invoke-RestMethod -Uri https://raw.githubusercontent.com/anshulyadav32/setupx-windows-setup/main/install.ps1 | Invoke-Expression
```

### Force Installation (No Prompts)
```powershell
iwr https://raw.githubusercontent.com/anshulyadav32/setupx-windows-setup/main/install.ps1 | iex -Force
```

### Manual Installation
```powershell
git clone https://github.com/anshulyadav32/setupx-windows-setup.git
cd setupx-windows-setup
.\install.ps1
```

### Alternative Installation Methods
```powershell
# Direct download and run
iwr https://raw.githubusercontent.com/anshulyadav32/setupx-windows-setup/main/install.ps1 | iex

# Force installation (overwrites existing)
iwr https://raw.githubusercontent.com/anshulyadav32/setupx-windows-setup/main/install.ps1 | iex -Force

# Using curl (if available)
curl -sSL https://raw.githubusercontent.com/anshulyadav32/setupx-windows-setup/main/install.ps1 | powershell
```

## 📁 Clean Structure

```
setupx/
├── setupx.ps1                    # Main entry point
├── install.ps1                  # Complete installer (downloads everything)
├── src/                          # Source code
│   ├── core/                     # Core functionality
│   │   ├── module-manager.ps1   # Module management
│   │   └── package-manager.ps1  # Package manager operations
│   ├── cli/                      # Command line interface
│   │   └── setupx-cli.ps1       # Main CLI
│   ├── utils/                    # Utilities
│   │   ├── logger.ps1           # Logging
│   │   └── helpers.ps1          # Helper functions
│   ├── installers/               # Installation logic
│   │   └── setupx-installer.ps1 # SetupX installer
│   ├── config/                   # Configuration
│   │   └── setupx.json          # Main config
│   └── modules/                  # Development modules
│       ├── package-managers/     # Package managers
│       ├── web-development/      # Web dev tools
│       ├── mobile-development/  # Mobile dev tools
│       ├── backend-development/ # Backend dev tools
│       ├── cloud-development/   # Cloud dev tools
│       └── common-development/  # Common tools
└── README.md                     # This file
```

## 🎯 Usage

```powershell
# Show help
setupx -h

# List all modules
setupx list

# Show system status
setupx status

# Install a module
setupx install package-managers

# Show module components
setupx components package-managers

# Interactive menu
setupx menu
```

## 📦 Available Modules

- **package-managers**: WinGet, Chocolatey, Scoop, NPM
- **web-development**: Node.js, Browsers, VS Code
- **mobile-development**: Flutter, Android Studio, Xcode
- **backend-development**: Python, Node.js, Docker, PostgreSQL
- **cloud-development**: AWS CLI, Azure CLI, Docker, Kubernetes
- **common-development**: Git, VS Code, PowerShell, Terminal

## 🔧 Features

- ✅ **Modular Architecture**: Clean, organized code structure
- ✅ **Package Manager Support**: WinGet, Chocolatey, Scoop, NPM
- ✅ **Development Modules**: Web, Mobile, Backend, Cloud, Common
- ✅ **Status Checking**: Comprehensive system status
- ✅ **Interactive Menu**: User-friendly interface
- ✅ **Error Handling**: Robust error handling and logging
- ✅ **One-Command Install**: Single `install.ps1` downloads everything
- ✅ **Force Mode**: `-Force` parameter for automated installations
- ✅ **Existing File Detection**: Handles `C:\setupx` conflicts gracefully
- ✅ **Clean Structure**: Minimal, maintainable codebase

## 🏗️ Architecture

### Core Modules
- **Module Manager**: Discovers and manages development modules
- **Package Manager**: Handles package manager operations
- **CLI**: Command-line interface with all commands
- **Logger**: Consistent logging across all components
- **Helpers**: Common utility functions

### Benefits
- **Separation of Concerns**: Each module has a single responsibility
- **Reusability**: Utility functions shared across modules
- **Maintainability**: Easy to maintain and debug
- **Scalability**: Easy to add new modules and features

## ⚙️ Installation Options

### Standard Installation
- Downloads all files from GitHub
- Asks for confirmation if `C:\setupx` exists
- Safe for first-time installations

### Force Installation
- Downloads all files from GitHub
- Overwrites existing installation without prompts
- Perfect for automated scripts and updates

### Local Installation
- Clone repository and run `install.ps1`
- Useful for development and customization
- Full control over installation process

## 📋 Requirements

- Windows 10/11
- PowerShell 5.1 or later
- Internet connection for installation

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

MIT License - see LICENSE file for details

## 🔧 Troubleshooting

### Common Issues

**❌ "404: Not Found" Error**
- **Problem**: Using old `one-cmd-install.ps1` URL
- **Solution**: Use the new `install.ps1` URL:
  ```powershell
  Invoke-RestMethod -Uri https://raw.githubusercontent.com/anshulyadav32/setupx-windows-setup/main/install.ps1 | Invoke-Expression
  ```

**❌ "setupx command not found"**
- **Problem**: PATH not updated in current session
- **Solution**: Restart PowerShell or run:
  ```powershell
  refreshenv
  ```

**❌ "Module not found" after installation**
- **Problem**: Installation didn't complete properly
- **Solution**: Reinstall with force mode:
  ```powershell
  iwr https://raw.githubusercontent.com/anshulyadav32/setupx-windows-setup/main/install.ps1 | iex -Force
  ```

**❌ Emoji parsing errors**
- **Problem**: PowerShell version compatibility
- **Solution**: Use the latest `install.ps1` (emoji-free version)

### Installation Methods

**✅ Recommended (Latest)**
```powershell
iwr https://raw.githubusercontent.com/anshulyadav32/setupx-windows-setup/main/install.ps1 | iex
```

**✅ Force Installation (No Prompts)**
```powershell
iwr https://raw.githubusercontent.com/anshulyadav32/setupx-windows-setup/main/install.ps1 | iex -Force
```

## 🆘 Support

- **Issues**: [GitHub Issues](https://github.com/anshulyadav32/setupx-windows-setup/issues)
- **Documentation**: [GitHub Wiki](https://github.com/anshulyadav32/setupx-windows-setup/wiki)
- **Discussions**: [GitHub Discussions](https://github.com/anshulyadav32/setupx-windows-setup/discussions)

---

**SetupX** - Making Windows development setup simple and modular! 🚀