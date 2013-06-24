# created Jan 10, 2013
# author: Jordan Schroeder
#
# purpose: email managers with their department's user list for review 


Import-Module ActiveDirectory

$depts = @{
     'Claims' =         'manager@example.com'; 
     'Underwriting' =   'manager@example.com'; 
     'BSS' =            'manager@example.com'; 
     'TSG' =            'manager@example.com'; 
     'Administration' = 'manager@example.com'; 
     'Finance' =        'manager@example.com'; 
     'HR' =             'manager@example.com';
     'Marketing' =      'manager@example.com';}


# basic email module customized with audit review message
function sendMail($smtpServer, $from, $mgr, $users){

     # SMTP server name
     $subject = "Manager's Monthly review of user access"  

     $body = "Please review this user list to determine that those listed are authorized to have network access as a member of your department.<br><br>Reply to this email with either: <br>a) an indication that the list below is correct, or <br> b) changes that are required.<br><br>This monthly review is required for audits.<br><br>" 
     $body += $users

     send-MailMessage -SmtpServer $smtpServer -To $mgr -From $from -Subject $subject -Body $body -BodyAsHtml

}


$now = Get-Date
$header = 'Report run on:'

# for each department, email the user list to the department's manager
foreach ($dept in $depts.keys) {
     
     # skip TSG as a standalone department - it is combined in the BSS processing below
     if ($dept -eq 'TSG'){
        continue
     }    
     
      
     Write-Host "Processing $dept"
     
     $preamble = $dept,$header,$now

     $html = "<style>TABLE</style>"
     $userList = Get-ADUser -Filter {enabled -eq $true -and Department -eq $dept} | Select-Object GivenName,Surname | Sort-Object Surname | ConvertTo-Html -head $html


     # combine BSS and TSG
     if ($dept -like 'BSS'){
        $userList = Get-ADUser -Filter {enabled -eq $true -and (Department -eq "BSS" -or Department -eq "TSG")} | Select-Object GivenName,Surname | Sort-Object Surname | ConvertTo-Html -head $html
     }

     # combine user list with preamble
     $users = "$preamble `r`n$userList"

     # Extract manager email from hash table
     $mgr = $($depts.$dept) 

     Write-Host $users`r`n

     # send email to manager
     # sendMail <SMTPServer> <source address> $mgr $users
}

Write-Host "`r`n Email sent to all managers. Press any key to continue ..."

#$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

Write-Host