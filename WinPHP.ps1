param (
	[Parameter(Mandatory=$true)][string]$Operation,
	[string]$Version
)
New-Variable -Name "WinPHPLoc" -Value "https://windows.php.net/downloads/releases"

Function Get-Version {
	Write-Host "Version 0.1";
}

Function Invoke-PHPDownload {
	param(
		[string]$Version
	)

	Get-Download $Version
}

Function Get-Download {
	param(
		[string]$Version,
		[int]$Archive = 0
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
	if ( $Archive -eq 0 ) {
		Set-Variable -Name "RequestURL" -Value "${WinPHPLoc}/php-${Version}-nts-Win32-VC15-${CurrentArch}.zip"
	} else {
		Set-Variable -Name "RequestURL" -Value "${WinPHPLoc}/archives/php-${Version}-nts-Win32-VC15-${CurrentArch}.zip"
	}

	New-Variable `
		-Name "DownloadLink" `
		-Value $RequestURL

	#Write-Host $RequestURL
	try {
		Invoke-WebRequest -Uri $DownloadLink -OutFile "php-${Version}.zip" -ErrorAction Stop
	} catch [System.Net.WebException] {
		Write-Verbose "An exception was caught: $($_.Exception.Message)"
		if ( $Archive -eq 0 ) {
			Get-Download $Version 1
		} else {
			Write-Host "Unable to find the requested PHP version ${Version}, on either live or archive."
			exit
		}
	}
}

Invoke-PHPDownload $Version;