# Script test Rate Limiter với curl
# Sử dụng: .\test-rate-limiter.ps1

$API_URL = "http://localhost:5000/api/upload/audio"
$TOKEN = "your_test_token_here"  # Thay bằng token thực tế

# Tạo file audio giả
$dummyPath = "dummy-audio.mp3"
if (-not (Test-Path $dummyPath)) {
    # Tạo file 100KB
    $buffer = New-Object byte[] (100 * 1024)
    [System.IO.File]::WriteAllBytes($dummyPath, $buffer)
    Write-Host "✅ Tạo file audio dummy thành công" -ForegroundColor Green
}

Write-Host "`n🔥 Bắt đầu spam 15 requests đến $API_URL`n" -ForegroundColor Yellow

$successCount = 0
$rateLimitedCount = 0

for ($i = 1; $i -le 15; $i++) {
    try {
        $response = curl.exe -s -w "`n%{http_code}" `
            -X POST "$API_URL" `
            -H "Authorization: Bearer $TOKEN" `
            -F "audio=@$dummyPath"
        
        # Tách status code từ response
        $lines = $response -split "`n"
        $statusCode = $lines[-1]
        $body = $lines[0..($lines.Length-2)] -join "`n"
        
        Write-Host "Request #$i - Status: $statusCode" -ForegroundColor Cyan
        
        if ($statusCode -eq "200") {
            $successCount++
        } elseif ($statusCode -eq "429") {
            $rateLimitedCount++
            Write-Host "  ⚠️ Rate Limited!" -ForegroundColor Red
        }
    } catch {
        Write-Host "Request #$i - ❌ Error: $_" -ForegroundColor Red
    }
    
    # Chờ 100ms giữa các request
    Start-Sleep -Milliseconds 100
}

Write-Host "`n📊 Kết quả:" -ForegroundColor Green
Write-Host "✅ Requests thành công (200): $successCount"
Write-Host "🚫 Requests bị chặn (429): $rateLimitedCount"

if ($rateLimitedCount -gt 0 -and $successCount -eq 10) {
    Write-Host "`n✨ Rate Limiter hoạt động đúng! 10 requests được chấp nhận, những request sau bị chặn." -ForegroundColor Green
}
