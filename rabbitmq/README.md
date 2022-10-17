# RabbitMQ

## Erlang compatability matrix
[link](https://www.rabbitmq.com/which-erlang.html)

| RabbitMQ | Minimum Erlang | Maximum Erlang |
| --- | --- | --- |
| 3.11.1 | 25.0 | 25.1 |
| 3.11.0 | 25.0 | 25.1 |

## TLS Support
[link](https://www.rabbitmq.com/ssl.html#overview)

### Erlang/OTP Requirements for TLS Support

Debian/Ubuntu
```sh
sudo apt update
sudo apt install erlang-asn1 erlang-crypto erlang-public-key erlang-ssl 
```

RHEL and CentOS <br/>

Note: Erlang 25 depends on OpenSLL `1.1`. Therefore Erlang 25 packages are only produced for modern Defora, Rocky Linux and CentOS Stream.

You must install OpenSSL/librcypto version `1.1.x` or later separately.

Note: If the certificate is self-signed, the root CA cert must be copied to the trusted certifcate store on the OS. Stores can be per user or system-wide. `certmgr` can be used to do this on Windows and Linux systems.

[link](https://github.com/rabbitmq/erlang-rpm)

use one of the following repos -

```sh
## repo 1
## primary RabbitMQ signing key
rpm --import https://github.com/rabbitmq/signing-keys/releases/download/2.0/rabbitmq-release-signing-key.asc
## modern Erlang repository
rpm --import 'https://dl.cloudsmith.io/public/rabbitmq/rabbitmq-erlang/gpg.E495BB49CC4BBE5B.key'
```
```sh
## repo 2
## primary RabbitMQ signing key
rpm --import https://github.com/rabbitmq/signing-keys/releases/download/2.0/rabbitmq-release-signing-key.asc
## modern Erlang repository
rpm --import https://packagecloud.io/rabbitmq/erlang/gpgkey
```

## .NET SSL Support
[link](https://www.rabbitmq.com/ssl.html#dotnet-client) <br />

Certs can be in a number of different formats including DER and PKCS#12 <ins>but not PEM</ins>. For the DER format .NET expects them to be stored with .cer extensions. tls-gen generates both PEM and PKCS#12 files.

Modern .NET frameworks default to `TLSv1.2`.

The .NET client requires TLS peer verification, to supress verification, an applicaiton can set the `System.Net.Security.SslPolicyErrors.RemoteCertificateNotAvailable` and `System.Net.Security.SslPolicyErrors.RemoteCertificateChainErrors` flags in SslOptions

In practice, this means the hostname of the server you're connecting to needs to match the  server's certificate commonname (CN) and subjectAltName.

```sh
sudo openssl req -newkey rsa:4096 \
    -subj "/C=US/ST=Connecticut/L=Hartford/O=ACME Corp/OU=IT/CN=${hostname}.${domain}" \
    -addext "subjectAltName = DNS:${hostname}.${domain}" \
    -nodes -sha256 \
    -keyout "${hostname}.${domain}.key" -verify -x509 -days 3650 \
    -out "${hostname}.${domain}.crt"
```

Example -
```csharp
using System;
using System.IO;
using System.Text;

using RabbitMQ.client;
using RabbitMQ.Util;

namespace RabbitMQ.client.Examples {
  public class TestSSL {
    public static int Main(string[] args) {
      ConnectionFactory cf = new ConnectionFactory();

      cf.Ssl.Enabled = true;
      cf.Ssl.ServerName = System.Net.Dns.GetHostName();
      cf.Ssl.CertPath = "/path/to/client_key.p12";
      cf.Ssl.CertPassphrase = "MySecretPassword";

      using (IConnection conn = cf.CreateConnection()) {
        using (IModel ch = conn.CreateModel()) {
          Console.WriteLine("Successfully connected and opened a channel");
          ch.QueueDeclare("rabbitmq-dotnet-test", false, false, false, null);
          Console.WriteLine("Successfully declared a queue");
          ch.QueueDelete("rabbitmq-dotnet-test");
          Console.WriteLine("Successfully deleted the queue");
        }
      }
      return 0;
    }
  }
}
```

## .NET Core RabbitMQ client library
[link](https://www.rabbitmq.com/dotnet.html) <br/>
[github](https://github.com/rabbitmq/rabbitmq-dotnet-client)

## Generating a self-signed Certificate Authority (CA) and two or more pairs of keys (client & server)
[link](https://www.rabbitmq.com/ssl.html#automated-certificate-generation)
[github](https://github.com/rabbitmq/tls-gen)

## Manually generating the self-signed CA manually with server and client keys

```sh
mkdir testca
cd testca
mkdir certs private
chmod 700 private
echo 01 > serial
touch index.txt
```

add to `openssl.conf` in the testca directory
```ini
[ ca ]
default_ca = testca

[ testca ]
dir = .
certificate = $dir/ca_certificate.pem
database = $dir/index.txt
new_certs_dir = $dir/certs
private_key = $dir/private/ca_private_key.pem
serial = $dir/serial

default_crl_days = 7
default_days = 365
default_md = sha256

policy = testca_policy
x509_extensions = certificate_extensions

[ testca_policy ]
commonName = supplied
stateOrProvinceName = optional
countryName = optional
emailAddress = optional
organizationName = optional
organizationalUnitName = optional
domainComponent = optional

[ certificate_extensions ]
basicConstraints = CA:false

[ req ]
default_bits = 2048
default_keyfile = ./private/ca_private_key.pem
default_md = sha256
prompt = yes
distinguished_name = root_ca_distinguished_name
x509_extensions = root_ca_extensions

[ root_ca_distinguished_name ]
commonName = hostname

[ root_ca_extensions ]
basicConstraints = CA:true
keyUsage = keyCertSign, cRLSign

[ client_ca_extensions ]
basicConstraints = CA:false
keyUsage = digitalSignature,keyEncipherment
extendedKeyUsage = 1.3.6.1.5.5.7.3.2

[ server_ca_extensions ]
basicConstraints = CA:false
keyUsage = digitalSignature,keyEncipherment
extendedKeyUsage = 1.3.6.1.5.5.7.3.1
```

Gen the key and cert for our CA in the `testca` directory
```ssh
openssl req -x509 -config openssl.cnf -newkey rsa:2048 -days 365 \
    -out ca_certificate.pem -outform PEM -subj /CN=MyTestCA/ -nodes
openssl x509 -in ca_certificate.pem -out ca_certificate.cer -outform DER
```

generate the server pem and p12 keys
```sh
cd ..
ls
# => testca
mkdir server
cd server
openssl genrsa -out private_key.pem 2048
openssl req -new -key private_key.pem -out req.pem -outform PEM \
    -subj /CN=$(hostname)/O=server/ -nodes
cd ../testca
openssl ca -config openssl.cnf -in ../server/req.pem -out \
    ../server/server_certificate.pem -notext -batch -extensions server_ca_extensions
cd ../server
openssl pkcs12 -export -out server_certificate.p12 -in server_certificate.pem -inkey private_key.pem \
    -passout pass:MySecretPassword
```

client pem and p12 keys
```sh
cd ..
ls
# => server testca
mkdir client
cd client
openssl genrsa -out private_key.pem 2048
openssl req -new -key private_key.pem -out req.pem -outform PEM \
    -subj /CN=$(hostname)/O=client/ -nodes
cd ../testca
openssl ca -config openssl.cnf -in ../client/req.pem -out \
    ../client/client_certificate.pem -notext -batch -extensions client_ca_extensions
cd ../client
openssl pkcs12 -export -out client_certificate.p12 -in client_certificate.pem -inkey private_key.pem \
    -passout pass:MySecretPassword
```