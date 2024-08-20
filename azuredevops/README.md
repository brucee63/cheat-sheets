# Azure DevOps

## Setup Linux Build-Deploy Agent
Bash script to create build agent. This will allow for unattended setup as long as the user has sudo permissions and the user exists on the host. Please replace the url, pat, user and pool in the script below with your values.

```sh
#!/bin/bash
echo "$0 beginning setup of Azure DevOps agent..."

# agent name will be the hostname.
currenthost=$(hostname | awk -v RS=. 1 | head -n 1 | awk '{print tolower($0)}')
devopsurl=https://my-org.visualstudio.com/
azurepat="pat-generated-from-azure-devops"	# be sure scope includes Agent Pools (Read & manage)
buildaccount="user-serviceaccount"  # this is case sensitive
azurepool="build-deploy-pool"

sudo mkdir -p /data/build
sudo mkdir -p /data/build/myagent

echo "downloading Azure DevOps agent..."
cd /data/build/myagent
sudo wget https://vstsagentpackage.azureedge.net/agent/2.211.0/vsts-agent-linux-x64-2.211.0.tar.gz
echo "unpacking tar.gz download..."
sudo tar zxvf vsts-agent-linux-x64-2.211.0.tar.gz

sudo chown -R ${buildaccount} /data/build/myagent

echo "configuring agent with token, pool name..."
echo "note that the next few statements need to be executed as the build account and not sudo"
sudo -u ${buildaccount} bash -c "./config.sh --unattended --url ${devopsurl} \
    --auth pat --token ${azurepat} \
    --pool ${azurepool} \
    --agent ${currenthost} \
    --replace \
    --work /data/build/myagent/_work \
    --acceptTeeEula"

echo "installing / creating agent to run as a service for current user..."
sudo -u ${buildaccount} bash -c "sudo ./svc.sh install ${buildaccount}"
echo "starting agent..."
sudo -u ${buildaccount} bash -c "sudo ./svc.sh start"

echo "$0 complete..."

```

## Setup Windows Build-Deploy agent

```ps
# run this on the windows server
$devopsurl="https://my-org.visualstudio.com/"
$azurepat="pat-generated-from-azure-devops"
$deploymentpool="build-deploy-pool"

# for more information on setup of a deployment agent - https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/v2-windows?view=azure-devops

Write-Host "Registering deployment agent..."

$ErrorActionPreference = "Stop";
If(-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent() ).IsInRole( [Security.Principal.WindowsBuiltInRole] "Administrator")) 
{ throw "Run command in an administrator PowerShell prompt" };
If ($PSVersionTable.PSVersion -lt (New-Object System.Version("3.0"))) { 
    throw "The minimum version of Windows PowerShell that is required by the script (3.0) does not match the currently running version of Windows PowerShell." 
};
If (-NOT (Test-Path $env:SystemDrive\'azagent')) {
    mkdir $env:SystemDrive\'azagent'
};
cd $env:SystemDrive\'azagent';
for ($i = 1; $i -lt 100; $i++) {
    $destFolder = "A" + $i.ToString();
    if (-NOT (Test-Path ($destFolder))) {
        mkdir $destFolder; 
        cd $destFolder; 
        break;
    }
};
$agentZip = "$PWD\agent.zip";
$DefaultProxy = [System.Net.WebRequest]::DefaultWebProxy; 
$securityProtocol = @();
$securityProtocol += [Net.ServicePointManager]::SecurityProtocol;
$securityProtocol += [Net.SecurityProtocolType]::Tls12; [Net.ServicePointManager]::SecurityProtocol = $securityProtocol; $WebClient = New-Object Net.WebClient;
$Uri='https://vstsagentpackage.azureedge.net/agent/3.220.5/vsts-agent-win-x64-3.220.5.zip';
if($DefaultProxy -and (-not $DefaultProxy.IsBypassed($Uri)))
$WebClient.DownloadFile($Uri, $agentZip);
Add-Type -AssemblyName System.IO.Compression.FileSystem;
[System.IO.Compression.ZipFile]::ExtractToDirectory( $agentZip, "$PWD");

#this will run as NT AUTHORITY\SYSTEM
#default agent name to hostname
.\config.cmd --unattended `
    --deploymentpool `
    --deploymentpoolname "${deploymentpool}" `
    --agent $env:COMPUTERNAME `
    --replace `
    --runasservice --work '_work' `
    --url $devopsurl `
    --auth PAT --token "${azurepat}"
Remove-Item $agentZip;
```