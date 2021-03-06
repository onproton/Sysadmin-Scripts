function create {
	param(
		$vmname,
		$hostname,
		$IPAdd,
		$PorV,
		$DJ,
		$OS,
		$IO
	)
	
	$o = New-Object psobject
	$o | Add-Member -MemberType NoteProperty -Name VMName -Value $vmname
	$o | Add-Member -MemberType NoteProperty -Name Hostname -Value $hostname 
	$o | Add-Member -MemberType NoteProperty -Name IPAddress -value $IPAdd
	$o | Add-Member -MemberType NoteProperty -Name PorV -Value $PorV
	$o | Add-Member -MemberType NoteProperty -Name DJ -Value $DJ
	$o | Add-Member -MemberType NoteProperty -Name OS -Value $OS
	$o | Add-Member -MemberType NoteProperty -Name IO -Value $IO 
	
	$o
}

$master = @() 

$cred = Get-Credential
Connect-VIServer -Server "vmware server here" -Credential $cred

$hosts = Get-VMhost

foreach($esxi in $hosts) {
	$vmname = "N/A"
	$hostname = $esxi.name
	Write-Progress -Activity "Checking VM Guests" -Status "In Progress" -CurrentOperation $hostname -PercentComplete (($i/$m)*100)
	$hostnic = $esxi | Get-VMHostNetworkAdapter 
	$IPAdd = $hostnic.IP | where {$_ -ne ""}
	$IPAdd = $IPAdd -join ", "
	$PorV = "Physical"
	$DJ = "No"
	$OS = "ESXi " + $esxi.version
	$IO = if($esxi.powerstate -ne "PoweredOff"){"On"} else {"Off"}
	
	$master += create $vmname $hostname $IPAdd $PorV $DJ $OS $IO
}

$master | Export-Csv "c:\esxi_hosts.csv" -NoTypeInformation