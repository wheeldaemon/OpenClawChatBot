# OpenClaw Installer for Windows
# Repository: https://github.com/wheeldaemon/OpenClawChatBot
# Ключи запрашиваются ТОЛЬКО здесь, при установке!

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "    OpenClaw Interactive Installer" -ForegroundColor Cyan
Write-Host "    GitHub: wheeldaemon/OpenClawChatBot" -ForegroundColor Gray
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Проверка зависимостей
$git = Get-Command git -ErrorAction SilentlyContinue
$python = Get-Command python -ErrorAction SilentlyContinue
if (-not $python) { $python = Get-Command py -ErrorAction SilentlyContinue }

if (-not $git) {
    Write-Host "Git не найден! Установи: https://git-scm.com/download/win" -ForegroundColor Red
    exit 1
}

if (-not $python) {
    Write-Host "Python не найден! Установи: https://python.org/downloads/" -ForegroundColor Red
    exit 1
}

# === ИНТЕРАКТИВНЫЙ ВВОД ДАННЫХ (ТОЛЬКО ПРИ УСТАНОВКЕ) ===
Write-Host ""
Write-Host "Введи данные для конфигурации OpenClaw:" -ForegroundColor Yellow
Write-Host ""

$apiKey = Read-Host "OpenRouter API Key"
$modelName = Read-Host "Название модели (например: qwen/qwen-2.5-72b-instruct)"
$telegramBotId = Read-Host "Telegram Bot ID"
$telegramUserId = Read-Host "Telegram User ID"

# Клонирование
$repoUrl = "https://github.com/wheeldaemon/OpenClawChatBot"
$installDir = "$env:USERPROFILE\OpenClawChatBot"

Write-Host ""
Write-Host "Клонирую репозиторий..." -ForegroundColor Green

if (Test-Path $installDir) {
    Remove-Item -Recurse -Force $installDir
}

git clone $repoUrl $installDir
Set-Location $installDir

# Создание .env
$configContent = @"
OPENROUTER_API_KEY=$apiKey
OPENROUTER_MODEL=$modelName
TELEGRAM_BOT_ID=$telegramBotId
TELEGRAM_USER_ID=$telegramUserId
LOG_LEVEL=INFO
"@

$configContent | Out-File -FilePath ".env" -Encoding UTF8

# Python окружение
Write-Host "Создаю виртуальное окружение..." -ForegroundColor Green
python -m venv venv
& .\venv\Scripts\Activate.ps1

Write-Host "Устанавливаю зависимости..." -ForegroundColor Green
pip install --upgrade pip
pip install -r requirements.txt

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "    Установка завершена!" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Для запуска:" -ForegroundColor Yellow
Write-Host "  cd $installDir" -ForegroundColor White
Write-Host "  .\venv\Scripts\Activate.ps1" -ForegroundColor White
Write-Host "  python bot.py" -ForegroundColor White
