# Script avanzado para optimizar y limpiar archivos SVG para compatibilidad con GitHub
# Elimina clases CSS, grupos innecesarios y elementos que GitHub puede filtrar

Write-Host "Aplicando optimizacion profunda a todos los archivos SVG..." -ForegroundColor Green

# Cambiar al directorio icons
Set-Location -Path ".\icons"

# Obtener todos los archivos SVG
$svgFiles = Get-ChildItem -Filter "*.svg" -File
Write-Host "Encontrados $($svgFiles.Count) archivos SVG para optimizar" -ForegroundColor Yellow

# Crear respaldo antes de optimizar
$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backupDir = "..\svg-backup-advanced-$timestamp"
New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
Copy-Item *.svg $backupDir -Force
Write-Host "Respaldo creado en: $backupDir" -ForegroundColor Cyan

# Variables para estadisticas
$totalOriginalSize = 0
$totalOptimizedSize = 0
$processedFiles = 0

# Procesar cada archivo SVG
foreach ($file in $svgFiles) {
    Write-Host "Procesando: $($file.Name)" -ForegroundColor White
    
    # Obtener tamano original
    $originalSize = $file.Length
    $totalOriginalSize += $originalSize
    
    $filePath = $file.FullName
    
    try {
        # Leer el contenido del archivo
        $content = Get-Content -Path $filePath -Raw
        
        # Aplicar optimizaciones avanzadas
        
        # 1. Asegurar que tenga los atributos basicos necesarios
        if ($content -match '<svg[^>]*>') {
            $svgTag = $matches[0]
            
            # Verificar y anadir atributos esenciales si faltan
            if ($svgTag -notmatch 'xmlns=') {
                $svgTag = $svgTag -replace '<svg', '<svg xmlns="http://www.w3.org/2000/svg"'
            }
            if ($svgTag -notmatch 'width=') {
                $svgTag = $svgTag -replace '<svg', '<svg width="24"'
            }
            if ($svgTag -notmatch 'height=') {
                $svgTag = $svgTag -replace '<svg', '<svg height="24"'
            }
            
            $content = $content -replace '<svg[^>]*>', $svgTag
        }
        
        # 2. Eliminar comentarios XML y HTML
        $content = $content -replace '<!--[\s\S]*?-->', ''
        
        # 3. Eliminar todas las clases CSS (problematicas en GitHub)
        $content = $content -replace '\s+class="[^"]*"', ''
        
        # 4. Eliminar IDs complejos auto-generados
        $content = $content -replace '\s+id="[^"]*"', ''
        
        # 5. Eliminar atributos xmlns innecesarios duplicados
        $content = $content -replace '\s+xmlns:xlink="[^"]*"', ''
        
        # 6. Eliminar elementos <rect> vacios o transparentes que no aportan contenido
        $content = $content -replace '<rect[^>]*class="frame-background"[^>]*/?>', ''
        $content = $content -replace '<rect[^>]*rx="0"[^>]*ry="0"[^>]*width="24"[^>]*height="24"[^>]*/?>', ''
        
        # 7. Simplificar grupos anidados innecesarios
        # Eliminar grupos que solo contienen clases sin contenido util
        $content = $content -replace '<g[^>]*class="frame-container[^"]*"[^>]*>', ''
        $content = $content -replace '<g[^>]*class="fills"[^>]*>\s*</g>', ''
        $content = $content -replace '</g>\s*</g>\s*</g>\s*</g>\s*</g>', '</g>'
        
        # 8. Limpiar grupos vacios consecutivos
        do {
            $oldContent = $content
            $content = $content -replace '<g[^>]*>\s*</g>', ''
            $content = $content -replace '</g>\s*</g>', '</g>'
        } while ($content -ne $oldContent)
        
        # 9. Optimizar espacios en blanco
        $content = $content -replace '>\s+<', '><'
        $content = $content -replace '\s+', ' '
        
        # 10. Limpiar espacios al inicio y final
        $content = $content.Trim()
        
        # 11. Asegurar formato de una sola linea para elementos simples
        if ($content.Length -lt 1000) {
            $content = $content -replace '\r?\n', ''
        } else {
            # Para archivos mas grandes, mantener formato legible
            $content = $content -replace '><', ">`n<"
        }
        
        # 12. Eliminar atributos version si existen
        $content = $content -replace '\s+version="[^"]*"', ''
        
        # 13. Optimizar fill y stroke attributes
        $content = $content -replace 'fill-opacity="1"', ''
        $content = $content -replace 'stroke-opacity="1"', ''
        
        # Escribir el contenido optimizado
        [System.IO.File]::WriteAllText($filePath, $content, [System.Text.Encoding]::UTF8)
        
        # Obtener tamano optimizado
        $optimizedSize = (Get-Item $filePath).Length
        $totalOptimizedSize += $optimizedSize
        
        $savings = $originalSize - $optimizedSize
        $savingsPercent = if ($originalSize -gt 0) { [math]::Round(($savings / $originalSize) * 100, 2) } else { 0 }
        
        Write-Host "  Original: $originalSize bytes -> Optimizado: $optimizedSize bytes" -ForegroundColor Green
        Write-Host "  Ahorro: $savings bytes ($savingsPercent%)" -ForegroundColor Cyan
        
        $processedFiles++
        
    } catch {
        Write-Host "  Error procesando $($file.Name): $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Volver al directorio principal
Set-Location -Path ".."

# Mostrar estadisticas finales
$totalSavings = $totalOriginalSize - $totalOptimizedSize
$totalSavingsPercent = if ($totalOriginalSize -gt 0) { [math]::Round(($totalSavings / $totalOriginalSize) * 100, 2) } else { 0 }

Write-Host ""
Write-Host "============================================================" -ForegroundColor Magenta
Write-Host "OPTIMIZACION AVANZADA COMPLETADA" -ForegroundColor Magenta
Write-Host "============================================================" -ForegroundColor Magenta
Write-Host "Archivos procesados: $processedFiles de $($svgFiles.Count)" -ForegroundColor Yellow
Write-Host "Tamano original total: $totalOriginalSize bytes" -ForegroundColor White
Write-Host "Tamano optimizado total: $totalOptimizedSize bytes" -ForegroundColor White
Write-Host "Ahorro total: $totalSavings bytes ($totalSavingsPercent%)" -ForegroundColor Green
Write-Host "Backup guardado en: $backupDir" -ForegroundColor Cyan
Write-Host ""
Write-Host "Optimizaciones aplicadas:" -ForegroundColor Yellow
Write-Host "- Eliminacion de clases CSS" -ForegroundColor Gray
Write-Host "- Limpieza de IDs auto-generados" -ForegroundColor Gray
Write-Host "- Eliminacion de grupos innecesarios" -ForegroundColor Gray
Write-Host "- Eliminacion de elementos transparentes" -ForegroundColor Gray
Write-Host "- Optimizacion de espacios y formato" -ForegroundColor Gray
Write-Host "- Compatibilidad mejorada con GitHub" -ForegroundColor Gray
Write-Host ""
Write-Host "Todos los SVG ahora son compatibles con GitHub Markdown!" -ForegroundColor Green