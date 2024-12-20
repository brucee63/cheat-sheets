# OpenAPI / Swagger

## Prerequisites
- node.js
- npm

## Generate service proxy definition
If provider or vendor supplies an openapi/swagger .json file (call it `proposed-spec.json`) as a stand-in for the API itself (while under development). This will allow you to more easily inspect the API.

Step 1: Clone `swagger-ui` git repo

```bash
mkdir -p ~/git
cd ~/git
git clone https://github.com/swagger-api/swagger-ui.git 
```

Step 2: Build to generate dist release

```bash
npm run build
```

Step 3: Copy .json and update the index.html file

copy your .json file to the `/dist` folder

edit the index.html file in the `/dist` folder

remove
```html
<script src="./swagger-initializer.js" charset="UTF-8"> </script>
```

add 
```html
<!--<script src="./swagger-initializer.js" charset="UTF-8"> </script>-->
<script>
  // Initialize Swagger UI with your OpenAPI JSON file URL
  const ui = SwaggerUIBundle({
    url: "proposed-spec.json", // Replace with your JSON file path
    dom_id: '#swagger-ui',
    presets: [
      SwaggerUIBundle.presets.apis,
      SwaggerUIStandalonePreset
    ],
    layout: "StandaloneLayout"
  });
</script>
```

Step 4: Create `Dockerfile`

create a `Dockerfile` in the root of the repo
```dockerfile
# Looking for information on environment variables?
# We don't declare them here — take a look at our docs.
# https://github.com/swagger-api/swagger-ui/blob/master/docs/usage/configuration.md

FROM nginxinc/nginx-unprivileged:bookworm
USER root

RUN apt update
RUN apt install curl -y
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash
RUN apt install -y nodejs

LABEL maintainer="char0n"

ENV API_KEY="**None**" \
    SWAGGER_JSON="/app/swagger.json" \
    PORT="8080" \
    PORT_IPV6="" \
    BASE_URL="/" \
    SWAGGER_JSON_URL="" \
    CORS="true" \
    EMBEDDING="false"

COPY --chown=nginx:nginx --chmod=0666 ./docker/default.conf.template ./docker/cors.conf ./docker/embedding.conf /etc/nginx/templates/

COPY --chmod=0666 ./dist/* /usr/share/nginx/html/
COPY --chmod=0555 ./docker/docker-entrypoint.d/ /docker-entrypoint.d/
COPY --chmod=0666 ./docker/configurator /usr/share/nginx/configurator

# Simulates running NGINX as a non root; in future we want to use nginxinc/nginx-unprivileged.
# In future we will have separate unpriviledged images tagged as v5.1.2-unprivileged.
RUN chmod 777 /usr/share/nginx/html/ /etc/nginx/conf.d/ /etc/nginx/conf.d/default.conf /var/cache/nginx/ /var/run/

EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]
```

Step 6: Serve API definition locally
```bash
docker build . -t proposedapi:latest
docker run -d -p 8080:8080 --user 1000 proposedapi:latest
```

## Generate .NET classes based on spec

Step 1: Install [Nswag](https://www.npmjs.com/package/nswag)

```powershell
npm install -g nswag
```

Step 2: Specify the runtime version for .NET Core

If `nswag` isn't recognized, close and open terminal.
```powershell
nswag version /runtime:Net80
```

Step 3: Acquire openapi json defition of service

If the service definition has changed, the OpenAPI endpoint will allow you to acquire the latest json definition.
Nagivate to API endpoint, click on `swagger.json` or other referenced .json link. Save file locally to the service folder as `swagger.json`

Step 4: Generate classes

PowerShell:

```powershell
# execute from projet solution root folder where .json file is present
nswag openapi2csclient /input:$PWD\swagger.json /namespace:My.Namespace /output:$PWD\MyClassName.cs 
```

`nswag` will generate the API calls for HTTP GET, POST, PUT methods as well as the POCO or domain objects. 