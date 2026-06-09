<#
.SYNOPSIS
Runs a SQL Server health check and creates CSV + HTML reports.

.EXAMPLE
.\Invoke-SqlHealthCheck.ps1 -ConfigPath ..\config\sample.config.json
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ConfigPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Import-RequiredModule {
    if (-not (Get-Module -ListAvailable -Name SqlServer)) {
        throw "SqlServer PowerShell module not found. Install it with: Install-Module SqlServer -Scope CurrentUser"
    }
    Import-Module SqlServer -ErrorAction Stop
}

function Invoke-HealthQuery {
    param(
        [string]$Name,
        [string]$SqlFile,
        [object]$Config
    )

    Write-Host "Running check: $Name"

    $params = @{
        ServerInstance = $Config.SqlInstance
        Database       = $Config.Database
        InputFile      = $SqlFile
        QueryTimeout   = 120
        ErrorAction    = 'Stop'
    }

    if (-not $Config.UseWindowsAuthentication) {
        $securePassword = ConvertTo-SecureString $Config.SqlPassword -AsPlainText -Force
        $credential = New-Object System.Management.Automation.PSCredential ($Config.SqlUsername, $securePassword)
        $params.Credential = $credential
    }

    Invoke-Sqlcmd @params
}

function Convert-ResultToHtmlSection {
    param(
        [string]$Title,
        [object[]]$Data
    )

    if (-not $Data -or $Data.Count -eq 0) {
        return "<h2>$Title</h2><p class='ok'>No rows returned.</p>"
    }

    $html = $Data | ConvertTo-Html -Fragment
    return "<h2>$Title</h2>$html"
}

Import-RequiredModule

$configFullPath = Resolve-Path $ConfigPath
$config = Get-Content $configFullPath -Raw | ConvertFrom-Json
$root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$sqlFolder = Join-Path $root 'sql'
$outputFolder = Join-Path $PSScriptRoot $config.OutputFolder
$csvFolder = Join-Path $outputFolder 'csv'
New-Item -ItemType Directory -Path $outputFolder -Force | Out-Null
New-Item -ItemType Directory -Path $csvFolder -Force | Out-Null

$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$checks = @(
    @{ Name = 'Database Status'; File = 'database_status.sql' },
    @{ Name = 'Backup Status'; File = 'backup_status.sql' },
    @{ Name = 'Disk Space'; File = 'disk_space.sql' },
    @{ Name = 'Failed SQL Agent Jobs'; File = 'failed_jobs.sql' },
    @{ Name = 'Blocking Sessions'; File = 'blocking_sessions.sql' },
    @{ Name = 'Index Fragmentation'; File = 'index_fragmentation.sql' },
    @{ Name = 'Top Queries by CPU'; File = 'top_queries_cpu.sql' }
)

$sections = @()
$summary = @()

foreach ($check in $checks) {
    $sqlFile = Join-Path $sqlFolder $check.File
    try {
        $data = @(Invoke-HealthQuery -Name $check.Name -SqlFile $sqlFile -Config $config)
        $csvPath = Join-Path $csvFolder (($check.Name -replace '[^a-zA-Z0-9]', '_') + "_$timestamp.csv")
        $data | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8
        $sections += Convert-ResultToHtmlSection -Title $check.Name -Data $data
        $summary += [pscustomobject]@{ Check = $check.Name; Status = 'OK'; Rows = $data.Count; Error = '' }
    }
    catch {
        $msg = $_.Exception.Message
        $sections += "<h2>$($check.Name)</h2><p class='critical'>ERROR: $msg</p>"
        $summary += [pscustomobject]@{ Check = $check.Name; Status = 'ERROR'; Rows = 0; Error = $msg }
    }
}

$summaryHtml = $summary | ConvertTo-Html -Fragment
$html = @"
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8" />
<title>SQL Server Health Check</title>
<style>
body { font-family: Segoe UI, Arial, sans-serif; margin: 32px; color: #222; }
h1 { color: #1f4e79; }
h2 { margin-top: 32px; color: #2f5597; }
table { border-collapse: collapse; width: 100%; margin-top: 10px; font-size: 13px; }
th { background: #1f4e79; color: white; text-align: left; }
th, td { border: 1px solid #ddd; padding: 6px; }
tr:nth-child(even) { background: #f7f7f7; }
.ok { color: #107c10; font-weight: 600; }
.critical { color: #c00000; font-weight: 600; }
.meta { color: #666; }
</style>
</head>
<body>
<h1>SQL Server Health Check Report</h1>
<p class="meta">Instance: $($config.SqlInstance) | Generated: $(Get-Date)</p>
<h2>Execution Summary</h2>
$summaryHtml
$($sections -join "`n")
</body>
</html>
"@

$reportPath = Join-Path $outputFolder "HealthCheck_$timestamp.html"
$html | Out-File -FilePath $reportPath -Encoding UTF8
Write-Host "Report created: $reportPath"
