#Check if S1 is already installed
try {
    $installed = Get-ItemProperty -LiteralPath "HKLM\SYSTEM\CurrentControlSet\Services\SentinelAgent\config\"
}
catch {
    Write-Output "Unable to read HKLM\SYSTEM\CurrentControlSet\Services\SentinelAgent\config\ . Cannot determine if S1 is already installed. Full error message:"
    Write-Output $_
    exit 1
}

if ($installed) {
    Write-Output "SentinelOne is already installed"
    exit 1
} 
else {
    Write-Host "SentinelOne is not installed, proceeding to next check"
}

#Check that site token is filled out
#S1SiteToken is the global and site variable for the SentinelOne site token.
#This tells S1 what site to tie the agent to in the S1 portal after install

if (!$env:SentinelOneSiteToken) {
    Write-Output "S1 site token not found, please check site variables for S1SiteToken and make sure it exists and is filled out"
    Write-Output "S1 site token reporting as $env:SentinelOneSiteToken"
    exit 1
}
elseif ($env:SentinelOneSiteToken -eq 0) {
    Write-Output "S1 site token still has the default value of 0, please check site variables for S1SiteToken and make sure it exists and is filled out"
    exit 1
}
else {
    Write-Output "S1 site token is $env:SentinelOneSiteToken, proceeding to next step"
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
    C:\Software\SentinelAgent.exe /silent /SITE_TOKEN=$env:SentinelOneSiteToken
}
catch {
    Write-Output "S1 agent was not able to install successfully. Full error message:"
    Write-Output $_
    exit 1
}

#Clean up the S1 installer
try {
    Remove-Item -Path "C:\Software\SentinelAgent.exe"
}
catch {
    Write-Output "Could not clean up installer. Please check C:\Software\SentinelAgent.exe and see if it was removed. Full error message:"
    Write-Output $_
    exit 1
}

#Check that S1 was installed
try {
    $S1installed = Get-ItemProperty -LiteralPath "HKLM\SYSTEM\CurrentControlSet\Services\SentinelAgent\config\"
}
catch {
    Write-Output "Unable to read HKLM\SYSTEM\CurrentControlSet\Services\SentinelAgent\config\ . Cannot determine if S1 was installed successfully. Full error message:"
    Write-Output $_
    exit 1
}

if ($S1installed) {
    Write-Output "SentinelOne is installed."
    Write-Output "NOTE: Endpoint restart is required for full SentinelOne visibility and control"
    exit 0
} 
else {
    Write-Host "SentinelOne is not installed."
    exit 1
}
