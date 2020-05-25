#### VARIABLE FILE OF JSON ####
# Get current directory
$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path
# Add on the name of the variable file
$ScriptDir += "\variablesJSON.txt"

#Getting information from the json file
#The we pass the output from Get-Content to ConvertFrom-Json Cmdlet
$program = Get-Content $ScriptDir | ConvertFrom-Json
 
#Right now we have an array which means that we have to index
#an element to use it
$program.Users[0]
 
#When indexed we can call the attributes of the elements
$program.Users[0].firstName
$program.Users[0].middleName
$program.Users[0].surName
$program.Users[0].address
$program.Users[0].phoneMobile
$program.Users[0].email
