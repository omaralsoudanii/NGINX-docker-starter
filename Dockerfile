ARG NGINX_VERSION=1.21.2

# headers-more-nginx module repo latest commit
# https://github.com/openresty/headers-more-nginx-module.git
ARG NGX_MORE_HDR_COMMIT=f85af9649b858e21b400a2150a4c7b8ebd36e921

# Google brotli repo latest commit
# https://github.com/google/ngx_brotli/commit/9aec15e2aa6feea2113119ba06460af70ab3ea62
ARG NGX_BROTLI_COMMIT=9aec15e2aa6feea2113119ba06460af70ab3ea62

# Arguments that we will configure NGINX with
ARG CONFIG="\
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --modules-path=/usr/lib/nginx/modules \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    --user=nginx \
    --group=nginx \
    --with-http_ssl_module \
    --with-http_realip_module \
    --with-http_addition_module \
    --with-http_sub_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_mp4_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_random_index_module \
    --with-http_secure_link_module \
    --with-http_stub_status_module \
    --with-http_auth_request_module \
    --with-http_xslt_module=dynamic \
    --with-http_image_filter_module=dynamic \
    --with-http_geoip_module=dynamic \
    --with-threads \
    --with-stream \
    --with-stream_ssl_module \
    --with-stream_ssl_preread_module \
    --with-stream_realip_module \
    --with-stream_geoip_module=dynamic \
    --with-http_slice_module \
    --with-mail \
    --with-mail_ssl_module \
    --with-compat \
    --with-file-aio \
    --with-http_v2_module \
    --add-module=/usr/src/ngx_brotli \
    --add-module=/usr/src/ngx_http_headers_more_filter_module \
    "


# Multi stage build, we start from alpine
FROM alpine:3.14.2 as build
LABEL maintainer="NGINX Docker Maintainers <docker-maint@nginx.com>"

# Declare the ARGS we defined above, due to entering new build stage (FROM alpine)
ARG NGINX_VERSION
ARG NGX_BROTLI_COMMIT
ARG NGX_MORE_HDR_COMMIT
ARG CONFIG

# Deps for NGINX and brotli
RUN \
    apk add --no-cache --virtual .build-deps \
    gcc \
    libc-dev \
    make \
    openssl-dev \
    pcre-dev \
    zlib-dev \
    linux-headers \
    curl \
    gnupg1 \
    libxslt-dev \
    gd-dev \
    geoip-dev \
    && apk add --no-cache --virtual .brotli-build-deps \
    autoconf \
    libtool \
    automake \
    git \
    g++ \
    cmake

# NGINX GPG key https://www.nginx.com/blog/updating-gpg-key-nginx-products/
COPY nginx.pub /tmp/nginx.pub

# Clone brotli to the commit hash we defined, grab NGINX source code, grab headers-more-nginx module tar ball
RUN \
    mkdir -p /usr/src/ngx_brotli \
    && cd /usr/src/ngx_brotli \
    && git init \
    && git remote add origin https://github.com/google/ngx_brotli.git \
    && git fetch --depth 1 origin $NGX_BROTLI_COMMIT \
    && git checkout --recurse-submodules -q FETCH_HEAD \
    && git submodule update --init --depth 1 \    
    # Grab headers-more-nginx module 
    && mkdir -p /usr/src/ngx_http_headers_more_filter_module \
    && cd /usr/src/ngx_http_headers_more_filter_module \
    && git init \
    && git remote add origin https://github.com/openresty/headers-more-nginx-module.git \
    && git fetch --depth 1 origin $NGX_MORE_HDR_COMMIT \
    && git checkout --recurse-submodules -q FETCH_HEAD \
    && git submodule update --init --depth 1 \
    # Grab NGINX source code
    && cd .. \
    && curl -fSL https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz -o nginx.tar.gz \
    && curl -fSL https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz.asc  -o nginx.tar.gz.asc \
    && sha512sum nginx.tar.gz nginx.tar.gz.asc \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --import /tmp/nginx.pub \
    && gpg --batch --verify nginx.tar.gz.asc nginx.tar.gz \
    && mkdir -p /usr/src \
    && tar -zxC /usr/src -f nginx.tar.gz

# Configure NGINX with the config we assigned, above then compile it from the source
RUN \
    cd /usr/src/nginx-$NGINX_VERSION \
    && ./configure $CONFIG --with-debug \
    && make -j$(getconf _NPROCESSORS_ONLN) \
    && mv objs/nginx objs/nginx-debug \
    && mv objs/ngx_http_xslt_filter_module.so objs/ngx_http_xslt_filter_module-debug.so \
    && mv objs/ngx_http_image_filter_module.so objs/ngx_http_image_filter_module-debug.so \
    && mv objs/ngx_http_geoip_module.so objs/ngx_http_geoip_module-debug.so \
    && mv objs/ngx_stream_geoip_module.so objs/ngx_stream_geoip_module-debug.so \
    && ./configure $CONFIG \
    && make -j$(getconf _NPROCESSORS_ONLN)

# install NGINX, and it's modules in addition to brotli, headers-more-nginx
RUN \
    cd /usr/src/nginx-$NGINX_VERSION \
    && make install \
    && rm -rf /etc/nginx/html/ \
    && mkdir /etc/nginx/conf.d/ \
    && mkdir /etc/nginx/ssl/ \
    && mkdir -p /usr/share/nginx/html/ \
    && install -m644 html/index.html /usr/share/nginx/html/ \
    && install -m644 html/50x.html /usr/share/nginx/html/ \
    && install -m755 objs/nginx-debug /usr/sbin/nginx-debug \
    && install -m755 objs/ngx_http_xslt_filter_module-debug.so /usr/lib/nginx/modules/ngx_http_xslt_filter_module-debug.so \
    && install -m755 objs/ngx_http_image_filter_module-debug.so /usr/lib/nginx/modules/ngx_http_image_filter_module-debug.so \
    && install -m755 objs/ngx_http_geoip_module-debug.so /usr/lib/nginx/modules/ngx_http_geoip_module-debug.so \
    && install -m755 objs/ngx_stream_geoip_module-debug.so /usr/lib/nginx/modules/ngx_stream_geoip_module-debug.so \
    && strip /usr/sbin/nginx* \
    && strip /usr/lib/nginx/modules/*.so \
    \
    && apk add --no-cache --virtual .gettext gettext \
    \
    && scanelf --needed --nobanner /usr/sbin/nginx /usr/lib/nginx/modules/*.so /usr/bin/envsubst \
    | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
    | sort -u \
    | xargs -r apk info --installed \
    | sort -u > /tmp/runDeps.txt


# Multi build stage 2, again from alpine. This is the release stage, which contains the installed NGINX only
FROM alpine:3.14.2 as release
ARG NGINX_VERSION

# Copy nginx and it's deps from build stage
COPY --from=build /tmp/runDeps.txt /tmp/runDeps.txt
COPY --from=build /etc/nginx /etc/nginx
COPY --from=build /usr/lib/nginx/modules/*.so /usr/lib/nginx/modules/
COPY --from=build /usr/sbin/nginx /usr/sbin/nginx-debug /usr/sbin/
COPY --from=build /usr/share/nginx/html/* /usr/share/nginx/html/
COPY --from=build /usr/bin/envsubst /usr/local/bin/envsubst

# Create NGINX user and group inside the container
RUN \
    addgroup -S nginx \
    && adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx \
    && apk add --no-cache --virtual .nginx-rundeps tzdata $(cat /tmp/runDeps.txt) \
    && rm /tmp/runDeps.txt \
    && ln -s /usr/lib/nginx/modules /etc/nginx/modules \
	# forward request and error logs to docker log collector
	&& mkdir /var/log/nginx \
	&& touch /var/log/nginx/access.log /var/log/nginx/error.log \
	&& ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log


# COPY your NGINX configuration files to the container
COPY ./conf/ /etc/nginx

# Define your servers here 
COPY ./conf.d/ /etc/nginx/conf.d

# Don't copy SSL Certs.... just don't, mount them via docker volumes

# Override stop signal to stop process gracefully
STOPSIGNAL SIGQUIT

# Start NGINX
CMD ["nginx", "-g", "daemon off;"]
