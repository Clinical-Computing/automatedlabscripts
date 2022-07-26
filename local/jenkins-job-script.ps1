Import-Module -Name AutomatedLab -Force

$LabName = $env:COMPUTERNAME.Replace('-', '')
$VMName = "CCISSBUILD"
$VMTempDirectory = 'C:\temp'
$VMCVWebDirectory = 'C:\cvweb\setup'
$sourceFolderPath = "\\cciss-build\latestbuild\cvWeb\Deployment\build\setup"
$destinationFolderPath = "C:\cvweb\"
$CVLocalPath = "C:\cvweb\setup\cvweb.msi"
$CVTransforms = "TRANSFORMS=:cvweb_x64.mst;"

try {
    Import-Lab -Name $LabName
    
    Invoke-LabCommand -ActivityName 'Remove Old cvweb verison' -ComputerName $VMName -ScriptBlock {Remove-Item 'C:\cvweb\setup' -Recurse -Force}  -UseLocalCredential -Verbose

    # copy latestbuild of cvweb from cciss-build
    Copy-LabFileItem -Path $sourceFolderPath -ComputerName $VMName -DestinationFolderPath $destinationFolderPath -Recurse -Verbose

    # create java options on vm
    New-Item -ItemType Directory -Force -Path $VMTempDirectory
    $sourceFolderPath = "C:\LabSources\Tools\tomcatJavaOptions.jar"
    $destinationFolderPath = $VMTempDirectory
    # copy tomacatJavaOptions.jar from cciss-hyper to vm
    Copy-LabFileItem -Path $sourceFolderPath -ComputerName $VMName -DestinationFolderPath $destinationFolderPath -Verbose 
    
    $logFileName = "`"C:\DeployDebug\tomcatJavaOptions $CVwebVersion $(Get-Date -Format "yyyy-MM-dd").log`""

    Invoke-LabCommand -ActivityName 'creating tomcat java options on vm' -ComputerName $VMName -ScriptBlock { Start-Process -FilePath (Get-Command -All java).Source -WorkingDirectory 'C:\temp' -ArgumentList '-jar tomcatJavaOptions.jar' -RedirectStandardOutput 'C:\DeployDebug\tomcatJavaOptions_stdout.log' -RedirectStandardError 'C:\DeployDebug\tomcatJavaOptions_stderror.log' -Verbose  }
    Invoke-LabCommand -ActivityName 'Removing C:\temp' -ComputerName $VMName -ScriptBlock {Remove-Item 'C:\temp' -Recurse -Force}  -UseLocalCredential -Verbose

    # upgrade cvweb on vm
    
    if(Test-Path -Path "\\cciss-build\latestbuild\cvWeb\Deployment\build\setup\cvweb_x64.mst") {
        $CVTransforms = "TRANSFORMS=cvweb_x64.mst;"    
    }
    
    $logFileName = "`"C:\DeployDebug\cvweb latestbuild upgrade $CVwebVersion $(Get-Date -Format "yyyy-MM-dd").log`""

    $CVParams = "/qn /log $logFileName DBSERVERNAME=`"$VMName`" MSSQLSERVERNAME=`"$VMName`" CVDOMAIN=Production INSTALLDIR=`"C:\Program Files (x86)\Clinical Computing\cvwebappserver\`" SQLINSTANCE_JTDS.4B175C70_94AB_42E4_B485_1478B3DF7933=`"localhost;integratedSecurity=true`" CREATENEWCVDB.4B175C70_94AB_42E4_B485_1478B3DF7933=1 LOCALEARGS.4B175C70_94AB_42E4_B485_1478B3DF7933=`"-Dcv.locale=ClinicalVisionCore:SystemSettings.UnitedKingdom -Dcv.language=ClinicalVisionCore:SystemSettings.UKEnglish`" CVLANGUAGE=GB UPGRADEOPTION=new MYUSERNAME=`"$VMName\Administrator`" MYPASSWORD=Somepass1 NTDOMAIN=$VMName NTUSER=Administrator $CVTransforms PROCARCHITECTURE=`"x64`" INSTANCEID=default SSLPORT=443 CVINTPORT=8448 JVMMS=1024 JVMMX=2048 UPGRADEOPTION=upgrade"
    
    # install cvweb    
    Install-LabSoftwarePackage -ComputerName $VMName -LocalPath $CVLocalPath -CommandLine $CVParams -Verbose -Timeout 60

    Checkpoint-LabVM -ComputerName $VMName -SnapshotName "After upgrade cvweb to latestbuild"

}
catch {
    Write-Host 'Lab not found!'
    Write-Host "Creating a new lab CCISSBUILD"
    
    # default network switch for internet conectivity
    $defaultNetworkSwitch = 'Default Switch'

    # create an empty lab template and define where the lab XML files and the VMs will be stored
    New-LabDefinition -Name $LabName -DefaultVirtualizationEngine HyperV -VmPath C:\AutomatedLab-VMs

    #make the network definition
    Add-LabVirtualNetworkDefinition -Name $defaultNetworkSwitch -HyperVProperties @{ SwitchType = 'Internal'; AdapterName = 'vEthernet' }

    # read all ISOs in the LabSources folder and add the SQL 2019 ISO
    Add-LabIsoImageDefinition -Name SQLServer2019 -Path $labSources\ISOs\SQLServer2019-x64-ENU.iso

    # define VM
    Add-LabMachineDefinition -Name $VMName -Memory 6GB -Network $defaultNetworkSwitch -Roles SQLServer2019 -OperatingSystem 'Windows 10 Enterprise Evaluation'

    Install-Lab -Verbose

    # grant service logon privilege to the default user
    Invoke-LabCommand -ActivityName 'Grant Service-Logon Privilege to the default user' -ComputerName $VMName -FilePath $labSources\CustomScripts\grant_service_logon_privilege.ps1 -Verbose
    
    #install jdk-8 - x64
    Install-LabSoftwarePackage -ComputerName $VMName -Path $labSources\SoftwarePackages\jdk-8u321-windows-x64.exe -CommandLine '/s /log C:\DeployDebug\Java.log /Q' -Verbose

    Show-LabDeploymentSummary -Detailed

    Checkpoint-LabVM -ComputerName $VMName -SnapshotName 'After creating a new VM with win10, jdk8 and SQLServer2019'

    # copy cvweb from cciss-build
    
    Import-Lab -Name $VMName -Path "C:\ProgramData\AutomatedLab\Labs\$LabName\Lab.xml"
 
    Copy-LabFileItem -Path $sourceFolderPath -ComputerName $VMName -DestinationFolderPath $destinationFolderPath -Recurse -Verbose
    
    if(Test-Path -Path "\\cciss-build\latestbuild\cvWeb\Deployment\build\setup\cvweb_x64.mst") {
        $CVTransforms = "TRANSFORMS=cvweb_x64.mst;"    
    }

    $logFileName = "`"C:\DeployDebug\cvweb latestbuild $(Get-Date -Format "yyyy-MM-dd").log`""

    $CVParams = "/qn /log $logFileName DBSERVERNAME=`"$VMName`" MSSQLSERVERNAME=`"$VMName`" CVDOMAIN=Production INSTALLDIR=`"C:\Program Files (x86)\Clinical Computing\cvwebappserver\`" SQLINSTANCE_JTDS.4B175C70_94AB_42E4_B485_1478B3DF7933=`"localhost;integratedSecurity=true`" CREATENEWCVDB.4B175C70_94AB_42E4_B485_1478B3DF7933=1 LOCALEARGS.4B175C70_94AB_42E4_B485_1478B3DF7933=`"-Dcv.locale=ClinicalVisionCore:SystemSettings.UnitedKingdom -Dcv.language=ClinicalVisionCore:SystemSettings.UKEnglish`" CVLANGUAGE=GB UPGRADEOPTION=new MYUSERNAME=`"$VMName\Administrator`" MYPASSWORD=Somepass1 NTDOMAIN=$VMName NTUSER=Administrator $CVTransforms PROCARCHITECTURE=`"x64`" INSTANCEID=default SSLPORT=443 CVINTPORT=8448 JVMMS=1024 JVMMX=2048"

    # install cvweb    
    Install-LabSoftwarePackage -ComputerName $VMName -LocalPath $CVLocalPath -CommandLine $CVParams -Verbose -Timeout 60

    Checkpoint-LabVM -ComputerName $VMName -SnapshotName "After installation of cvweb latestbuild"

}