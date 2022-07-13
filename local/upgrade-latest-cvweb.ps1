function copy-cvweb-from-cciss-build {
    param (
        $VMName
    )
    $sourceFolderPath = "\\cciss-build\latestbuild\cvWeb\Deployment\build\setup"
    $destinationFolderPath = "C:\cvwebSetupLatest"
    Write-Output "copying cvweb latestbuild from  '\\cciss-build\latestbuild\cvWeb\Deployment\build\setup' to virtual machine on path 'C:\cvwebSetupLatest'"
    
    Copy-LabFileItem -Path $sourceFolderPath -ComputerName $VMName -DestinationFolderPath $destinationFolderPath -Recurse -Verbose 
}

function install-cvweb {
    param (
        $VMName
    )

    $CVLocalPath = "C:\cvwebSetupLatest\setup\cvweb.msi"

    $CVTransforms = "TRANSFORMS=:cvweb_x64.mst;"
    
    if(Test-Path -Path "\\cciss-build\latestbuild\cvWeb\Deployment\build\setup\cvweb_x64.mst") {
        $CVTransforms = "TRANSFORMS=cvweb_x64.mst;"    
    }

    $CVParams = "/qn /log C:\DeployDebug\cvwebSetupLatest.log DBSERVERNAME=`"$VMName`" MSSQLSERVERNAME=`"$VMName`" CVDOMAIN=Production INSTALLDIR=`"C:\Program Files (x86)\Clinical Computing\cvwebappserver\`" SQLINSTANCE_JTDS.4B175C70_94AB_42E4_B485_1478B3DF7933=`"localhost;integratedSecurity=true`" CREATENEWCVDB.4B175C70_94AB_42E4_B485_1478B3DF7933=1 LOCALEARGS.4B175C70_94AB_42E4_B485_1478B3DF7933=`"-Dcv.locale=ClinicalVisionCore:SystemSettings.UnitedKingdom -Dcv.language=ClinicalVisionCore:SystemSettings.UKEnglish`" CVLANGUAGE=GB UPGRADEOPTION=new MYUSERNAME=`"$VMName\Administrator`" MYPASSWORD=Somepass1 NTDOMAIN=$VMName NTUSER=Administrator $CVTransforms PROCARCHITECTURE=`"x64`" INSTANCEID=default SSLPORT=443 CVINTPORT=8448 JVMMS=1024 JVMMX=2048 UPGRADEOPTION=upgrade"
    
    # install cvweb    
    Install-LabSoftwarePackage -ComputerName $VMName -LocalPath $CVLocalPath -CommandLine $CVParams -Verbose -Timeout 30

}

function upgrade-latest-cvweb {
    param (
        [Parameter(Mandatory=$true)]
        [string]$VMName
    )

    copy-cvweb-from-cciss-build -VMName $VMName -Wait -Verbose

    install-cvweb -VMName $VMName
    
}

#upgrade-cvweb -VMName "CV5KANG5R2U3"