function upgrade-interface-server {
    param (
        [Parameter(Mandatory)]$VMName, [Parameter(Mandatory)]$cvwebVersion
    )
    
    $sourceFolderPath = "C:\LabSources\Tools\upgradeInterfacesServer.jar"
    $destinationFolderPath = "C:\"
    Copy-LabFileItem -Path $sourceFolderPath -ComputerName $VMName -DestinationFolderPath $destinationFolderPath -Verbose 
    
    $scriptBlock = {
        
        Param ([string]$cvwebVersion)

        Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"java -jar C:\upgradeInterfacesServer.jar `"$cvwebVersion`"`"" -Wait
    } 
    
    Invoke-LabCommand -ActivityName 'Upgrading Interfaces Server.' -ComputerName $VMName -ScriptBlock $scriptBlock -ArgumentList $cvwebVersion -Verbose  
     
    Checkpoint-LabVM -ComputerName $VMName -SnapshotName "After upgrade of cvweb inetrfaces server to $CVWebVersion"

}