# =============================================================================
# Pre-commit хук для автоматического форматирования Dart-файлов
# Запускается автоматически перед каждым коммитом
# =============================================================================

Write-Host "🔍 Запуск pre-commit проверок..." -ForegroundColor Cyan

# Получаем список изменённых .dart файлов, которые будут закоммичены
$stagedFiles = git diff --cached --name-only --diff-filter=ACM | Where-Object { $_ -match "\.dart$" }

# Если нет изменённых .dart файлов - пропускаем
if (-not $stagedFiles) {
    Write-Host "✅ Нет изменённых Dart-файлов для форматирования" -ForegroundColor Green
    exit 0
}

Write-Host "📝 Найдены изменённые Dart-файлы:" -ForegroundColor Yellow
$stagedFiles | ForEach-Object { Write-Host "   $_" }

Write-Host ""
Write-Host "🎨 Форматирование Dart-файлов..." -ForegroundColor Cyan

$formatFailed = $false

foreach ($file in $stagedFiles) {
    if (Test-Path $file) {
        Write-Host "   Форматирование: $file"
        dart format $file
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ Ошибка форматирования: $file" -ForegroundColor Red
            $formatFailed = $true
        } else {
            # Добавляем отформатированный файл обратно в индекс
            git add $file
        }
    }
}

if ($formatFailed) {
    Write-Host ""
    Write-Host "❌ Форматирование завершилось с ошибками" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "✅ Форматирование завершено успешно" -ForegroundColor Green
exit 0
