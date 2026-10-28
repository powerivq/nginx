FROM nginx:stable-alpine-perl

# The official binary includes stream and ssl_preread statically.
RUN apk --no-cache add supervisor curl

COPY tests/stream.conf /tmp/stream-test.conf
RUN nginx -V 2>&1 | grep -Eq -- ' --with-stream( |$)' \
    && nginx -V 2>&1 | grep -Eq -- ' --with-stream_ssl_preread_module( |$)' \
    && nginx -t -c /tmp/stream-test.conf \
    && rm /tmp/stream-test.conf \
    && mkdir -p /etc/nginx/stream-enabled

COPY nginx.conf /etc/nginx/
COPY cloudflare.conf /etc/nginx/
COPY ssl.conf /etc/nginx/
COPY monitoring.conf /etc/nginx/
COPY fastcgi_params /etc/nginx/
COPY reload.sh /reload.sh
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf 
COPY dhparam.pem /dhparam.pem

WORKDIR /etc/nginx
EXPOSE 80
EXPOSE 443
EXPOSE 8880
HEALTHCHECK --interval=5s CMD curl -f http://127.0.0.1:8880/nginx_status || exit 1
ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
