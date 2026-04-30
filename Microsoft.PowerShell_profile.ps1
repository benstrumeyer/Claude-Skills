function yolo {
    $extraArgs = $args -join " "
    $claudeCmd = "claude --dangerously-skip-permissions --mcp-config `"$env:USERPROFILE\.claude\mcp-docs.json`" $extraArgs"
    nvim -c "terminal $claudeCmd"
}
function mystery {
    nvim -c "MysterySession"
}
function petlordz {
    Set-Location C:\Users\ben\repos\petlordz
    nvim -c "PetlordzSession"
}
function shellphone {
    Set-Location C:\Users\ben\repos\Shellphone
    yolo
}
function js {
    # Start backend if not running
    $backendWasDown = -not (Test-NetConnection -ComputerName localhost -Port 5000 -InformationLevel Quiet -WarningAction SilentlyContinue)
    if ($backendWasDown) {
        Write-Host "Starting backend..." -ForegroundColor Cyan
        Start-Process -WindowStyle Hidden -FilePath "dotnet" -ArgumentList "run --urls http://localhost:5000" -WorkingDirectory "$env:USERPROFILE\repos\Mystery-Project\packages\job-search\backend\JobScraper.Api" -RedirectStandardOutput "$env:TEMP\job-search-backend.log" -RedirectStandardError "$env:TEMP\job-search-backend-err.log"
    }
    # Start frontend if not running
    if (-not (Test-NetConnection -ComputerName localhost -Port 5173 -InformationLevel Quiet -WarningAction SilentlyContinue)) {
        Write-Host "Starting frontend..." -ForegroundColor Cyan
        Start-Process -WindowStyle Hidden -FilePath "npm.cmd" -ArgumentList "run dev" -WorkingDirectory "$env:USERPROFILE\repos\Mystery-Project\packages\job-search\frontend" -RedirectStandardOutput "$env:TEMP\job-search-frontend.log" -RedirectStandardError "$env:TEMP\job-search-frontend-err.log"
    }
    # Wait for backend to be ready before launching Claude
    if ($backendWasDown) {
        Write-Host "Waiting for backend to be ready..." -ForegroundColor Cyan
        $timeout = 60
        $elapsed = 0
        while ($elapsed -lt $timeout) {
            if (Test-NetConnection -ComputerName localhost -Port 5000 -InformationLevel Quiet -WarningAction SilentlyContinue) {
                Write-Host "Backend ready." -ForegroundColor Green
                break
            }
            Start-Sleep -Seconds 2
            $elapsed += 2
        }
        if ($elapsed -ge $timeout) { Write-Host "Backend did not start in time." -ForegroundColor Red }
    }
    $extraArgs = $args -join " "
    $claudeCmd = "claude --dangerously-skip-permissions --mcp-config `"$env:USERPROFILE\.claude\mcp-playwright-fleet.json`" $extraArgs"
    nvim -c "terminal $claudeCmd"
}
