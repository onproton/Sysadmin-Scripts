$file1 = Import-Csv "c:\nmapresults.csv"

$master = @()
foreach($ping in $file1) {
	$a = $null
	if($ping.DeviceType -notlike "*switch*" -and $ping.devicetype -notlike "*WAP*" -and $ping.devicetype -notlike "*router*" -and $ping.DeviceType -notlike "*print*" -and $ping.DeviceType -notlike "*load balancer*" -and $ping.DeviceType -notlike "*firewall*" -and $ping.DeviceType -notlike "*storage*" -and $ping.DeviceType -notlike "*media*") {
		$ping.hostname = $ping.hostname.Trim(".hcps.internal")
		$a = $ping 
		$master += $a
	}
	else {
	}
	
}

$master | Export-Csv "c:\nmapservers.csv" -NoTypeInformation