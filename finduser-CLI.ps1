##############################################################################################
##  Find out what computers a user is logged into on the domain (User computers) by running the script
##  and entering in the requested logon id for the user.
##
##  Can take 3.5 minutes to run through all computers
##
##  This script requires the free Quest ActiveRoles Management Shell for Active Directory
##  snapin  http://www.quest.com/powershell/activeroles-server.aspx
##############################################################################################

Add-PSSnapin Quest.ActiveRoles.ADManagement -ErrorAction SilentlyContinue
$ErrorActionPreference = "SilentlyContinue"

# array for list of computers
$comparray = @()

# Display menu to CLI to get Department to search
# Uses the SelectFromList engine
Function Get-Dept {
    $choices = ("Claims","Underwriting","BSS","TSG","Finance-HR","Marketing-Admin-Training","All User Computers")
    $d = SelectFromList $choices " Department: "
     
    if ($d -ne $null) {
        $Global:Dept = $choices[$d]
        
        switch ($d){
            0 {$Global:root = 'van.com/Claims'}
            1 {$Global:root = 'van.com/Underwriting'}
            2 {$Global:root = 'van.com/BSS'}
            3 {$Global:root = 'van.com/TSG/Computers'} 
            4 {$Global:root = 'van.com/FINANCE&HR'}
            5 {$Global:root = 'van.com/MKT&ADM&TRN'}
            6 {$Global:root = 'van.com/Claims','van.com/MKT&ADM&TRN','van.com/Underwriting','van.com/BSS','van.com/TSG/Computers','van.com/FINANCE&HR','van.com/Computers'}
        }
    }
    else {
        write-host "`nPlease make a choice`n" -back black -fore red
    }
}

# Retrieve Username to search for, error checks to make sure the username
# is not blank and that it exists in Active Directory
Function Get-Username {
    $Global:Username = Read-Host "`nEnter username you want to search for"
    if ($Username -eq $null){
    	Write-Host "Username cannot be blank, please re-enter username!!!!!"
    	Get-Username}
    $UserCheck = Get-QADUser -SamAccountName $Username
    if ($UserCheck -eq $null){
    	Write-Host "`nInvalid username, please verify this is the logon id for the account"
    	Get-Username}
    else {
        Write-host "Username OK`n"}
}

# For SelectFromList function
Function isNumeric ($x) {
    $x2 = 0
    $isNum = [System.Int32]::TryParse($x, [ref]$x2)
    return $isNum
}

# Menu list engine
# use: SelectFromList $arrayOfChoices "Title " [-verbose]
Function SelectFromList {
    param([string[]]$List,[string]$Title="Choices",[switch]$verbose=$false)
    
    write-host $Title.padright(80) -back green -fore black
    $digits = ([string]$List.length).length
    $fmt = "{0,$digits}"
    
    #display selection list
    for ($LN=0; $LN -lt $List.length) {
        write-host ("  $fmt : $($List[$LN])" -f ++$ln)
        }
        
    #query user until valid selection is made	
    do {
        write-host ("  Please select from list (1 to {0}) or `"q`" to quit" -f ($list.length)) -back black -fore green -nonewline
        $sel = read-host " "
        if ($sel -eq "q") {
            write-host "  quiting selection per user request..." -back black -fore yellow
            exit
            }
        elseif (isNumeric $sel) {
            if (([int]$sel -gt 0) -and ([int]$sel -le $list.length)) {
                if ($verbose) {
                    write-host ("  You selected item #{0} ({1})" -f $sel,$List[$sel-1]) -back black -fore green
                    }
                }
            else {
                write-host "error: selection isn't in range"
                $sel = $null
                }
            }
        else {
            write-host "error: selection isn't a number or 'q' "
            $sel = $null
            }
        } until ($sel)
        
    # return the valid selction
    if (isNumeric $sel) {
        $sel = $sel - 1
        return $sel
    }
    else {write-host "Error in choice engine"}
}

# on-screen yes/no menu
# if yes, reprints the screen and the displays the successful findings
Function Opt-Out {
    $title = "Continue?"
    $message = "User found. Do you want to continue?"
    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", ""
    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", ""
    $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
    $result = $host.ui.PromptForChoice($title, $message, $options, 0) 
    switch ($result) {
            # yes
            0 {
                Boiler-Plate
                Show-Comparray-Result $comparray}
            # no
            1 { exit }
    }
}

# Prints a green plus with the line
Function Show-Plus {
    param ([string]$line)
    
    write-host "[+] " -fore green -nonewline
    write-host "$line"
}

# Prints the array, option of printing only the last item
# use: Show-Comparray-Result $array [-last]
Function Show-Comparray-Result {
    param ([string[]]$List,[switch]$last=$false)
  
    # debug
    # write-host "$List"
  
    # show only last item
    if($last) { 
        Show-Plus "$Username is logged on $($List[-1])" 
    }
    
    # loop through all items
    else {
        foreach ($c in $List) { 
            Show-Plus "$Username is logged on $c" 
        }
    }
}

# simple clear screen and boilerplate text
Function Boiler-Plate{
    clear-host 
    write-host "`nChecking for $Username in the $Dept department.`nA full network check can take up to 2 minutes:"
}

# Main function
# looks for computers in AD container, searches logged in users for the desired user, adds computer matches to array
Function Find-Users_in_Domain {
    Boiler-Plate

    $computers = Get-QADComputer -SearchRoot $root | where {$_.accountisdisabled -eq $false}

    foreach ($comp in $computers) {
        $Computer = $comp.Name
        if(Test-Connection -ComputerName $Computer -Count 1 -Quiet) {
        
            write-host "[*] Checked: $Computer "
        
            # get logged in users
            $proc = Get-WmiObject Win32_LoggedOnUser -ComputerName $Computer | Select Antecedent -Unique | %{“{0}” -f $_.Antecedent.ToString().Split(‘"‘)[3]}

            # Search for username
            # add computer name to array
		    ForEach ($p in $proc) {
                if ($p -eq $Username) {
			        $comparray = $comparray + $Computer
                    Show-Comparray-Result $comparray -last
                    Opt-Out
		        }
            }
        }
    }
}

Get-Dept

Get-Username

Find-Users_in_Domain
