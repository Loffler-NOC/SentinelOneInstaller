#Check if S1 is already installed

$programName = "Sentinel Agent"

try {
    $installed = Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
}
catch {
    Write-Output "Unable to read HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* . Cannot determine if S1 is already installed. Full error message:"
    Write-Output $_
    exit 1
}

if ($installed) {
    Write-Output "SentinelOne is already installed."
    exit 1
} 
else {
    Write-Host "SentinelOne is not installed, proceeding to next check"
}

#Check that S1 deployment is enabled
#UDF11 is Disable S1 Autodeploy
#DisableS1AutoDeploy is the global and site variable for disable S1 Autodeploy

if ($env:UDF_11 -eq 1) {
    Write-Output "SentinelOne deployment is disabled at the device level, exiting script."
    exit 1
} 
elseif ($env:UDF_11 -eq 0) {
    Write-Output "SentinelOne deployment is enabled at the device level, proceeding to next check."
}
elseif (!$env:UDF_11) {
    Write-Output "UDF11 DisableS1AutoDeploy is blank, value is reporting as: "$env:UDF_11" , valid values are 0 or 1, exiting script with error"
    exit 1
}
else {
    Write-Output "UDF11 DisableS1AutoDeploy has an unexpected value of $env:UDF_11 , valid values are 0 or 1, exiting script with error"
    exit 1
}

if ($env:SentinelOneDeployEnabled -eq 0) {
    Write-Output "$programName deployment is disabled at the site level, exiting script."
    exit 1
} 
elseif ($env:SentinelOneDeployEnabled -eq 1) {
    Write-Output "$programName deployment is enabled at the device level, proceeding to next check."
}
else {
    Write-Output "Site variable SentinelOneDeployEnabled has an unexpected value of $env:SentinelOneDeployEnabled , valid values are 0 or 1, exiting script with error"
    exit 1
}

#Check that site token is filled out
#S1SiteToken is the global and site variable for the SentinelOne site token.
#This tells S1 what site to tie the agent to in the S1 portal after install

if (!$env:S1SiteToken) {
    Write-Output "S1 site token not found, please check site variables for S1SiteToken and make sure it exists and is filled out"
    exit 1
}
elseif ($env:S1SiteToken -eq 0) {
    Write-Output "S1 site token still has the default value of 0, please check site variables for S1SiteToken and make sure it exists and is filled out"
    exit 1
}
else {
    Write-Output "S1 site token is $env:S1SiteToken, proceeding to next step."
}

#Download the S1 installer
try {
    Invoke-WebRequest -Uri https://update.itsupport247.net/SentinelOne/SentinelOne_windows.exe -Outfile C:\Software\SentinelAgent.exe
}
catch {
    Write-Output "S1 was not able to be downloaded. Please check that the device is able to reach https://update.itsupport247.net/SentinelOne/SentinelOne_windows.exe . Full error message:"
    Write-Output $_
    exit 1
}

#Run the S1 installer
try {
    C:\Software\SentinelAgent.exe /silent /SITE_TOKEN=$env:S1SiteToken
}
catch {
    Write-Output "S1 agent was not able to install successfully. Full error message:"
    Write-Output $_
    exit 1
}

#Clean up the S1 installer
try {
    Remove-Item -Path "C:\Temp"
}
catch {
    Write-Output "Could not clean up installer. Please check C:\Software\SentinelAgent.exe and see if it was removed. Full error message:"
    Write-Output $_
    exit 1
}

#Check that S1 was installed
try {
    $S1installed = Get-ItemProperty -Path "HKLM\SYSTEM\CurrentControlSet\Services\SentinelAgent\config\"
}
catch {
    Write-Output "Unable to read HKLM\SYSTEM\CurrentControlSet\Services\SentinelAgent\config\ . Cannot determine if S1 was installed successfully. Full error message:"
    Write-Output $_
    exit 1
}

if ($S1installed) {
    Write-Output "SentinelOne is installed."
    Write-Output "NOTE: Endpoint restart is required for full SentinelOne visibility and control."
    exit 0
} 
else {
    Write-Host "SentinelOne is not installed."
    exit 1
}
