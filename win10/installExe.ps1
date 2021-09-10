
$path="./exe"
$exefiles=get-childitem -path $path -filter *.exe -Name
foreach ($exefile in $exefiles){
	Write-Output $exefile
	if (![string]::IsNullOrEmpty($exefile)){
	$exefile=$path+"/"+$exefile
	Write-Output $exefile
	start-process $exefile
	}
}

pause
