# SetupX Modular Structure

## 📁 Project Organization

```
setupx/
├── setupx.ps1                    # Main entry point
├── setupx-modular-install.ps1   # Modular auto-installer
├── src/                          # Source code
│   ├── core/                     # Core functionality
│   │   ├── module-manager.ps1   # Module discovery and management
│   │   └── package-manager.ps1  # Package manager operations
│   ├── cli/                      # Command line interface
│   │   └── setupx-cli.ps1       # Main CLI implementation
│   ├── utils/                    # Utility functions
│   │   ├── logger.ps1           # Logging functionality
│   │   └── helpers.ps1          # Common helper functions
│   ├── installers/               # Installation modules
│   │   └── setupx-installer.ps1 # SetupX installation logic
│   ├── config/                   # Configuration files
│   │   └── setupx.json          # Main configuration
│   └── modules/                  # Development modules
│       ├── package-managers/     # Package manager module
│       ├── web-development/      # Web development tools
│       ├── mobile-development/   # Mobile development tools
│       ├── backend-development/ # Backend development tools
│       ├── cloud-development/   # Cloud development tools
│       └── common-development/  # Common development tools
└── README.md                     # Project documentation
```

## 🏗️ Architecture

### **Core Modules**
- **`module-manager.ps1`**: Handles module discovery, loading, and management
- **`package-manager.ps1`**: Manages package manager operations and status

### **CLI Module**
- **`setupx-cli.ps1`**: Main command-line interface with all commands

### **Utility Modules**
- **`logger.ps1`**: Consistent logging across all components
- **`helpers.ps1`**: Common utility functions

### **Installer Module**
- **`setupx-installer.ps1`**: Handles SetupX installation and setup

### **Configuration**
- **`setupx.json`**: Central configuration file for all modules

## 🚀 Benefits of Modular Structure

### **1. Separation of Concerns**
- Each module has a single responsibility
- Easy to maintain and debug
- Clear code organization

### **2. Reusability**
- Utility functions can be shared across modules
- Core functionality is modular and reusable
- Easy to extend with new features

### **3. Maintainability**
- Changes to one module don't affect others
- Easy to test individual components
- Clear dependency management

### **4. Scalability**
- Easy to add new modules
- Simple to extend functionality
- Modular installation process

## 📋 Module Dependencies

```
setupx.ps1
└── src/cli/setupx-cli.ps1
    ├── src/core/module-manager.ps1
    ├── src/core/package-manager.ps1
    ├── src/utils/logger.ps1
    └── src/utils/helpers.ps1
```

## 🔧 Installation

### **Modular Auto-Install**
```powershell
Invoke-RestMethod -Uri https://raw.githubusercontent.com/anshulyadav32/setupx-windows-setup/main/setupx-modular-install.ps1 | Invoke-Expression
```

### **Manual Installation**
1. Clone the repository
2. Run `setupx-modular-install.ps1`
3. Use `setupx` command from anywhere

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

## 🔄 Migration from Old Structure

The new modular structure is backward compatible:
- All existing commands work the same way
- Same CLI interface
- Enhanced functionality with better organization
- Improved error handling and logging

## 📈 Future Enhancements

- **Plugin System**: Easy to add custom modules
- **Configuration Management**: Centralized config system
- **Update Mechanism**: Automatic updates for modules
- **Plugin Marketplace**: Community-contributed modules
