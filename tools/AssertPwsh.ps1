using namespace System.IO
using namespace System.Net

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$RequiredVersion
)
end {
    $targetFolder = $PSCmdlet.GetUnresolvedProviderPathFromPSPath(
        "$PSScriptRoot/../output/pwsh-$RequiredVersion")

    if ($IsWindows) {
        $downloadUrl = "https://github.com/PowerShell/PowerShell/releases/download/v$RequiredVersion/PowerShell-$RequiredVersion-win-x64.zip"
        $fileName = "pwsh-$RequiredVersion.zip"
        $nativeExt = ".exe"
    }
    else {
        $downloadUrl = "https://github.com/PowerShell/PowerShell/releases/download/v$RequiredVersion/powershell-$RequiredVersion-linux-x64.tar.gz"
        $fileName = "pwsh-$RequiredVersion.tar.gz"
        $nativeExt = ""
    }

    if (Test-Path "$targetFolder\pwsh$nativeExt") {
        return
    }

    if (-not (Test-Path $targetFolder)) {
        $null = New-Item $targetFolder -ItemType Directory -Force
    }

    $oldSecurityProtocol = [ServicePointManager]::SecurityProtocol
    try {
        & {
            $ProgressPreference = 'SilentlyContinue'
            [ServicePointManager]::SecurityProtocol = 'Tls12'
            Invoke-WebRequest -UseBasicParsing -Uri $downloadUrl -OutFile $targetFolder/$fileName
        }
    }
    finally {
        [ServicePointManager]::SecurityProtocol = $oldSecurityProtocol
    }

    if ($IsWindows) {
        $oldPreference = $global:ProgressPreference
        try {
            $global:ProgressPreference = 'SilentlyContinue'
            Expand-Archive -LiteralPath $targetFolder/$fileName -DestinationPath $targetFolder
        }
        finally {
            $global:ProgressPreference = $oldPreference
        }
    }
    else {
        tar -xf $targetFolder/$fileName --directory $targetFolder
        if ($LASTEXITCODE) {
            throw "Failed to extract pwsh tar for $RequiredVersion"
        }

        chmod +x $targetFolder/$fileName
        if ($LASTEXITCODE) {
            throw "Failed to set pwsh as executable at $targetFolder/$fileName"
        }
    }

    Remove-Item -LiteralPath $targetFolder/$fileName -Force -Confirm:$false
}
