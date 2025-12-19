# Параметры
$localFile = "C:\AMK\index.html"
$containerName = "amk-test"
$containerPath = "/usr/share/nginx/html/index.html"

# Проверяем, что файл существует
if (-Not (Test-Path $localFile)) {
    Write-Host "Файл $localFile не найден!"
    exit
}

# Получаем время последнего изменения файла
$lastWrite = (Get-Item $localFile).LastWriteTime

Write-Host "Запущен мониторинг файла: $localFile"
Write-Host "Для выхода нажмите Ctrl+C"

while ($true) {
    Start-Sleep -Seconds 1
    $currentWrite = (Get-Item $localFile).LastWriteTime
    if ($currentWrite -ne $lastWrite) {
        # Файл изменился
        $dest = "$containerName:$containerPath"
        docker cp $localFile $dest
        docker exec $containerName nginx -s reload
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] index.html обновлён в контейнере."
        $lastWrite = $currentWrite
    }
}