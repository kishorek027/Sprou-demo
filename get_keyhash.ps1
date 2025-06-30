Write-Host "Getting Facebook Key Hash..." -ForegroundColor Green
Write-Host ""

$androidHome = "C:\Users\Kishore K\AppData\Local\Android\Sdk"
$keytool = "$androidHome\build-tools\34.0.0\keytool.exe"
$keystore = "$env:USERPROFILE\.android\debug.keystore"

Write-Host "Using keystore: $keystore" -ForegroundColor Yellow
Write-Host ""

if (Test-Path $keytool) {
    Write-Host "Keytool found. Extracting certificate..." -ForegroundColor Green
    
    # Export certificate
    & $keytool -exportcert -alias androiddebugkey -keystore $keystore -storepass android -keypass android | Out-File -FilePath "temp_cert.der" -Encoding ASCII
    
    if (Test-Path "temp_cert.der") {
        Write-Host "Certificate exported successfully!" -ForegroundColor Green
        
        # Convert to base64 using certutil
        certutil -encode temp_cert.der temp_cert.b64 | Out-Null
        
        if (Test-Path "temp_cert.b64") {
            Write-Host ""
            Write-Host "Your Facebook Key Hash is:" -ForegroundColor Cyan
            Write-Host ""
            
            # Read and display the base64 content
            $content = Get-Content "temp_cert.b64"
            $base64 = $content | Where-Object { $_ -notmatch "CERTIFICATE" -and $_ -notmatch "-----" }
            Write-Host $base64 -ForegroundColor White
            
            # Cleanup
            Remove-Item "temp_cert.der" -ErrorAction SilentlyContinue
            Remove-Item "temp_cert.b64" -ErrorAction SilentlyContinue
            
            Write-Host ""
            Write-Host "Done!" -ForegroundColor Green
        } else {
            Write-Host "Failed to create base64 file" -ForegroundColor Red
        }
    } else {
        Write-Host "Failed to export certificate" -ForegroundColor Red
    }
} else {
    Write-Host "Keytool not found at: $keytool" -ForegroundColor Red
    Write-Host "Please check your Android SDK installation" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") 