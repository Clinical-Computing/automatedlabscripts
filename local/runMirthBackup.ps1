#C:\Program Files\Clinical Computing\cvinterfaceserver\Mirth Connect

# runMirthbackup() from FrontEndUtilityFunctions.js
# 1. initIntSettings();
#     1.1  read the value for http.port from mirth.properties
#     1.2  read the value for https.port from mirth.properties
#     1.3  read the value for database from mirth.properties
#     1.4  read the value for procArch from hta ui. default is x64
# 2. start Mirth Connect Service
# 3. exportChannels

$mirthDir = 'C:\Program Files\Clinical Computing\cvinterfaceserver\Mirth Connect'
$backupsDir = 'C:\cvwebSetup\Kang 5.3 R3\Install\backups2'
$channelBackupDir = "$backupsDir\channels\"
$statsFile = "$backupsDir\stats.csv"

function getMirthPropertyValue() {
    param (
        [Parameter(Mandatory)]$propertyKey
    )
    $file = "$mirthDir\conf\mirth.properties"
    
    foreach($line in Get-Content $file) {
        if($line.StartsWith("$propertyKey = ")) {
            # Work here
            $value = $line.Replace("$propertyKey = ",'')
            Write-Host $value
        }
    }
}

getMirthPropertyValue -propertyKey 'http.port'
getMirthPropertyValue -propertyKey 'https.port'
getMirthPropertyValue -propertyKey 'database'

$mirthConnectService = Get-Service -Name 'Mirth Connect Service'
if($mirthConnectService.Status -eq 'Stopped') {
    $mirthConnectService.Start()
}

$mccomandApp = "$mirthDir\mccommand.exe"
$exportFileCmd = "$backupsDir\exportChannels.txt"


If(!(Test-Path -Path $backupsDir)) {
      New-Item -ItemType Directory -Path $backupsDir
      $_statsFile = $statsFile.Replace('\','/')
      $_channelBackupDir = $channelBackupDir.Replace('\','/')
      New-Item -Path $backupsDir -Name 'exportChannels.txt' -Value "dump stats `"$_statsFile`"`r`export * `"$_channelBackupDir`""
}
