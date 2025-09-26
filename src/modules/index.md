# SetupX Modules Index

## 📊 Module Overview

| Module | Display Name | Category | Components | Status |
|--------|-------------|----------|------------|--------|
| `package-managers` | Package Managers | foundation | 3 | ✅ Active |
| `web-development` | Web Development | development | 5 | ✅ Active |
| `mobile-development` | Mobile Development | development | 4 | ✅ Active |
| `backend-development` | Backend Development | development | 5 | ✅ Active |
| `cloud-development` | Cloud Development | development | 5 | ✅ Active |
| `common-development` | Common Development | development | 5 | ✅ Active |

## 🎯 Module Details

### 1. Package Managers (`package-managers`)
**Foundation module for Windows package management**

**Components:**
- **Chocolatey** - Community package manager
- **Scoop** - Portable applications manager  
- **WinGet** - Microsoft's official package manager

**Configuration:**
- **Priority**: 1 (Foundation)
- **Admin Required**: Yes
- **Install Time**: 5-10 minutes
- **Auto Install**: Yes

### 2. Web Development (`web-development`)
**Modern web development tools and frameworks**

**Components:**
- **Node.js** - JavaScript runtime
- **npm** - Node package manager
- **Git** - Version control
- **VS Code** - Code editor
- **Chrome** - Web browser

**Configuration:**
- **Priority**: 2
- **Admin Required**: No
- **Install Time**: 10-15 minutes
- **Auto Install**: Yes

### 3. Mobile Development (`mobile-development`)
**Mobile app development tools**

**Components:**
- **Android Studio** - Android IDE
- **Flutter** - Cross-platform framework
- **React Native CLI** - React Native tools
- **Xamarin** - Microsoft mobile dev

**Configuration:**
- **Priority**: 3
- **Admin Required**: Yes
- **Install Time**: 20-30 minutes
- **Auto Install**: Yes

### 4. Backend Development (`backend-development`)
**Backend development tools and databases**

**Components:**
- **Docker** - Containerization
- **PostgreSQL** - Database
- **Redis** - In-memory store
- **MongoDB** - NoSQL database
- **Apache** - Web server

**Configuration:**
- **Priority**: 4
- **Admin Required**: Yes
- **Install Time**: 15-20 minutes
- **Auto Install**: Yes

### 5. Cloud Development (`cloud-development`)
**Cloud development and deployment**

**Components:**
- **AWS CLI** - Amazon Web Services
- **Azure CLI** - Microsoft Azure
- **Google Cloud SDK** - Google Cloud
- **Terraform** - Infrastructure as Code
- **Kubernetes** - Container orchestration

**Configuration:**
- **Priority**: 5
- **Admin Required**: No
- **Install Time**: 10-15 minutes
- **Auto Install**: Yes

### 6. Common Development (`common-development`)
**Common development utilities**

**Components:**
- **PowerShell** - Windows automation
- **Python** - Programming language
- **Java** - Programming language
- **C++** - Programming language
- **Visual Studio** - Development IDE

**Configuration:**
- **Priority**: 6
- **Admin Required**: Yes
- **Install Time**: 15-25 minutes
- **Auto Install**: Yes

## 🚀 Quick Commands

### List All Modules
```bash
setupx list
```

### Show System Status
```bash
setupx status
```

### Install Specific Module
```bash
setupx install package-managers
setupx install web-development
setupx install mobile-development
```

### Show Module Components
```bash
setupx components package-managers
setupx components web-development
```

### Test Module
```bash
setupx test package-managers
setupx test web-development
```

### Interactive Menu
```bash
setupx menu
```

## 📁 Directory Structure

```
src/modules/
├── package-managers/
│   ├── module.json
│   ├── chocolatey.ps1
│   ├── scoop.ps1
│   ├── winget.ps1
│   └── components/
│       ├── chocolatey.ps1
│       ├── scoop.ps1
│       └── winget.ps1
├── web-development/
│   ├── module.json
│   ├── nodejs.ps1
│   ├── npm.ps1
│   ├── git.ps1
│   ├── vscode.ps1
│   ├── chrome.ps1
│   └── components/
├── mobile-development/
│   ├── module.json
│   ├── android-studio.ps1
│   ├── flutter.ps1
│   ├── react-native.ps1
│   ├── xamarin.ps1
│   └── components/
├── backend-development/
│   ├── module.json
│   ├── docker.ps1
│   ├── postgresql.ps1
│   ├── redis.ps1
│   ├── mongodb.ps1
│   ├── apache.ps1
│   └── components/
├── cloud-development/
│   ├── module.json
│   ├── aws-cli.ps1
│   ├── azure-cli.ps1
│   ├── gcloud.ps1
│   ├── terraform.ps1
│   ├── kubernetes.ps1
│   └── components/
├── common-development/
│   ├── module.json
│   ├── powershell.ps1
│   ├── python.ps1
│   ├── java.ps1
│   ├── cpp.ps1
│   ├── visual-studio.ps1
│   └── components/
├── README.md
└── index.md
```

## 🔧 Module Development

### Adding a New Module

1. **Create Module Directory:**
   ```bash
   mkdir src/modules/new-module
   ```

2. **Create module.json:**
   ```json
   {
     "name": "new-module",
     "displayName": "New Module",
     "description": "Description of the module",
     "version": "1.0.0",
     "category": "development",
     "supportsAutoInstall": true,
     "requiresAdmin": false,
     "estimatedInstallTime": "10-15 minutes",
     "dependencies": [],
     "components": [...]
   }
   ```

3. **Create Component Scripts:**
   - `component-name.ps1` - Installation script
   - `components/component-name.ps1` - Component script

4. **Test Module:**
   ```bash
   setupx test new-module
   ```

## 📚 Documentation Links

- [SetupX Main Documentation](../README.md)
- [Installation Guide](../install.ps1)
- [CLI Reference](../src/cli/setupx-cli.ps1)
- [Module Manager](../src/core/module-manager.ps1)
- [Package Manager](../src/core/package-manager.ps1)

---

**SetupX v2.0 - Modular Windows Development Setup**
*Comprehensive development environment management*
