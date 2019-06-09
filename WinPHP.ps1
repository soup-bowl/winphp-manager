param (
	[Parameter(Mandatory=$true)][string]$Operation,
	[string]$Version
)
New-Variable -Name "WinPHPLoc" -Value "https://windows.php.net/downloads/releases"

Function Get-Version {
	Write-Host "Version 0.1";
}

Function Invoke-PHPDownload {
	param( [string]$Version )

	if ( ! ( Test-Path -Path $Version ) ) { 
		Get-PHPDownload $Version
		Expand-Archive -Path "${env:temp}\win-php\php-${Version}.zip" -DestinationPath $Version
	} else {
		Write-Output "The requested PHP version exists in this directory."
	}
}

Function Get-PHPDownload {
	param(
		[string]$Version,
		[int]$Archive = $false
	)

	# Grab the PHP version suited to the current architecture.
	New-Variable -Name "CurrentArch"
	if ( [Environment]::Is64BitOperatingSystem ) {
		Set-Variable -Name "CurrentArch" -Value "x64"
	} else {
		Set-Variable -Name "CurrentArch" -Value "x86"
	}

	# Pull from Archive if requested.
	New-Variable -Name "RequestURL"
	if ( $Archive -eq $false ) {
		Set-Variable -Name "RequestURL" -Value "${WinPHPLoc}/php-${Version}-nts-Win32-VC15-${CurrentArch}.zip"
	} else {
		Set-Variable -Name "RequestURL" -Value "${WinPHPLoc}/archives/php-${Version}-nts-Win32-VC15-${CurrentArch}.zip"
	}

	New-Variable `
		-Name "DownloadLink" `
		-Value $RequestURL

	if( ! ( Test-Path -Path "${env:temp}\win-php" ) ) {
		New-Item -Path "${env:temp}\win-php" -ItemType "directory"
	}

	# Check if a cached download is available.
	if( Test-Path -Path "${env:temp}\win-php\php-${Version}.zip" ) {
		Write-Host "Extracting ${Version} from cache."
	} else {
		# Attempt to download the requested PHP version.
		try {
			Invoke-WebRequest `
				-Uri $DownloadLink `
				-OutFile "${env:temp}\win-php\php-${Version}.zip" `
				-ErrorAction Stop
		} catch [System.Net.WebException] {
			if ( $Archive -eq $false ) {
				Get-PHPDownload $Version $true
			} else {
				Write-Host "Unable to find the requested PHP version ${Version}, either current or archived."
				exit
			}
		}
	}
}

Invoke-PHPDownload $Version;