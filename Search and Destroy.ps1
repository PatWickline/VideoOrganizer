# === CONFIGURATION ===
$SourceDir = "C:\Users\12068\Documents\OrganizedVideos\Exclude Files"      # Folder containing reference files
$TargetDir = "C:\Users\12068\Documents\Powershell\Test Folder with Files to delete"      # Folder to search and delete matching files
$LogFile = ".\DeleteLog_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"

# === LOGGING FUNCTION ===
function Log {
    param ([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogFile -Value "$timestamp - $Message"
}

# === VALIDATION ===
if (!(Test-Path $SourceDir)) {
    Log "ERROR: Source directory '$SourceDir' does not exist."
    return
}
if (!(Test-Path $TargetDir)) {
    Log "ERROR: Target directory '$TargetDir' does not exist."
    return
}

# === MAIN EXECUTION ===
$sourceFiles = Get-ChildItem -Path $SourceDir -File | Select-Object -ExpandProperty Name
Log "Scanning source directory: $SourceDir"
Log "Found $($sourceFiles.Count) files to match."

$deletedCount = 0

foreach ($fileName in $sourceFiles) {
    try {
        $foundFiles = Get-ChildItem -Path $TargetDir -Recurse -File -Filter $fileName
        if ($foundFiles.Count -eq 0) {
            Log "No match found for '$fileName'."
            continue
        }

        foreach ($file in $foundFiles) {
            try {
                Remove-Item -Path $file.FullName -Force
                Log "Deleted: $($file.FullName)"
                $deletedCount++
            } catch {
                Log "ERROR deleting '$($file.FullName)': $_"
            }
        }
    } catch {
        Log "ERROR searching for '$fileName': $_"
    }
}

Log "Operation complete."
Log "Total files deleted: $deletedCount"