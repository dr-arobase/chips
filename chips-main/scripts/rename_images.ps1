# Renomme toutes les images du dossier `image` en "chips 1.ext", "chips 2.ext", ...
# Usage: Exécuter depuis PowerShell :
#   powershell -NoProfile -ExecutionPolicy Bypass -File "./scripts/rename_images.ps1"

$dir = "c:\Users\e6296083\Downloads\Nouveau dossier\chips\image"
if (-not (Test-Path -LiteralPath $dir)) {
    Write-Error "Le dossier $dir n'existe pas"
    exit 1
}
Set-Location -LiteralPath $dir

# Extensions acceptées
$exts = @('jpg','jpeg','png','webp','avif','gif')

# Récupère les fichiers d'images triés par nom
$files = Get-ChildItem -File | Where-Object { $exts -contains ($_.Extension.TrimStart('.').ToLower()) } | Sort-Object Name

# Première passe : renommer en tmp__ pour éviter collisions
$i = 1
foreach ($f in $files) {
    $ext = $f.Extension
    $target = "chips $i$ext"
    if ($f.Name -ieq $target) {
        # déjà correctement nommé
        $i++
        continue
    }
    $tmpName = "tmp__${i}__" + [guid]::NewGuid().ToString('N') + $ext
    Rename-Item -LiteralPath $f.FullName -NewName $tmpName
    $i++
}

# Deuxième passe : renommer tmp__ en chips N
$tmps = Get-ChildItem -File -Filter 'tmp__*' | Sort-Object Name
$j = 1
foreach ($f in $tmps) {
    $ext = $f.Extension
    $newName = "chips $j$ext"
    Rename-Item -LiteralPath $f.FullName -NewName $newName
    $j++
}

Write-Output "RENAMES_DONE"
