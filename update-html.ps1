# Параметры
$localFile = "C:\AMK\index.html"
$containerName = "amk-test"
$containerPath = "/usr/share/nginx/html/index.html"

# Проверка наличия файла
if (-not (Test-Path $localFile)) {
    Write-Host "Файл $localFile не найден!"
    exit
}

# Сохраняем время последнего изменения
$lastWrite = (Get-Item $localFile).LastWriteTime

Write-Host "Начинаем слежение за $localFile..."
while ($true) {
    Start-Sleep -Seconds 1
    $currentWrite = (Get-Item $localFile).LastWriteTime
    if ($currentWrite -ne $lastWrite) {
        # Файл изменился
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Файл изменился. Обновляем контейнер..."
        
        # Копируем файл в контейнер
        docker cp $localFile "$containerName:$containerPath"
        
        # Перезапускаем nginx внутри контейнера
        docker exec $containerName sh -c "nginx -s reload"
        
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Контейнер обновлён!"
        $lastWrite = $currentWrite
    }
}