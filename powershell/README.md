# PowerShell

## History
to get all history
```PowerShell
cat (Get-PSReadlineOption).HistorySavePath

# equivalent of history | grep ""
# with filename and line numbers
Select-String "<search pattern>" (Get-PSReadlineOption).HistorySavePath

# just the commands
Get-Content (Get-PSReadlineOption).HistorySavePath | Select-String "<search pattern>" 
```

## Active Directory (AD) Commands

All groups which a user belongs to
```PowerShell
Get-ADUser -Identity account -Property MemberOf | Select-Object -ExpandProperty MemberOf | ForEach-Object { Get-ADGroup -Identity $_ }
```

All members of a group
```PowerShell
get-adgroupmember group | select name
```

Is the account locked out?
```PowerShell
Get-ADUser account -Properties * | Select-Object LockedOut
```

Recursive group membership (groups within groups)
```PowerShell
Get-ADGroupMember -Identity group | Select-Object -Property @{n="Username";e={$_.Name}}, @{n="AD Group";e={group}}, Department
```