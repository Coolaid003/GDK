[CmdletBinding()]
param
(
    [Parameter(Mandatory=$false)]
    [string]
    $AppxPath,

    [Parameter(Mandatory=$false)]
    [string]
    $LogPath,

    [Parameter(Mandatory=$false)]
    [string]
    $AppxDepDirPath
)

function Logic
{
   $Error.Clear();

   if(!$AppxPath)
   {
       $AppxPath = Join-Path $PSScriptRoot "GamingServices.appxbundle";
   }

    if(-not (test-path $AppxPath))
   {
       Write-Output "ERROR: Appx not found: $AppxPath";
       exit 1;
   }
   
   if(!$AppxDepDirPath)
   {
       $AppxDepDirPath = (get-item $AppxPath).Directory.FullName;
   }

   $systemVolume = Get-AppxVolume | Where-Object -Property IsSystemVolume -eq $True | Select-Object -First 1;

   if(!$systemVolume)
   {
       Write-Output "ERROR: System volume not found.";
       exit 1;
   }

   Write-Output ("System volume found.`n{0}" -f ($systemVolume | Format-List | Out-String).trim());

   $systemRoot = [System.IO.path]::GetPathRoot($systemVolume.PackageStorePath);

   if(!$systemRoot)
   {
       Write-Output "ERROR: System root not found.";
       exit 1;
   }

   Write-Output "System root found: $systemRoot";

   $package = Get-AppxPackage -Name Microsoft.GamingServices* | Sort-Object -Property Version -Descending | Select-Object -First 1;
   $isOldPackagePresent = $false;

   if($package)
   {
       Write-Output ("Version {0} of {1} was found already installed on the PC.`n{2}" -f $package.Version, $package.Name, ($package | Format-List | Out-String).trim());

       $isOldPackagePresent = (([Version]$package.Version -lt [Version]'2.53.24001.0') -or ([Version]$package.Version -eq [Version]'1.43.2002.0'));

       if($isOldPackagePresent)
       {
           Write-Output "Uninstalling $($package.PackageFullName) version $($package.Version)";
           remove-appxpackage -allusers $package.PackageFullName -ErrorAction Continue;

           if($Error)
           {
               Write-Output "Remove-AppxPackage failed for $($package.PackageFullName)";
           }
           else
           {
               Write-Output "Remove-AppxPackage completed for $AppxPath";
           }
       }
   }
   else
   {
       Write-Output 'No versions of Microsoft.GamingServices were found installed on the PC.';
   }

   if(($package -eq $null) -or $isOldPackagePresent)
   {
       Write-Output "Installing $AppxPath Version 2.53.24001.0 Volume $systemRoot";

       $allDepsFound = $TRUE;
       [string[]]$depPackageNames = 'Microsoft.NET.Native.Runtime.2.2','Microsoft.NET.Native.Framework.2.2','Microsoft.VCLibs.x64.14.00';
       $dependencyPaths = $depPackageNames | ForEach-Object {Join-Path -Path $AppxDepDirPath -ChildPath "$_.appx"};
       ForEach ($dep in $dependencyPaths) {if (-not (test-path $dep)) {$allDepsFound = $FALSE;}};

       if($allDepsFound)
       {
           Write-Output "Installing $AppxPath Version 2.53.24001.0 Volume $systemRoot -DependencyPath $dependencyPaths";
           add-appxpackage -forceApplicationShutdown -path $AppxPath -Volume $systemRoot -DependencyPath $dependencyPaths -ErrorAction Continue;
       }
       else
       {
           Write-Output "Installing $AppxPath Version 2.53.24001.0 Volume $systemRoot";
           add-appxpackage -forceApplicationShutdown -path $AppxPath -Volume $systemRoot -ErrorAction Continue;
       }

       if($Error)
       {
           Write-Output "ERROR: Add-AppxPackage failed for $AppxPath";
           $guid = ($error -split ' ' | select -Last 1) -as [Guid];
           if($guid)
           {
               Write-Output "Get-AppPackageLog -ActivityID $guid";
               Get-AppPackageLog -ActivityID $guid;
           }
       }
       else
       {
           Write-Output "Add-AppxPackage completed for $AppxPath";
       }
   }
   else
   {
       Write-Output "No installation needed as version $($package.Version) of $($package.Name) was found already installed on the PC.";
   }
}

$output = Logic;

if($LogPath)
{
    $output | Out-File -FilePath $LogPath -Append -Force;
}
else
{
    $output;
}

exit ($Error.Count);

# SIG # Begin signature block
# MIIl2wYJKoZIhvcNAQcCoIIlzDCCJcgCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCB9KivsG2Eh9+sZ
# RPx1FMLiNhi/UPOuYYDUbXcNMh2kSaCCC2cwggTvMIID16ADAgECAhMzAAAEOA/I
# Xba8U/0OAAAAAAQ4MA0GCSqGSIb3DQEBCwUAMH4xCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25p
# bmcgUENBIDIwMTAwHhcNMjEwOTAyMTgyNTU3WhcNMjIwOTAxMTgyNTU3WjB0MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMR4wHAYDVQQDExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQCurn8/CcSq9qOPnAFrKtGtCy/iX+WUNZ9pll+bOTwGISP3nAKZGu3AJVgzK2Kx
# dEciTQExXZIEpUKSBJDNY4QX6beqtbbU6lGNlbxB3b73e5tQ16DpQGYUkeHJk2a9
# uT3cv0j8VOZDZCqb1zFpJtrF4vggAimoc2DPUVa7B7oDemRU8GQuCCFPl1IydL4u
# 57q9W7gb0zIm0DGw1P03Yv7SzQPAFbVRe+92D8f4W9SM8/EYDAAEdOn1RwRmRZd5
# avK5U1D3/APqdldgNzn0UozCWbiz84AsHR7BheqzDWEx0wvSsCIywv82xUW7wY2c
# 0K6eXMKAIjhAOtJT5RCun1CnAgMBAAGjggFuMIIBajAfBgNVHSUEGDAWBgorBgEE
# AYI3PQYBBggrBgEFBQcDAzAdBgNVHQ4EFgQUgZix3QHakOJ1+OMpggGOIMFUPxgw
# RQYDVR0RBD4wPKQ6MDgxHjAcBgNVBAsTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEW
# MBQGA1UEBRMNMjMwODY1KzQ2NzM5NzAfBgNVHSMEGDAWgBTm/F97uyIAWORyTrX0
# IXQjMubvrDBWBgNVHR8ETzBNMEugSaBHhkVodHRwOi8vY3JsLm1pY3Jvc29mdC5j
# b20vcGtpL2NybC9wcm9kdWN0cy9NaWNDb2RTaWdQQ0FfMjAxMC0wNy0wNi5jcmww
# WgYIKwYBBQUHAQEETjBMMEoGCCsGAQUFBzAChj5odHRwOi8vd3d3Lm1pY3Jvc29m
# dC5jb20vcGtpL2NlcnRzL01pY0NvZFNpZ1BDQV8yMDEwLTA3LTA2LmNydDAMBgNV
# HRMBAf8EAjAAMA0GCSqGSIb3DQEBCwUAA4IBAQDOS4QT+AjIqX3O7FH4FD6TTJWK
# viXQBZv1aL02GgTGqHvFqbilEbQ8TW81TcoU7t7WB2QGqu/utgFqh1UaNsrQNf+R
# +NIvcB5hESNsDco18jQtul935jlJu+J01I1CeeoW4/Xlrbmbuluugm5wUcGclLi5
# 3uALKWQGMp2d14BeIu52stPJQdnn292bk6b9aONC4ic3rjSZGxwz92kmO2XRFsdK
# 5DPVlJj06FLU7i4nzcOLijtLkuIm9vcWDIwgpSV+JHYirr3nGis2AbR9qzTGhOHq
# OfsHvN7gunVTcP3Fz8JRds8nmyS0tSR9ulYU/n1uyDx1CxRq5seFa7fGBfVMMIIG
# cDCCBFigAwIBAgIKYQxSTAAAAAAAAzANBgkqhkiG9w0BAQsFADCBiDELMAkGA1UE
# BhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAc
# BgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEyMDAGA1UEAxMpTWljcm9zb2Z0
# IFJvb3QgQ2VydGlmaWNhdGUgQXV0aG9yaXR5IDIwMTAwHhcNMTAwNzA2MjA0MDE3
# WhcNMjUwNzA2MjA1MDE3WjB+MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGlu
# Z3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBv
# cmF0aW9uMSgwJgYDVQQDEx9NaWNyb3NvZnQgQ29kZSBTaWduaW5nIFBDQSAyMDEw
# MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA6Q5kUHlntcTj/QkATJ6U
# rPdWaOpE2M/FWE+ppXZ8bUW60zmStKQe+fllguQX0o/9RJwI6GWTzixVhL99COMu
# K6hBKxi3oktuSUxrFQfe0dLCiR5xlM21f0u0rwjYzIjWaxeUOpPOJj/s5v40mFfV
# HV1J9rIqLtWFu1k/+JC0K4N0yiuzO0bj8EZJwRdmVMkcvR3EVWJXcvhnuSUgNN5d
# pqWVXqsogM3Vsp7lA7Vj07IUyMHIiiYKWX8H7P8O7YASNUwSpr5SW/Wm2uCLC0h3
# 1oVH1RC5xuiq7otqLQVcYMa0KlucIxxfReMaFB5vN8sZM4BqiU2jamZjeJPVMM+V
# HwIDAQABo4IB4zCCAd8wEAYJKwYBBAGCNxUBBAMCAQAwHQYDVR0OBBYEFOb8X3u7
# IgBY5HJOtfQhdCMy5u+sMBkGCSsGAQQBgjcUAgQMHgoAUwB1AGIAQwBBMAsGA1Ud
# DwQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MB8GA1UdIwQYMBaAFNX2VsuP6KJcYmjR
# PZSQW9fOmhjEMFYGA1UdHwRPME0wS6BJoEeGRWh0dHA6Ly9jcmwubWljcm9zb2Z0
# LmNvbS9wa2kvY3JsL3Byb2R1Y3RzL01pY1Jvb0NlckF1dF8yMDEwLTA2LTIzLmNy
# bDBaBggrBgEFBQcBAQROMEwwSgYIKwYBBQUHMAKGPmh0dHA6Ly93d3cubWljcm9z
# b2Z0LmNvbS9wa2kvY2VydHMvTWljUm9vQ2VyQXV0XzIwMTAtMDYtMjMuY3J0MIGd
# BgNVHSAEgZUwgZIwgY8GCSsGAQQBgjcuAzCBgTA9BggrBgEFBQcCARYxaHR0cDov
# L3d3dy5taWNyb3NvZnQuY29tL1BLSS9kb2NzL0NQUy9kZWZhdWx0Lmh0bTBABggr
# BgEFBQcCAjA0HjIgHQBMAGUAZwBhAGwAXwBQAG8AbABpAGMAeQBfAFMAdABhAHQA
# ZQBtAGUAbgB0AC4gHTANBgkqhkiG9w0BAQsFAAOCAgEAGnTvV08pe8QWhXi4UNMi
# /AmdrIKX+DT/KiyXlRLl5L/Pv5PI4zSp24G43B4AvtI1b6/lf3mVd+UC1PHr2M1O
# HhthosJaIxrwjKhiUUVnCOM/PB6T+DCFF8g5QKbXDrMhKeWloWmMIpPMdJjnoUdD
# 8lOswA8waX/+0iUgbW9h098H1dlyACxphnY9UdumOUjJN2FtB91TGcun1mHCv+KD
# qw/ga5uV1n0oUbCJSlGkmmzItx9KGg5pqdfcwX7RSXCqtq27ckdjF/qm1qKmhuyo
# EESbY7ayaYkGx0aGehg/6MUdIdV7+QIjLcVBy78dTMgW77Gcf/wiS0mKbhXjpn92
# W9FTeZGFndXS2z1zNfM8rlSyUkdqwKoTldKOEdqZZ14yjPs3hdHcdYWch8ZaV4XC
# v90Nj4ybLeu07s8n07VeafqkFgQBpyRnc89NT7beBVaXevfpUk30dwVPhcbYC/GO
# 7UIJ0Q124yNWeCImNr7KsYxuqh3khdpHM2KPpMmRM19xHkCvmGXJIuhCISWKHC1g
# 2TeJQYkqFg/XYTyUaGBS79ZHmaCAQO4VgXc+nOBTGBpQHTiVmx5mMxMnORd4hzbO
# TsNfsvU9R1O24OXbC2E9KteSLM43Wj5AQjGkHxAIwlacvyRdUQKdannSF9PawZSO
# B3slcUSrBmrm1MbfI5qWdcUxghnKMIIZxgIBATCBlTB+MQswCQYDVQQGEwJVUzET
# MBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMV
# TWljcm9zb2Z0IENvcnBvcmF0aW9uMSgwJgYDVQQDEx9NaWNyb3NvZnQgQ29kZSBT
# aWduaW5nIFBDQSAyMDEwAhMzAAAEOA/IXba8U/0OAAAAAAQ4MA0GCWCGSAFlAwQC
# AQUAoIIBBDAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgEL
# MQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQxIgQgiKd+p1iNCfun0jNPbwQU
# H8gy7yWbWdUl4rKK77jcGBQwPAYKKwYBBAGCNwoDHDEuDCxzRzFaekRPZ0EraTNM
# Y0NOWU83Uy9xdWhadEtaVWpoNy9RV0FOYi9Gam84PTBaBgorBgEEAYI3AgEMMUww
# SqAkgCIATQBpAGMAcgBvAHMAbwBmAHQAIABXAGkAbgBkAG8AdwBzoSKAIGh0dHA6
# Ly93d3cubWljcm9zb2Z0LmNvbS93aW5kb3dzMA0GCSqGSIb3DQEBAQUABIIBAGOF
# 1VWixpgb2xv0oZkjPoot5qxlsOjY26v+7fO8zrzynhiu7+g62/c/1h3cYlN2LJ0a
# Oi1mt6HA351NdR3fthUOaZ/VCG6LGugy9Zrt/xNNr8bC5bce/Lv2Z0h7HF5RnJly
# ukpOY5OjO3bcDzrQs/9FdDdab51vgETW3U4QbkOXfKsuLPLTUYBCsl/tgkGAIrGU
# KQpEBVwDvlE7ikBzgBYD9TiaUtCJjgg8MIP7Baa1m/vX6aJOSyGAawknic4ZxXLn
# LoJJkiVQQEJUNNzy16zLwAs8eeb7a16lw7t5D8JVYNgy4tj1XrrImmo0A2rTPy5f
# KwZBkuOOEcCeIT5S+dyhghb9MIIW+QYKKwYBBAGCNwMDATGCFukwghblBgkqhkiG
# 9w0BBwKgghbWMIIW0gIBAzEPMA0GCWCGSAFlAwQCAQUAMIIBUQYLKoZIhvcNAQkQ
# AQSgggFABIIBPDCCATgCAQEGCisGAQQBhFkKAwEwMTANBglghkgBZQMEAgEFAAQg
# iFJ3cgBBOvnTGuOqjhGUV5aSnmS0Zul9GpOZSINQno4CBmIWXq81qRgTMjAyMjAy
# MjYxMTU2NTEuMjcyWjAEgAIB9KCB0KSBzTCByjELMAkGA1UEBhMCVVMxEzARBgNV
# BAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jv
# c29mdCBDb3Jwb3JhdGlvbjElMCMGA1UECxMcTWljcm9zb2Z0IEFtZXJpY2EgT3Bl
# cmF0aW9uczEmMCQGA1UECxMdVGhhbGVzIFRTUyBFU046MjI2NC1FMzNFLTc4MEMx
# JTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2WgghFUMIIHDDCC
# BPSgAwIBAgITMwAAAZh2s4zF0AWhAQABAAABmDANBgkqhkiG9w0BAQsFADB8MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNy
# b3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDAeFw0yMTEyMDIxOTA1MTVaFw0yMzAy
# MjgxOTA1MTVaMIHKMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQ
# MA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9u
# MSUwIwYDVQQLExxNaWNyb3NvZnQgQW1lcmljYSBPcGVyYXRpb25zMSYwJAYDVQQL
# Ex1UaGFsZXMgVFNTIEVTTjoyMjY0LUUzM0UtNzgwQzElMCMGA1UEAxMcTWljcm9z
# b2Z0IFRpbWUtU3RhbXAgU2VydmljZTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCC
# AgoCggIBAMbUlaxWSynzEbiwsyd/F+K3dKEj7sbUx9NP7le9DO4A57yvkxEAUhNO
# aMXHOgsV+ZrEu89WWYOCQOLSuqw6z0CX2NXBhIVUX/BYLb4Hvo7KyLJGPD40+PkD
# hyYyE+oh02REsIT7C24j/AJqrf8t/iSgMa50hwRhGAyqpOg45QhXh7sR1hveT2tg
# 83tKyXCwsVKn4W+b9BzLkqp+SYxfhLegnHsd2JCEpsrULpl+Jv7vrVuat08tPp51
# 2WfLCWzuEKsgi4W2BRtSPookhmfUxthjyGsAzn228ul4aYVbcaN4ECa8HECfuj0u
# nafKRPXD0jSz113CkWeMtPY8rvgYNKzEVRkbVS0vKmL+RlyD1Z6c8BmlS08V87ky
# 2J/wlryNdcsg/or5vkuJBXygjEVIF+AU3v9Mva1JJ9BVy+pfWZxI6vH+2yCrcvpg
# DEjo+XiHXNCtwCZOjKkSg9g1z9GVIGTqWOY3I0OxfeC0rynpzscJZSEX5iMyB9qd
# CYyNRixuN0SwLIvpACiNnR/qS143hxXqhsXBxQS+JjKBZt51pPzo4Z70sQ7E+6HO
# AW/ZmhtWvQnyGXUVV1xkVt8U3+B2Mdn+dwMOos1aBygygSHDDOjsUA5uoprF8HnM
# IGphKPjmaI07mDeE/wCALR5IIeXesrsk8yvUH7wlMe3BGRIrP/5zAgMBAAGjggE2
# MIIBMjAdBgNVHQ4EFgQUbpGEco2myDeaCiezstHlgdPN4TcwHwYDVR0jBBgwFoAU
# n6cVXQBeYl2D9OXSZacbUzUZ6XIwXwYDVR0fBFgwVjBUoFKgUIZOaHR0cDovL3d3
# dy5taWNyb3NvZnQuY29tL3BraW9wcy9jcmwvTWljcm9zb2Z0JTIwVGltZS1TdGFt
# cCUyMFBDQSUyMDIwMTAoMSkuY3JsMGwGCCsGAQUFBwEBBGAwXjBcBggrBgEFBQcw
# AoZQaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9jZXJ0cy9NaWNyb3Nv
# ZnQlMjBUaW1lLVN0YW1wJTIwUENBJTIwMjAxMCgxKS5jcnQwDAYDVR0TAQH/BAIw
# ADATBgNVHSUEDDAKBggrBgEFBQcDCDANBgkqhkiG9w0BAQsFAAOCAgEAJPoHoXfe
# L/z3NdOCpDwvoJgwfH0GJoc5X7CTnck6uILN5ouNiBHKywmGaecn8J0drmqNxLC9
# Gm1alkk9UrmzGE4iNEE+Cz/f4RHS9LzsgD5oZt/s0XstlmXFY86X/IUGD2pne2k4
# Y6iFAidCfnOlXbeFailo3hzj2MYkcs8B/L27v5lIZC7DXgKxb9dEsQsdPXwjrRbS
# 4o4Frk+bZWKiEyi9xuk1QIQRGog71Y/DMjAxFHDfj8uCO6yUcmin7/VV78J/I2rB
# 5SbB6lAcmt37BMtSWCbgQ1tcXqLnaMV9ikRLAt0Cfnqj+mP6Cux3YusAQ9BHKHj2
# ta8j+pl86G1PYVabMXDogm9nsLNPU74VzSAgME2pqyzlBuaQ6QpjL1TucUDqqfdl
# n4ytkywlOPuDEB/TIyRWrBhZlGThutj2rwkM+Zx81KNGtV+ljLMRUSp6YZqebG8M
# NPNLbCRIFrfNw3A6BiFYFOYl0uDKJYkZ6rKPWblvA2Cc7Do3NcKJUzN9vO12So51
# NHzwu0AkY1GN69aNB3leK0a56BKnaYwmCUXNHCSdxBq7UEmwKP/VoNjigyI7xyie
# SZpYGth7XVAJLz3r+xnBJ2cRQlqTSqmcFEUH5MdEjEiK8Io1vEbZBFnx2H3lw5eC
# jRi8E3lrWn6Ine83DOd5TYAgLvPeushs3Z8wggdxMIIFWaADAgECAhMzAAAAFcXn
# a54Cm0mZAAAAAAAVMA0GCSqGSIb3DQEBCwUAMIGIMQswCQYDVQQGEwJVUzETMBEG
# A1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWlj
# cm9zb2Z0IENvcnBvcmF0aW9uMTIwMAYDVQQDEylNaWNyb3NvZnQgUm9vdCBDZXJ0
# aWZpY2F0ZSBBdXRob3JpdHkgMjAxMDAeFw0yMTA5MzAxODIyMjVaFw0zMDA5MzAx
# ODMyMjVaMHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYD
# VQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAk
# BgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwMIICIjANBgkqhkiG
# 9w0BAQEFAAOCAg8AMIICCgKCAgEA5OGmTOe0ciELeaLL1yR5vQ7VgtP97pwHB9Kp
# bE51yMo1V/YBf2xK4OK9uT4XYDP/XE/HZveVU3Fa4n5KWv64NmeFRiMMtY0Tz3cy
# wBAY6GB9alKDRLemjkZrBxTzxXb1hlDcwUTIcVxRMTegCjhuje3XD9gmU3w5YQJ6
# xKr9cmmvHaus9ja+NSZk2pg7uhp7M62AW36MEBydUv626GIl3GoPz130/o5Tz9bs
# hVZN7928jaTjkY+yOSxRnOlwaQ3KNi1wjjHINSi947SHJMPgyY9+tVSP3PoFVZht
# aDuaRr3tpK56KTesy+uDRedGbsoy1cCGMFxPLOJiss254o2I5JasAUq7vnGpF1tn
# YN74kpEeHT39IM9zfUGaRnXNxF803RKJ1v2lIH1+/NmeRd+2ci/bfV+Autuqfjbs
# Nkz2K26oElHovwUDo9Fzpk03dJQcNIIP8BDyt0cY7afomXw/TNuvXsLz1dhzPUNO
# wTM5TI4CvEJoLhDqhFFG4tG9ahhaYQFzymeiXtcodgLiMxhy16cg8ML6EgrXY28M
# yTZki1ugpoMhXV8wdJGUlNi5UPkLiWHzNgY1GIRH29wb0f2y1BzFa/ZcUlFdEtsl
# uq9QBXpsxREdcu+N+VLEhReTwDwV2xo3xwgVGD94q0W29R6HXtqPnhZyacaue7e3
# PmriLq0CAwEAAaOCAd0wggHZMBIGCSsGAQQBgjcVAQQFAgMBAAEwIwYJKwYBBAGC
# NxUCBBYEFCqnUv5kxJq+gpE8RjUpzxD/LwTuMB0GA1UdDgQWBBSfpxVdAF5iXYP0
# 5dJlpxtTNRnpcjBcBgNVHSAEVTBTMFEGDCsGAQQBgjdMg30BATBBMD8GCCsGAQUF
# BwIBFjNodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL0RvY3MvUmVwb3Np
# dG9yeS5odG0wEwYDVR0lBAwwCgYIKwYBBQUHAwgwGQYJKwYBBAGCNxQCBAweCgBT
# AHUAYgBDAEEwCwYDVR0PBAQDAgGGMA8GA1UdEwEB/wQFMAMBAf8wHwYDVR0jBBgw
# FoAU1fZWy4/oolxiaNE9lJBb186aGMQwVgYDVR0fBE8wTTBLoEmgR4ZFaHR0cDov
# L2NybC5taWNyb3NvZnQuY29tL3BraS9jcmwvcHJvZHVjdHMvTWljUm9vQ2VyQXV0
# XzIwMTAtMDYtMjMuY3JsMFoGCCsGAQUFBwEBBE4wTDBKBggrBgEFBQcwAoY+aHR0
# cDovL3d3dy5taWNyb3NvZnQuY29tL3BraS9jZXJ0cy9NaWNSb29DZXJBdXRfMjAx
# MC0wNi0yMy5jcnQwDQYJKoZIhvcNAQELBQADggIBAJ1VffwqreEsH2cBMSRb4Z5y
# S/ypb+pcFLY+TkdkeLEGk5c9MTO1OdfCcTY/2mRsfNB1OW27DzHkwo/7bNGhlBgi
# 7ulmZzpTTd2YurYeeNg2LpypglYAA7AFvonoaeC6Ce5732pvvinLbtg/SHUB2Rje
# bYIM9W0jVOR4U3UkV7ndn/OOPcbzaN9l9qRWqveVtihVJ9AkvUCgvxm2EhIRXT0n
# 4ECWOKz3+SmJw7wXsFSFQrP8DJ6LGYnn8AtqgcKBGUIZUnWKNsIdw2FzLixre24/
# LAl4FOmRsqlb30mjdAy87JGA0j3mSj5mO0+7hvoyGtmW9I/2kQH2zsZ0/fZMcm8Q
# q3UwxTSwethQ/gpY3UA8x1RtnWN0SCyxTkctwRQEcb9k+SS+c23Kjgm9swFXSVRk
# 2XPXfx5bRAGOWhmRaw2fpCjcZxkoJLo4S5pu+yFUa2pFEUep8beuyOiJXk+d0tBM
# drVXVAmxaQFEfnyhYWxz/gq77EFmPWn9y8FBSX5+k77L+DvktxW/tM4+pTFRhLy/
# AsGConsXHRWJjXD+57XQKBqJC4822rpM+Zv/Cuk0+CQ1ZyvgDbjmjJnW4SLq8CdC
# PSWU5nR0W2rRnj7tfqAxM328y+l7vzhwRNGQ8cirOoo6CGJ/2XBjU02N7oJtpQUQ
# wXEGahC0HVUzWLOhcGbyoYICyzCCAjQCAQEwgfihgdCkgc0wgcoxCzAJBgNVBAYT
# AlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYD
# VQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJTAjBgNVBAsTHE1pY3Jvc29mdCBB
# bWVyaWNhIE9wZXJhdGlvbnMxJjAkBgNVBAsTHVRoYWxlcyBUU1MgRVNOOjIyNjQt
# RTMzRS03ODBDMSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNl
# oiMKAQEwBwYFKw4DAhoDFQDzLB7+IXkzx8hTZpPrJDe+c+lXk6CBgzCBgKR+MHwx
# CzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRt
# b25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1p
# Y3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwMA0GCSqGSIb3DQEBBQUAAgUA5cQo
# 1DAiGA8yMDIyMDIyNjEyMTkzMloYDzIwMjIwMjI3MTIxOTMyWjB0MDoGCisGAQQB
# hFkKBAExLDAqMAoCBQDlxCjUAgEAMAcCAQACAg7kMAcCAQACAhFVMAoCBQDlxXpU
# AgEAMDYGCisGAQQBhFkKBAIxKDAmMAwGCisGAQQBhFkKAwKgCjAIAgEAAgMHoSCh
# CjAIAgEAAgMBhqAwDQYJKoZIhvcNAQEFBQADgYEAaieBkr/Vwn0LBrpXGry18tkW
# 8vqm9Dw0sCKedZwETO3/dPu0jGQb1ILteTRqZnXyKNkf+NGd+DR0I8xtEase5uv+
# f5uNgys5gkYYHRO3KFblBkGvATEqBKk2sPQi2lryD22sVVttcwfm9l7D038h7Rpf
# ShRc6zctIsoafkMGZHIxggQNMIIECQIBATCBkzB8MQswCQYDVQQGEwJVUzETMBEG
# A1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWlj
# cm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFt
# cCBQQ0EgMjAxMAITMwAAAZh2s4zF0AWhAQABAAABmDANBglghkgBZQMEAgEFAKCC
# AUowGgYJKoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEEMC8GCSqGSIb3DQEJBDEiBCBU
# 0bhDr0sgm/Ihnh4qPzAxFUt8JyHcxrqHyHX8dgqCtTCB+gYLKoZIhvcNAQkQAi8x
# geowgecwgeQwgb0EIL+mzgY5Of/3A7U2Ecz1B97SWgHeyWTDUUXev5uHbVbEMIGY
# MIGApH4wfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNV
# BAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQG
# A1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTACEzMAAAGYdrOMxdAF
# oQEAAQAAAZgwIgQgEBLGiRqR2FtVjyBuNnxmHO3M81iOXoxx1Iu71auAISUwDQYJ
# KoZIhvcNAQELBQAEggIAQt7ZLFUSA3YB/uZ4BMJM9mqdXpMj57v9lwmVZ1L6WAmC
# SmO6jipQQXkQj62Z2LK4vh9kqRXi5lMnnoEnI3iEcrdkBVoKPIbXMUk059VqtaH9
# uFmzXOYLozNidHZjpwsr7pOIWPrIYj7z2WTrz4R8B6e/yg9WxTpSoi+ILgCDpgtt
# wDMlauJg0OSNZSZn7GWF7vtQ1QWxLjr3Jr6p5QxopMGOolrPxZD7nhNd0IVSs+TJ
# yCADNyDJ1VHL5qg9bJ4GuCz2LdC98EozraV5HHmbasMbV+wvY17EQTzv79e7sMaU
# q1LUxZt7vumBIflI8qJ9SFF7LF3/uAqbl1vraPEah73zpXD9Vf7NZsNZnP+nhm+Z
# g8IkyfNr+c04p5r2mmB8E/vFJ/MNy4wG/Vrf8OhqtmsIBwPQiwereDlZzXheq6AI
# UJOATlkpl9m03ZqWXYhCVdsjuUylYAqGbpvQvOMARZHVmLGWemXbiUClMeCovQ8Z
# 5mxnt9Gl9RPxR+WmcCG7wD2RTuhF1FBn4+zcSVWYuqb9sjO9jUX+lJU11SMLoDUB
# iA8qNdcW9CBprNYdHwS/sGrcoH49Ua2QNtHGjaMDXP1R4vI0f1E0VCXgDCMdSDwK
# 3jK7PWre3ye9IMYSgR0ENgJixGFlizR2JcfTArfwNo2HacmWaJyFYJwLG4OjnNE=
# SIG # End signature block
