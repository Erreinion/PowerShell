#############
## author: Jordan Schroeder
## date: May 20, 2010
## sources: http://theessentialexchange.com/blogs/michael/archive/2008/02/04/Rename-Reboot-with-Powershell.aspx
#############

$computer = Read-Host "What is the current name of the computer to be renamed?" 
$newname = Read-Host "What is the new name of the computer?"


function renameFIC([string]$computer, [string]$newname)
{
        $comp = gwmi win32_computersystem  -computer $computer
        $os   = gwmi win32_operatingsystem -computer $computer

        $comp.Rename($newname)
        ##$os.Reboot()
}

Write-Host "Computer must be rebooted for changes to take effect..."
Write-Host "Exiting"
