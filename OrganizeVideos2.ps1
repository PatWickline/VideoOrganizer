# Config block
$sourcePath      = "C:\Users\12068\Pictures\Camera"
$targetPath      = "C:\Users\12068\Documents\OrganizedVideos"
$logFile         = "C:\Users\12068\Documents\OrganizedVideos"
$videoExtensions = "*.mp4", "*.mov", "*.avi", "*.mkv"

# Absolute folder paths to skip
$skipFolders = @(
    "C:\Path\To\Source\Temp",
    "C:\Path\To\Source\Old",
    "C:\Path\To\Source\Test"
)

# Logging function
function Log {
    param ($message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $logFile -Value "$timestamp - $message"
}

# Initialize
Log "Script started"
$hashTable    = @{}
$dedupedFiles = @()

# Retrieve and filter files
$allVideoFiles = Get-ChildItem -Path $sourcePath -Recurse -Include $videoExtensions -File

$videoFiles = $allVideoFiles | Where-Object {
    $folderPath = $_.Directory.FullName
    ($skipFolders -notcontains $folderPath)
}

Log "Filtered to $($videoFiles.Count) files after skipping folders"

# Process and copy unique files
foreach ($file in $videoFiles) {
    try {
        $hash = Get-FileHash -Algorithm MD5 -Path $file.FullName
        $hashKey = $hash.Hash.ToLower()

        if (-not $hashTable.ContainsKey($hashKey)) {
            $hashTable[$hashKey] = $file.FullName
            $dedupedFiles += $file

            # Create folder structure based on creation date
            $creationDate = (Get-Item $file.FullName).CreationTime
            $monthYearFolder = "$($creationDate.ToString("yyyy-MM"))"
            $finalTargetFolder = Join-Path $targetPath $monthYearFolder

            if (-not (Test-Path $finalTargetFolder)) {
                New-Item -ItemType Directory -Path $finalTargetFolder -Force | Out-Null
            }

            $targetFilePath = Join-Path $finalTargetFolder $file.Name
            Copy-Item -Path $file.FullName -Destination $targetFilePath -Force
            Log "Copied: $($file.FullName) → $targetFilePath"
        } else {
            Log "Duplicate skipped: $($file.FullName) matches $($hashTable[$hashKey])"
        }
    } catch {
        Log "Error processing file: $($file.FullName) — $_"
    }
}

Log "Copied $($dedupedFiles.Count) unique video files"
Log "Script completed"