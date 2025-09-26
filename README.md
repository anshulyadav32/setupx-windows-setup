# SetupX Windows Development Environment Setup

A comprehensive modular Windows development environment setup tool that automates the installation and configuration of development tools, package managers, and frameworks.

## 🚀 Features

- **Modular Design**: 6 development modules with 43+ components
- **Package Manager Support**: WinGet, Chocolatey, and Scoop integration
- **CLI Interface**: Command-line interface for easy automation
- **Component Testing**: Automated testing and verification
- **Cross-Platform**: Flutter-based GUI with PowerShell backend

## 📦 Available Modules

### 1. Package Managers
Essential Windows package managers for software installation:
- **Chocolatey** - Community package manager
- **Scoop** - Portable application installer  
- **WinGet** - Microsoft official package manager
- **NPM** - Node Package Manager

### 2. Common Development
Essential development tools used across all programming languages:
- **Git** - Version control system
- **VSCode** - Source code editor
- **PowerShell** - Automation and configuration
- **Terminal** - Modern terminal application
- **Docker** - Containerization platform
- **Postman** - API development and testing
- **Compression Tools** - 7-Zip and WinRAR
- **Fonts** - Programming fonts (Fira Code, JetBrains Mono)

### 3. Web Development
Complete web development environment:
- **Node.js** - JavaScript runtime
- **Yarn** - Fast package manager
- **Browsers** - Chrome, Firefox, Edge
- **React Tools** - Create React App, DevTools
- **Vue Tools** - Vue CLI, DevTools
- **Angular Tools** - Angular CLI
- **Webpack Tools** - Modern build tools

### 4. Backend Development
Server-side development tools:
- **Python** - Programming language with pip
- **.NET** - Microsoft development framework
- **Node.js Backend** - Backend-specific packages
- **Go** - Google's programming language
- **Rust** - Systems programming language
- **PostgreSQL** - Advanced relational database
- **MySQL** - Popular relational database
- **MongoDB** - NoSQL document database
- **Redis** - In-memory data store

### 5. Cloud Development
Cloud platform tools and SDKs:
- **AWS CLI** - Amazon Web Services
- **Azure CLI** - Microsoft Azure
- **Google Cloud** - Google Cloud Platform
- **Kubernetes** - Container orchestration
- **Docker** - Containerization
- **Terraform** - Infrastructure as Code
- **Helm** - Kubernetes package manager

### 6. Mobile Development
Cross-platform mobile development:
- **Flutter** - Google's UI toolkit
- **Dart** - Flutter programming language
- **Android Studio** - Android development IDE
- **Android SDK** - Android development kit
- **ADB** - Android debugging bridge
- **React Native** - Cross-platform framework
- **Expo CLI** - React Native development tools
- **Java JDK** - Android development runtime

## 🛠️ Installation

### Prerequisites
- Windows 10/11
- PowerShell 5.1 or later
- Administrator privileges (for some installations)

### Quick Start

1. **Clone the repository:**
   ```bash
   git clone https://github.com/anshulyadav32/setupx-windows-setup.git
   cd setupx-windows-setup
   ```

2. **Run the setup:**
   ```powershell
   cd windows_scripts
   .\setupx-main.ps1 -h
   ```

## 📋 Usage

### Command Line Interface

#### Basic Commands

```powershell
# Show help and available commands
setupx -h
setupx --help

# List all available modules
setupx list

# Show system status and package managers
setupx status

# Interactive menu (recommended for beginners)
setupx menu
```

#### Module Management Commands

```powershell
# List components in a specific module
setupx components <module-name>

# Test components in a module
setupx test <module-name>

# Install a complete module
setupx install <module-name>
```

#### Available Modules

```powershell
# Package Managers Module
setupx components package-managers
setupx test package-managers
setupx install package-managers

# Common Development Module
setupx components common-development
setupx test common-development
setupx install common-development

# Web Development Module
setupx components web-development
setupx test web-development
setupx install web-development

# Backend Development Module
setupx components backend-development
setupx test backend-development
setupx install backend-development

# Cloud Development Module
setupx components cloud-development
setupx test cloud-development
setupx install cloud-development

# Mobile Development Module
setupx components mobile-development
setupx test mobile-development
setupx install mobile-development
```

### Complete Command Reference

#### Help Commands
```powershell
setupx -h                    # Show help message
setupx --help               # Show help message
setupx help                 # Show help message
```

#### Information Commands
```powershell
setupx list                 # List all available modules
setupx status               # Show system status
setupx components <module>  # List module components
```

#### Testing Commands
```powershell
setupx test <module>        # Test module components
setupx test package-managers # Test package managers
setupx test common-development # Test common tools
setupx test web-development  # Test web development tools
setupx test backend-development # Test backend tools
setupx test cloud-development # Test cloud tools
setupx test mobile-development # Test mobile tools
```

#### Installation Commands
```powershell
setupx install <module>     # Install a module
setupx install package-managers # Install package managers
setupx install common-development # Install common tools
setupx install web-development # Install web tools
setupx install backend-development # Install backend tools
setupx install cloud-development # Install cloud tools
setupx install mobile-development # Install mobile tools
```

#### Interactive Commands
```powershell
setupx menu                 # Show interactive menu
setupx                      # Default to interactive menu
```

### Examples

#### Quick Setup Examples
```powershell
# Complete development environment setup
.\setupx-main.ps1 install package-managers
.\setupx-main.ps1 install common-development
.\setupx-main.ps1 install web-development

# Test your installation
.\setupx-main.ps1 test package-managers
.\setupx-main.ps1 test common-development

# Check system status
.\setupx-main.ps1 status
```

#### Module-Specific Examples
```powershell
# Package Managers Setup
.\setupx-main.ps1 components package-managers
.\setupx-main.ps1 test package-managers
.\setupx-main.ps1 install package-managers

# Web Development Setup
.\setupx-main.ps1 components web-development
.\setupx-main.ps1 test web-development
.\setupx-main.ps1 install web-development

# Backend Development Setup
.\setupx-main.ps1 components backend-development
.\setupx-main.ps1 test backend-development
.\setupx-main.ps1 install backend-development
```

#### Advanced Usage
```powershell
# Check what's available
.\setupx-main.ps1 list

# See system status
.\setupx-main.ps1 status

# Interactive setup
.\setupx-main.ps1 menu

# Test everything
.\setupx-main.ps1 test package-managers
.\setupx-main.ps1 test common-development
.\setupx-main.ps1 test web-development
.\setupx-main.ps1 test backend-development
.\setupx-main.ps1 test cloud-development
.\setupx-main.ps1 test mobile-development
```

## 🧪 Testing

The setupx tool includes comprehensive testing capabilities:

```powershell
# Test all components in a module
setupx test package-managers

# Test results show:
# - Installation status
# - Version information
# - Completion percentage
```

## 📊 System Status

Check your system status:

```powershell
setupx status
```

Shows:
- Package manager availability
- Module configuration status
- System requirements
- Installation progress

## 🔧 Configuration

### Module Configuration
Each module has a `module.json` configuration file:

```json
{
  "name": "package-managers",
  "description": "Essential Windows package managers",
  "version": "1.0.0",
  "components": [
    {
      "name": "chocolatey",
      "description": "Windows package manager",
      "package": "chocolatey",
      "manager": "winget",
      "testCommand": "choco --version"
    }
  ]
}
```

### Component Scripts
Each component has its own PowerShell script for installation and testing.

## 🎯 Flutter GUI

The project includes a Flutter-based GUI for visual management:

```bash
# Run Flutter app
flutter run
```

Features:
- Module selection interface
- Component status dashboard
- Installation progress tracking
- System status monitoring

## 📁 Project Structure

```
setupx-windows-setup/
├── windows_scripts/          # PowerShell scripts
│   ├── setupx-main.ps1      # Main CLI interface
│   ├── modules/              # Development modules
│   │   ├── package-managers/
│   │   ├── common-development/
│   │   ├── web-development/
│   │   ├── backend-development/
│   │   ├── cloud-development/
│   │   └── mobile-development/
│   └── shared/               # Shared utilities
├── lib/                      # Flutter app source
├── android/                  # Android app files
├── ios/                      # iOS app files
├── windows/                  # Windows app files
└── README.md                 # This file
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

- **Issues**: Report bugs and request features
- **Documentation**: Check the wiki for detailed guides
- **Community**: Join discussions in GitHub Discussions

## 🎉 Acknowledgments

- Microsoft for WinGet
- Chocolatey community
- Scoop developers
- Flutter team
- All contributors

---

**SetupX** - Making Windows development environment setup simple and automated! 🚀