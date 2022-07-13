function copy-cvweb-from-cciss-file {
    param (
        [Parameter(Mandatory=$true)]
        [string]$VMName,
        [Parameter(Mandatory=$true)]
        [string]$cvwebVersion
    )
    $sourceFolderPath = "\\cciss-file\Product\clinicalvision5\Install\General Availability\$cvwebVersion\Install"
    $destinationFolderPath = "C:\cvwebSetup\$cvwebVersion"
   
    Copy-LabFileItem -Path $sourceFolderPath -ComputerName $VMName -DestinationFolderPath $destinationFolderPath -Recurse -Verbose
}

function create-tomcat-java-options-on-vm {
    param (
        [Parameter(Mandatory=$true)]
        [string]$VMName
    )
    
    New-Item -ItemType Directory -Force -Path C:\temp
    $sourceFolderPath = "C:\LabSources\Tools\tomcatJavaOptions.jar"
    $destinationFolderPath = "C:\temp"
    Copy-LabFileItem -Path $sourceFolderPath -ComputerName $VMName -DestinationFolderPath $destinationFolderPath -Verbose 
    
    $logFileName = "`"C:\DeployDebug\tomcatJavaOptions $CVwebVersion $(Get-Date -Format "yyyy-MM-dd").log`""

    Invoke-LabCommand -ActivityName 'creating tomcat java options on vm' -ComputerName $VMName -ScriptBlock { Start-Process -FilePath (Get-Command -All java).Source -WorkingDirectory 'C:\temp' -ArgumentList '-jar tomcatJavaOptions.jar' -RedirectStandardOutput 'C:\DeployDebug\tomcatJavaOptions_stdout.log' -RedirectStandardError 'C:\DeployDebug\tomcatJavaOptions_stderror.log' -Verbose  }
    #Remove-Item $destinationFolderPath -Force 
    
}

function install-cvweb-on-vm {
    param (
        [Parameter(Mandatory=$true)]
        [string]$VMName,
        [Parameter(Mandatory=$true)]
        [string]$cvwebVersion
    )
    
    $CVLocalPath = "C:\cvwebSetup\$cvwebVersion\Install\cvweb.msi"

    $CVTransforms = "TRANSFORMS=:cvweb_x64.mst;"
    
    if(Test-Path -Path "\\cciss-file\Product\clinicalvision5\Install\General Availability\$CVwebVersion\Install\cvweb_x64.mst") {
        $CVTransforms = "TRANSFORMS=cvweb_x64.mst;"    
    }
    
    $logFileName = "`"C:\DeployDebug\cvweb upgrade $CVwebVersion $(Get-Date -Format "yyyy-MM-dd").log`""

    $CVParams = "/qn /log $logFileName DBSERVERNAME=`"$VMName`" MSSQLSERVERNAME=`"$VMName`" CVDOMAIN=Production INSTALLDIR=`"C:\Program Files (x86)\Clinical Computing\cvwebappserver\`" SQLINSTANCE_JTDS.4B175C70_94AB_42E4_B485_1478B3DF7933=`"localhost;integratedSecurity=true`" CREATENEWCVDB.4B175C70_94AB_42E4_B485_1478B3DF7933=1 LOCALEARGS.4B175C70_94AB_42E4_B485_1478B3DF7933=`"-Dcv.locale=ClinicalVisionCore:SystemSettings.UnitedKingdom -Dcv.language=ClinicalVisionCore:SystemSettings.UKEnglish`" CVLANGUAGE=GB UPGRADEOPTION=new MYUSERNAME=`"$VMName\Administrator`" MYPASSWORD=Somepass1 NTDOMAIN=$VMName NTUSER=Administrator $CVTransforms PROCARCHITECTURE=`"x64`" INSTANCEID=default SSLPORT=443 CVINTPORT=8448 JVMMS=1024 JVMMX=2048 UPGRADEOPTION=upgrade"
    
    # install cvweb    
    Install-LabSoftwarePackage -ComputerName $VMName -LocalPath $CVLocalPath -CommandLine $CVParams -Verbose -Timeout 30

}

function upgrade-cvweb {
    param (
        [Parameter(Mandatory=$true)]
        [string]$VMName,
        [Parameter(Mandatory=$true)]
        [string]$cvwebVersion
    )

    #copy-cvweb-from-cciss-file -VMName $VMName -cvwebVersion $cvwebVersion

    create-tomcat-java-options-on-vm -VMName $VMName

    install-cvweb-on-vm -VMName $VMName -cvwebVersion $cvwebVersion

    Checkpoint-LabVM -ComputerName $VMName -SnapshotName "After upgrade cvweb to $CVWebVersion"
    
}