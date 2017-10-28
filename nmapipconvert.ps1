$file1 = Import-Csv "c:\nmap165pings.csv"

$master = @()

foreach($obj in $file1){
	$string = $obj.item
	
	if($string.Contains("(")){
		$ipa = $string.Split("(")
		$ipa = $ipa[1]
		$ipa = $ipa.split(")")
		$ipa = $ipa[0]
	}
	else {
		$ipa = $string
	}
	
	$master += $ipa 
}

$master | Out-File 'c:\NmapIPList.txt'