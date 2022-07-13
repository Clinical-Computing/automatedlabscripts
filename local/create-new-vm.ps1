param ([Parameter(Mandatory)]$LabName, [Parameter(Mandatory)]$VMName)
    
# default network switch for internet conectivity
$defaultNetworkSwitch = 'Default Switch'

# create an empty lab template and define where the lab XML files and the VMs will be stored
New-LabDefinition -Name $LabName -DefaultVirtualizationEngine HyperV -VmPath S:\AutomatedLab-VMs

#make the network definition
Add-LabVirtualNetworkDefinition -Name $defaultNetworkSwitch -HyperVProperties @{ SwitchType = 'External'; AdapterName = 'Wi-Fi' }

# read all ISOs in the LabSources folder and add the SQL 2019 ISO
Add-LabIsoImageDefinition -Name SQLServer2019 -Path $labSources\ISOs\SQLServer2019-x64-ENU.iso

# define VM
Add-LabMachineDefinition -Name $VMName -Memory 2GB -Network $defaultNetworkSwitch -Roles SQLServer2019 -OperatingSystem 'Windows 10 Enterprise Evaluation' 

Install-Lab -Verbose

# grant service logon privilege to the default user
Invoke-LabCommand -ActivityName 'Grant Service-Logon Privilege to the default user' -ComputerName $VMName -FilePath $labSources\CustomScripts\grant_service_logon_privilege.ps1 -Verbose
    
#install jdk-8 - x64
Install-LabSoftwarePackage -ComputerName $VMName -Path $labSources\SoftwarePackages\jdk-8u321-windows-x64.exe -CommandLine '/s /log C:\DeployDebug\Java.log /Q' -Verbose

Show-LabDeploymentSummary -Detailed

Checkpoint-LabVM -ComputerName $VMName -SnapshotName 'After creating a new VM with win10, jdk8 and SQLServer2019'