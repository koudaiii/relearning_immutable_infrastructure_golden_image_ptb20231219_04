# see https://qiita.com/m-oka-system/items/fc7428a566b3d6f4b724
Write-Host "Override the UI language with Japanese."
Set-WinUILanguageOverride -Language ja-JP

Write-Host "Set the time/date format to the same as the Windows language."
Set-WinCultureFromLanguageListOptOut -OptOut $False

Write-Host "Location is set to Japan."
Set-WinHomeLocation -GeoId 0x7A

Write-Host "Set the system locale to Japan."
Set-WinSystemLocale -SystemLocale ja-JP

Write-Host "Modify the registry to change the Welcome screen and default user display language."
$DefaultHKEY = "HKU\DEFAULT_USER"
$DefaultRegPath = "C:\Users\Default\NTUSER.DAT"
reg load $DefaultHKEY $DefaultRegPath
reg import "C:\ja-JP-default.reg"
reg unload $DefaultHKEY
reg import "C:\ja-JP-welcome.reg"
Remove-Item "C:\ja-JP-*.reg"

## Note: Switch the language bar to legacy mode if necessary
# Write-Host "Set MS-IME input method."
# Set-WinLanguageBarOption -UseLegacySwitchMode -UseLegacyLanguageBar

## Note: Time zone settings will initialized by Sysprep
# Write-Host "Set the time zone to Tokyo."
# Set-TimeZone -Id "Tokyo Standard Time"
