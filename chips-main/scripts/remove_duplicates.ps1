# Supprime les fichiers en double dans le dossier `image` en se basant sur MD5.
# Garde le fichier avec le nom le plus petit (tri par nom).
$dir = "c:\Users\e6296083\Downloads\Nouveau dossier\chips\image"
$log = "c:\Users\e6296083\Downloads\Nouveau dossier\chips\scripts\dups_log.txt"

if (-not (Test-Path -LiteralPath $dir)) { Write-Error "Dossier introuvable: $dir"; exit 1 }
if (Test-Path $log) { Remove-Item -LiteralPath $log -Force }

Set-Location -LiteralPath $dir

$items = Get-ChildItem -File | ForEach-Object {
    $h = (Get-FileHash -LiteralPath $_.FullName -Algorithm MD5).Hash
    [PSCustomObject]@{ Name = $_.Name; FullName = $_.FullName; Hash = $h }
}

$groups = $items | Group-Object -Property Hash

foreach ($g in $groups) {
    if ($g.Count -le 1) { continue }
    $keep = $g.Group | Sort-Object Name | Select-Object -First 1
    Add-Content -Path $log -Value ("KEEP: " + $keep.Name)
    foreach ($dup in $g.Group | Where-Object { $_.Name -ne $keep.Name }) {
        try {
            Remove-Item -LiteralPath (Join-Path -Path $dir -ChildPath $dup.Name) -ErrorAction Stop
            Add-Content -Path $log -Value ("DELETE: " + $dup.Name)
        } catch {
            Add-Content -Path $log -Value ("ERROR DELETE: " + $dup.Name + " -> " + $_.Exception.Message)
        }
    }
}
Write-Output 'DUP_SCRIPT_DONE'