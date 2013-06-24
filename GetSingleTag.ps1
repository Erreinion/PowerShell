# Feb 15, 2010
# http://gallery.technet.microsoft.com/ScriptCenter/en-us/ee7116ea-b0f2-42ce-9fe8-af9ff727a784
# Jordan Schroeder
#
# lookup a single service tag
#

Add-PSSnapin Quest.ActiveRoles* -erroraction silentlycontinue

$tag = $args[0]
$tempfile="c:\temp\foo.txt"

write-host
Get-QADComputer | Select-Object -Property name | Export-Csv $tempfile

Import-Csv $tempfile | foreach{
		$a = Get-WmiObject Win32_BIOS -computername $_.name -erroraction silentlycontinue -errorvariable err
		$aname = $_.name
		
		if ($a -eq $null) { 
			write-host -NoNewline "."
		} else {
			$a = $a | select-object SerialNumber
			$b = $a.serialnumber
			if($b -eq $tag){
				write-host
				write-host "Service tag for $aname :: $b"
				exit
			}
			else {
				write-host -NoNewline "."
			}
		}
	}	

del $tempfile
