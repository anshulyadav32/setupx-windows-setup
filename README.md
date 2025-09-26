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
   git clone https://github.com/yourusername/setupx-windows-setup.git
   cd setupx-windows-setup
   ```

2. **Run the setup:**
   ```powershell
   cd windows_scripts
   .\setupx-main.ps1 -h
   ```

## 📋 Usage

### Command Line Interface

```powershell
# Show help
setupx -h

# List all modules
setupx list

# Show system status
setupx status

# List module components
setupx components package-managers

# Test module components
setupx test package-managers

# Install a module
setupx install package-managers

# Interactive menu
setupx menu
```

### Examples

```powershell
# Install package managers
.\setupx-main.ps1 install package-managers

# Test common development tools
.\setupx-main.ps1 test common-development

# List web development components
.\setupx-main.ps1 components web-development
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