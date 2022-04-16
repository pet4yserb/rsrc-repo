$OUpath = 'OU=Employees,dc=allsafe,dc=com'
$users = Get-ADUser -Filter * -SearchBase $OUpath | Select -ExpandProperty sAMAccountName
foreach ($user in $users) {
Add-Content -Path C:\Users\Administrator\Desktop\Userpass.txt -Value $user","Password123!
}