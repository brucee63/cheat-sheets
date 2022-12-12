
## git global configuration
```sh
git config --global user.name "First Last"
git config --global user.email "first.last@acme.com"
```

## git-credential-manager setup on Linux
[github link](https://github.com/GitCredentialManager/git-credential-manager)

This is needed if you can't SSH to Azure DevOps (preferred approach, but if not supported inside network)

```sh
cd
wget https://github.com/GitCredentialManager/git-credential-manager/releases/download/v2.0.785/gcm-linux_amd64.2.0.785.tar.gz
sudo tar -xvf gcm-linux_amd64.2.0.785.tar.gz -C /usr/local/bin


#export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1
echo "export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1" >> ~/.bashrc
source ~/.bashrc

# you need either the export in your .bashrc or the git config setting (but not both).
# ther are other options for a store, but this is to verify access.
#export GCM_CREDENTIAL_STORE=plaintext
git config --global credential.credentialStore plaintext

git-credential-manager-core configure
```
Once this is setup, you'll need to generate a token from your profile in Azure DevOps
to be able to authenticate to the repo.

<br />