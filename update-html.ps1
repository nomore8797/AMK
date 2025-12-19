# Путь к локальному файлу
$localFile = "C:\AMK\index.html"

# Имя контейнера
$containerName = "amk-test"

# Порт на хосте и в контейнере
$hostPort = 8080
$containerPort = 80

# Проверяем и удаляем старый контейнер
$existing = docker ps -a --filter "name=$containerName" --format "{{.ID}}"
if ($existing) {
    Write-Host "Удаляем старый контейнер $containerName ($existing)..."
    docker rm -f $containerName | Out-Null
}

# Запускаем новый контейнер
Write-Host "Запускаем новый контейнер $containerName..."
docker run -d -p $hostPort:$containerPort --name $containerName -v "$localFile:/usr/share/nginx/html/index.html" nginx:alpine

Write-Host "Контейнер $containerName запущен! Открой http://localhost:$hostPort"