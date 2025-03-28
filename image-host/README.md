# image-host

Simple container to host images as an alternative to a CDN for a few images. Runs as an unprivileged container. Based on the [nging-unprivileged](https://hub.docker.com/r/nginxinc/nginx-unprivileged) image.

```bash
docker build -t image-host:latest .
docker run -d -p 8080:8080 -u 101:101 --name image-server image-host

#test
curl -o test.png http://localhost:8080/test.png
```