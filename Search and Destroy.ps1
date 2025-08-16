# === CONFIGURATION ===
param (
    [string]$MetaDataFile = ".\TargetFilesMetaData.csv",    # Metadata CSV file created by ExtractMetaData.ps1
    [string]$SearchDir = "E:\Pat\Backup 3-1-25" # Directory tree to search and delete matching files
)
$LogFile = ".\DeleteLog_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"

# === LOGGING FUNCTION ===
function Log {
    param ([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogFile -Value "$timestamp - $Message"
}

# === VALIDATION ===
if (!(Test-Path $MetaDataFile)) {
    Log "ERROR: Metadata file '$MetaDataFile' does not exist."
    return
}
if (!(Test-Path $SearchDir)) {
    Log "ERROR: Search directory '$SearchDir' does not exist."
    return
}

# === MAIN EXECUTION ===
Log "Loading metadata from: $MetaDataFile"
$metaData = Import-Csv -Path $MetaDataFile

Log "Found $($metaData.Count) files in metadata."
$deletedCount = 0

# Build a lookup table for metadata hashes
$metaHashSet = $metaData | Select-Object -ExpandProperty Hash | Sort-Object -Unique

# Search the specified directory tree for files matching the metadata hashes
$searchFiles = Get-ChildItem -Path $SearchDir -Recurse -File

foreach ($file in $searchFiles) {
    try {
        $fileHash = (Get-FileHash $file.FullName -Algorithm SHA256).Hash
        if ($metaHashSet -contains $fileHash) {
            Remove-Item -Path $file.FullName -Force
            Log "Deleted: $($file.FullName) (Hash: $fileHash)"
            $deletedCount++
        }
    } catch {
        Log "ERROR processing '$($file.FullName)': $_"
    }
}

Log "Operation complete."
Log "Total files deleted: $deletedCount"