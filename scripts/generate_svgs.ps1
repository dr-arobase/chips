# generate_svgs.ps1
# Génère des SVG placeholders pour atteindre 300 images "chips N" sans écraser les existants
# Usage: powershell -ExecutionPolicy Bypass -File scripts\generate_svgs.ps1

$imageDir = "c:\Users\e6296083\Downloads\Nouveau dossier\chips\image"
$target = 300

if (-not (Test-Path -LiteralPath $imageDir)) { Write-Error "Dossier image/ introuvable : $imageDir"; exit 1 }

# Collecte des numéros existants
$existing = Get-ChildItem -LiteralPath $imageDir -File | ForEach-Object {
    if ($_.Name -match '^chips\s+(\d+)\.') { [int]$matches[1] } else { $null }
} | Where-Object { $_ -ne $null } | Sort-Object -Unique

# Trouve les numéros manquants et génère jusqu'à $target
$next = 1
$created = 0
for ($i = 1; $i -le $target; $i++) {
    if ($existing -contains $i) { continue }
    $filename = "chips $i.svg"
    $path = Join-Path $imageDir $filename
    if (Test-Path -LiteralPath $path) { continue }

    # Génère un SVG simple et unique (forme + numéro)
    $svg = @"
<svg xmlns='http://www.w3.org/2000/svg' width='1200' height='900' viewBox='0 0 1200 900'>
  <rect width='100%' height='100%' rx='30' fill='#fff7f2'/>
  <g transform='translate(600,450)'>
    <g>
      <ellipse rx='420' ry='240' fill='#fff3e0' transform='rotate(-12)'/>
      <path d='M-300,-20 C-150,-180 150,-180 300,-20 C150,-60 -150,-60 -300,-20 Z' fill='#ffecd5' transform='rotate(6)'/>
    </g>
    <text x='0' y='30' text-anchor='middle' font-family='Nunito, sans-serif' font-size='80' font-weight='800' fill='#ff6b35'>Chips $i</text>
  </g>
</svg>
"@
    Set-Content -LiteralPath $path -Value $svg -Encoding UTF8
    $created++
}

Write-Host "Created $created SVG files (up to $target)." -ForegroundColor Green
