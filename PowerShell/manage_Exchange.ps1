# ------------------------------------------------------------------------------------------------------------------------------
# REQUIRED MODULES FOR RUNNING SCRIPT
# ------------------------------------------------------------------------------------------------------------------------------

Find-Module -Name AzureAD | Install-Module
Import-Module AzureAD
Connect-AzureAD

Find-Module -Name MSOnline | Install-Module
Import-Module MSOnline
Connect-MsolService

Find-Module -Name ExchangeOnlineManagement | Install-Module
Import-Module ExchangeOnlineManagement 
Connect-ExchangeOnline

Find-Module -Name MicrosoftTeams | Install-Module
Import-Module MicrosoftTeams
Connect-MicrosoftTeams

Import-Module Microsoft.Online.Sharepoint.PowerShell -DisableNameChecking

$AdminSiteURL="https://haakohsk-admin.sharepoint.com"
    
$Credential = Get-Credential
Connect-SPOService -url $AdminSiteURL -Credential $Credential

# Get all users in CyberDyne domain from exported csv file
Import-Csv -Path "path\to\csv\file" 
# ------------------------------------------------------------------------------------------------------------------------------


# ------------------------------------------------------------------------------------------------------------------------------
# CREATE DYNAMIC DISTRIBUTION LISTS
# ------------------------------------------------------------------------------------------------------------------------------
# https://docs.microsoft.com/en-us/powershell/module/exchange/new-dynamicdistributiongroup?view=exchange-ps
# ------------------------------------------------------------------------------------------------------------------------------

# Create dynamic distribution group for the different departments
New-DynamicDistributionGroup -Name "All HR" -IncludedRecipients "MailboxUsers" -ConditionalDepartment "HR"
New-DynamicDistributionGroup -Name "All IT" -IncludedRecipients "MailboxUsers" -ConditionalDepartment "IT"
New-DynamicDistributionGroup -Name "All Developer" -IncludedRecipients "MailboxUsers" -ConditionalDepartment "IT"

# Create dynamic distribution group for all employees
New-DynamicDistributionGroup -Name "CyberDyne Employees" -IncludedRecipients "MailboxUsers" -ConditionalCompany "CyberDyne"


# ------------------------------------------------------------------------------------------------------------------------------
# SECURITY FOR EXCHANGE
# ------------------------------------------------------------------------------------------------------------------------------
# https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/preset-security-policies?view=o365-worldwide
# ------------------------------------------------------------------------------------------------------------------------------

# Get Standard Policies for anti-malware, anti-spam & anti-phishing
Write-Output -InputObject ("`r`n" * 3), "Standard anti-malware policy", ("-" * 79);
Get-MalwareFilterPolicy | Where-Object -Property RecommendedPolicyType -eq -Value "Standard"; 
Write-Output -InputObject ("`r`n" * 3), "Standard anti-spam policy", ("-" * 79);
Get-HostedContentFilterPolicy | Where-Object -Property RecommendedPolicyType -eq -Value "Standard"; 
Write-Output -InputObject ("`r`n" * 3), "Standard anti-phishing policy", ("-" * 79);
Get-AntiPhishPolicy | Where-Object -Property RecommendedPolicyType -eq -Value "Standard"

# Get Strict Policies for anti-malware, anti-spam & anti-phishing
Write-Output -InputObject ("`r`n" * 3), "Strict anti-malware policy", ("-" * 79);
Get-MalwareFilterPolicy | Where-Object -Property RecommendedPolicyType -eq -Value "Strict"; 
Write-Output -InputObject ("`r`n" * 3), "Strict anti-spam policy", ("-" * 79);
Get-HostedContentFilterPolicy | Where-Object -Property RecommendedPolicyType -eq -Value "Strict"; 
Write-Output -InputObject ("`r`n" * 3), "Strict anti-phishing policy", ("-" * 79);
Get-AntiPhishPolicy | Where-Object -Property RecommendedPolicyType -eq -Value "Strict"


# ------------------------------------------------------------------------------------------------------------------------------
# SET STANDARD AND STRICT PRESET SECURITY POLICY 
# ------------------------------------------------------------------------------------------------------------------------------
# https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/preset-security-policies?view=o365-worldwide
# https://learn.microsoft.com/en-us/powershell/module/exchange/Set-atpprotectionpolicyrule?view=exchange-ps
# https://learn.microsoft.com/en-us/powershell/module/exchange/set-eopprotectionpolicyrule?view=exchange-ps
# ------------------------------------------------------------------------------------------------------------------------------

# Define Departments and users applicable to standard and strict preset policies
$AllEmployees = CyberDyneEmployees@haakohsk.onmicrosoft.com
$ITDepartment = it@haakohsk.onmicrosoft.com
# Get CEO & CTO from csv file
$CEO = Import-Csv -Path "path\to\users.csv" | Select-Object UserPrincipalName, jobTitle | Where-Object -Property jobTitle -eq CEO
$CTO = Import-Csv -Path "path\to\users.csv" | Select-Object UserPrincipalName, jobTitle | Where-Object -Property jobTitle -eq CTO

# Check if Standard Preset Security Policy is enabled/disabled
Get-EOPProtectionPolicyRule -Identity "Standard Preset Security Policy" | Format-Table Name, State
# Check if strict policy is enabled
Get-EOPProtectionPolicyRule -Identity "Strict Preset Security Policy" | Format-Table Name, State

# Turn on Standard Preset Security Policy
Enable-EOPProtectionPolicyRule -Identity "Standard Preset Security Policy" 
# Turn on Strict Preset Security Policy
Enable-EOPProtectionPolicyRule -Identity "Strict Preset Security Policy"

# Set Standard Preset Security Policy for every employee in the CyberDyneEmployee Dynamic distribution group
Set-EOPProtectionPolicyRule -Identity "Standard Preset Security Policy" -SentToMemberOf $AllEmployees
# Set Strict Preset Security Policy for every member of IT department + CEO & CTO of CyberDyne
Set-EOPProtectionPolicyRule -Identity "Strict Preset Security Policy"`
    -SentToMemberOf $ITDepartment`
-SentTo $CEO.UserPrincipalName, $CTO

# Apply Defender for Office 365 protection to the Standard Preset Security Policy for every CyberDyne Employee
Set-ATPProtectionPolicyRule -Identity "Standard Preset Security Policy" -SentToMemberOf $AllEmployees
# Apply Defender for Office 365 protection to the Strict Preset Security Policy for IT department + CEO & CTO of CyberDyne
Set-ATPProtectionPolicyRule -Identity "Strict Preset Security Policy"`
    -SentToMemberOf $ITDepartment`
-SentTo $CEO.UserPrincipalName, $CTO
# ------------------------------------------------------------------------------------------------------------------------------


# ------------------------------------------------------------------------------------------------------------------------------
# CREATE TEAMS CHANNELS & SHAREPOINT SITES 
# ------------------------------------------------------------------------------------------------------------------------------

# Get current teams for tenant
Get-Team | Select-Object DisplayName, description, GroupId, MailNickName

# Create shared channel for all employees
New-Team -DisplayName "All Employees Channel" `
    -Description "Group for all employees at CyberDyne Systems" `
    -Visibility "Public" `
    # This will be the endpoint for the SharePoint URL (e.g haakohsk.sharepoint.com/sites/all-employees)
    -MailNickName "all-employees"

# Get every unique department based on assigned departments in csv file (NOTE: -Path is unique to system being used)
$Departments = Import-Csv -Path "path\to\users.csv" | Select-Object department | ForEach-Object department | Get-Unique

# Create new private Teams channels & SharePoint for each department based on info from csv
foreach ($line in $Departments) {
    New-Team -DisplayName "$($line)" -Description "Group portal for $($line) employees" -Visibility "Private" -MailNickName $($line).toLower()
}

# Get all employees from csv and put in variable for later use
$Employees = Import-Csv -Path "path\to\users.csv" | Select-Object UserPrincipalName, department, companyName
$TeamChannels = @("Work", "Social")

# Get each groups specific GroupId
$AllEmployeesGroup = Get-Team | Where-Object -Property DisplayName -eq "All Employees Channel" | Select-Object GroupId
$HREmployeesGroup = Get-Team | Where-Object -Property DisplayName -eq "HR" | Select-Object GroupId
$ITEmployeesGroup = Get-Team | Where-Object -Property DisplayName -eq "IT" | Select-Object GroupId 
$DeveloperEmployeesGroup = Get-Team | Where-Object -Property DisplayName -eq "Developer" | Select-Object GroupId  

# Add every employee in CyberDyne to All Employees Channel
foreach ($line in $Employees | Where-Object -Property companyName -eq "CyberDyne Systems") {
    Add-TeamUser -GroupId $AllEmployeesGroup -User $line.UserPrincipalName -Role "Member"
}

# Create Work and Social channels within the "All employee group" in Teams
foreach ($line in $TeamChannels) {
    New-TeamChannel -GroupId $AllEmployeesGroup -DisplayName $line
}

# Add every employee in HR group to HR team
foreach ($line in $Employees | Where-Object -Property department -eq HR) {
    Add-TeamUser -GroupId $HREmployeesGroup -User $line.UserPrincipalName -Role "Member"
}

# Add every employee in IT group to HR team
foreach ($line in $Employees | Where-Object -Property department -eq IT) {
    Add-TeamUser -GroupId $ITEmployeesGroup -User $line.UserPrincipalName -Role "Member"
}

# Add every employee in Developer group to Developer team
foreach ($line in $Employees | Where-Object -Property department -eq Developer) {
    Add-TeamUser -GroupId $DeveloperEmployeesGroup -User $line.UserPrincipalName -Role "Member"
}


# ------------------------------------------------------------------------------------------------------------------------------
# CREATE MAILBOX/ROOM RESOURCE GENISYS & TANK
# ------------------------------------------------------------------------------------------------------------------------------

# Create Genisys & Tank rooms
Set-Mailbox "Genisys" -DisplayName "Genisys (12)" -EmailAddresses "genisys@haakohsk.onmicrosoft.com" -ResourceCapacity 12
Set-Mailbox "Tank" -DisplayName "Tank (8)" -EmailAddresses "tank@haakohsk.onmicrosoft.com" -ResourceCapacity 8

# Set password for Room Mailbox
Get-Mailbox -Identity "Genisys" | Set-Mailbox -EnableRoomMailboxAccount $true `
-RoomMailboxPassword (ConvertTo-SecureString -String "Th1s_1s_4_s3CuRe_P4$$W0rD" -AsPlainText -Force)

Get-Mailbox -Identity "Tank" | Set-Mailbox -EnableRoomMailboxAccount $true `
-RoomMailboxPassword (ConvertTo-SecureString -String "Th1s_1s_4_s3CuRe_P4$$W0rD" -AsPlainText -Force)

Add-MailboxPermission -Identity "Genisys" -Owner "skaufel@haakohsk.onmicrosoft.com"

# Give all employees full access to meeting rooms and their mailbox
foreach ($line in $Employees) {
    Add-MailboxPermission -Identity "Genisys" -User $line.UserPrincipalName -AccessRights FullAccess -InheritanceType All
    Add-MailboxPermission -Identity "Tank" -User $line.UserPrincipalName -AccessRights FullAccess -InheritanceType All
}


# ------------------------------------------------------------------------------------------------------------------------------
# SOME TEAMS SECURITY SETTINGS
# ------------------------------------------------------------------------------------------------------------------------------
# https://learn.microsoft.com/en-us/powershell/module/skype/set-csteamschannelspolicy?view=skype-ps
# ------------------------------------------------------------------------------------------------------------------------------

# Teams settings for all channels
Set-CsTeamsClientConfiguration -Identity Global -AllowDropBox $false -AllowEgnyte $false -AllowGoogleDrive $false -AllowBox $false

Set-CsTeamsChannelsPolicy -Identity Global `
    -AllowChannelSharingToExternalUser $false `
    -AllowPrivateTeamDiscovery $false `
    -AllowSharedChannelCreation $true


# ------------------------------------------------------------------------------------------------------------------------------
# SOME SHAREPOINT SECURITY SETTINGS
# ------------------------------------------------------------------------------------------------------------------------------
# Credit: https://learn.microsoft.com/en-us/answers/questions/616205/change-default-34site-sharing-settings34-for-new-s.html
# ------------------------------------------------------------------------------------------------------------------------------

# sharepoint online list all site collections powershell
$SiteColl = Get-SPOSite 
ForEach($Site in $SiteColl)
{
    Write-host $Site.Url
    # Prevents non-owners of a site from inviting new users to the site
    Set-SPOSite -Identity $Site.Url -DisableSharingForNonOwners
}
