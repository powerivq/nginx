FROM debian:stretch

RUN mkdir /build && cd /build \
    && apt-get update -yq \
    && apt-get upgrade -yq \
    && apt-get install curl wget sudo build-essential zlib1g-dev libssl-dev libpcre3 libpcre3-dev unzip uuid-dev supervisor -yq \
    && /bin/bash -c "bash <(curl -k -f -L -sS https://ngxpagespeed.com/install) -p -y -n latest \
        -a '--with-debug --with-http_auth_request_module --with-http_ssl_module --with-http_realip_module --with-http_v2_module --with-http_gzip_static_module --with-ipv6 --with-cc-opt=\"-O2\" --pid-path=/run/nginx.pid --conf-path=/etc/nginx/nginx.conf'" \
    && SUDO_FORCE_REMOVE=yes apt-get remove wget sudo build-essential zlib1g-dev libssl-dev libpcre3-dev openssl unzip uuid-dev -yq --purge \
    && apt-get autoremove -yq \
    && cd /etc/nginx \
    && rm -rf /var/lib/apt/lists/* /build \
    && ln -s -f /usr/local/nginx/sbin/nginx /bin/nginx

COPY nginx.conf /etc/nginx/
COPY fastcgi_params /etc/nginx/
COPY reload.sh /reload.sh
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf 
COPY dhparam.pem /dhparam.pem

WORKDIR /etc/nginx
EXPOSE 80
EXPOSE 443
HEALTHCHECK --interval=5s CMD curl -f http://127.0.0.1/healthcheck || exit 1
ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

