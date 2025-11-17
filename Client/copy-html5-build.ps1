# Post-build script
$sourceDir = "Export\html5\bin"
$destDir = "..\Server\static\client"

# Delete existing files and directories in destination
if (Test-Path $destDir) {
    Get-ChildItem -Path $destDir -Recurse | Remove-Item -Force -Recurse
    Write-Host "Cleaned destination directory" -ForegroundColor Yellow
}

# Ensure destination directory exists
if (-Not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }

# Copy new build
Copy-Item -Path "$sourceDir\*" -Destination $destDir -Recurse -Force
Write-Host "Copied HTML5 build" -ForegroundColor Green
