# Параметры
$containerName = "amk-test"
$imageName = "nginx:alpine"
$localFile = "C:\AMK\index.html"
$containerPath = "/usr/share/nginx/html/index.html"
$port = 8080

# Проверяем, что файл существует
if (-Not (Test-Path $localFile)) {
    Write-Host "Файл $localFile не найден!"
    exit
}

# Останавливаем и удаляем старый контейнер (если есть)
if (docker ps -a --format "{{.Names}}" | Select-String $containerName) {
    Write-Host "Останавливаем и удаляем старый контейнер..."
    docker rm -f $containerName
}

# Запускаем новый контейнер с пробросом порта и монтированием файла
Write-Host "Запускаем контейнер $containerName на порту $port..."
docker run -d -p $port:80 --name $containerName -v "$localFile":"$containerPath" $imageName

Write-Host "Контейнер запущен. Проверь в браузере: http://localhost:$port"

# Запускаем авто-обновление
$lastWrite = (Get-Item $localFile).LastWriteTime
Write-Host "Запущен мониторинг файла: $localFile"
Write-Host "Для выхода нажмите Ctrl+C"

while ($true) {
    Start-Sleep -Seconds 1
    $currentWrite = (Get-Item $localFile).LastWriteTime
    if ($currentWrite -ne $lastWrite) {
        $dest = "$containerName:$containerPath"
        docker cp $localFile $dest
        docker exec $containerName nginx -s reload
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] index.html обновлён в контейнере."
        $lastWrite = $currentWrite
    }
}