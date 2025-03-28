FROM nginxinc/nginx-unprivileged:bookworm
COPY --chown=101:101 nginx.conf /etc/nginx/nginx.conf
COPY --chown=101:101 images /usr/share/nginx/html
# Fix cache directories
RUN mkdir -p /var/cache/nginx/client_temp /var/cache/nginx/proxy_temp /var/cache/nginx/fastcgi_temp /var/cache/nginx/uwsgi_temp /var/cache/nginx/scgi_temp \
    && chown -R 101:101 /var/cache/nginx \
    && chmod -R 755 /var/cache/nginx
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]