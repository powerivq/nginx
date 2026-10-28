# Nginx
## Build prerequisite
You need to have those installed:
* Docker

## How to build Nginx container
Go to the root directory of this repo, and execute:

```sh
docker build --pull -t powerivq/nginx .
```

The image follows `nginx:stable-alpine-perl`. Use `--pull` to fetch the current
stable release and its fixes. CI also pulls the base image on every build.

## Stream and TLS preread

The official NGINX binary already includes `--with-stream` and
`--with-stream_ssl_preread_module` statically; no custom compilation or
`load_module` directive is needed. Each image build checks these flags and runs
`nginx -t` against an SNI routing configuration on both CI architectures.

Mount stream configuration files into `/etc/nginx/stream-enabled/*.conf`.
They are included inside the top-level `stream` block, so files should contain
`map`, `upstream`, or `server` directives without another `stream` wrapper.
For example:

```nginx
map $ssl_preread_server_name $tls_backend {
    app.example.com app:443;
    default         fallback:443;
}

server {
    listen 8443;
    ssl_preread on;
    proxy_pass $tls_backend;
}
```

Publish the chosen port when starting the container (for example, `-p 8443:8443`).
If using port 443, first move or remove any HTTP HTTPS listener on the same
address and port. TLS preread routes the original TLS connection without
terminating it; certificates belong on the upstream servers.

Inspect the binary or repeat the isolated configuration test with:

```sh
docker run --rm --entrypoint nginx powerivq/nginx -V
docker run --rm --entrypoint nginx \
  -v "$PWD/tests/stream.conf:/tmp/stream-test.conf:ro" \
  powerivq/nginx -t -c /tmp/stream-test.conf
```

Pull requests build and test `linux/amd64` and `linux/arm64` without publishing.
Pushes to `main`, manual runs on `main`, and the monthly schedule publish
`powerivq/nginx:latest` using the configured Docker Hub credentials.
