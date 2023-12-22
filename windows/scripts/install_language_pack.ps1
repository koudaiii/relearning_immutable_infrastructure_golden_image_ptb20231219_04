# see https://qiita.com/m-oka-system/items/fc7428a566b3d6f4b724
Write-Host "Download the languagePack for Windows Server 2022"
$downloadPath = "C:\lang.iso"
$downloadUrl = "https://go.microsoft.com/fwlink/p/?linkid=2195333"

# Windows Server 2019
# $downloadUrl = "https://software-download.microsoft.com/download/pr/17763.1.180914-1434.rs5_release_SERVERLANGPACKDVD_OEM_MULTI.iso"

## Note: Download speed is faster with net.webclient than with the Invoke-WebRequest command.
# Invoke-WebRequest -Uri $downloadUrl -OutFile $downloadPath
$wc = New-Object net.webclient
$wc.Downloadfile($downloadUrl, $downloadPath)

Write-Host "Mount ISO."
$mountResult = Mount-DiskImage $downloadPath -PassThru

Write-Host "Get the drive letter of the mounted ISO."
$driveLetter = ($mountResult | Get-Volume).DriveLetter

Write-Host "Stores paths"
$lppath = $driveLetter + ":\LanguagesAndOptionalFeatures\Microsoft-Windows-Server-Language-Pack_x64_ja-jp.cab"

# Windows Server 2019
# $lppath = $driveLetter + ":\x64\langpacks\Microsoft-Windows-Server-Language-Pack_x64_ja-jp.cab"

Write-Host "Install Japanese languagePack using Lpksetup.exe command."
lpksetup.exe /i ja-JP /s /p $lppath

while((Get-Process "lpksetup" -ErrorAction SilentlyContinue) -ne $null) {
    Write-Host "lpksetup process is running."
    Start-Sleep -Seconds 60
}
Write-Host "The process has been completed."

Write-Host "Unmount disk and delete ISO."
DisMount-DiskImage $downloadPath
Remove-Item $downloadPath

Write-Host "Set the language used by the user to Japanese."
Set-WinUserLanguageList -LanguageList ja-JP,en-US -Force

Write-Host "Overwrites the input language with Japanese."
Set-WinDefaultInputMethodOverride -InputTip "0411:00000411"
