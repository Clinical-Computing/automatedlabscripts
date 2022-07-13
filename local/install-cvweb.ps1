# copy cvweb from cciss-file
function copy-cvweb-from-cciss-file {
    param ([Parameter(Mandatory)]$VMName, [Parameter(Mandatory)]$CVwebVersion)
    
    $sourceFolderPath = "\\cciss-file\Product\clinicalvision5\Install\General Availability\$CVwebVersion\Install"
    $destinationFolderPath = "C:\cvwebSetup\$CVwebVersion"
 
    Copy-LabFileItem -Path $sourceFolderPath -ComputerName $VMName -DestinationFolderPath $destinationFolderPath -Recurse -Verbose 
}

function install-cvweb-on-vm {
    param ([Parameter(Mandatory)]$VMName, [Parameter(Mandatory)]$CVwebVersion)
    
            
    $CVLocalPath = "C:\cvwebSetup\$CVwebVersion\Install\cvweb.msi"
    
    $CVTransforms = "TRANSFORMS=:cvweb_x64.mst;"
    
    if(Test-Path -Path "\\cciss-file\Product\clinicalvision5\Install\General Availability\$CVwebVersion\Install\cvweb_x64.mst") {
        $CVTransforms = "TRANSFORMS=cvweb_x64.mst;"    
    }

    $logFileName = "`"C:\DeployDebug\cvweb $CVwebVersion $(Get-Date -Format "yyyy-MM-dd").log`""

    $CVParams = "/qn /log $logFileName DBSERVERNAME=`"$VMName`" MSSQLSERVERNAME=`"$VMName`" CVDOMAIN=Production INSTALLDIR=`"C:\Program Files (x86)\Clinical Computing\cvwebappserver\`" SQLINSTANCE_JTDS.4B175C70_94AB_42E4_B485_1478B3DF7933=`"localhost;integratedSecurity=true`" CREATENEWCVDB.4B175C70_94AB_42E4_B485_1478B3DF7933=1 LOCALEARGS.4B175C70_94AB_42E4_B485_1478B3DF7933=`"-Dcv.locale=ClinicalVisionCore:SystemSettings.UnitedKingdom -Dcv.language=ClinicalVisionCore:SystemSettings.UKEnglish`" CVLANGUAGE=GB UPGRADEOPTION=new MYUSERNAME=`"$VMName\Administrator`" MYPASSWORD=Somepass1 NTDOMAIN=$VMName NTUSER=Administrator $CVTransforms PROCARCHITECTURE=`"x64`" INSTANCEID=default SSLPORT=443 CVINTPORT=8448 JVMMS=1024 JVMMX=2048"

    # install cvweb    
    Install-LabSoftwarePackage -ComputerName $VMName -LocalPath $CVLocalPath -CommandLine $CVParams -Verbose -Timeout 30

}


function install-cvweb {

    param ([Parameter(Mandatory)]$VMName, [Parameter(Mandatory)]$CVWebVersion)

    $ccissPath = "\\cciss-file\Product\clinicalvision5\Install\General Availability\$CVWebVersion\Install\cvweb.msi"

    $isPathValid = Test-Path -Path $ccissPath

    if($isPathValid) {

        copy-cvweb-from-cciss-file -VMName $VMName -cvwebVersion $CVWebVersion -Verbose

        install-cvweb-on-vm -VMName $VMName -CVwebVersion $CVWebVersion -Verbose

        Checkpoint-LabVM -ComputerName $VMName -SnapshotName "After installation of cvweb $CVWebVersion"

    }
    else {
        Write-Output "cvweb version $CVWebVersion on cciss-file not found!"
    }

}