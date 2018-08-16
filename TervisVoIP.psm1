$ModulePath = (Get-Module -ListAvailable TervisVoIP).ModuleBase
. $ModulePath\Definition.ps1

$VoIPUserDefinition = [PSCustomObject][Ordered]@{
    Name = "JabberOnly"
    CallingSearchSpace = "TPA_CSS"
},
[PSCustomObject][Ordered]@{
    Name = "ContactCenter"
    CallingSearchSpace = "UCCX_CSS"
}

function Invoke-TervisVOIPTerminateUser {
    param (
        [Parameter(Mandatory)]$SamAccountName
    )
    Invoke-TervisCUCMTerminateUser -UserName $SamAccountName
    Invoke-TervisCUCTerminateVM -Alias $SamAccountName
    Set-ADUser $SamAccountName -Clear TelephoneNumber
}

Function New-TervisVOIPUser {
    param (
        [Parameter(Mandatory)][ValidateSet("CallCenterAgent")] [String]$UserType,
        [Parameter(Mandatory)][String]$UserID
    )

    if ($UserType -eq "CallCenterAgent") {
        $Pattern = Find-CUCMLine -Pattern 7% -Description "" | select -First 1
        Set-ADUser $UserID -OfficePhone $Pattern
        Sync-CUCMtoLDAP -LDAPDirectory TERV_AD

        do {
            sleep -Seconds 3
        } until (Get-CUCMUser -UserID $UserID -ErrorAction SilentlyContinue)

        $ADUser = Get-ADUser $UserID
        $DisplayName = $ADUser.name
        $DeviceName = "CSF"
        
        $Parameters = @{
            Pattern = $Pattern
            routePartition = "UCCX_PT"
            CSS = "UCCX_CSS"
            Description = $DisplayName
            AlertingName = $DisplayName
            AsciiAlertingName = $DisplayName
            userHoldMohAudioSourceId = "0"
            networkHoldMohAudioSourceId = "0"
            voiceMailProfileName = "Voicemail"
            CallForwardAllForwardToVoiceMail = "False"
            CallForwardAllcallingSearchSpaceName = "UCCX_CSS"
            CallForwardAllsecondarycallingSearchSpaceName = "UCCX_CSS"
            CallForwardBusyForwardToVoiceMail= "True"
            CallForwardBusycallingSearchSpaceName = "UCCX_CSS"
            CallForwardBusyIntForwardToVoiceMail = "True"
            CallForwardBusyIntcallingSearchSpaceName = "UCCX_CSS"
            CallForwardNoAnswerForwardToVoiceMail = "True"
            CallForwardNoAnswercallingSearchSpaceName = "UCCX_CSS"
            CallForwardNoAnswerIntForwardToVoiceMail = "True"
            CallForwardNoAnswerIntcallingSearchSpaceName = "UCCX_CSS"
            CallForwardNoCoverageForwardToVoiceMail = "True"
            CallForwardNoCoveragecallingSearchSpaceName = "UCCX_CSS"
            CallForwardNoCoverageIntForwardToVoiceMail = "True"
            CallForwardNoCoverageIntcallingSearchSpaceName = "UCCX_CSS"
            CallForwardOnFailureForwardToVoiceMail = "True"
            CallForwardOnFailurecallingSearchSpaceName = "UCCX_CSS"
            CallForwardNotRegisteredForwardToVoiceMail = "True"
            CallForwardNotRegisteredcallingSearchSpaceName = "UCCX_CSS"
            CallForwardNotRegisteredIntForwardToVoiceMail = "True"
            CallForwardNotRegisteredIntcallingSearchSpaceName = "UCCX_CSS"
            index = "1"
            Display = $DisplayName
        }

        $Dirnuuid = Set-CUCMAgentLine @Parameters

        $Parameters = @{
            UserID = $UserID
            DeviceName = "$DeviceName" + $UserID
            Description = $DisplayName
            Product = "Cisco Unified Client Services Framework"
            Class = "Phone"
            Protocol = "SIP"
            ProtocolSide = "User"
            CallingSearchSpaceName = "Gateway_outbound_CSS"
            DevicePoolName = "TPA_DP"
            SecurityProfileName = "Cisco Unified Client Services Framework - Standard SIP Non-Secure"
            SipProfileName = "Standard SIP Profile"
            MediaResourceListName = "TPA_MRL"
            Locationname = "Hub_None"
            Dirnuuid = $Dirnuuid
            Label = $DisplayName
            AsciiLabel = $DisplayName
            Display = $DisplayName
            DisplayAscii = $DisplayName
            E164Mask = "941441XXXX"
            PhoneTemplateName = "Standard Client Services Framework"
        }
        
        Add-CUCMPhone @Parameters
        
        $Parameters = @{
            UserID = $UserID
            Pattern = $Pattern
            imAndPresenceEnable = "True"
            serviceProfile = "UCServiceProfile_Migration_1"
            DeviceName = "$DeviceName" + $UserID
            routePartitionName = "UCCX_PT"
            userGroupName = "CCM END USER SETTINGS"
            userRolesName = "CCM END USER SETTINGS"
        }
       
        Set-CUCMUser @Parameters

        $Parameters = @{
            Pattern = $Pattern
            UserID = $UserID
            RoutePartition = "UCCX_PT"
            CSS = "UCCX_CSS"

        }

        Set-CUCMIPCCExtension @Parameters

        $CUCMAppuser = Get-CUCMAppuser -UserID AXL_uccx_RmCm
        $DeviceNames = @($CUCMAppuser.associatedDevices.device)
        $DeviceNames += "$DeviceName" + $UserID
        Set-CUCMAppuser -UserID AXL_uccx_RmCm -DeviceNames $DeviceNames
    }
}

function New-TervisCiscoJabber {
    param (
        [Parameter(Mandatory)][String]$UserID
    )

    $ADUser = Get-ADUser $UserID
    if (-not $ADUser) { Throw "No ADUser with identity $UserID"}
    
    $Pattern = Find-CUCMLine -Pattern 7% -Description "" | select -First 1
    Set-ADUser $UserID -OfficePhone $Pattern
    Sync-CUCMtoLDAP -LDAPDirectory TERV_AD

    do {
        sleep -Seconds 3
    } until (Get-CUCMUser -UserID $UserID -ErrorAction SilentlyContinue)

    $DisplayName = $ADUser.name
    $DeviceName = "CSF"
        
    $Parameters = @{
        Pattern = $Pattern
        routePartition = "Phones_TPA_PT"
        CSS = "TPA_CSS"
        Description = $DisplayName
        AlertingName = $DisplayName
        AsciiAlertingName = $DisplayName
        userHoldMohAudioSourceId = "0"
        networkHoldMohAudioSourceId = "0"
        voiceMailProfileName = "Voicemail"
        CallForwardAllForwardToVoiceMail = "False"
        CallForwardAllcallingSearchSpaceName = "TPA_CSS"
        CallForwardAllsecondarycallingSearchSpaceName = "TPA_CSS"
        CallForwardBusyForwardToVoiceMail= "True"
        CallForwardBusycallingSearchSpaceName = "TPA_CSS"
        CallForwardBusyIntForwardToVoiceMail = "True"
        CallForwardBusyIntcallingSearchSpaceName = "TPA_CSS"
        CallForwardNoAnswerForwardToVoiceMail = "True"
        CallForwardNoAnswercallingSearchSpaceName = "TPA_CSS"
        CallForwardNoAnswerIntForwardToVoiceMail = "True"
        CallForwardNoAnswerIntcallingSearchSpaceName = "TPA_CSS"
        CallForwardNoCoverageForwardToVoiceMail = "True"
        CallForwardNoCoveragecallingSearchSpaceName = "TPA_CSS"
        CallForwardNoCoverageIntForwardToVoiceMail = "True"
        CallForwardNoCoverageIntcallingSearchSpaceName = "TPA_CSS"
        CallForwardOnFailureForwardToVoiceMail = "True"
        CallForwardOnFailurecallingSearchSpaceName = "TPA_CSS"
        CallForwardNotRegisteredForwardToVoiceMail = "True"
        CallForwardNotRegisteredcallingSearchSpaceName = "TPA_CSS"
        CallForwardNotRegisteredIntForwardToVoiceMail = "True"
        CallForwardNotRegisteredIntcallingSearchSpaceName = "TPA_CSS"
        index = "1"
        Display = $DisplayName
    }

    $Dirnuuid = Set-CUCMAgentLine @Parameters

    $Parameters = @{
        UserID = $UserID
        DeviceName = "$DeviceName" + $UserID
        Description = $DisplayName
        Product = "Cisco Unified Client Services Framework"
        Class = "Phone"
        Protocol = "SIP"
        ProtocolSide = "User"
        CallingSearchSpaceName = "Gateway_outbound_CSS"
        DevicePoolName = "TPA_DP"
        SecurityProfileName = "Cisco Unified Client Services Framework - Standard SIP Non-Secure"
        SipProfileName = "Standard SIP Profile"
        MediaResourceListName = "TPA_MRL"
        Locationname = "Hub_None"
        Dirnuuid = $Dirnuuid
        Label = $DisplayName
        AsciiLabel = $DisplayName
        Display = $DisplayName
        DisplayAscii = $DisplayName
        E164Mask = "941441XXXX"
        PhoneTemplateName = "Standard Client Services Framework"
    }
        
    Add-CUCMPhone @Parameters
        
    $Parameters = @{
        UserID = $UserID
        Pattern = $Pattern
        imAndPresenceEnable = "True"
        serviceProfile = "UCServiceProfile_Migration_1"
        DeviceName = "$DeviceName" + $UserID
        routePartitionName = "Phones_TPA_PT"
        userGroupName = "CCM END USER SETTINGS"
        userRolesName = "CCM END USER SETTINGS"
    }

    Set-CUCMUser @Parameters

    $Parameters = @{
        Pattern = $Pattern
        UserID = $UserID
        RoutePartition = "Phones_TPA_PT"
        CSS = "TPA_CSS"
    }
}
function Import-TervisCsOnlineSession {

    $Sessions = Get-PsSession |
    Where-Object ComputerName -eq "admin2a.online.lync.com" |
    Where-Object ConfigurationName -eq "Microsoft.PowerShell"
    
    $Sessions |
    Where-Object State -eq "Broken" |
    Remove-PSSession
    $Session = $Sessions |
    Where-Object State -eq "Opened" |
    Select-Object -First 1

    if (-Not $Session) {
        New-CsOnlineSession -UserName "$env:USERNAME@$env:USERDOMAIN.com" | Out-Null
        $Session = Get-PsSession |
        Where-Object ComputerName -eq "admin2a.online.lync.com" |
        Where-Object ConfigurationName -eq "Microsoft.PowerShell" |
        Where-Object State -eq "Opened" |
        Select-Object -First 1
        Import-Module -Global  (Import-PSSession -DisableNameChecking -AllowClobber $Session)
    }
    Import-Module -Global (Import-PSSession -AllowClobber -DisableNameChecking $Session)
}

function Set-MicrosoftTeamsPhoneNumber {
    param (
        $UserID,
        $LocationID
    )
    $phoneNumber = Get-CsOnlineTelephoneNumber | Where-Object TargetType -Like "" | Select-Object -ExpandProperty Id -First 1
    
    While (-not (Get-CsOnlineVoiceUser -Identity $UserID | Where-Object PSTNConnectivity -Like "Online" )) {
        
        Start-Sleep 60
    }
    Set-CsOnlineVoiceUser -Identity $UserID -TelephoneNumber $phoneNumber -LocationID "d99a1eb3-f053-448a-86ec-e0d515dc0dea"
    Set-ADUser $UserID -OfficePhone $phoneNumber
}

function New-TervisMicrosoftTeamPhone {
    param (
        [Parameter(Mandatory)][String]$UserID,
        [Parameter(Mandatory)][ValidateSet("d99a1eb3-f053-448a-86ec-e0d515dc0dea")][String]$LocationID
    )
    Connect-TervisMsolService
    
    $PhoneSystemSKU = Get-MsolAccountSku |
    Where-Object {$_.AccountSkuID -match "MCOEV"} |
    Select-Object -ExpandProperty AccountSkuID

    $CallingPlanSKU = Get-MsolAccountSku |
    Where-Object {$_.AccountSkuID -match "MCOPSTN_5"} |
    Select-Object -ExpandProperty AccountSkuID
    
    Set-MsolUserLicense -UserPrincipalName $UserID@tervis.com -AddLicenses $PhoneSystemSKU
    Set-MsolUserLicense -UserPrincipalName $UserID@tervis.com -AddLicenses $CallingPlanSKU
    
    Import-TervisCsOnlineSession

    Set-MicrosoftTeamsPhoneNumber -UserID $UserID -LocationID $LocationID
    Grant-CsTeamsUpgradePolicy -PolicyName tag:UpgradeToTeams -Identity $UserID@tervis.com
    Grant-CsTeamsInteropPolicy -PolicyName tag:DisallowOverrideCallingTeamsChatTeams -Identity $UserID@tervis.com
}

function Get-TervisMicrosoftCallingPlan {
    param (
    $Name
    )

    $MicrosoftCallingPlanName | Where-Object Name -EQ $Name
}

function Get-MicrosoftTeamVoipPricing {
    param(
        [int]$DomesticUsers,
        [int]$InterNationalUsers,
        [int]$Domestic120MintsUsers,
        [int]$Domestic240MintsUsers
    )
    [decimal]$PhoneSystem = 6.6
    $Domestic = Get-TervisMicrosoftCallingPlan -Name "MCOPSTN1"
    $InterNational = Get-TervisMicrosoftCallingPlan -Name "MCOPSTN2"
    $Domestic120 = Get-TervisMicrosoftCallingPlan -Name "MCOPSTN5"
    $Domestic240 = Get-TervisMicrosoftCallingPlan -Name "MCOPSTN6"
    
    $DomesticPrice = $DomesticUsers * ($Domestic.UserMonthPrice + $PhoneSystem)
    Write-Host "Price of Domestic Calling is "$DomesticPrice"" 
    
    $InterNationalPrice = $InterNationalUsers * ($InterNational.UserMonthPrice + $PhoneSystem)
    Write-Host "Price of International Calling is "$InterNationalPrice"" 
    
    $Domestic120MinPrice = $Domestic120MintsUsers * ($Domestic120.UserMonthPrice + $PhoneSystem)
    Write-Host "Price of Domestic120Minutes Calling is "$Domestic120MinPrice""
    
    $Domestic240MinPrice = $Domestic240MintsUsers * ($Domestic240.UserMonthPrice + $PhoneSystem)
    Write-Host "Price of Domestic240Minutes Calling is "$Domestic240MinPrice""
    
    $TotalPrice = $DomesticPrice + $InterNationalPrice + $Domestic120MinPrice + $Domestic240MinPrice
    Write-Host "The total monthly Price is "$TotalPrice""
    $TotalMinutes = ($DomesticUsers * $Domestic.MinutePermonth) + ($InterNationalUsers * $InterNational.MinutePerMonth) +
                    ($Domestic120MintsUsers * $Domestic120.MinutePerMonth) + ($Domestic240MintsUsers * $Domestic240.MinutePerMonth)
    Write-Host "The total Minutes is "$TotalMinutes""
}

function Get-CiscoCallingPlan {
    param (
    $Name
    )
    $CiscoCallingPlan | Where-Object Name -EQ $Name
}

function Get-CiscoPhonePricing {
    param (
        [int]$NumberOfUsers
    )
    [int]$WindstreamMonthlyCharge = 3602
    [int]$VoiceGatewayMonthyCharge = 96
    $Cer = Get-CiscoCallingPlan -Name CER
    $CUCM = Get-CiscoCallingPlan -Name CUCM

    $CerMonthlyCharge = $Cer.UserMonthPrice * $NumberOfUsers
    $CucmMonthlyCharge = $CUCM.UserMonthPrice * $NumberOfUsers

    $TotalMonthlyCharge = ($CerMonthlyCharge + $CucmMonthlyCharge + $WindstreamMonthlyCharge + $VoiceGatewayMonthyCharge)
    Write-Host "The total Monthly Charge is  is "$TotalMonthlyCharge""
    
}


