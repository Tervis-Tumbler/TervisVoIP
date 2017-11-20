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
    
    $Pattern = Find-CUCMLine -Pattern 4% -Description "" | select -First 1
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
