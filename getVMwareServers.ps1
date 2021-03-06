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

$vms = Get-VM
$m = $vms.count
$i = 1
foreach($vm in $vms) {
	$name = $vm.name
	Write-Progress -Activity "Checking VM Guests" -Status "In Progress" -CurrentOperation $name -PercentComplete (($i/$m)*100)
	$guest = Get-VMGuest $name 
	$hostname = $guest.Hostname
	$IPAdd = $guest.IPAddress
	$IPAdd = $IPAdd -join ', '
	$PorV = "Virtual"
	$DJ = if($hostname -like "*.domain.here") {"Yes"} else{"No"}
	$OS = if($hostname -ne $null){$guest.OSFullName} else{(Get-View -viewtype virtualmachine -Filter @{"Name"=$name}).config.guestfullname}
	$IO = if($vm.powerstate -ne "PoweredOff"){"On"} else {"Off"}
	
	$master += create $name $hostname $IPAdd $PorV $DJ $OS $IO
	$i++
}

$master | Export-Csv "c:\vmware_machines.csv" -NoTypeInformation