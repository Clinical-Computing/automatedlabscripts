param ([Parameter(Mandatory)]$VMName, [Parameter(Mandatory)]$CVwebVersion)

$LabName = "$VMName$CVwebVersion".Replace(' ', '')

$VMName = $LabName

Import-Module -Name AutomatedLab -Force

#$LabName = $env:COMPUTERNAME.Replace('-', '')

# default network switch for internet conectivity
$defaultNetworkSwitch = 'Default Switch'

# create an empty lab template and define where the lab XML files and the VMs will be stored
New-LabDefinition -Name $LabName -DefaultVirtualizationEngine HyperV -VmPath C:\AutomatedLab-VMs

#make the network definition
Add-LabVirtualNetworkDefinition -Name $defaultNetworkSwitch -HyperVProperties @{ SwitchType = 'Internal'; AdapterName = 'vEthernet' }

# read all ISOs in the LabSources folder and add the SQL 2019 ISO
Add-LabIsoImageDefinition -Name SQLServer2019 -Path $labSources\ISOs\SW_DVD9_NTRL_SQL_Svr_Standard_Edtn_2019Dec2019_64Bit_English_OEM_VL_X22-22109.iso

$role = Get-LabMachineRoleDefinition -Role SQLServer2019 -Properties @{Features = 'SQL,Tools'}

# define VM
Add-LabMachineDefinition -Name "$VMName" -Memory 6GB -Network $defaultNetworkSwitch -Roles $role -OperatingSystem 'Windows Server 2019 Standard (Desktop Experience)'

Install-Lab -Verbose

# grant service logon privilege to the default user
Invoke-LabCommand -ActivityName 'Grant Service-Logon Privilege to the default user' -ComputerName "$VMName" -FilePath $labSources\CustomScripts\grant_service_logon_privilege.ps1 -Verbose
#Enable-LabAutoLogon -ComputerName "$VMName"
    
#install jdk-8 - x64
Install-LabSoftwarePackage -ComputerName "$VMName" -Path $labSources\SoftwarePackages\jdk-8u321-windows-x64.exe -CommandLine '/s /log C:\DeployDebug\Java.log /Q' -Verbose

# install open jdk 8
#Install-LabSoftwarePackage -ComputerName $VMName -Path 'C:\LabSources\SoftwarePackages\OpenJDK8U-jdk_x64_windows_hotspot_8u342b07.msi' -CommandLine '/qn /log C:\DeployDebug\OpenJDK.log' -Verbose

Show-LabDeploymentSummary -Detailed

# create checkpoint
Checkpoint-LabVM -ComputerName $VMName -SnapshotName 'After the installation of WinServer2019, jdk8 and SQLServer2019'

$CVTransforms = "TRANSFORMS=:cvweb_x64.mst;"

if($CVWebVersion -eq 'latestbuild') {
    $sourceFolderPath = "\\cciss-build\latestbuild\cvWeb\Deployment\build\setup"
    $CVLocalPath = "C:\cvweb\setup\cvweb.msi"
    $destinationFolderPath = "C:\cvweb\"
}
else {
    $sourceFolderPath = "\\cciss-file\Product\clinicalvision5\Install\General Availability\$CVwebVersion\Install"
    $CVLocalPath = "C:\cvweb\$CVwebVersion\Install\cvweb.msi"
    $destinationFolderPath = "C:\cvweb\$CVwebVersion"

    if(Test-Path -Path "\\cciss-file\Product\clinicalvision5\Install\General Availability\$CVwebVersion\Install\cvweb_x64.mst") {
        $CVTransforms = "TRANSFORMS=cvweb_x64.mst;"    
    }
}

Copy-LabFileItem -Path $sourceFolderPath -ComputerName $VMName -DestinationFolderPath $destinationFolderPath -Recurse -Verbose 

$logFileName = "`"C:\DeployDebug\cvweb $CVwebVersion $(Get-Date -Format "yyyy-MM-dd").log`""

$CVParams = "/qn /log $logFileName DBSERVERNAME=`"$VMName`" MSSQLSERVERNAME=`"$VMName`" CVDOMAIN=Production INSTALLDIR=`"C:\Program Files (x86)\Clinical Computing\cvwebappserver\`" SQLINSTANCE_JTDS.4B175C70_94AB_42E4_B485_1478B3DF7933=`"localhost;integratedSecurity=true`" CREATENEWCVDB.4B175C70_94AB_42E4_B485_1478B3DF7933=1 LOCALEARGS.4B175C70_94AB_42E4_B485_1478B3DF7933=`"-Dcv.locale=ClinicalVisionCore:SystemSettings.UnitedKingdom -Dcv.language=ClinicalVisionCore:SystemSettings.UKEnglish`" CVLANGUAGE=GB UPGRADEOPTION=new MYUSERNAME=`"$VMName\Administrator`" MYPASSWORD=Somepass1 NTDOMAIN=$VMName NTUSER=Administrator $CVTransforms PROCARCHITECTURE=`"x64`" INSTANCEID=default SSLPORT=443 CVINTPORT=8448 JVMMS=1024 JVMMX=2048"

# install cvweb    
Install-LabSoftwarePackage -ComputerName $VMName -LocalPath $CVLocalPath -CommandLine $CVParams -Verbose -Timeout 30