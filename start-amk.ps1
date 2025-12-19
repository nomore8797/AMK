# Параметры
$containerName = "amk-test"
$imageName = "nginx:alpine"
$localFile = "C:\AMK\index.html"
$containerPath = "/usr/share/nginx/html/index.html"
$port = 8080

# Останавливаем и удаляем старый контейнер (если есть)
if (docker ps -a --format "{{.Names}}" | Select-String $containerName) {
    Write-Host "Останавливаем и удаляем старый контейнер..."
    docker rm -f $containerName
}

# Запускаем новый контейнер с пробросом порта и монтированием файла
Write-Host "Запускаем новый контейнер..."
docker run -d -p $port:80 --name $containerName -v "$localFile":"$containerPath" $imageName

Write-Host "Контейнер запущен. Проверь в браузере: http://localhost:$port"