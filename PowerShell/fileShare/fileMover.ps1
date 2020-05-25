# Set parameters first
$fileMoverLogName=".\logs\fileMover_$(Get-Date -Format 'yyyyMMdd').log"
$sleepSecs=10
$successCount=3
$fileMoverList=".\fileMover.lst"
$processingFolder=".\processing"

Import-Module -Name ".\functions\logEntries.psm1"

# Rename the file so we know it is processing (we will push data back into a new file as we process)
Move-Item $fileMoverList "$fileMoverList.processing"

# Open the file and read line by line and assign to a variable
ForEach($line in Get-Content "$fileMoverList.processing") {
# Split the line into columns
  $filePath, $fileName, $outputPath, $lastChecked = $line.split("|")
# Check if the $lastChecked is null, if it is, we assume it is a new file to check and hasn't been checked before, so add a date in over 2 years ago
  if ([string]::IsNullOrEmpty($lastChecked)) {
    $lastChecked = (Get-Date).AddDays(-730)
  }
# Add this row back to the original file with current time for lastChecked
  $currentTimestamp = Get-Date
  Add-Content -Path $fileMoverList -Value $filePath'|'$fileName'|'$outputPath'|'$currentTimestamp
  Write-LogEntry -logName $fileMoverLogName -LogEntry "CHECK - $fileName, checking for files since $lastChecked"
# Now lets search the Inbound folder location for our files, which includes wildcard and last modified date!
  Get-ChildItem $filePath -Filter $fileName -Recurse | ? {$_.LastWriteTime -gt $lastChecked} |
  ForEach-Object {
# For each file that is found, make sure we aren't already processing it and if we aren't send it to mainMove process. If we are, ignore it.
    Write-LogEntry -logName $fileMoverLogName -LogEntry "FOUND - $($_.Name) found"
    if (!(Test-Path "$processingFolder\$($_.Name)")) {
      New-Item -Type F "$processingFolder\$($_.Name)" -force
      $mainMoveLogDate="$(Get-Date -Format 'yyyyMMdd')"
      $mainMoveLogName=".\logs\mainMove_$mainMoveLogDate.log"
      Write-LogEntry -logName $fileMoverLogName -LogEntry "FOUND - $($_.Name) sent for processing - further logs can be found in $mainMoveLogName"
      Start-Process -FilePath "powershell" -Argument ".\mainMove.ps1 -fileName '$($_.FullName)' -outputPath '$outputPath' -logName '$mainMoveLogName' -sleepSecs $sleepSecs -successCount $successCount"
    #-WindowStyle hidden 
    } else {
      Write-LogEntry -logName $fileMoverLogName -LogEntry "$($_.Name) already processing - ignoring file"
      Write-Output "$fileName already processing - alert to double check what has happened?"
    }
  }
}

# Remove "processing" file as processed now
Remove-Item "$fileMoverList.processing" -Force
