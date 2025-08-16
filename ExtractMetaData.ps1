param (
    [string]$TargetDir = "C:\Users\12068\Documents\Powershell\Test Folder with Files to delete",
    [string]$MetaDataFile = ".\TargetFilesMetaData.csv"
)

# Extract metadata sufficient to identify each file
$files = Get-ChildItem -Path $TargetDir -Recurse -File

$metaData = $files | Select-Object `
    Name,                # File name
    FullName,            # Full path
    Length,              # Size in bytes
    CreationTime,        # When file was created
    LastWriteTime,       # Last modified time
    Extension,           # File extension
    @{Name="Hash";Expression={ (Get-FileHash $_.FullName -Algorithm SHA256).Hash }} # SHA256 hash for uniqueness

# Append new metadata to the file (without headers if file exists)
if (Test-Path $MetaDataFile) {
    $metaData | Export-Csv -Path $MetaDataFile -NoTypeInformation -Append
} else {
    $metaData | Export-Csv -Path $MetaDataFile -NoTypeInformation
}

Write-Host "Metadata extracted and appended to $MetaDataFile"