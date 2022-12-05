# Installation

Debian/Ubuntu
```sh
# add debian package repo
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee \
    /usr/share/keyrings/jenkins-keyring.asc > /dev/null

# add jenkins apt repo entry
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
    https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
    /etc/apt/sources.list.d/jenkins.list > /dev/null

# update and install
sudo apt-get update
sudo apt-get install fontconfig openjdk-11-jre
sudo apt-get install jenkins
```

## Publish Over SSH
- Install the Publish Over SSH plugin
- Verify the remote server has sshd running and accepts PK authentication

```sh
nano /etc/ssh/sshd_config

# ensure the following
PubkeyAuthentication yes
PubkeyAcceptedKeyTypes=+ssh-rsa

sudo systemctl restart sshd
```

- Generate RSA key for jenkins user
```sh
sudo su - jenkins
ssh-keygen -t rsa -b 4096 -m PEM
ssh-copy-id user@remoteserver

#verify login to remote server
ssh user@remoteserver 
```

- Goto Manage Jenkins -> Configure System -> Publish Over SSH <br >
Path to key: `/var/lib/jenkins/.ssh/id_rsa`

- Add an SSH server