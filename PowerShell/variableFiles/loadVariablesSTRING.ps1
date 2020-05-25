#### VARIABLE FILE OF STRING ####
# Get current directory
$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path
# Add on the name of the variable file
$ScriptDir += "\variablesSTRING.txt"
# Getting the contents of the External Variable text file
# This file is store in plan text and is not in any special format
 
# We use the "raw" parameter here in Get-Content so that when we get the contents
# of the file so that our hashtable is not converted to an object
$program = Get-Content -raw -Path $ScriptDir | ConvertFrom-StringData
 
# Set the contents of "$program" into Types, which makes it an object
$program.GetType()

# List all out
$program

# Write out all the variables contained in "$program" one by one
$program.firstName
$program.middleName
$program.surName
$program.address
$program.phoneMobile
$program.email
