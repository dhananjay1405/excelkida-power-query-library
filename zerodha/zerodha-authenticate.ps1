$apiKey = Read-Host "Enter your Zerodha API Key"
$apiSecret = Read-Host "Enter your Zerodha API Secret" -AsSecureString
$requestToken = Read-Host "Enter your Zerodha Request Token"
$apiSecretPlainText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($apiSecret))
$hashCombination = $apiKey + $requestToken + $apiSecretPlainText
$stringAsStream = [System.IO.MemoryStream]::new()
$writer = [System.IO.StreamWriter]::new($stringAsStream)
$writer.Write($hashCombination)
$writer.Flush()
$stringAsStream.Position = 0
$fileHash = Get-FileHash -InputStream $stringAsStream
$checksum = $fileHash.Hash.ToLower()
$reqHeaders = @{
    "X-Kite-Version" = "3"
}
$reqBody = @{
    "api_key" = $apiKey
    "request_token" = $requestToken
    "checksum" = $checksum
}
Invoke-WebRequest -Uri "https://api.kite.trade/session/token" -Headers $reqHeaders -Method Post -Body $reqBody -UseBasicParsing | ForEach-Object {
    $response = $_.Content | ConvertFrom-Json
    if ($response.status -eq "success") {
        $accessToken = $response.data.access_token
        Write-Host "Access Token: $accessToken"
    } else {
        Write-Host "Error: $($response.message)"
    }
}
Read-Host "Press any key to exit..."