#start-transcript -Append
Function usercheck
{
$User = Get-ADUser -LDAPFilter "(sAMAccountName=$AJP)"
If ($User -eq $Null) {"User does not exist in AD"}
Else {"User found in AD"}
}

$line = "`n ======================================================================================================================"
$path = 'ou=Application Disabled,Dc=itsamar,Dc=com'
$Password = (ConvertTo-SecureString -AsPlainText Password@123 -Force)
$server= Get-ADDomainController | select HOSTNAME |ForEach-Object -Process {$_.hostName} | out-string
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null
if (Get-Module -ListAvailable -Name ActiveDirectory) {
    Import-Module ActiveDirectory

###########################################################################

cls
do{
$line
Write-Host " `n                                                   iTSAMAR.COM " -foregroundcolor Green -erroraction Stop
$line
write-host "`n `n Welcome !!
 Logged in as $env:USERDOMAIN\$env:USERNAME and trying to connect DC server ..."
 write-host " `n Connected to $server `n " -nonewline -Foregroundcolor Green

###########################################################################

Write-host "                   1. USER DETAILS 

2. USER UNLOCK                          3. PASSWORD RESET

4. USER ENABLE                          5. USER DISABLE `n"

write-host "6. USER CREATION " -foregroundcolor gree -NoNewline
write-host "                       7. USER DELETION "-foregroundcolor Red

Write-host  "`n8. BULK USER CREATION FROM CSV " -ForegroundColor Yellow
write-host "`n9. ADD RDP ACCESS " -foregroundcolor cyan -nonewline ; write-host "                      10.REMOVE RDP ACCESS" -foregroundcolor red
write-host "`n11.ADD AD group " -foregroundcolor cyan -nonewline ; write-host "                        12.REMOVE AD group" -foregroundcolor red
Write-host  "`n Press 0 to QUIT "
write-host "`n Please make sure you're selecting correct option `n " -ForegroundColor Magenta
$input=Read-Host "`n Select the option (1-8)" 

############################################################################

switch ($input)
{
1{
do{ 
$AJP = [Microsoft.VisualBasic.Interaction]::InputBox("Enter the Username ", "userID", "XYZ")
write-host "`nAJP: " -nonewline 
write-host "$ajp" -BackgroundColor Yellow -ForegroundColor DarkRed
Get-ADUser $AJP -Properties * | select DisplayName, EmailAddress, Description, Department, Enabled , Lockedout |fl -Verbose
#$clip1 = Get-ADUser $ajp -Properties * | select samaccountname |ForEach-Object -Process {$_.samaccountname} | out-string
$clip2 = Get-ADUser $ajp -Properties * | select EmailAddress  |ForEach-Object -Process {$_.emailaddress -replace "@mitsamar.com" ,"" } | Out-String
$clip2.trim() | clip
Write-host "Group Membership Detail:" -ForegroundColor darkBlue -BackgroundColor green -NoNewline ; "`n"
Get-ADPrincipalGroupMembership $AJP | select name |ForEach-Object -Process {$_.Name}|fl -Verbose
$inflow =Read-host "`n Press ANY KEY to CHECK another user or 0 to re-direct back to HOME <- " 
}while ($inflow -ne 0)}

############################################################################
2{
do{ 
$AJP = [Microsoft.VisualBasic.Interaction]::InputBox("Enter the AJP ", "AJP", "AJP")
write-host "`nAJP: " -nonewline 
write-host "$ajp" -BackgroundColor Yellow -ForegroundColor DarkRed
if (Get-ADUser $ajp -Properties Lockedout |select Lockedout | ForEach-Object -Process {$_.Lockedout} )
{unlock-adaccount $ajp -confirm -Verbose
write-host "user is unlocked"}
else {write-host "User is NOT locked"}
$inflow =Read-host "`n Press ANY KEY to UNLOCK another user or 0 to re-direct back to HOME "
}while ($inflow -ne 0)
}
############################################################################
3{
do{
#$AJP = [Microsoft.VisualBasic.Interaction]::InputBox("Enter the AJP ", "AJP", "AJP")
$AJP=Read-host "Enter AJP"
write-host "`nAJP: " -nonewline 
write-host "$ajp" -BackgroundColor Yellow -ForegroundColor DarkRed
$tkt = Read-host "Enter the ticket # for Password reset"
Set-adaccountpassword $ajp -reset -newpassword $Password -CONFIRM -Verbose
Set-aduser $ajp -changepasswordatlogon $true
write-host "Password reset to " -Nonewline; Write-host "DEFAULT PASSWORD" -foregroundcolor DARKRED -backgroundcolor GREEN -NoNewline ; Write-host " for $AJP" -ForegroundColor Green -NoNewline; Write-host "(User must change pasword at next logon - ENABLED)"
$Result = "$tkt $ajp Pwd reset"
$Result | Set-Clipboard
$inflow =Read-host "`n Press ANY KEY to RESET for another user or 0 to re-direct back to HOME "
}while ($inflow -ne 0)
}
############################################################################
4{
do{
$AJP = [Microsoft.VisualBasic.Interaction]::InputBox("Enter the AJP ", "AJP", "AJP")
#$AJP=Read-host "Enter AJP"
write-host "`nAJP: " -nonewline 
write-host "$ajp" -BackgroundColor Yellow -ForegroundColor DarkRed
$tkt = Read-host "Enter the ticket # for LAN Enable"
Enable-adaccount $ajp -CONFIRM -Verbose
Write-host "$AJP is enabled"
$Result = "$tkt $ajp Enable"
$Result | Set-Clipboard
$inflow =Read-host "`n Press ANY KEY to ENABLE another user or 0 to re-direct back to HOME "
}while ($inflow -ne 0)
}
############################################################################
5{
do{
$AJP = [Microsoft.VisualBasic.Interaction]::InputBox("Enter the AJP ", "AJP", "AJP")
#$AJP=Read-host "Enter AJP"
write-host "`nAJP: " -nonewline 
write-host "$ajp" -BackgroundColor Yellow -ForegroundColor DarkRed
$tkt = Read-host "Enter the ticket # for LAN disable"
Disable-adaccount $ajp -CONFIRM -Verbose
Write-host "$AJP is Disabled"
$Result = "$tkt $ajp Disable"
$Result | Set-Clipboard
$inflow = Read-host "`n Press ANY KEY to DISABLE any user or 0 to re-direct back to HOME "
}while ($inflow -ne 0)
}
############################################################################
6{
do{
#collecting info
$fname = Read-Host "Enter First Name"
$lname = Read-host "Enter Last Name"
$AJP= Read-host "Enter AJP"
$ajp1= $ajp + "@itsamar.com"
$mail= Read-host "Enter mail address"
$description = Read-host "description"
$name = $fname + " " + $lname
#creation
New-ADUser -Name $name -GivenName $fname -Surname $lname -DisplayName $name -SamAccountName $ajp -UserPrincipalName $ajp1 -accountpassword $Password -ChangePasswordAtLogon $true -path $path -EmailAddress $mail -Description $description |Enable-ADAccount -whatif -confirm -verbose
#New-ADuser -Name $name -DisplayName $name -accountpassword $Password -ChangePasswordAtLogon $true -path $path -EmailAddress $mail -Description $description -UserPrincipalName $AJP1 |Enable-ADAccount
$inflow =Read-host "`n Press 0 to CREATE another user or ANY KEY to re-direct back to HOME "
}while ($inflow -ne 0)
}
############################################################################
7{
do{
$AJP=Read-host "Enter AJP"
write-host "`nAJP: " -nonewline 
write-host "$ajp" -BackgroundColor Yellow -ForegroundColor DarkRed
Get-ADUser $ajp -Properties * | select DisplayName, EmailAddress, Description, Department, Enabled |fl -Verbose
Write-host "Group Membership Details `n " -ForegroundColor darkBlue -BackgroundColor green
Get-ADPrincipalGroupMembership $AJP | select name |ForEach-Object -Process {$_.Name}|fl -Verbose
Get-ADUser $ajp -Properties * | select EmailAddress |ForEach-Object -Process {$_.emailaddress -replace "@itsamar.com",""} |clip
write-host "`n"
$tkt = Read-host "Enter the ticket# for deletion"
Get-ADUser $ajp -Properties * | select EmailAddress |ForEach-Object -Process {$_.emailaddress -replace "@itsamar.com",""} |clip
do{
$confirm=Read-host "Action taken on mail ID in itsamar.com ? (Y/N) "
} while ($confirm -ne "Y")
do{
$confirm=Read-host "Action taken on mail ID in itsamar.com? (Y/N) "
} while ($confirm -ne "Y")
Disable-adaccount $ajp -verbose
Remove-ADUser -Identity $ajp -confirm -verbose
write-host "`n $AJP" -ForegroundColor Red -BackgroundColor Yellow -NoNewline; " has been deleted successfully"
$Result = "$tkt $ajp Deletion"
$Result | Set-Clipboard
$inflow =Read-host "`n Press ANY KEY to DELETE another user or 0 to re-direct back to HOME "
}while ($inflow -ne 0)
}
############################################################################
8{
do{
$inflow =Read-host "`n Press ANY KEY for another BULK creation of another user or 0 to re-direct back to HOME "
}while ($inflow -ne 0)
}
############################################################################
9{
do{
$inflow =Read-host "`n Press ANY KEY for another RDC ACCESS or 0 to re-direct back to HOME "
}while ($inflow -ne 0)
}

############################################################################
10{
do{
$inflow =Read-host "`n Press ANY KEY to RESTRICT RDC access or 0 to re-direct back to HOME "
}while ($inflow -ne 0)
}

############################################################################
11{
do{
$inflow =Read-host "`n Press ANY KEY for another PATH ACCESS or 0 to re-direct back to HOME "
}while ($inflow -ne 0)
}

############################################################################
12{
do{
$inflow =Read-host "`n Press ANY to restrict PATH access or 0 to re-direct back to HOME "
}while ($inflow -ne 0)
}

############################################################################
#9{
#do{
#$inflow =Read-host "`n Press ANY for another user access or 0 to re-direct back to HOME "
#}while ($inflow -ne 0)
#}

############################################################################
#9{
#do{
#$inflow =Read-host "`n Press ANY for another user access or 0 to re-direct back to HOME "
#}while ($inflow -ne 0)
#}

############################################################################


}
} while ($input -ne '0')
} else{
     { 
     pause
     Start-Sleep 5seconds
     
    $end=Read-Host "Powershell module for AD is unavailable. Please install required modules manually |out=Null"
    Start-Sleep 5seconds
      Start-Sleep 5seconds
       Read-Host "The above error occurred. Press Enter to exit."
       Start-Sleep 5seconds
   }      
}
