# PowerShell

## History

Ensure you have >= PSReadLine version 2.0

```PowerShell
Get-Module -Name PSReadLine -ListAvailable
```

If outdated or missing, install/update it:
```PowerShell
Install-Module -Name PSReadLine -Force
```

Configure PSReadLine to save history 
```PowerShell
Set-PSReadLineOption -HistorySavePath "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt"
Set-PSReadLineOption -HistorySaveStyle SaveIncrementally
```

Press up or `Ctrl+R` to search through history.

to get all history
```PowerShell
cat (Get-PSReadlineOption).HistorySavePath

# equivalent of history | grep ""
# with filename and line numbers
Select-String "<search pattern>" (Get-PSReadlineOption).HistorySavePath

# just the commands
Get-Content (Get-PSReadlineOption).HistorySavePath | Select-String "<search pattern>" 

#For an alias

function Get-HistoryFile {
    Get-Content (Get-PSReadlineOption).HistorySavePath
}

```

For more informaton on [Command history](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_history?view=powershell-7.4), 
and the [Set-PSReadLineOption command](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_history?view=powershell-7.4)

## Aliases
Set-Alias -Name hist -Value hist

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