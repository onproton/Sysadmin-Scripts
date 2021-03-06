function create `
{
	param `
	(
		$hostname,
		$IP,
		$OS,
		$DType,
		$IO
	)
	
	$o = New-Object psobject
	$o | Add-Member -MemberType NoteProperty -Name "Hostname" -Value $hostname
	$o | Add-Member -MemberType NoteProperty -Name "IPAddress" -Value $IP
	$o | Add-Member -MemberType NoteProperty -Name "OperatingSystem" -Value $OS
	$o | Add-Member -MemberType NoteProperty -Name "Device Type" -Value $DType
	$o | Add-Member -MemberType NoteProperty -Name "IO" -Value $IO
	$o
}
[xml]$xml = gc 'c:\DMZscan.xml'
$desktop = [Environment]::GetFolderPath('Desktop')
$master = @()
$hostname = $null
$items = $xml.nmaprun.host
foreach($item in $items)
{
	IF($item.hostnames -ne "")
	{
		$hostname = $item.hostnames.hostname.name
	}
	ELSE
	{
		$hostname = "N/A"
	}
	$IP = $item.address.addr
	IF($item.os.osmatch.name.count -gt 1)
	{
		$OS = $item.os.osmatch.name -join ", "
	}
	ELSE
	{
		$OS = $item.os.osmatch.name
	}
	
	IF($item.os.osmatch.osclass.type.count -gt 1){
		$DType = $item.os.osmatch.osclass.type -join "/"
	}
	ELSE {
		$DType = $item.os.osmatch.osclass.type
	}
	IF($item.status.state -eq "up") {
		$IO = "On"
	}
	ELSE {
		$IO = "Off"
	}
	
	
	$master += create $hostname $IP $OS $DType $IO
}
$master | Export-Csv $desktop\DMZnmapresults.csv -NoTypeInformation