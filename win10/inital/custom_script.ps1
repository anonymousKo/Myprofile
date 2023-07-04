If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
		Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $PSCommandArgs" -Verb RunAs
		Exit
	}

function Set-RegistryValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RegistryPath,
        
        [Parameter(Mandatory = $true)]
        [string]$ValueName,
        
        [Parameter(Mandatory = $true)]
        [int]$NewValue
    )

    if (Test-Path $RegistryPath) {
        Set-ItemProperty -Path $RegistryPath -Name $ValueName -Value $NewValue

        # Read the registry value
        $updatedValue = (Get-ItemProperty -Path $RegistryPath -Name $ValueName).$ValueName
        Write-Host "Updated value: $updatedValue"
    } else {
        Write-Host "Registry path or value not found."
    }
}

function speedUpShutdown {
	$regPath = "HKLM:\SYSTEM\CurrentControlSet\Control"
	$regName = "WaitToKillServiceTimeout"
	$newValue = 2000
	Set-RegistryValue -RegistryPath $regPath -ValueName $regName -NewValue $newValue
}

function addIndex {
	$rootDirectories = @(
		"D:\Program Files",
		"D:\Program Files (x86)"
		#,
		#"C:\Program Files",
		#"C:\Program Files (x86)"
	)
	$outputDirectory = "D:\index"

	# Ensure that the output directory exists
	if (-not (Test-Path $outputDirectory -PathType Container)) {
		New-Item -Path $outputDirectory -ItemType Directory | Out-Null
	}

	foreach ($rootDirectory in $rootDirectories) {
		# Recursively search for subdirectories in the root directory
		$subdirectories = Get-ChildItem -Path $rootDirectory -Directory

		# Loop through the subdirectories
		foreach ($subdirectory in $subdirectories) {
			# Search for executable files within the subdirectory
			$executableFiles = Get-ChildItem -Path $subdirectory.FullName -Filter "*.exe" -File -Recurse

			# Loop through the executable files
			$mainExecutable = $executableFiles | Sort-Object -Property Length -Descending | Select-Object -First 1
			if ($mainExecutable) {
				$shortcutFilePath = Join-Path -Path $outputDirectory -ChildPath "$($mainExecutable.Name).lnk"
				$shortcut = (New-Object -ComObject WScript.Shell).CreateShortcut($shortcutFilePath)
				$shortcut.TargetPath = $mainExecutable.FullName
				$shortcut.Save()
				Write-Host "$subdirectory Shortcut created: $shortcutFilePath"
			}
		}
	}

}


#speedUpShutdown
addIndex


Pause
