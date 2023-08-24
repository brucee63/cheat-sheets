# cert management

## trust self-signed ca (linux)
```sh
openssl s_client -showcerts -connect host.name.com:443 -servername host.name.com  </dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > host.name.com.crt

sudo apt-get install -y ca-certificates
sudo cp host.name.com.crt /usr/local/share/ca-certificates
sudo update-ca-certificates
```

## docker
restart docker services to pick up the change
```sh
sudo systemctl restart docker
# or 
sudo service docker restart
```
