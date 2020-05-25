# Ensure we have the parameters we need to move the file
param(
  [Parameter()]
  [ValidateNotNullOrEmpty()]
  [string]$fileNameFull=$(throw "fileNameFull is mandatory, investigate"),

  [Parameter()]
  [ValidateNotNullOrEmpty()]
  [string]$outputPath=$(throw "outputPath is mandatory, investigate"),

  [Parameter()]
  [ValidateNotNullOrEmpty()]
  [string]$logName=$(throw "logName is mandatory, investigate"),
  
  [Parameter()]
  [ValidateRange(10,600)]
  [int]$sleepSecs=$(throw "sleepSecs is mandatory, investigate"),
  
  [Parameter()]
  [ValidateRange(1,10)]
  [int]$successCount=$(throw "successCount is mandatory, investigate")
)

Import-Module -Name ".\functions\logEntries.psm1"

# Now do some checks to see if the file is still being transfered or if it has completed.
# We can do this by checking the file size every 30 seconds and when we have 3 itterations of the same,
# we can safely assume the file has stopped copying.

$currentCount=0
$currentLoop=0
$currentLength=(Get-Item $fileNameFull).length
$fileNameOnly=Split-Path $fileNameFull -leaf

do {
  $currentLoop++
  Write-LogEntry -logName $logName -LogEntry "$fileNameOnly  :  Currently working loop $currentLoop - Going to sleep for $sleepSecs seconds"
  Write-Output "Currently working loop $currentLoop - Going to sleep for $sleepSecs seconds"
  Start-Sleep -s $sleepSecs
  $previousLength=$currentLength
  $currentLength=(Get-Item $fileNameFull).length
  Write-LogEntry -logName $logName -LogEntry "$fileNameOnly  :  Checking filesizes before and after sleep // Current filesize=$currentLength // Previous filesize=$previousLength"
  Write-Output "Checking filesizes before and after sleep // Current filesize=$currentLength // Previous filesize=$previousLength"
  if ($currentLength -eq $previousLength) {
    $currentCount++
  } else {
    $currentCount=0
  }
  Write-LogEntry -logName $logName -LogEntry "$fileNameOnly  :  Checks successful - $currentCount / $successCount"
  Write-Output "Checks successful - $currentCount / $successCount"
} until($currentCount -eq $successCount)

# Checks complete, we assume file is okay now, so copy it
Write-LogEntry -logName $logName -LogEntry "$fileNameOnly  :  Copying file to $outputPath"
Write-Output "Copying file to $outputPath"
Copy-Item -Path $fileNameFull -Destination $outputPath -Recurse -ErrorAction SilentlyContinue -ErrorVariable processError
if ($processError) {
  Write-LogEntry -logName $logName -LogEntry "$fileNameOnly -  Error when copying file, continuing script"
}

# Remove processing file as now complete
Write-LogEntry -logName $logName -LogEntry "$fileNameOnly  :  Copy complete, removing processing file"
Write-Output "Copy complete, removing processing file"
Remove-Item ".\processing\$fileNameOnly" -force


Write-Output "RC stop here for 30 seconds to read output"
Start-Sleep -s 100
