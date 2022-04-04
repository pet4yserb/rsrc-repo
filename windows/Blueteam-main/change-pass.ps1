$users = Get-Content -path C:\Users\Administrator\Desktop\users.txt
foreach($user in $users)
{
$Password = ConvertTo-SecureString 'CHANGEME' -AsPlainText -Force
Set-LocalUser -Name $user -Password $Password
}
