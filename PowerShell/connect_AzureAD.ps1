# Commands to connect to AzureAD with Windows PowerShell
Find-Module -Name AzureAD | Install-Module
Import-Module AzureAD
Connect-AzureAD

Find-Module -Name MSOnline | Install-Module
Import-Module MSOnline
Connect-MsolService