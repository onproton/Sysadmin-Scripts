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

$file1 = [collections.arraylist]@(Import-Csv "c:\masterlist.csv")
$file2 = Import-Csv "c:\nmapservers.csv"

$master = [collections.ArrayList]@()
$masterlist = [Collections.ArrayList]$file1

foreach($nmap in $file2){
	$IP = "*" + $nmap.IPAddress + "*"
	$hostname = "*" + ($nmap.Hostname.split('.') | select -first 1) + "*"
	#$referenceHN = $file1 | where {$file1.hostname -NE $null}
	$value = $null 
	$value = $file1 | where {$_.ipaddress -like $IP -or $_.hostname -like $hostname}
	IF($value -eq $null) {
		$master += $nmap
	}
}

foreach($item in $master){
	$vmname = "N/A"
	$hostname = ($item.Hostname.split('.') | select -First 1)
	$IPAdd = $item.ipaddress
	$PorV = "Unknown"
	$DJ = "Unknown"
	$OS = $item.operatingSystem
	$OU = "N/A"
	$IO = "On"
	
	$add = create $vmname $hostname $IPAdd $PorV $DJ $OS $OU $IO
	$masterlist.Add($add)
	}

$masterlist | Export-Csv "c:\MASTERLISTnmap.csv" -NoTypeInformation