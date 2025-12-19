# Получаем обновления с удалённого репозитория
git fetch origin

# Получаем количество коммитов вперед/назад относительно origin/main
$ahead = git rev-list --count HEAD..origin/main
$behind = git rev-list --count origin/main..HEAD

if ($ahead -eq 0 -and $behind -eq 0) {
    Write-Host "✅ Ветка синхронизирована с origin/main"
} elseif ($ahead -gt 0 -and $behind -eq 0) {
    Write-Host "⚠️ Ветка локально впереди на $ahead коммит(ов). Нужно git push"
} elseif ($ahead -eq 0 -and $behind -gt 0) {
    Write-Host "⚠️ Ветка отстаёт от origin/main на $behind коммит(ов). Нужно git pull"
} else {
    Write-Host "⚠️ Ветка расходится: локально впереди $behind, отстаёт $ahead. Требуется merge"
}
