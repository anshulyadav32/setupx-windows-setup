# Minimal test to isolate the issue
function Test-Switch {
    $managers = @("winget", "choco")
    
    foreach ($manager in $managers) {
        switch ($manager) {
            "winget" {
                Write-Host "WinGet case"
            }
            "choco" {
                Write-Host "Choco case"
            }
        }
    }
    
    return $false
}

Test-Switch
Write-Host "Test completed successfully"
