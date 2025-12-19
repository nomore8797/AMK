# Путь к локальному файлу
$localFile = "C:/AMK/index.html"

# Имя контейнера
$containerName = "amk-test"

# Путь в контейнере
$containerPath = "/usr/share/nginx/html/index.html"

# Чтение текущего содержимого для сравнения
if (Test-Path $localFile) {
    $lastHash = (Get-FileHash $localFile -Algorithm SHA256).Hash
} else {
    $lastHash = ""
}

# Создаем FileSystemWatcher
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = "C:/AMK"
$watcher.Filter = "index.html"
$watcher.NotifyFilter = [System.IO.NotifyFilters]'LastWrite'

# Действие при изменении файла
$action = {
    $newHash = (Get-FileHash $using:localFile -Algorithm SHA256).Hash
    if ($newHash -ne $using:lastHash) {
        Write-Host "$(Get-Date -Format "HH:mm:ss") - Обнаружены изменения, обновляем контейнер..."
        docker cp "${using:localFile}" "${using:containerName}:${using:containerPath}"
        docker exec $using:containerName nginx -s reload
        Write-Host "$(Get-Date -Format "HH:mm:ss") - Контейнер обновлен."
        $using:lastHash = $newHash
    } else {
        Write-Host "$(Get-Date -Format "HH:mm:ss") - Изменений нет, пропускаем."
    }
}

# Привязываем событие
Register-ObjectEvent $watcher Changed -Action $action

# Включаем наблюдение
$watcher.EnableRaisingEvents = $true

Write-Host "Скрипт запущен. Отслеживание реальных изменений index.html..."
Write-Host "Контейнер будет обновляться только если содержимое файла изменилось."
Write-Host "Для остановки скрипта закройте PowerShell или нажмите Ctrl+C."