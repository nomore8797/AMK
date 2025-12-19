# Путь к локальному файлу
$localFile = "C:\AMK\index.html"

# Имя контейнера
$containerName = "amk-test"

# Путь внутри контейнера
$containerPath = "/usr/share/nginx/html/index.html"

# Предыдущее время изменения файла
$lastWriteTime = (Get-Item $localFile).LastWriteTime

Write-Host "Автообновление index.html каждые 10 секунд. Ctrl+C для выхода."

while ($true) {
    Start-Sleep -Seconds 10

    $currentWriteTime = (Get-Item $localFile).LastWriteTime

    if ($currentWriteTime -gt $lastWriteTime) {
        # Файл обновлён
        docker cp "${localFile}" "${containerName}:${containerPath}"
        docker exec $containerName nginx -s reload
        Write-Host "$(Get-Date -Format 'HH:mm:ss') - Файл обновлён и Nginx перезагружен."
        $lastWriteTime = $currentWriteTime
    }
}