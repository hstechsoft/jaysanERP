# PowerShell script to sync /php folder and push changes to two Git repositories
param([string]$msg)

# Source and Destination
$SRC = Join-Path (Get-Location) "php"       # only copy /php subfolder
$DEST = "C:\xampp\htdocs\jaysanERP\php"            # destination (adjust path)

Write-Output "Copying /php folder..."
robocopy $SRC $DEST /MIR

# Push Folder A (main repo)
Write-Output "Pushing Folder A..."
cd (Get-Location)
git add .
git commit -m "$msg"
git push origin main

# Push Folder B (second repo)
Write-Output "Pushing Folder B..."
cd "C:\xampp\htdocs\jaysan"
git add .
git commit -m "$msg"
git push origin main
