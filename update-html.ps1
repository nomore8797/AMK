# Пути и контейнер
$localFile = "C:\AMK\index.html"
$containerName = "amk-test"
$containerPath = "/usr/share/nginx/html/index.html"

# Следим за временем изменения файла
$lastWrite = (Get-Item $localFile).LastWriteTime

while ($true) {
    Start-Sleep -Seconds 1
    $currentWrite = (Get-Item $localFile).LastWriteTime
    if ($currentWrite -ne $lastWrite) {
        try {
            # Копируем файл в контейнер
            & docker cp $localFile "${containerName}:$containerPath"
            # Перезагружаем nginx
            & docker exec $containerName nginx -s reload
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] index.html обновлён в контейнере."
        } catch {
            Write-Host "Ошибка при обновлении файла: $_"
        }
        $lastWrite = $currentWrite
    }
}