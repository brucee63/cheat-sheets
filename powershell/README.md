# PowerShell

## History

Note: PSReadLine is installed by default in PowerShell versions 5.1 or later.

If you an older version of PowerShell, you can check to see if it's installed and configured properly.

Ensure you have >= PSReadLine version 2.0

```PowerShell
Get-Module -Name PSReadLine -ListAvailable
```

If outdated or missing, install/update it:
```PowerShell
Install-Module -Name PSReadLine -Force
```

Note that the following settings to save history are default in PowerShell 5.1 or later.
To check you default settings you can use the following command -

```PowerShell
Get-PSReadLineOption
```

Configure PSReadLine to save history, add to your PowerShell profile via `notepad $PROFILE` if on an older version of PowerShell, or if you want to override these default settings.
```PowerShell
Set-PSReadLineOption -HistorySavePath "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt"
Set-PSReadLineOption -HistorySaveStyle SaveIncrementally
Set-PSReadLineOption -MaximumHistoryCount 4096
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

## Grep 
Grep command that works like linux for piping results in

```PowerShell
function Grep-Command {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Pattern,

        [Parameter(ValueFromPipeline = $true)]
        [Alias("FilePath")]
        [string[]]$Path
    )

    begin {
        $inputLines = @()
    }

    process {
        # Collect input lines if piped data exists
        if ($null -ne $_) {
            $inputLines += $_
        }
    }

    end {
        if ($inputLines.Count -gt 0) {
            # If piped input exists, search it
            $inputLines | Select-String -Pattern $Pattern
        } elseif ($Path) {
            # If file paths are provided, search the files
            Select-String -Pattern $Pattern -Path $Path
        } else {
            Write-Error "No input provided. Either pipe input or specify a file."
        }
    }
}

```

## Aliases
For more on [Using Aliases](https://learn.microsoft.com/en-us/powershell/scripting/learn/shell/using-aliases?view=powershell-7.4)

Add to your profile, using `notepad $PROFILE`
```PowerShell 
Set-Alias -Name grep -Value Grep-Command
Set-Alias -Name hist -Value hist
```

## Active Directory (AD) Commands

Install the Rsat Tools
```PowerShell
Add-WindowsCapability -Online -Name "Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0"
```

Import the Active Directory Module 
```PowerShell
Import-Module ActiveDirectory
```

Verify Install
```PowerShell
Get-Module -ListAvailable ActiveDirectory
```

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