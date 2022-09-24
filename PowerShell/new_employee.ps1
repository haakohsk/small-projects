# Script for adding new single user in Azure interactivly 
# Script dependencies:
# PowerShell 5.1 is ran as Administrator 
# ./connect_AzureAD is ran

# Known bug: "running scripts is disabled on this machine" - Run following command for fix.
# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine

$username = Read-Host -Prompt 'Input new username: '
Write-Host "UserPrincipalName is set to $username@haakohsk.onmicrosoft.com"

$userPrincipalName = $username + '@haakohsk.onmicrosoft.com'
# Write-Host $userPrincipalName

$FirstName = Read-Host -Prompt 'Input first name'
$LastName = Read-Host -Prompt 'Input last name'

# New-MsolUser gives warning if username is taken, and does not overwrite by default.
# script still continues. 
# todo: add script abort if username is taken

Write-Host "Full name is set to $FirstName $LastName"
$DisplayName = $FirstName + ' ' + $LastName

# important to set -ForceChangePassword to true. Forces user to change pwd on first sign-in
New-MsolUser -UserPrincipalName $userPrincipalName -DisplayName $DisplayName -FirstName $FirstName -LastName $LastName -UsageLocation "NO" -ForceChangePassword $true



# Will display not licensed even if 'yes' is chosen. License is still given.
# Double check with Get-MsolUser
$license = Read-Host -Prompt "Want to give user a license? [yes/no]"
if ( $license -eq 'yes' )
{
    Set-MsolUserLicense -UserPrincipalName $userPrincipalName -AddLicenses "haakohsk:DEVELOPERPACK_E5"
} elseif ( $license -eq 'no' ) {
    Write-Host "No license given to $userPrincipalName"
}

# Assign roles to new user
# Script struggles to read $user.objectId at times..
# Only works for 1 single role atm
$setRoles = Read-Host -Prompt "Want to set role for new user? [yes/no]"
if ( $setRoles -eq 'yes' )
{
    $user = Get-AzureADUser -Filter "userPrincipalName eq '$userPrincipalName'"
    $roleName = Read-Host -Prompt "What role should $DisplayName get? (e.g Guest User)"
    $roleDefinition = Get-AzureADMSRoleDefinition -Filter "displayName eq '$roleName'"
    New-AzureADMSRoleAssignment -DirectoryScopeId '/' -RoleDefinitionId $roleDefinition.Id -PrincipalId $user.objectId 
} 
else 
{
    Write-Host "No roles were set for $userPrincipalName"
}

# Add user to group (Attempt)
    # Gives "permission denied for some reason"
# $addToGroup = Read-Host -Prompt "Want to add user in group? [yes/no]"
# if ( $addToGroup -eq 'yes' ) 
# {
#     $user = Get-AzureADUser -Filter "userPrincipalName eq '$userPrincipalName'"
#     $groupName = Read-Host -Prompt "What group should $userPrincipalName be added to? (e.g HR)"
#     $groupDefinition = Get-AzureADGroup -Filter "displayName eq '$groupName'"
#     Add-AzureADGroupMember -ObjectId $groupDefinition.objectId -RefObjectId $user.objectId
# }

# Create the StrongAuthenticationRequirement Object
# Credit: https://lazyadmin.nl/powershell/powershell-enable-mfa-for-office-365-users/
$sa = New-Object -TypeName Microsoft.Online.Administration.StrongAuthenticationRequirement
$sa.RelyingParty = "*"
$sa.State = "Enabled"
$sar = @($sa)

# Enable MFA for user
Set-MsolUser -UserPrincipalName $userPrincipalName -StrongAuthenticationRequirements $sar

Write-Host "$userPrincipalName was created successfully."