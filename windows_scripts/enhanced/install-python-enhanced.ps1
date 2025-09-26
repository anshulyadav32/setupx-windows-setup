# Enhanced Python Installation Script
# Installs Python with comprehensive development environment

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

function Install-PythonEnhanced {
    Write-ColorOutput "`n=== Installing Python (Enhanced Development Environment) ===" $Cyan

    if (-not (Test-Administrator)) {
        Write-ColorOutput "✗ This script requires Administrator privileges." $Red
        exit 1
    }

    # Check if already installed
    if (Get-Command "python" -ErrorAction SilentlyContinue) {
        $version = python --version
        Write-ColorOutput "✓ Python is already installed: $version" $Green

        $update = Read-Host "Do you want to update Python and packages? (y/n)"
        if ($update -ne "y" -and $update -ne "Y") {
            return
        }
    } else {
        Write-ColorOutput "Installing Python..." $Yellow

        # Try WinGet first
        if (Get-Command "winget" -ErrorAction SilentlyContinue) {
            try {
                winget install --id Python.Python.3.12 --silent --accept-source-agreements --accept-package-agreements
                Write-ColorOutput "✓ Python installed via WinGet" $Green
            } catch {
                Write-ColorOutput "! WinGet installation failed, trying Chocolatey..." $Yellow

                # Fallback to Chocolatey
                if (Get-Command "choco" -ErrorAction SilentlyContinue) {
                    choco install python -y
                    Write-ColorOutput "✓ Python installed via Chocolatey" $Green
                } else {
                    Write-ColorOutput "✗ Failed to install Python" $Red
                    return
                }
            }
        } elseif (Get-Command "choco" -ErrorAction SilentlyContinue) {
            choco install python -y
            Write-ColorOutput "✓ Python installed via Chocolatey" $Green
        } else {
            Write-ColorOutput "✗ No package manager available. Please install Chocolatey or WinGet first." $Red
            return
        }

        # Refresh environment
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

        # Wait for installation to complete
        Start-Sleep -Seconds 10
    }

    # Verify installation
    if (-not (Get-Command "python" -ErrorAction SilentlyContinue)) {
        Write-ColorOutput "✗ Python installation verification failed" $Red
        return
    }

    # Update pip
    Write-ColorOutput "`n=== Updating pip ===" $Cyan
    try {
        python -m pip install --upgrade pip
        Write-ColorOutput "✓ pip updated to latest version" $Green
    } catch {
        Write-ColorOutput "! Failed to update pip" $Yellow
    }

    # Install core development packages
    Write-ColorOutput "`n=== Installing Core Development Packages ===" $Cyan

    $corePackages = @(
        "virtualenv",
        "pipenv",
        "virtualenvwrapper-win",
        "poetry",
        "pipx"
    )

    foreach ($package in $corePackages) {
        try {
            Write-ColorOutput "Installing $package..." $Yellow
            pip install $package --upgrade
            Write-ColorOutput "✓ $package installed" $Green
        } catch {
            Write-ColorOutput "! Failed to install $package" $Red
        }
    }

    # Install web development packages
    Write-ColorOutput "`n=== Installing Web Development Packages ===" $Cyan

    $webPackages = @(
        "requests",
        "urllib3",
        "beautifulsoup4",
        "lxml",
        "selenium",
        "scrapy",
        "flask",
        "django",
        "fastapi",
        "uvicorn",
        "gunicorn",
        "celery",
        "redis"
    )

    foreach ($package in $webPackages) {
        try {
            Write-ColorOutput "Installing $package..." $Yellow
            pip install $package --upgrade
            Write-ColorOutput "✓ $package installed" $Green
        } catch {
            Write-ColorOutput "! Failed to install $package" $Red
        }
    }

    # Install data science and AI packages
    Write-ColorOutput "`n=== Installing Data Science and AI Packages ===" $Cyan

    $dataPackages = @(
        "numpy",
        "pandas",
        "matplotlib",
        "seaborn",
        "plotly",
        "bokeh",
        "scipy",
        "scikit-learn",
        "statsmodels",
        "openpyxl",
        "xlsxwriter",
        "jupyter",
        "jupyterlab",
        "ipython",
        "notebook"
    )

    foreach ($package in $dataPackages) {
        try {
            Write-ColorOutput "Installing $package..." $Yellow
            pip install $package --upgrade
            Write-ColorOutput "✓ $package installed" $Green
        } catch {
            Write-ColorOutput "! Failed to install $package" $Red
        }
    }

    # Install AI/ML packages (optional due to size)
    Write-ColorOutput "`n=== Installing AI/ML Packages ===" $Cyan
    $installAI = Read-Host "Install TensorFlow and PyTorch? (Large download, y/n)"

    if ($installAI -eq "y" -or $installAI -eq "Y") {
        $aiPackages = @(
            "tensorflow",
            "torch",
            "torchvision",
            "transformers",
            "opencv-python",
            "pillow",
            "imageio"
        )

        foreach ($package in $aiPackages) {
            try {
                Write-ColorOutput "Installing $package..." $Yellow
                pip install $package --upgrade
                Write-ColorOutput "✓ $package installed" $Green
            } catch {
                Write-ColorOutput "! Failed to install $package" $Red
            }
        }
    }

    # Install development tools
    Write-ColorOutput "`n=== Installing Development Tools ===" $Cyan

    $devTools = @(
        "pytest",
        "pytest-cov",
        "unittest-xml-reporting",
        "black",
        "flake8",
        "pylint",
        "autopep8",
        "mypy",
        "bandit",
        "safety",
        "pre-commit",
        "tox",
        "cookiecutter",
        "wheel",
        "setuptools",
        "twine"
    )

    foreach ($package in $devTools) {
        try {
            Write-ColorOutput "Installing $package..." $Yellow
            pip install $package --upgrade
            Write-ColorOutput "✓ $package installed" $Green
        } catch {
            Write-ColorOutput "! Failed to install $package" $Red
        }
    }

    # Install database packages
    Write-ColorOutput "`n=== Installing Database Packages ===" $Cyan

    $dbPackages = @(
        "sqlalchemy",
        "psycopg2-binary",
        "pymongo",
        "redis",
        "sqlite3"
    )

    foreach ($package in $dbPackages) {
        try {
            Write-ColorOutput "Installing $package..." $Yellow
            pip install $package --upgrade
            Write-ColorOutput "✓ $package installed" $Green
        } catch {
            Write-ColorOutput "! Failed to install $package" $Red
        }
    }

    # Install useful CLI tools via pipx
    Write-ColorOutput "`n=== Installing CLI Tools via pipx ===" $Cyan

    $cliTools = @(
        "httpie",
        "youtube-dl",
        "streamlit",
        "rich-cli",
        "typer-cli"
    )

    foreach ($tool in $cliTools) {
        try {
            Write-ColorOutput "Installing $tool via pipx..." $Yellow
            pipx install $tool
            Write-ColorOutput "✓ $tool installed" $Green
        } catch {
            Write-ColorOutput "! Failed to install $tool" $Red
        }
    }

    # Create development directories
    Write-ColorOutput "`n=== Creating Development Environment ===" $Cyan

    $devDirs = @(
        "$env:USERPROFILE\Documents\Python Projects",
        "$env:USERPROFILE\Documents\Python Projects\Web Development",
        "$env:USERPROFILE\Documents\Python Projects\Data Science",
        "$env:USERPROFILE\Documents\Python Projects\Machine Learning",
        "$env:USERPROFILE\Documents\Python Projects\Automation"
    )

    foreach ($dir in $devDirs) {
        try {
            if (-not (Test-Path $dir)) {
                New-Item -Path $dir -ItemType Directory -Force | Out-Null
                Write-ColorOutput "✓ Created directory: $dir" $Green
            }
        } catch {
            Write-ColorOutput "! Failed to create directory: $dir" $Red
        }
    }

    # Create sample project structure
    Write-ColorOutput "`nCreating sample project template..." $Yellow

    $sampleProject = "$env:USERPROFILE\Documents\Python Projects\sample_project"
    if (-not (Test-Path $sampleProject)) {
        New-Item -Path $sampleProject -ItemType Directory -Force | Out-Null

        # Create basic project structure
        $projectStructure = @(
            "src",
            "tests",
            "docs",
            "data",
            "notebooks"
        )

        foreach ($folder in $projectStructure) {
            New-Item -Path "$sampleProject\$folder" -ItemType Directory -Force | Out-Null
        }

        # Create sample files
        $requirementsTxt = @'
# Core packages
requests==2.31.0
pandas==2.0.3
numpy==1.24.3
matplotlib==3.7.2

# Development packages
pytest==7.4.0
black==23.7.0
flake8==6.0.0

# Web development (uncomment if needed)
# flask==2.3.2
# django==4.2.3
'@

        $requirementsTxt | Out-File -FilePath "$sampleProject\requirements.txt" -Encoding UTF8

        $readmeMd = @'
# Sample Python Project

This is a sample Python project structure.

## Setup

1. Create virtual environment:
```bash
python -m venv venv
```

2. Activate virtual environment:
```bash
# Windows
venv\Scripts\activate

# macOS/Linux
source venv/bin/activate
```

3. Install dependencies:
```bash
pip install -r requirements.txt
```

## Project Structure

- `src/` - Source code
- `tests/` - Test files
- `docs/` - Documentation
- `data/` - Data files
- `notebooks/` - Jupyter notebooks
'@

        $readmeMd | Out-File -FilePath "$sampleProject\README.md" -Encoding UTF8

        Write-ColorOutput "✓ Sample project created at: $sampleProject" $Green
    }

    Write-ColorOutput "`n=== Installation Complete ===" $Green
    Write-ColorOutput "Enhanced Python development environment has been set up!" $Green

    Write-ColorOutput "`n=== Installed Packages ===" $Cyan
    Write-ColorOutput "Core development:" $White
    Write-ColorOutput "• Virtual environments (virtualenv, pipenv, poetry)" $White
    Write-ColorOutput "• Package management (pipx, wheel, setuptools)" $White

    Write-ColorOutput "`nWeb development:" $White
    Write-ColorOutput "• HTTP libraries (requests, urllib3)" $White
    Write-ColorOutput "• Web scraping (BeautifulSoup, Selenium, Scrapy)" $White
    Write-ColorOutput "• Web frameworks (Flask, Django, FastAPI)" $White

    Write-ColorOutput "`nData science:" $White
    Write-ColorOutput "• Data analysis (pandas, numpy, scipy)" $White
    Write-ColorOutput "• Visualization (matplotlib, seaborn, plotly)" $White
    Write-ColorOutput "• Interactive development (Jupyter, JupyterLab)" $White

    if ($installAI -eq "y" -or $installAI -eq "Y") {
        Write-ColorOutput "`nAI/ML packages:" $White
        Write-ColorOutput "• TensorFlow and PyTorch for deep learning" $White
        Write-ColorOutput "• Computer vision (OpenCV, Pillow)" $White
        Write-ColorOutput "• NLP (Transformers)" $White
    }

    Write-ColorOutput "`nDevelopment tools:" $White
    Write-ColorOutput "• Testing (pytest, coverage)" $White
    Write-ColorOutput "• Code quality (black, flake8, pylint, mypy)" $White
    Write-ColorOutput "• Security (bandit, safety)" $White

    Write-ColorOutput "`n=== Next Steps ===" $Cyan
    Write-ColorOutput "• Create virtual environments for your projects" $White
    Write-ColorOutput "• Explore the sample project in Documents/Python Projects" $White
    Write-ColorOutput "• Install additional packages as needed" $White
    Write-ColorOutput "• Set up VS Code with Python extension" $White

    Write-ColorOutput "`n=== Useful Commands ===" $Cyan
    Write-ColorOutput "  python -m venv myproject   # Create virtual environment" $Yellow
    Write-ColorOutput "  pip list                   # List installed packages" $Yellow
    Write-ColorOutput "  jupyter lab                # Start JupyterLab" $Yellow
    Write-ColorOutput "  black myfile.py           # Format code with Black" $Yellow
}

Install-PythonEnhanced
Write-ColorOutput "`nPress any key to exit..." $Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")