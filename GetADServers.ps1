function make {
	param(
		$name,
		$IPv4Address,
		$OperatingSystem,
		$OU,
		$DJ
		)
		
	$o = New-Object psobject
	$o | Add-Member -MemberType NoteProperty -Name name -Value $name 
	$o | Add-Member -MemberType NoteProperty -Name IPv4Address -value $IPv4Address
	$o | Add-Member -MemberType NoteProperty -Name OperatingSystem -Value $OperatingSystem
	$o | Add-Member -MemberType NoteProperty -Name OU -Value $OU
	$o | Add-Member -MemberType NoteProperty -Name DJ -Value $DJ
	
	}



Import-Module ActiveDirectory
Get-ADComputer -Filter {OperatingSystem -like "*Server*"} -Properties * | Select-object Name,IPv4Address,OperatingSystem,CanonicalName | Export-Csv "c:\ADServerListTest.csv" -NoTypeInformation
