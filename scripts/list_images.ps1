$dir = "c:\Users\e6296083\Downloads\Nouveau dossier\chips\image"
$re = '^chips\s+(\d+)\.'

$files = Get-ChildItem -LiteralPath $dir -File |
    Where-Object { $_.Name -match $re } |
    Sort-Object { [int]([regex]::Match($_.Name, $re).Groups[1].Value) }

Write-Output $files.Count
$files | ForEach-Object { $_.Name }
