# Mar 1, 2010
# Jordan Schroeder
#
# enables and unlocks the user entered

# Check for arguments, grab username
if ($args[0]) { $samaccountName = $args[0] }
else {Write-Host "Must supply a valid username" }

# Determine if user exists
if (Get-ADUser $samaccountName){
	Unlock-ADAccount $samaccountName
	Enable-ADAccount $samaccountName
	$subject = $samaccountName + " scheduled unlock success"
}
else { 
	$subject = $samaccountName + " scheduled unlock failure"
}
	
# compose and send email notification of unlock result
$emailFrom = "<email address>"
$emailTo = "<email address"
$body = $subject
$smtpServer = "<smtp server>"
$smtp = new-object Net.Mail.SmtpClient($smtpServer)
$smtp.Send($emailFrom, $emailTo, $subject, $body)
