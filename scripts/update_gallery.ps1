# update_gallery.ps1
# Scanne le dossier image/, génère les <figure> triés et met à jour index.html
# Usage : powershell -ExecutionPolicy Bypass -File scripts\update_gallery.ps1

$imageDir = "c:\Users\e6296083\Downloads\Nouveau dossier\chips\image"
$htmlFile = "c:\Users\e6296083\Downloads\Nouveau dossier\chips\index.html"
$marker_start = "<!-- GALLERY:START -->"
$marker_end   = "<!-- GALLERY:END -->"

if (-not (Test-Path -LiteralPath $imageDir)) { Write-Error "Dossier image/ introuvable"; exit 1 }
if (-not (Test-Path -LiteralPath $htmlFile)) { Write-Error "index.html introuvable"; exit 1 }

$exts  = @('jpg','jpeg','png','webp','avif','gif','svg')
$re    = '^chips\s+(\d+)\.'

$files = Get-ChildItem -LiteralPath $imageDir -File |
    Where-Object { $exts -contains ($_.Extension.TrimStart('.').ToLower()) -and $_.Name -match $re } |
    Sort-Object  { [int]([regex]::Match($_.Name, $re).Groups[1].Value) }

if ($files.Count -eq 0) { Write-Warning "Aucune image trouvée dans $imageDir"; exit 0 }

# Génère les lignes HTML
$lines = @("        <!-- GALLERY:START -->")
foreach ($f in $files) {
    $num  = [regex]::Match($f.Name, $re).Groups[1].Value
    $name = [System.IO.Path]::GetFileNameWithoutExtension($f.Name)
    $cap  = "Chips $num"
    $lines += "        <figure class=`"chip-card`"><img src=`"/image/$($f.Name)`" alt=`"$cap`"><figcaption>$cap</figcaption></figure>"
}
$lines += "        <!-- GALLERY:END -->"
$galleryBlock = $lines -join "`n"

# Remplace le bloc entre les marqueurs dans index.html
$html = [System.IO.File]::ReadAllText($htmlFile, [System.Text.Encoding]::UTF8)
$pattern = "(?s)        <!-- GALLERY:START -->.*?        <!-- GALLERY:END -->"
$newHtml = [regex]::Replace($html, $pattern, $galleryBlock)
[System.IO.File]::WriteAllText($htmlFile, $newHtml, [System.Text.Encoding]::UTF8)

Write-Host "Galerie mise a jour : $($files.Count) images" -ForegroundColor Green
