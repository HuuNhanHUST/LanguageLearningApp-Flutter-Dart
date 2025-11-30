# Script test Rate Limiter với token tự động
# Chạy: .\run-rate-limiter-test.ps1

Write-Host "🚀 Bắt đầu test Rate Limiter..." -ForegroundColor Yellow

# Tạo token
Write-Host "`n📝 Tạo token JWT..." -ForegroundColor Cyan
$tokenOutput = node generate-test-token.js 2>&1
$token = $tokenOutput | Select-String "eyJhbGciOiJIUzI1NiIs" | Select-Object -First 1
$token = $token -replace '.*?(eyJ[^:]*)', '$1'

if ([string]::IsNullOrWhiteSpace($token)) {
    Write-Host "❌ Không thể tạo token!" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Token đã tạo thành công" -ForegroundColor Green

# Chạy test
Write-Host "`n🔥 Chạy test spam 15 requests..." -ForegroundColor Cyan
$env:TEST_TOKEN = $token
node test-rate-limiter.js
