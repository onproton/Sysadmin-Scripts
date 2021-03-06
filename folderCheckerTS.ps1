$computers = Import-Csv "C:\temp\computernames.csv" 

$master = @()

foreach ($computer in $computers) {
	$name = $computer | select -ExpandProperty name
	$folder1 = "\\$name\C$\_SMSTaskSequence"
	$testpath1 = Test-Path $folder1
	$folder2 = "C:\Program Files (x86)\Java\jre1.8.0_91"
	$testpath2 = Test-Path $folder2
	$folder3 =  "C:\Program Files\Microsoft Silverlight\5.1.41212.0"
	$testpath3 = Test-Path $folder3
	if ($testpath3 -eq $false){
		$master += $computer
	}
}

$master | Export-Csv "C:\temp\TSfail.csv" -NoTypeInformation

