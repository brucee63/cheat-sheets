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