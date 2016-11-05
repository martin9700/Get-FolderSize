Function Get-FolderSize
{
    <#
    .SYNOPSIS
        Get a list of folders and their size
    .DESCRIPTION
        Point the script at a folder and it will report all the subfolders and their size
    .PARAMETER Path
        Path that you point the script at.  All subfolders will be processed
    .INPUTS
        None
    .OUTPUTS
        None
    .EXAMPLE
        Get-FolderSize c:\Data

    .EXAMPLE
        Get-FolderSize \\server1\share1\data

    .NOTES
        Author:             Martin Pugh
        Twitter:            @thesurlyadm1n
        Spiceworks:         Martin9700
        Blog:               www.thesurlyadmin.com
      
        Changelog:
            11/04/16        Initial Release
    .LINK
        https://github.com/martin9700/Get-FolderSize
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [ValidateScript({ Test-Path $_ })]
        [string[]]$Path
    )

    Function Get-FriendlySize
    {
        Param (
            [int64]$Size
        )
        Switch ($Size) 
        {
            { $Size -gt 1pb } { "{0:N2} PB" -f ($Size / 1pb); Break }
            { $Size -gt 1tb } { "{0:N2} TB" -f ($Size / 1tb); Break }
            { $Size -gt 1gb } { "{0:N2} GB" -f ($Size / 1gb); Break }
            { $Size -gt 1mb } { "{0:N2} MB" -f ($Size / 1mb); Break }
            { $Size -gt 1kb } { "{0:N2} KB" -f ($Size / 1kb); Break }
            DEFAULT { "$Size B" }
        }
    }

    $Folders = Get-ChildItem -Path $Path -Directory | Sort Name
    If ($VerbosePreference -eq "Continue")
    {
        $Count = 1
        Write-Progress -Activity "Scanning Folders..." -Id 0 -PercentComplete 0
    }
    $Data = ForEach ($Folder in $Folders)
    {
        If ($VerbosePreference -eq "Continue")
        {
            Write-Progress -Activity "Scanning Folders..." -Status "$($Folder.Name)..." -Id 0 -PercentComplete (($Count / $Folders.Count) * 100)
            $Count ++
        }
        Get-ChildItem -Path "$($Folder.Fullname)\*" -File -Recurse | Measure-Object -Property Length -Sum | 
            Select @{Name="Name";Expression={ $Folder.Name }},
                @{Name="FolderSize";Expression={ $_.Sum }}
    }

    If ($VerbosePreference -eq "Continue")
    {
        Write-Progress -Activity "Scanning Folders" -Id 0 -Completed
    }

    $Data | Format-Table Name,@{Name="Size";Expression={ Get-FriendlySize $_.FolderSize };Align="Right"}
}
