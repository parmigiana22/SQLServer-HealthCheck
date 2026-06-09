# Usage

1. Edit `config/sample.config.json` with your SQL instance.
2. Run PowerShell as a user with SQL permissions.
3. Execute:

```powershell
.\scripts\Invoke-SqlHealthCheck.ps1 -ConfigPath .\config\sample.config.json
```

## Scheduling idea
Create a Windows Task Scheduler action:

```powershell
powershell.exe -ExecutionPolicy Bypass -File "C:\Tools\SQLServer-HealthCheck-Toolkit\scripts\Invoke-SqlHealthCheck.ps1" -ConfigPath "C:\Tools\SQLServer-HealthCheck-Toolkit\config\sample.config.json"
```
