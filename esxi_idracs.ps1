function Get-VMHostWSManInstance {
	param (
	[Parameter(Mandatory=$TRUE,HelpMessage="VMHosts to probe")]
	[VMware.VimAutomation.Client20.VMHostImpl[]]
	$VMHost,

	[Parameter(Mandatory=$TRUE,HelpMessage="Class Name")]
	[string]
	$class,

	[switch]
	$ignoreCertFailures,

	[System.Management.Automation.PSCredential]
	$credential=$null
	)

	$omcBase = "http://schema.omc-project.org/wbem/wscim/1/cim-schema/2/"
	$dmtfBase = "http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/"
	$vmwareBase = "http://schemas.vmware.com/wbem/wscim/1/cim-schema/2/"

	if ($ignoreCertFailures) {
		$option = New-WSManSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck
	} else {
		$option = New-WSManSessionOption
	}
	foreach ($H in $VMHost) {
		if ($credential -eq $null) {
			$hView = $H | Get-View -property Value
			$ticket = $hView.AcquireCimServicesTicket()
			$password = convertto-securestring $ticket.SessionId -asplaintext -force
			$credential = new-object -typename System.Management.Automation.PSCredential -argumentlist $ticket.SessionId, $password
		}
		$uri = "https`://" + $h.Name + "/wsman"
		if ($class -cmatch "^CIM") {
			$baseUrl = $dmtfBase
		} elseif ($class -cmatch "^OMC") {
			$baseUrl = $omcBase
		} elseif ($class -cmatch "^VMware") {
			$baseUrl = $vmwareBase
		} else {
			throw "Unrecognized class"
		}
		Get-WSManInstance -Authentication basic -ConnectionURI $uri -Credential $credential -Enumerate -Port 443 -UseSSL -SessionOption $option -ResourceURI "$baseUrl/$class"
	}
}

# Examples (make sure you are connected to an ESX server.)
# Get-VMHostWSManInstance -VMHost (Get-VMHost) -class CIM_Fan -ignoreCertFailures
# Get-VMHostWSManInstance -VMHost (Get-VMHost) -class VMware_Role -ignoreCertFailures
# Get-VMHostWSManInstance -VMHost (Get-VMHost) -class OMC_Card -ignoreCertFailures
# See http`://www.vmware.com/support/developer/cim-sdk/smash/u2/ga/apirefdoc/ for a list of classes.


#creates function to format a new object for each esxi host with the following parameters
function create {
	param(
		$vmname,
		$hostname,
		$IPAdd,
		$PorV,
		$DJ,
		$OS,
		$OU,
		$idrac,
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
	$o | Add-Member -MemberType NoteProperty -Name iDRAC -Value $idrac
	$o | Add-Member -MemberType NoteProperty -Name IO -Value $IO 
	
	$o
}

$cred = Get-Credential
Connect-VIServer -Server "w-sch-vcenter5.hcps.internal" -Credential $cred

$file1 = Import-Csv "c:\esxi_hosts_test.csv"

foreach($esxi in $file1){
	$info = Get-VMHostWSManInstance -VMHost (Get-VMHost "insert esxi host here") -ignoreCertFailures -class OMC_IPMIIPProtocolEndpoint
	$vmname = "N/A"
	$hostname = $esxi.hostname
	$IPAdd = $esxi.ipaddress
	$PorV = "Physical"
	$DJ = "No"
	$OS = $esxi.OS
	$OU = "N/A"
	$idrac = $info.IPv4Address
	$IO = $esxi.IO
	
	$master += create $vmname $hostname $PorV $DJ $OS $OU $idrac $IO
}

$master | Export-Csv "c:\esxi_hosts_drac.csv" -NoTypeInformation