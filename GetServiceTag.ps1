# Feb 15, 2010
# http://gallery.technet.microsoft.com/ScriptCenter/en-us/ee7116ea-b0f2-42ce-9fe8-af9ff727a784
# Jordan Schroeder
#
# lookup a single computer, or search the entire AD
#

Add-PSSnapin Quest.ActiveRoles* -erroraction silentlycontinue

$server = $args[0]
$tempfile="c:\temp\foo.txt"

if ($server -eq $null) {
	$server = ""
}

write-host
Get-QADComputer $server | Select-Object -Property name | Export-Csv $tempfile

Import-Csv $tempfile | foreach{ 
	$a = Get-WmiObject Win32_BIOS -computername $_.name -erroraction silentlycontinue -errorvariable err
	$aname = $_.name
	
	if ($a -eq $null) { 
		write-host -foregroundcolor "red" "$aname not found or can't connect, could not get tag number"
	} else {
		$a = $a | select-object SerialNumber
		$b = $a.serialnumber
		write-host "Service tag for $aname :: $b"
	}
}

del $tempfile
