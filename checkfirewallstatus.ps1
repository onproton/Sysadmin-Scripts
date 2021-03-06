$file1 = Import-Csv "c:\testserverlist.csv"

$master = @()

foreach ($hostname in $file1) {

$a = netsh -r $hostname.Server advfirewall show allprofiles 

$domainprofile = $a | Select-String 'Domain Profile' -Context 2
$privateprofile = $a | Select-String 'Private Profile' -Context 2
$publicprofile = $a | Select-String 'Public Profile' -Context 2

$master += Write-Output $hostname.server $domainprofile $privateprofile $publicprofile


}

$master | Out-File "c:\firewallstatustest.txt" 