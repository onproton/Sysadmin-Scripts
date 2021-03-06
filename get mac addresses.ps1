$array = Get-Content c:\capstone.txt
$master = @()
Foreach ($obj in $array)
{
	IF(Test-Connection $obj -Count 1 -Quiet) 
	{
		$MAC = Get-WmiObject win32_networkadapterconfiguration -ComputerName $obj | select description, macaddress | where{$_.description -like "*MT Network Connection*"}
		$MAC = $MAC.macaddress
		$name = $obj 
		$IP = (Test-Connection $obj -Count 1).IPV4Address 
		$o = New-Object psobject
		$o | Add-Member -MemberType NoteProperty -Name "Name" -Value $name
		$o | Add-Member -MemberType NoteProperty -Name "MACAddress" -Value $MAC
		$o | Add-Member -MemberType NoteProperty -Name "IPAddress" -Value $IP
		$master += $o
	}
	ELSE 
	{
		$MAC = "Not Online"
		$IP = $MAC 
		$name = $obj 
		$o = New-Object psobject
		$o | Add-Member -MemberType NoteProperty -Name "Name" -Value $name
		$o | Add-Member -MemberType NoteProperty -Name "MACAddress" -Value $MAC
		$o | Add-Member -MemberType NoteProperty -Name "IPAddress" -Value $IP
		$master += $o
	}
}

$master | Export-Csv "c:\maclist.csv" -NoTypeInformation 