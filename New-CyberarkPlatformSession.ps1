# New-CyberArkPlatformSession
<#
.SYNOPSIS
Creates a session object which can be imported into psPAS using the Use-PASSession command

.DESCRIPTION
psPAS does not support authentication to the CyberArk Shared Services platform. This script will
generate a CyberArk Session object which can be provided to psPAS to bypass its authentication
and allow you to run other commands against Privilege Cloud

.PARAMETER PlatformUri
Your Shared Services platform Uri, e.g. https://subdomain.cyberark.cloud
This may vary based on when your tenant was provisioned. For details see
https://docs.cyberark.com/Product-Doc/OnlineHelp/PrivCloud-SS/Latest/en/Content/WebServices/ISP-Auth-APIs.htm

.PARAMETER Credential
A credential object (created with with the username and password for an OAuth user in Identity
which has the required Privilege Cloud roles and permissions

.INPUTS
None. You cannot pipe objects to New-CyberArkPlatformSession

.OUTPUTS
A psPAS.CyberArk.Vault.Session object

.EXAMPLE
PS> $PASSession = New-CyberArkPlatformSession -Credential $Credential -PlatformUri https://acmecorp.cyberark.cloud -PrivilegeCloudUri https://acmecorp.privilegecloud.cyberark.cloud
PS> Use-PASSession -Session $PASSession
#>

param(
    [Parameter(Mandatory = $True)]
    [pscredential]
    $Credential,

    [Parameter(Mandatory = $True)]
    [string]
    $PlatformUri,

    [Parameter(Mandatory = $True)]
    [string]
    $PrivilegeCloudUri
)

$LogonRequest = @{
    Method      = "POST"
    ContentType = "application/x-www-form-urlencoded"
    Uri         = "$PlatformUri/api/idadmin/oauth2/platformtoken"
    Body        = @{
        grant_type    = "client_credentials"
        client_id     = $($Credential.UserName)
        client_secret = $($Credential.GetNetworkCredential().Password)
    }
}

$Request = Invoke-RestMethod @LogonRequest
$Token = $Request.access_token
$WebSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$WebSession.Headers.Add("Authorization", "Bearer $Token")

$PASSession = [PSCustomObject]@{
    User            = $Credential.Username
    BaseURI         = "$PrivilegeCloudUri/PasswordVault"
    ExternalVersion = "0.0"
    WebSession      = $WebSession
}

$PASSession.PSTypeNames.Insert(0, "psPAS.CyberArk.Vault.Session")

$PASSession
