function Write-LogEntry {
param(
  [Parameter()]
  [ValidateNotNullOrEmpty()]
  [string]$logName,
  
  [Parameter()]
  [ValidateNotNullOrEmpty()]
  [string]$logEntry
)

  if (!(Test-Path $logName)) {
    New-Item -Type F $logName -force
  }
  
  $logDateTime=$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
  Add-Content -Path $logName -Value "$logDateTime  :  $logEntry"
}
