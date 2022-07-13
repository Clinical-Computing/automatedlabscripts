#Import-Module -Name AutomatedLab

try {
    Import-Lab -Name $env:COMPUTERNAME
}
catch {
    Write-Host 'Lab not found!'
    Write-Host "Creating a new lab $env:COMPUTERNAME"
    
    ."C:\LabSources\CustomScripts\testscript.ps1" -fileName "TestFile1" -LabName $env:COMPUTERNAME -VMName "${env:JOB_NAME}"
    #."C:\LabSources\CustomScripts\create-new-vm.ps1" -LabName "$env:COMPUTERNAME" -VMName "${env:JOB_NAME}"

}