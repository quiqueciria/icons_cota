# Script para convertir SVGs a formato compatible con GitHub Markdown
# Basado en la estructura exitosa de icn_notass.svg

Write-Host "Script para conversion de SVGs a formato compatible con GitHub" -ForegroundColor Green
Write-Host "=============================================================" -ForegroundColor Cyan

# ESTRUCTURA REQUERIDA PARA GITHUB:
# 1. Atributos en orden especifico: width, height, xmlns, viewBox, fill
# 2. Contenido dentro de <g fill="#000">
# 3. Formato con saltos de linea
# 4. Sin grupos vacios ni clases CSS

function Convert-SVGToGitHubFormat {
    param(
        [string]$FilePath
    )
    
    Write-Host "Convirtiendo: $FilePath" -ForegroundColor Yellow
    
    # Leer contenido del archivo
    $content = Get-Content -Path $FilePath -Raw
    
    # PASO 1: Extraer el contenido de los paths
    $pathMatches = [regex]::Matches($content, '<path[^>]*>')
    $paths = @()
    foreach ($match in $pathMatches) {
        $pathContent = $match.Value
        # Limpiar clases CSS del path
        $pathContent = $pathContent -replace '\s+class="[^"]*"', ''
        # Asegurar que tenga fill="#000" si no lo tiene
        if ($pathContent -notmatch 'fill=') {
            $pathContent = $pathContent -replace '<path', '<path fill="#000"'
        }
        $paths += $pathContent
    }
    
    # PASO 2: Crear estructura GitHub-compatible
    $newContent = @"
<svg width="24" height="24" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none">
<g fill="#000">
$($paths -join "`n")
</g>
</svg>
"@
    
    # PASO 3: Escribir el archivo convertido
    [System.IO.File]::WriteAllText($FilePath, $newContent, [System.Text.Encoding]::UTF8)
    
    Write-Host "  Convertido exitosamente" -ForegroundColor Green
}

# PLANTILLA MANUAL PARA CONVERSION:
Write-Host ""
Write-Host "PLANTILLA PARA CONVERSION MANUAL:" -ForegroundColor Magenta
Write-Host "=================================" -ForegroundColor Magenta
Write-Host ""
Write-Host "ESTRUCTURA OBJETIVO:" -ForegroundColor Yellow
Write-Host @"
<svg width="24" height="24" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none">
<g fill="#000">
<path d="[CONTENIDO_DEL_PATH_1]"/>
<path d="[CONTENIDO_DEL_PATH_2]"/>
...
</g>
</svg>
"@ -ForegroundColor White

Write-Host ""
Write-Host "PASOS DE CONVERSION:" -ForegroundColor Yellow
Write-Host "1. Eliminar todos los grupos <g> con clases CSS" -ForegroundColor Gray
Write-Host "2. Eliminar elementos <rect> transparentes o vacios" -ForegroundColor Gray  
Write-Host "3. Extraer solo los elementos <path>" -ForegroundColor Gray
Write-Host "4. Aplicar estructura con atributos en orden exacto" -ForegroundColor Gray
Write-Host "5. Agrupar paths dentro de <g fill='#000'>" -ForegroundColor Gray
Write-Host "6. Formatear con saltos de linea" -ForegroundColor Gray

Write-Host ""
Write-Host "ATRIBUTOS CRITICOS (en este orden):" -ForegroundColor Yellow
Write-Host "- width='24'" -ForegroundColor Gray
Write-Host "- height='24'" -ForegroundColor Gray
Write-Host "- xmlns='http://www.w3.org/2000/svg'" -ForegroundColor Gray
Write-Host "- viewBox='0 0 24 24'" -ForegroundColor Gray
Write-Host "- fill='none'" -ForegroundColor Gray

Write-Host ""
Write-Host "EJEMPLO DE USO:" -ForegroundColor Yellow
Write-Host "Convert-SVGToGitHubFormat -FilePath 'icons\icn_ejemplo.svg'" -ForegroundColor White

Write-Host ""
Write-Host "Script guardado como referencia para conversiones futuras" -ForegroundColor Green