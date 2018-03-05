# Register Write-Host as a task
Register-SitecoreInstallExtension -Command Write-Host -As Write -Type Task

# Register Get-Random as a config function
Register-SitecoreInstallExtension -Command Get-Random -As GetRandom -Type ConfigFunction

# Overrwrite the out fo the box copy task
Register-SitecoreInstallExtension -Command Copy-Item -As Copy -Type Task -Force