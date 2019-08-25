FROM debian:stretch

RUN apt-get update -yq && apt-get upgrade -yq \
    && apt-get install curl wget git sudo build-essential zlib1g-dev libssl-dev libpcre3 libpcre3-dev unzip uuid-dev supervisor -yq \
    && git clone https://github.com/google/ngx_brotli.git /ngx_brotli \
    && cd /ngx_brotli && git submodule update --init \
    && mkdir /build && cd /build \
    && /bin/bash -c "bash <(curl -k -f -L -sS https://ngxpagespeed.com/install) -p -y -n latest \
        -a '--with-debug --with-http_auth_request_module --with-http_ssl_module --with-http_realip_module --with-http_v2_module --with-http_gzip_static_module --with-ipv6 --add-module=/ngx_brotli --with-cc-opt=\"-g -O2\" --pid-path=/run/nginx.pid --conf-path=/etc/nginx/nginx.conf'" \
    && SUDO_FORCE_REMOVE=yes apt-get remove wget git sudo build-essential zlib1g-dev libssl-dev libpcre3-dev openssl unzip uuid-dev -yq --purge \
    && apt-get autoremove -yq \
    && cd /etc/nginx \
    && rm -rf /var/lib/apt/lists/* /build /ngx_brotli \
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
