param ([Parameter(Mandatory)]$VMName, [Parameter(Mandatory)]$CVwebVersion)

$ccissPath = "\\cciss-file\Product\clinicalvision5\Install\General Availability\$CVWebVersion\Install\cvweb.msi"

Write-Output $ccissPath

$isPathValid = Test-Path -Path $ccissPath

if($isPathValid) {

    #copy-cvweb-from-cciss-file -VMName $VMName -cvwebVersion $CVWebVersion -Verbose

    #install-cvweb-on-vm -VMName $VMName -CVwebVersion $CVWebVersion -Verbose

    #Checkpoint-LabVM -ComputerName $VMName -SnapshotName "After installation of cvweb $CVWebVersion"

    Write-Output "cvweb version $CVWebVersion found on cciss-file server."

}
else {
    Write-Output "cvweb version $CVWebVersion not found on cciss-file server."
}