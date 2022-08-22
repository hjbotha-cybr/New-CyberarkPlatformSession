# New-CyberArkPlatformSession
psPAS does not support authentication to the CyberArk Shared Services platform, and implementing it is non-trivial.

This script will generate a CyberArk Session object which can be provided to psPAS instead of using New-PASSession.

## Usage
```
$PASSession = & New-CyberArkPlatformSession.ps1 -Credential $Credential -PlatformUri https://acmecorp.cyberark.cloud -PrivilegeCloudUri https://acmecorp.privilegecloud.cyberark.cloud

Use-PASSession -Session $PASSession
```

