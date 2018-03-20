<#
    Prepare Windows Server to support SIF installation
    Tested on Server 2016/2012r2

    NOTE: This should be ran on the machine where SIF will be executed.
#>

#Requires -RunAsAdministrator

param(
    [ValidateScript({Test-Path $_ })]
    [string]$Downloads = (Resolve-Path ~/Downloads)
)

# Check for PowerShell 5.1
$psversion = $PSVersionTable.PSVersion
if(!($psversion.Major -gt 4 -and $psversion.Minor -gt 0)) {
    throw "You must install WMF 5.1 to continue: https://www.microsoft.com/en-us/download/details.aspx?id=54616"
}

# Some utility functions to help in the script
Function ModuleAbsent ($Name){
    return $null -eq (Get-InstalledModule -Name $Name -ErrorAction SilentlyContinue)
}

Function PackageAbsent ($Name){
    return $null -eq (Get-Package -Name $Name -ErrorAction SilentlyContinue)
}

Function RepositoryAbsent ($Name) {
    return $null -eq (Get-PSRepository -Name $Name -ErrorAction SilentlyContinue)
}

Function ExecAndWait ($Path, $ExecArgs) {
    Start-Process -FilePath $Path -Wait -ArgumentList $ExecArgs
}

Function InstallPackage ($Source, $FileName, $InstallArgs = '/passive /norestart') {
    $destination = Join-Path $Downloads $FileName
    Invoke-WebRequest -Uri $Source -OutFile $destination
    ExecAndWait -Path $destination -ExecArgs $InstallArgs
}

### General Requirements - Helpful to check these are updated ###

# Ensure the nuget package provider is installed
Get-PackageProvider -Name Nuget -ForceBootstrap

###  Sitecore Platform - Requirements for the Sitecore Platform during runtime ###

# Windows Features
$windowsFeatures = @(
    'Net-Framework-45-ASPNET'   # ASP.Net Framework
    'Web-Server'                # IIS
    'Web-Mgmt-Tools'            # IIS GUI
    'Web-Asp-Net45'             # ASP.Net Framework in IIS
    'Web-Net-Ext45'             # .Net Framework in IIS
)
Install-WindowsFeature -Name $windowsFeatures

# Microsoft Visual C++ 2015 Redistributable Update 3
if(PackageAbsent 'Microsoft Visual C++ 2015 Redistributable (x64) - 14.0.24212') {
    InstallPackage -Source 'https://download.microsoft.com/download/6/D/F/6DF3FF94-F7F9-4F0B-838C-A328D1A7D0EE/vc_redist.x64.exe' -FileName  'cpp2015.exe' -InstallArgs '/install /passive /norestart'
}

### Sitecore Install - Requirements for install via Web Deploy ###

# Web Platform Installer - use to install other components
if(PackageAbsent 'Microsoft Web Platform Installer 5.0') {
    InstallPackage -Source 'https://download.microsoft.com/download/C/F/F/CFF3A0B8-99D4-41A2-AE1A-496C08BEB904/WebPlatformInstaller_amd64_en-US.msi' -FileName 'wpicmd.msi'
}

# Web Deploy 3.6 for Hosting Servers - Key component to install WDPs
# UrlRewrite module - Some WDPs contain web.configs using this IIS module
ExecAndWait -Path ([IO.Path]::Combine($env:ProgramFiles, 'Microsoft', 'Web Platform Installer', 'WebpiCmd-x64.exe')) -ExecArgs '/Install /AcceptEULA /SuppressReboot /Products:"WDeploy36PS,UrlRewrite2"'

# DacFx 2016 - x86 - Required for dacapacs inside of WDPs
if(PackageAbsent 'Microsoft SQL Server Data-Tier Application Framework (x86)') {
    InstallPackage -Source 'http://download.microsoft.com/download/E/4/1/E41A6614-9FB0-4675-8A97-08F8B1A1827D/EN/SQL13/x86/SQLSysClrTypes.msi' -FileName 'sqlclrTypes.x86.msi'
    InstallPackage -Source 'https://download.microsoft.com/download/5/E/4/5E4FCC45-4D26-4CBE-8E2D-79DB86A85F09/EN/x86/DacFramework.msi' -FileName  'dacfx.x86.msi'
}

# DacFx 2016 - x64 - Required for dacapacs inside of WDPs
if(PackageAbsent 'Microsoft SQL Server Data-Tier Application Framework (x64)') {
    InstallPackage -Source 'http://download.microsoft.com/download/E/4/1/E41A6614-9FB0-4675-8A97-08F8B1A1827D/EN/SQL13/amd64/SQLSysClrTypes.msi' -FileName 'sqlclrTypes.x64.msi'
    InstallPackage -Source 'https://download.microsoft.com/download/5/E/4/5E4FCC45-4D26-4CBE-8E2D-79DB86A85F09/EN/x64/DacFramework.msi' -FileName  'dacfx.x64.msi'
}

# Some configurations now require SqlCmd
if(PackageAbsent 'Microsoft Command Line Utilities 13 for SQL Server') {
    if(PackageAbsent 'Microsoft ODBC Driver 13 for SQL Server') {
        InstallPackage -Source 'https://download.microsoft.com/download/D/5/E/D5EEF288-A277-45C8-855B-8E2CB7E25B96/x64/msodbcsql.msi' -FileName 'sqlodbc.msi'  -InstallArgs '/passive /norestart IACCEPTMSODBCSQLLICENSETERMS=YES'
    }
    InstallPackage -Source 'https://download.microsoft.com/download/C/8/8/C88C2E51-8D23-4301-9F4B-64C8E2F163C5/x64/MsSqlCmdLnUtils.msi' -FileName 'sqlcmd.msi' -InstallArgs '/passive /norestart IACCEPTMSSQLCMDLNUTILSLICENSETERMS=YES'
}

# Register the Sitecore PowerShell Repository - This is where SIF is installed from
if(RepositoryAbsent SitecoreGallery){
    Register-PSRepository -Name SitecoreGallery -SourceLocation https://sitecore.myget.org/F/sc-powershell/api/v2 -InstallationPolicy Trusted
}

# Install Sitecore Installation Framework
if(ModuleAbsent SitecoreInstallFramework) {
    Install-Module -Name SitecoreInstallFramework -Repository SitecoreGallery
}
