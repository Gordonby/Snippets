configuration MixedBagConfigs
{
    Import-DscResource –ModuleName 'PSDesiredStateConfiguration'
    Import-DscResource -ModuleName 'xDSCDomainjoin'
    Import-DscResource -ModuleName 'PowerShellModule'

    $dscDomainAdmin = Get-AutomationPSCredential -Name ''
    $dscDomainName = ""

    Node SQLServer
    {
        PSModuleResource AzureRM
         {
                Ensure               = 'Present'
                Module_Name          = 'AzureRM'
         }

         PSModuleResource SqlServer
         {
                Ensure               = 'Present'
                Module_Name          = 'SqlServer'
         }
    }


    Node FullWebServer
    {
        WindowsFeature IIS
        {
            Ensure               = 'Present'
            Name                 = 'Web-Server'
            IncludeAllSubFeature = $true

        }

        WindowsFeature SMB1 {
            Ensure = 'Absent'
            Name = 'FS-SMB1'
        }

        WindowsFeature WebManagementService
        {
            Ensure = "Present"
            Name = "Web-Mgmt-Service"
        }

        Package WebDeploy
        {
             Ensure = "Present"
             Path  = "$Env:SystemDrive\TestFolder\WebDeploy_amd64_en-US.msi"
             Name = "Microsoft Web Deploy 3.5"
             LogPath = "$Env:SystemDrive\TestFolder\logoutput.txt"
             ProductId = "1A81DA24-AF0B-4406-970E-54400D6EC118"
             Arguments = "LicenseAccepted='0' ADDLOCAL=ALL"
        }
    }



    Node DomainJoinedWebServer
    {
        WindowsFeature IIS
        {
            Ensure               = 'Present'
            Name                 = 'Web-Server'
            IncludeAllSubFeature = $true

        }

        WindowsFeature SMB1 {
            Ensure = 'Absent'
            Name = 'FS-SMB1'
        }

        xDSCDomainjoin JoinDomain
        {
            Domain = $dscDomainName
            Credential = $dscDomainAdmin
        }
        
    }

    Node DotNetWebServer
    {
        WindowsFeature IIS
        {
            Ensure               = 'Present'
            Name                 = 'Web-Server'

        }
        
        #Install ASP.NET 4.5 
        WindowsFeature ASP 
        { 
          Ensure = “Present” 
          Name = “Web-Asp-Net45” 
        } 

        WindowsFeature SMB1 {
            Ensure = 'Absent'
            Name = 'FS-SMB1'
        }
    }

    Node SNMP
    {
        WindowsFeature IIS
        {
            Ensure               = 'Absent'
            Name                 = 'Web-Server'

        }

        WindowsFeature SMB1 {
            Ensure = 'Absent'
            Name = 'FS-SMB1'
        }

        WindowsFeature TelnetClient 
        {
	        Name = 'Telnet-Client'
	        Ensure = 'Present'
        }

        WindowsFeature SNMP 
        { 
          Ensure = "Present" 
          Name = "SNMP-Service" 
        } 
        WindowsFeature SnmpManagementTools 
        { 
          Ensure = "Present" 
          Name = "RSAT-SNMP" 
        } 
        WindowsFeature SnmpWmiProvider 
        { 
          Ensure = "Present" 
          Name = "SNMP-WMI-Provider" 
        } 
        Registry PublicCommunity 
        { 
          Key = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\TrapConfiguration\$SnmpCommunityName" 
          ValueName = '1' 
          ValueType = 'String' 
          ValueData = $SnmpHost 
        } 

    }

}
