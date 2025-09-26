# SetupX Modules Index

This directory contains all SetupX development modules organized by category.

## 📁 Module Structure

```
src/modules/
├── package-managers/     # Essential Windows package managers
├── web-development/      # Web development tools and frameworks
├── mobile-development/   # Mobile app development tools
├── backend-development/  # Backend development tools
├── cloud-development/    # Cloud development and deployment
└── common-development/   # Common development utilities
```

## 🎯 Available Modules

### 1. Package Managers (`package-managers`)
**Essential Windows package managers for software installation**

- **Chocolatey** - Community package manager for Windows
- **Scoop** - Portable applications manager
- **WinGet** - Microsoft's official Windows package manager

**Usage:**
```bash
setupx install package-managers
setupx components package-managers
```

### 2. Web Development (`web-development`)
**Modern web development tools and frameworks**

- **Node.js** - JavaScript runtime
- **npm** - Node package manager
- **Git** - Version control system
- **VS Code** - Code editor
- **Chrome** - Web browser for development

**Usage:**
```bash
setupx install web-development
setupx components web-development
```

### 3. Mobile Development (`mobile-development`)
**Mobile app development tools**

- **Android Studio** - Android development IDE
- **Flutter** - Cross-platform mobile framework
- **React Native CLI** - React Native development
- **Xamarin** - Microsoft mobile development

**Usage:**
```bash
setupx install mobile-development
setupx components mobile-development
```

### 4. Backend Development (`backend-development`)
**Backend development tools and databases**

- **Docker** - Containerization platform
- **PostgreSQL** - Database management
- **Redis** - In-memory data store
- **MongoDB** - NoSQL database
- **Apache** - Web server

**Usage:**
```bash
setupx install backend-development
setupx components backend-development
```

### 5. Cloud Development (`cloud-development`)
**Cloud development and deployment tools**

- **AWS CLI** - Amazon Web Services
- **Azure CLI** - Microsoft Azure
- **Google Cloud SDK** - Google Cloud Platform
- **Terraform** - Infrastructure as Code
- **Kubernetes** - Container orchestration

**Usage:**
```bash
setupx install cloud-development
setupx components cloud-development
```

### 6. Common Development (`common-development`)
**Common development utilities and tools**

- **PowerShell** - Windows automation
- **Python** - Programming language
- **Java** - Programming language
- **C++** - Programming language
- **Visual Studio** - Development IDE

**Usage:**
```bash
setupx install common-development
setupx components common-development
```

## 🚀 Quick Start

1. **List all modules:**
   ```bash
   setupx list
   ```

2. **Show system status:**
   ```bash
   setupx status
   ```

3. **Install a specific module:**
   ```bash
   setupx install <module-name>
   ```

4. **Show module components:**
   ```bash
   setupx components <module-name>
   ```

5. **Interactive menu:**
   ```bash
   setupx menu
   ```

## 📋 Module Configuration

Each module contains:
- `module.json` - Module configuration and metadata
- Component scripts - Individual tool installation scripts
- Test scripts - Module testing and validation

## 🔧 Development

To add a new module:
1. Create module directory in `src/modules/`
2. Add `module.json` configuration
3. Create component installation scripts
4. Test with `setupx install <module-name>`

## 📚 Documentation

- [SetupX Main Documentation](../README.md)
- [Installation Guide](../install.ps1)
- [CLI Reference](../src/cli/setupx-cli.ps1)

---

**SetupX v2.0 - Modular Windows Development Setup**
*Organized, efficient, and powerful development environment management*
