$zipFolder = "C:\Users\12068\Music\Frisell Recording"
$destination = "C:\Users\12068\Music\Frisell Recording\2025.6.23 frisell morgan royston bellingham"

# Ensure destination exists
if (-not (Test-Path $destination)) {
    New-Item -ItemType Directory -Path $destination | Out-Null
}

# Process each ZIP file
Get-ChildItem -Path $zipFolder -Filter *.zip | ForEach-Object {
    $zipPath = $_.FullName
    try {
        Expand-Archive -Path $zipPath -DestinationPath $destination -Force
        Write-Host "Extracted: $zipPath"
    }
    catch {
        Write-Warning "Failed to extract: $zipPath. Error: $_"
    }
}
