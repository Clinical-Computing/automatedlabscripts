function clone-vm {

    param ([Parameter(Mandatory)]$SourceVmName,[Parameter(Mandatory)]$TargetVmName)
    
    # get source vm by name
    $SourceVM = Get-VM | Where-Object {$_.VMName -eq $SourceVmName} -Verbose
    
    if($SourceVM) {
        Write-Output "$SourceVM"
        # export the source vm
        Export-VM -Name $SourceVM.VMName -Path 'C:\VDH\export\' -Passthru -Verbose

        # get the source vm configuration file
        $SourceVMFile = Get-ChildItem -Path "C:\VDH\export\$SourceVmName\Virtual Machines" -Filter *.vmcx -Verbose

        # import the exported vm
        $ImportedVM = Import-VM -Path "C:\VDH\export\$SourceVmName\Virtual Machines\$SourceVMFile" -VhdDestinationPath "C:\VDH\export\$SourceVmName" -VirtualMachinePath "D:\AutomatedLab-VMs" -Copy -GenerateNewId -Verbose

        # rename the imported vm
        Get-VM | Where-Object {$_.VMName -eq $SourceVmName -and $_.VMId -ne $SourceVM.VMId} | Rename-VM -NewName $TargetVmName -Verbose

    }
    else {
        Write-Output "SourceVM not found!"
    }

    

}

clone-vm -SourceVmName "Win10BaseImage" -TargetVmName "CV5 Kang 5.3 R2u3"
