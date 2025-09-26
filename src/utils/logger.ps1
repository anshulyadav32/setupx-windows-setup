# SetupX Logger Module
# Provides consistent logging functionality across all SetupX components

function Write-SetupxLog {
    param(
        [string]$Message,
        [string]$Level = "INFO",
        [string]$Color = "White"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $prefix = switch ($Level) {
        "ERROR" { "❌" }
        "WARN"  { "⚠️" }
        "SUCCESS" { "✅" }
        "INFO"  { "ℹ️" }
        default { "📝" }
    }
    
    $logMessage = "[$timestamp] $prefix $Message"
    Write-Host $logMessage -ForegroundColor $Color
}

function Write-SetupxError {
    param([string]$Message)
    Write-SetupxLog -Message $Message -Level "ERROR" -Color "Red"
}

function Write-SetupxWarning {
    param([string]$Message)
    Write-SetupxLog -Message $Message -Level "WARN" -Color "Yellow"
}

function Write-SetupxSuccess {
    param([string]$Message)
    Write-SetupxLog -Message $Message -Level "SUCCESS" -Color "Green"
}

function Write-SetupxInfo {
    param([string]$Message)
    Write-SetupxLog -Message $Message -Level "INFO" -Color "Cyan"
}

# Export functions for use in other modules
Export-ModuleMember -Function Write-SetupxLog, Write-SetupxError, Write-SetupxWarning, Write-SetupxSuccess, Write-SetupxInfo
