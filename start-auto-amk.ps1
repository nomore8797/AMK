# Параметры
$containerName = "amk-test"
$imageName = "nginx:alpine"
$localFile = "C:\AMK\index.html"
$containerPath = "/usr/share/nginx/html/index.html"
$port = 8080

# Удаляем старый контейнер, если он есть
if (docker ps -a --format "{{.Names}}" | Select-String $containerName) {
    docker rm -f $containerName | Out-Null
}

# Запускаем новый контейнер
docker run -d -p $port:80 --name $containerName -v "$localFile":"$containerPath" $imageName | Out-Null
Write-Host "Контейнер $containerName запущен. Проверяй: http://localhost:$port"

# Автообновление index.html в отдельном окне
$script = @"
\$lastWrite = (Get-Item '$localFile').LastWriteTime
while (\$true) {
    Start-Sleep 1
    \$currentWrite = (Get-Item '$localFile').LastWriteTime
    if (\$currentWrite -ne \$lastWrite) {
        docker cp '$localFile' '${containerName}:$containerPath'
        docker exec $containerName nginx -s reload
        Write-Host '[\$(Get-Date -Format ''HH:mm:ss'')] index.html обновлён в контейнере.'
        \$lastWrite = \$currentWrite
    }
}
"@

Start-Process powershell -ArgumentList "-NoExit", "-Command $script"
Write-Host "Автообновление index.html запущено в отдельном окне."