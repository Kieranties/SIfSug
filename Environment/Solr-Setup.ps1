<#
    Prepare Solr with SSL running under nssm on Windows Server 2016
    (YMMV on other operating systems)

    NOTE: This should be ran on the machine where Solr will be hosted.
#>

param(
    [string]$Version        = '6.6.2',
    [string]$NssmVersion    = '2.24',
    [string]$Jre            ='jre-9.0.4',
    [int]$Port              = 8983,
    [string]$HostName       = 'localhost',
    [ValidateScript({ Test-Path $_ -Type Container})]
    [string]$DownloadPath   = (Resolve-Path ~/Downloads),
    [ValidateScript({ Test-Path $_ -Type Container})]
    [string]$InstallPath    = (Join-Path $env:SystemDrive '\')
)

# Check we have java available
if($null -eq (Get-Command java -ErrorAction SilentlyContinue)) {
    throw "Java must be installed."
}

$keyTool = [IO.Path]::Combine($env:ProgramFiles, 'Java', $jre, 'bin', 'keytool.exe')
# Check we have the expected jre key tool (used for certs later)
if(!(Test-Path $keyTool )){
    throw "Could not find key tool, is the jre version installed? [$keyTool]"
}

function Download ($FileName, $Source) {
    $destination = Join-Path $DownloadPath $FileName
    if(!(Test-Path $destination)) {
        Invoke-WebRequest -Uri $source -OutFile $destination
        Unblock-File -Path $destination
    }
    return $destination
}

function Install ($Name, $Version, $SourceFormat) {
    $installDestination = [IO.Path]::Combine($InstallPath, $Name, $Version)
    if(!(Test-Path $installDestination)) {
        $zip = Download -FileName "${Name}-${Version}.zip" -Source ($SourceFormat -f $Version)
        Expand-Archive -Path $zip -DestinationPath $installDestination
        # Move expanded content up one level
        $cleanupPath = Join-Path $installDestination ([IO.Path]::GetFileNameWithoutExtension($zip))
        Move-Item -Path "$cleanUpPath\*" -Destination $installDestination
        Remove-Item $cleanupPath
    }

    return $installDestination
}

# Install Requirements if not installed.
$solrDir = Install -Name Solr -Version $Version -SourceFormat 'https://archive.apache.org/dist/lucene/solr/{0}/solr-{0}.zip'
$nssmDir = Install -Name Nssm -Version $NssmVersion -SourceFormat 'https://nssm.cc/release/nssm-{0}.zip'

# Configure Solr

# Stop service if it exists
$solrServiceName =  "Solr-${Version}"
$currentService = $null -ne (Get-Service -Name $solrServiceName -ErrorAction SilentlyContinue)
if($currentService) {
    Stop-Service -Name $solrServiceName
}

# Configure Cert
try {
    Push-Location -Path ([IO.Path]::Combine($solrDir, 'server', 'etc'))
    # Generate Cert
    Remove-Item solr-ssl.keystore.jks -Force -ErrorAction SilentlyContinue
    Remove-Item solr-ssl.keystore.p12 -Force -ErrorAction SilentlyContinue
    . $keyTool -genkeypair -alias solr-ssl -keyalg RSA -keysize 2048 -keypass secret -storepass secret -validity 9999 -keystore solr-ssl.keystore.jks -ext SAN=DNS:$HostName,IP:127.0.0.1 -dname "CN=$HostName, OU=Organizational Unit, O=Organization, L=Location, ST=State, C=Country"
    . $keyTool -importkeystore -srckeystore solr-ssl.keystore.jks -destkeystore solr-ssl.keystore.p12 -srcstoretype jks -deststoretype pkcs12 -deststorepass secret -srcstorepass secret -destkeypass secret -noprompt

    # Trust
    Import-PfxCertificate -FilePath solr-ssl.keystore.p12 -CertStoreLocation Cert:\LocalMachine\Root -Password (ConvertTo-SecureString secret -AsPlainText -Force)
} finally {
    Pop-Location
}

# Configure Solr Environment

# Update Solr startup env
$solrcmdFile = [IO.Path]::Combine($solrDir, 'bin', 'solr.in.cmd')
$solrcmdFileBak = [IO.Path]::Combine($solrDir, 'bin', 'solr.in.cmd.bak')
# Ensure original file exists if missing
if(!(Test-Path $solrcmdFileBak)) {
    Copy-Item -Path $solrcmdFile -Destination $solrcmdFileBak
}

$solrcmdContent = (Get-Content -Path $solrcmdFileBak)
# Ensure using SSL
$solrCmdContent = $solrCmdContent.Replace('REM set SOLR_SSL_KEY', 'set SOLR_SSL_KEY')
$solrCmdContent = $solrCmdContent.Replace('REM set SOLR_SSL_TRUST', 'set SOLR_SSL_TRUST')
$solrCmdContent = $solrCmdContent.Replace('REM set SOLR_SSL_NEED', 'set SOLR_SSL_NEED')
$solrCmdContent = $solrCmdContent.Replace('REM set SOLR_SSL_WANT', 'set SOLR_SSL_WANT')
# Update the host
$solrCmdContent = $solrCmdContent.Replace('REM set SOLR_HOST=192.168.1.1', "set SOLR_HOST=$HostName")
$solrCmdContent | Set-Content -Path $solrcmdFile

# Add host header entry if required
if($HostName -ne 'localhost') {
    $hostsFile = "${env:systemDrive}\windows\system32\drivers\etc\hosts"
    $pattern = '^\s*' + [Regex]::Escape('127.0.0.1') + '\s*' + [Regex]::Escape($HostName) + '\s*$'
	$existingEntries = @((Get-Content -Path $hostsFile -Encoding UTF8)) -match $pattern
	if($existingEntries.Count -eq 0) {
		Add-Content -Path $hostsFile -Value "`n127.0.0.1`t$HostName" -Encoding UTF8
	}
}

# Add java home to solr start
Add-Content -Path $solrcmdFile -Value "set JAVA_HOME=`"$([IO.Path]::Combine($env:ProgramFiles, 'Java', $jre))`""

# Configure Solr to run under Nssm
$nssmExe = [IO.Path]::Combine($nssmDir, 'win64', 'nssm.exe')
if($currentService) {
    . $nssmExe remove $solrServiceName confirm
}
. $Nssmexe install $solrServiceName ([IO.Path]::Combine($solrDir, 'bin', 'solr.cmd')) -f -p $Port
Start-Service $solrServiceName