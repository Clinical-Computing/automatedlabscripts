function upgrade-document-interface {
    param (
        [Parameter(Mandatory=$true)]
        [string]$VMName,
        [Parameter(Mandatory=$true)]
        [string]$cvwebVersion
    )

    $documentInterface = "$CVwebVersion Document Interface"
    $documentInterfacePath = "\\cciss-file\Product\clinicalvision5\Install\General Availability\$documentInterface\documentInterface.msi"
    
    if(Test-Path -Path $documentInterfacePath) {
        
        $sourceFolderPath = $documentInterfacePath
        $destinationFolderPath = "C:\cvwebSetup\$CVwebVersion\Install\"
 
        Copy-LabFileItem -Path $sourceFolderPath -ComputerName $VMName -DestinationFolderPath $destinationFolderPath -Recurse -Verbose
        
        $documentInterfaceLocalPath = "C:\cvwebSetup\$cvwebVersion\Install\documentInterface.msi"

        $logFileName = "`"C:\DeployDebug\document interface upgrade $CVwebVersion $(Get-Date -Format "yyyy-MM-dd").log`""
    
        $documentInterfaceParams = "/qn /log $logFileName"
    
        # install cvweb interface server  
        Install-LabSoftwarePackage -ComputerName $VMName -LocalPath $documentInterfaceLocalPath -CommandLine $documentInterfaceParams -Verbose 

        Checkpoint-LabVM -ComputerName $VMName -SnapshotName "After upgrade of cvweb document inetrface to $CVWebVersion"
         
    }
    else {
        Write-Host "Document Interface not found at $documentInterfacePath"
    }
}