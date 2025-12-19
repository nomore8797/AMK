# Параметры
$containerName = "amk-test"
$imageName = "nginx:alpine"
$localFile = "C:\AMK\index.html"
$containerPath = "/usr/share/nginx/html/index.html"
$port = 8080

# Проверяем, существует ли контейнер
$containerExists = docker ps -a --format "{{.Names}}" | Select-String $containerName

if ($containerExists) {
    Write-Host "Останавливаем и удаляем старый контейнер..."
    docker rm -f $containerName
}

# Запускаем новый контейнер с пробросом порта и монтированием файла
Write-Host "Запускаем новый контейнер..."
docker run -d -p $port:80 --name $containerName -v "$localFile":"$containerPath" $imageName

Write-Host "Контейнер запущен. Проверяй в браузере: http://localhost:$port"

# --- Автообновление ---
# Получаем время последнего изменения файла
$lastWrite = (Get-Item $localFile).LastWriteTime

Write-Host "Запущен мониторинг файла $localFile. Нажмите Ctrl+C для остановки."

while ($true) {
    Start-Sleep -Seconds 1
    $currentWrite = (Get-Item $localFile).LastWriteTime
    if ($currentWrite -ne $lastWrite) {
        docker cp $localFile "${containerName}:$containerPath"
        docker exec $containerName nginx -s reload
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] index.html обновлён в контейнере."
        $lastWrite = $currentWrite
    }
}