<#
    Prepare Sql Server to support Sitecore install via SIF
    Tested on Windows Server 2016/Sql Server 2016

    NOTE: This should be ran on the SQL server where databases will be installed

    You may receive errors when changing the contained mode.
    You may need to remove existing/databases users first.
#>
param(
    [string]$ServerName = ($env:COMPUTERNAME),
    [string]$UserName   = 'sa',
    [string]$Password   = '12345'
)

$isAdmin = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).Groups -match "S-1-5-32-544")
if($isAdmin -eq $false) {
    throw "You must run this script as an admin."
}

# Check for PS module
if($null -eq (Get-Module SqlPS -ErrorAction SilentlyContinue)) {
    throw "The SQL module is not available, are you sure SQL Server is installed?"
}

# Set contained database mode
$containdQuery = @"
sp_configure 'contained database authentication', 1;
GO
RECONFIGURE ;
GO
"@
Invoke-SqlCmd -Query $containdQuery -ServerInstance $ServerName -Username $UserName -Password $Password