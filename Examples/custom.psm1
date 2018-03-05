function Write-Message {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        [System.ConsoleColor]$Color = 'Red'
    )

    Write-Verbose "Starting Write-Message"

    if($PSCmdlet.ShouldProcess($Message, "Writing message")) {
        Write-TaskInfo -Message "Writing message: $Message" -Tag $Color

        Write-Host -Object $Message -ForegroundColor $Color
    }

    Write-Verbose "Complete Write-Message"
}

Register-SitecoreInstallExtension -Command Write-Message -As WriteMessage -Type Task

function Get-Color {
    [CmdletBinding()]
    param()

    Write-Verbose "Selecting random color"

    $selector = Get-Random -Minimum 0 -Maximum 15
    Write-Verbose "Selected number: $selector"

    $result = [System.ConsoleColor]$selector
    Write-Verbose "..returns color: $result"

    return $result

}

Register-SitecoreInstallExtension -Command Get-Color -As GetColor -Type ConfigFunction



