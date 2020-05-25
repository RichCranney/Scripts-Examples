#### VARIABLE FILE OF XML ####
# Get current directory
$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path
# Add on the name of the variable file
$ScriptDir += "\variablesXML.xml"
# Getting the contents of the External Variable text file
# This file is store in plan text and is not in any special format
 
# We use the "raw" parameter here in Get-Content so that when we get the contents
# of the file so that our hashtable is not converted to an object
[xml]$program = Get-Content -Path $ScriptDir

# List all out
$program.Variables.Users[0]

# Write out all the variables contained in "$program" one by one
$program.Variables.Users[0].firstName
$program.Variables.Users[0].middleName
$program.Variables.Users[0].surName
$program.Variables.Users[0].address
$program.Variables.Users[0].phoneMobile
$program.Variables.Users[0].email
