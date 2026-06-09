# SQLServer Health Check Toolkit

PowerShell + T-SQL toolkit for daily SQL Server DBA checks: backups, disk space, database status, failed jobs, blocking, index fragmentation and top resource-consuming queries.

## Why this project
This repository demonstrates practical DBA automation skills: SQL Server monitoring, PowerShell scripting, reporting, error handling and clean documentation.

## Features
- Run multiple SQL health checks from one PowerShell entry point
- Export results to CSV
- Generate a clean HTML report
- Keep SQL checks separated in reusable `.sql` files
- Configurable thresholds through JSON

## Requirements
- Windows PowerShell 5.1+ or PowerShell 7+
- SQL Server access with permissions to read system views and msdb
- `SqlServer` PowerShell module

Install module:

```powershell
Install-Module SqlServer -Scope CurrentUser
```

Microsoft documents `Invoke-Sqlcmd` as the cmdlet used to run T-SQL scripts from PowerShell.  
Reference: https://learn.microsoft.com/en-us/powershell/module/sqlserver/invoke-sqlcmd

## Quick start

```powershell
cd .\scripts
.\Invoke-SqlHealthCheck.ps1 -ConfigPath ..\config\sample.config.json
```

## Example output
- `reports/HealthCheck_YYYYMMDD_HHMMSS.html`
- `reports/csv/*.csv`

## Portfolio talking points
- Uses PowerShell to orchestrate SQL checks
- Separates configuration, scripts and SQL logic
- Produces readable reports for technical and non-technical stakeholders
- Can be scheduled with Windows Task Scheduler or SQL Agent PowerShell job step

## Repository structure

```text
SQLServer-HealthCheck-Toolkit/
├── config/
│   └── sample.config.json
├── docs/
│   └── usage.md
├── reports/
│   └── sample-report.html
├── scripts/
│   └── Invoke-SqlHealthCheck.ps1
└── sql/
    ├── backup_status.sql
    ├── blocking_sessions.sql
    ├── database_status.sql
    ├── disk_space.sql
    ├── failed_jobs.sql
    ├── index_fragmentation.sql
    └── top_queries_cpu.sql
```
