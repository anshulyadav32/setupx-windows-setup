# Test syntax of component-manager.ps1
try {
    . ".\shared\component-manager.ps1"
    Write-Host "Component manager loaded successfully"
} catch {
    Write-Host "Error loading component manager: $($_.Exception.Message)"
    Write-Host "Line: $($_.InvocationInfo.ScriptLineNumber)"
    Write-Host "Position: $($_.InvocationInfo.PositionMessage)"
}
