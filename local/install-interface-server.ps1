function install-interface-server {
    param (
        [Parameter(Mandatory)]$VMName, [Parameter(Mandatory)]$cvwebVersion
    )
    
    $cvwebInterfaceLocalPath = "C:\cvwebSetup\$cvwebVersion\Install\cvwebInterfaces_x64.msi"
    
    #$cvwebInterfaceParams = "/qn /log C:\DeployDebug\cvwebInterfaces.log HTTP_PORT=8080 ADMIN_PORT=8443 UPGRADEOPTION=upgrade MIRTHVERSION=5.3.22798.6 OLDMIRTHDIR=`"C:\Program Files\Clinical Computing\cvinterfaceserver\Mirth Connect\`""

    #MIRTHSQLCONNECTIONSTR=jdbc:jtds:sqlserver://TESTMACHINE1:1433/mirthdb

    if($cvwebVersion -eq 'Kang 5.3 GA' -or $cvwebVersion -eq 'Kang 5.3 R1u5' -or $cvwebVersion -eq 'Kang 5.3 R2' -or $cvwebVersion -eq 'Kang 5.3 R2u1 - reissue 2' -or $cvwebVersion -eq 'Kang 5.3 R2u2 - reissue 1' -or $cvwebVersion -eq 'Kang 5.3 R2u3' -or $cvwebVersion -eq 'Kang 5.3 R3') {
        $mirthConnectionString = "jdbc:jtds://"+$VMName+":1433/mirthdb;integratedSecurity=true"
    }
    else {
        $mirthConnectionString = "jdbc:sqlserver://"+$VMName+":1433;databaseName=mirthdb;integratedSecurity=true"
    }

    #$mirthConnectionString = "jdbc:jtds://"+$VMName.ToUpper()+":1433/mirthdb"

    $logFileName = "`"C:\DeployDebug\interfaces server $CVwebVersion $(Get-Date -Format "yyyy-MM-dd").log`""

    $cvwebInterfaceParams = "/qn /log $logFileName MIRTHSQLCONNECTIONSTR=$mirthConnectionString SQLAUTHENTICATION=NT SOURCEDIR=`"C:\cvwebSetup\$cvwebVersion\Install\`" TARGETDIR=C:\ CLINICALDIR=`"C:\Program Files\Clinical Computing\`" INSTALLDIR=`"C:\Program Files\Clinical Computing\cvinterfaceserver\`" GAC=C:\ WWWROOT=C:\ MSSQLSERVERNAME=$VMName USERNAME=NA COMPANYNAME=vm.net MYUSERNAME=$VMName\Administrator MYPASSWORD=Somepass1 NTDOMAIN=$VMName NTUSER=Administrator INSTALLDIR.DDC0F987_98BD_486C_8985_6895D3CA2C93=`"C:\Program Files\Clinical Computing\cvinterfaceserver\`" CURRENTDIRECTORY=`"C:\cvwebSetup\$cvwebVersion\Install\scripts`" CLIENTUILEVEL=0 CLIENTPROCESSID=7580 ACTION=INSTALL EXECUTEACTION=INSTALL SECONDSEQUENCE=1 JAVAVERSION=1.8 JAVAHOME=`"C:\Program Files\Java\jdk1.8.0_321`" ROOTDRIVE=C:\ USERISVALID=1 SQLCONNSTR= ADDLOCAL=Complete ACTION=INSTALL"
    

    # for old version
    #$cvwebInterfaceParams = "/qn /log $logFileName MIRTHSQLCONNECTIONSTR=jdbc:jtds:sqlserver://TESTMACHINE1:1433/mirthdb SQLAUTHENTICATION=NT SOURCEDIR=`"C:\cvwebSetup\$cvwebVersion\Install\`" TARGETDIR=C:\ CLINICALDIR=`"C:\Program Files\Clinical Computing\`" INSTALLDIR=`"C:\Program Files\Clinical Computing\cvinterfaceserver\`" GAC=C:\ WWWROOT=C:\ MSSQLSERVERNAME=$VMName USERNAME=NA COMPANYNAME=vm.net MYUSERNAME=$VMName\Administrator MYPASSWORD=Somepass1 NTDOMAIN=$VMName NTUSER=Administrator INSTALLDIR.DDC0F987_98BD_486C_8985_6895D3CA2C93=`"C:\Program Files\Clinical Computing\cvinterfaceserver\`" CURRENTDIRECTORY=`"C:\cvwebSetup\$cvwebVersion\Install\scripts`" CLIENTUILEVEL=0 CLIENTPROCESSID=5348 ACTION=INSTALL EXECUTEACTION=INSTALL SECONDSEQUENCE=1 JAVAVERSION=1.8 JAVAHOME=`"C:\Program Files\Java\jdk1.8.0_321`" ROOTDRIVE=C:\ USERISVALID=1 SQLCONNSTR= ADDLOCAL=Complete ACTION=INSTALL"

    # install cvweb interface server  
    Install-LabSoftwarePackage -ComputerName $VMName -LocalPath $cvwebInterfaceLocalPath -CommandLine $cvwebInterfaceParams -Verbose 

    Checkpoint-LabVM -ComputerName $VMName -SnapshotName "After installation of cvweb inetrfaces server $CVWebVersion"

}

