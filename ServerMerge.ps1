function create {
	param(
		$vmname,
		$hostname,
		$IPAdd,
		$PorV,
		$DJ,
		$OS,
		$OU,
		$IO
	)
	
	$o = New-Object psobject
	$o | Add-Member -MemberType NoteProperty -Name VMName -Value $vmname
	$o | Add-Member -MemberType NoteProperty -Name Hostname -Value $hostname 
	$o | Add-Member -MemberType NoteProperty -Name IPAddress -value $IPAdd
	$o | Add-Member -MemberType NoteProperty -Name PorV -Value $PorV
	$o | Add-Member -MemberType NoteProperty -Name DJ -Value $DJ
	$o | Add-Member -MemberType NoteProperty -Name OS -Value $OS
	$o | Add-Member -MemberType NoteProperty -Name OU -Value $OU
	$o | Add-Member -MemberType NoteProperty -Name IO -Value $IO 
	
	$o
}

#import the CSVs from the other processes
$file1 = Import-Csv "C:\ADServerList.csv"
$file1 = [Collections.ArrayList]$file1
$file2 = Import-Csv "C:\vmware_machines.csv"
$file3 = Import-Csv "C:\esxi_hosts.csv"


$master = [Collections.ArrayList]@()

#checks vmlist against AD list
foreach ($vm in $file2) {
	$AD = $null
	$reference = if($vm.hostname -ne "") {$vm.hostname} else {$vm.vmname}
	$AD = $file1 | where {$_.Name -eq $reference}
	#if vm not on ADList
	if($AD -eq $null){
		$vmname = $vm.vmname
		$hostname = $vm.hostname
		$ipaddress = $vm.ipaddress
		$PorV = $vm.PorV
		$DJ = "No"
		$OS = $vm.OS
		$OU = "N/A"
		$IO = $vm.io
		
		$add = create $vmname $hostname $ipaddress $PorV $DJ $OS $OU $IO
		$master.Add($add)
	}
	#If VM is on ADList
	else {
		$vmname = $vm.vmname
		$hostname = $AD.name
		$ipaddress = $AD.ipaddress + ", " + $vm.ipaddress 
		$ipaddress = $ipaddress.split(", ") | select -Unique
		$ipaddress = $ipaddress -join ", "
		$PorV = $vm.PorV
		$DJ = "Yes"
		$OS = if($vm.OS -ne ""){$vm.os} else {$AD.OperatingSystem}
		$OU = $AD.CanonicalName.Split("/")
		$OU = $OU | select -First ($OU.count -1)
		$OU = $OU -join "/"
		$IO = $vm.io
		
		$add = create $vmname $hostname $ipaddress $PorV $DJ $OS $OU $IO
		$master.Add($add)
		$file1.remove($AD)
	}
}

#Checks ADList against VM list for values not on VMList
foreach($PC in $file1){
	$vm = $null
	$reference = $PC.name
	$vm = $file2 | where {$_.vmname -eq $reference -or $_.hostname -eq $reference}
	if($vm -eq $null){
		$vmname = "N/A"
		$hostname = $PC.name
		$ipaddress = $PC.ipaddress  
		$PorV = "Physical"
		$DJ = "Yes"
		$OS = $PC.OperatingSystem
		$OU = $PC.CanonicalName.Split("/")
		$OU = $OU | select -First ($OU.count -1)
		$OU = $OU -join "/"
		$IO = if(test-connection $hostname -Quiet -Count 1){"Yes"} else {"No"}
		
		$add = create $vmname $hostname $ipaddress $PorV $DJ $OS $OU $IO
		$master.Add($add)
	}
}

foreach ($esxi in $file3) {
	$vmname = "N/A"
	$hostname = $esxi.Hostname
	$ipaddress = $esxi.IPaddress
	$PorV = "Physical"
	$compname = $hostname.split(".") | select -First 1
	$InAD = $null
	$InAD = Get-ADComputer $compname -ea "SilentlyContinue"
	$DJ = if($InAD -ne $null){"Yes"}ELSE{"No"}
	$OS = $esxi.os
	$OU = "N/A"
	$IO = $esxi.IO
	
	$add = create $vmname $hostname $ipaddress $PorV $DJ $OS $OU $IO
	$master.Add($add)
}

$master | Export-Csv "c:\MASTERLIST.csv" -notype

