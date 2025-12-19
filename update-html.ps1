$localFile = "C:\AMK\index.html"
$containerName = "amk-test"
$containerPath = "/usr/share/nginx/html/index.html"

# Проверяем, что файл существует
if (-not (Test-Path $localFile)) {
    Write-Host "Файл $localFile не найден."
    exit
}

$lastWrite = (Get-Item $localFile).LastWriteTime

Write-Host "Запуск мониторинга $localFile ..."

while ($true) {
    Start-Sleep -Seconds 1
    $currentWrite = (Get-Item $localFile).LastWriteTime
    if ($currentWrite -ne $lastWrite) {
        # Файл изменился
        docker cp $localFile $containerName:`$containerPath
        docker exec $containerName nginx -s reload
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] index.html обновлён в контейнере."
        $lastWrite = $currentWrite
    }
}