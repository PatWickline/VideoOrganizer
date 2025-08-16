$sourcePath      = "E:\Pat\Backup 3-1-25\Camera"
$destinationPath = "C:\Users\12068\Documents\OrganizedVideos"
$logFile = "C:\Users\12068\Documents\OrganizedVideos\video_copy_log.txt"
$videoExtensions = @("*.mp4", "*.mov", "*.avi", "*.mkv", "*.wmv")

$copiedFiles = @()
$skippedFiles = @()
$copiedCount = 0
$skippedCount = 0

# Collect all files and filter manually
$allFiles = Get-ChildItem -Path $sourcePath -Recurse -File

# Filter to just video extensions
$videoFiles = $allFiles | Where-Object {
    $ext = $_.Extension.ToLower()
    $videoExtensions -contains "*$ext"
}

foreach ($file in $videoFiles) {
    $shellApp = New-Object -ComObject Shell.Application
    $shellFolder = $shellApp.Namespace($file.DirectoryName)
    $shellFile = $shellFolder.ParseName($file.Name)
    $dateTakenRaw = $shellFolder.GetDetailsOf($shellFile, 12)

    $refDate = [ref]::new([datetime]::MinValue)
    if ([datetime]::TryParse($dateTakenRaw, $refDate)) {
        $dateTaken = $refDate.Value
    } else {
        $dateTaken = $file.LastWriteTime
    }

    $subfolderName = "{0:yyyy-MM}" -f $dateTaken
    $targetFolder = Join-Path $destinationPath $subfolderName
    if (!(Test-Path $targetFolder)) {
        New-Item -Path $targetFolder -ItemType Directory | Out-Null
    }

    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
    $ext = $file.Extension
    $destFile = Join-Path $targetFolder $file.Name
    $counter = 1
    $finalPath = $destFile
    $skip = $false

    while (Test-Path $finalPath) {
        $existingFile = Get-Item $finalPath
        if ($existingFile.Length -eq $file.Length) {
            $skip = $true
            break
        } else {
            $suffix = "_{0:D3}" -f $counter
            $newName = "$baseName$suffix$ext"
            $finalPath = Join-Path $targetFolder $newName
            $counter++
        }
    }

    if ($skip) {
        $skippedFiles += $file.FullName
        $skippedCount++
    } else {
        Copy-Item -Path $file.FullName -Destination $finalPath
        $copiedFiles += $finalPath
        $copiedCount++
    }
}

Set-Content -Path $logFile -Value "Video Copy Log - $(Get-Date)"
Add-Content -Path $logFile -Value "Total copied: $copiedCount"
Add-Content -Path $logFile -Value "Total skipped: $skippedCount"
Add-Content -Path $logFile -Value "`nCopied Files:"
$copiedFiles | ForEach-Object { Add-Content -Path $logFile -Value $_ }
Add-Content -Path $logFile -Value "`nSkipped Files:"
$skippedFiles | ForEach-Object { Add-Content -Path $logFile -Value $_ }