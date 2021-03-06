Add-PSSnapin VMware.VimAutomation.Core
Connect-VIServer -Server "vmware server here"
$array = Get-Content "c:\scripts\capstone.txt"
$master = @()

function create `
{
	param `
	(
		$hostname,
		$MacAddr
	)
	
	$o = New-Object psobject
	$o | Add-Member -MemberType NoteProperty -Name "Hostname" -Value $hostname
	$o | Add-Member -MemberType NoteProperty -Name "Mac Address" -Value $MacAddr
	$o
}


foreach($obj in $array){
	$NetworkCard = Get-vm | where { $_.Name -like $obj } | Get-NetworkAdapter
	$MacAddr = $NetworkCard.MacAddress
	$hostname = $obj
	$master += create $hostname $MacAddr
}
$master | Export-Csv $desktop\MacAddressesCIT.csv -NoTypeInformation
