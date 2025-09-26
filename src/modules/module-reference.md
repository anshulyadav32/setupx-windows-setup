# SetupX Module Reference

## 📋 All Available Modules

| Index | Module Name | Display Name | Priority | Category | Components |
|-------|-------------|--------------|----------|----------|------------|
| **1** | `package-managers` | Package Managers | 1 | foundation | 3 |
| **2** | `web-development` | Web Development | 2 | development | 7 |
| **3** | `mobile-development` | Mobile Development | 3 | development | 8 |
| **4** | `backend-development` | Backend Development | 4 | development | 9 |
| **5** | `cloud-development` | Cloud Development | 5 | development | 7 |
| **6** | `common-development` | Common Development | 6 | development | 8 |

## 🎯 Quick Installation Commands

### Direct Module Installation:
```bash
setupx install package-managers      # Priority 1 - Foundation
setupx install web-development       # Priority 2 - Web Dev
setupx install mobile-development    # Priority 3 - Mobile Dev
setupx install backend-development   # Priority 4 - Backend Dev
setupx install cloud-development     # Priority 5 - Cloud Dev
setupx install common-development    # Priority 6 - Common Dev
```

### Interactive Menu Options:
```
1. List all modules
2. Show system status
3. Install package managers (Priority 1)
4. Install web development (Priority 2)
5. Install mobile development (Priority 3)
6. Install backend development (Priority 4)
7. Install cloud development (Priority 5)
8. Install common development (Priority 6)
9. Install specific module
10. Show help
0. Exit
```

## 📦 Module Details

### 1. Package Managers (`package-managers`)
**Foundation module - Install first!**
- **Components**: Chocolatey, Scoop, WinGet
- **Dependencies**: None
- **Admin Required**: Yes
- **Install Time**: 5-10 minutes

### 2. Web Development (`web-development`)
**Modern web development tools**
- **Components**: Node.js, Yarn, Browsers, React, Vue, Angular, Webpack
- **Dependencies**: package-managers
- **Admin Required**: Yes
- **Install Time**: 15-20 minutes

### 3. Mobile Development (`mobile-development`)
**Cross-platform mobile development**
- **Components**: Flutter, Dart, Android Studio, React Native, Expo
- **Dependencies**: package-managers, web-development
- **Admin Required**: Yes
- **Install Time**: 25-30 minutes

### 4. Backend Development (`backend-development`)
**Server-side development tools**
- **Components**: Python, .NET, Node.js, Go, Rust, PostgreSQL, MySQL, MongoDB, Redis
- **Dependencies**: package-managers
- **Admin Required**: Yes
- **Install Time**: 20-25 minutes

### 5. Cloud Development (`cloud-development`)
**Cloud development and deployment**
- **Components**: AWS CLI, Azure CLI, Google Cloud SDK, Docker, Kubernetes, Terraform, Helm
- **Dependencies**: package-managers
- **Admin Required**: Yes
- **Install Time**: 10-15 minutes

### 6. Common Development (`common-development`)
**Essential development tools**
- **Components**: Git, VS Code, PowerShell, Terminal, Docker, Postman, Fonts
- **Dependencies**: package-managers
- **Admin Required**: Yes
- **Install Time**: 15-25 minutes

## 🚀 Usage Examples

### Check Status:
```bash
setupx status
```

### List All Modules:
```bash
setupx list
```

### Show Module Components:
```bash
setupx components package-managers
setupx components web-development
setupx components mobile-development
```

### Interactive Menu:
```bash
setupx menu
```

### Install Specific Module:
```bash
setupx install web-development
```

## 📝 Notes

- **Install in Priority Order**: Start with package-managers (Priority 1), then proceed in order
- **Dependencies**: Some modules require others to be installed first
- **Admin Rights**: Most modules require administrator privileges
- **Installation Time**: Times are estimates and may vary based on system performance

---

**SetupX v2.0 - Modular Windows Development Setup**
*Complete development environment management*
