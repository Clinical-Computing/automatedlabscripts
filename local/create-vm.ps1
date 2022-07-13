# copy cvweb from cciss-file
function copy-cvweb-from-cciss-file {
    param (
        $VMName,
        $cvwebVersion
    )
    $sourceFolderPath = "\\cciss-file\Product\clinicalvision5\Install\General Availability\$cvwebVersion\Install"
    $destinationFolderPath = "C:\cvwebSetup"
    Write-Output "copying cvweb $cvwebVersion from  '\\cciss-file\Product\clinicalvision5\Install\General Availability\$cvwebVersion\Install\' to virtual machine on path 'C:\cvwebSetup'"
    
    Copy-LabFileItem -Path $sourceFolderPath -ComputerName $VMName -DestinationFolderPath $destinationFolderPath -Recurse -Verbose
}

#copy-cvweb-from-cciss-file -cvwebVersion 'Kang 5.3 R2u3'


function create-vm {

    param ([Parameter(Mandatory)]$VMName,[Parameter(Mandatory)]$CVWebVersion)

    # Lab name
    $labName = 'CVTestLab'

    $ccissPath = "\\cciss-file\Product\clinicalvision5\Install\General Availability\$CVWebVersion\Install\cvweb.msi"

    $isPathValid = Test-Path -Path $ccissPath

    if($isPathValid) {
        
        # default network switch for internet conectivity
        $defaultNetworkSwitch = 'Default Switch'

        # create an empty lab template and define where the lab XML files and the VMs will be stored
        New-LabDefinition -Name $labName -DefaultVirtualizationEngine HyperV #-VmPath D:\AutomatedLab-VMs

        #make the network definition
        Add-LabVirtualNetworkDefinition -Name $defaultNetworkSwitch -HyperVProperties @{ SwitchType = 'External'; AdapterName = 'Wi-Fi' }

        # read all ISOs in the LabSources folder and add the SQL 2019 ISO
        Add-LabIsoImageDefinition -Name SQLServer2019 -Path $labSources\ISOs\SQLServer2019-x64-ENU.iso

        # define VM
        Add-LabMachineDefinition -Name $VMName  -Memory 2GB -Network $defaultNetworkSwitch -Roles SQLServer2019 `
            -OperatingSystem 'Windows 10 Enterprise Evaluation' # -ToolsPath "\\cciss-file\Product\clinicalvision5\Install\General Availability\$CVVersion" -ToolsPathDestination C:\Tools

        Install-Lab -Verbose

        copy-cvweb-from-cciss-file -VMName $VMName -cvwebVersion $CVWebVersion

        # grant service logon privilege to the default user
        Invoke-LabCommand -ActivityName 'Grant Service-Logon Privilege to the default user' -ComputerName $VmName -FilePath C:\LabSources\CustomScripts\grant_service_logon_privilege.ps1

        #install jdk-8 - x64
        Install-LabSoftwarePackage -ComputerName $VMName -Path $labSources\SoftwarePackages\jdk-8u321-windows-x64.exe -CommandLine '/s /log C:\DeployDebug\JavaSetup.log /Q' -Verbose

        # install cvweb
        #$CVPath = "\\cciss-file\Product\clinicalvision5\Install\General Availability\$cvwebVersion\Install\cvweb.msi"
        $CVLocalPath = "C:\cvwebSetup\Install\cvweb.msi"
        $CVParams = "/qn /log C:\DeployDebug\cvwebSetup.log DBSERVERNAME=`"$VMName`" MSSQLSERVERNAME=`"$VMName`" CVDOMAIN=Production INSTALLDIR=`"C:\Program Files (x86)\Clinical Computing\cvwebappserver\`" SQLINSTANCE_JTDS.4B175C70_94AB_42E4_B485_1478B3DF7933=`"localhost;integratedSecurity=true`" CREATENEWCVDB.4B175C70_94AB_42E4_B485_1478B3DF7933=1 LOCALEARGS.4B175C70_94AB_42E4_B485_1478B3DF7933=`"-Dcv.locale=ClinicalVisionCore:SystemSettings.UnitedKingdom -Dcv.language=ClinicalVisionCore:SystemSettings.UKEnglish`" CVLANGUAGE=GB UPGRADEOPTION=new MYUSERNAME=`"$VMName\Administrator`" MYPASSWORD=Somepass1 NTDOMAIN=$VMName NTUSER=Administrator TRANSFORMS=cvweb_x64.mst; PROCARCHITECTURE=`"x64`" INSTANCEID=default SSLPORT=443 CVINTPORT=8448 JVMMS=1024 JVMMX=2048"
        
       # Install-LabSoftwarePackage -ComputerName $VMName -Path $CVPath -CommandLine $CVParams -Verbose -Timeout 30
        Install-LabSoftwarePackage -ComputerName $VMName -LocalPath $CVLocalPath -CommandLine $CVParams -Verbose -Timeout 30

        Show-LabDeploymentSummary -Detailed

    }
    else {
        Write-Output "cvweb not found!"
    }

}
    
    

