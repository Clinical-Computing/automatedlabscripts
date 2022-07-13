param ([Parameter(Mandatory)]$fileName, [Parameter(Mandatory)]$LabName, [Parameter(Mandatory)]$VMName)
Write-Host $fileName
New-Item -Path "C:\" -Name "$fileName.txt" -ItemType "file" -Value "This is a text string. $LabName - $VMName"