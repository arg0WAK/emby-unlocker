FROM ubuntu:25.10

ARG PROXY_PORT

RUN apt-get update && \
    apt-get install -y nginx curl bash gettext && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/local/share/network && \
    curl -L -o /usr/local/share/network/network.js https://arg0.dev/emby/js/network.js && \
    curl -L -o /usr/local/share/network/network.html https://arg0.dev/emby/js/network.html

RUN curl -o /etc/nginx/nginx.conf.template https://arg0.dev/emby/nginx-configs/unlock.conf && \
    envsubst '${PROXY_PORT}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf && \
    rm -f /etc/nginx/sites-enabled/unlock.conf

CMD ["bash", "-c", "mkdir -p /system/dashboard-ui/network && cp --update=none /usr/local/share/network/* /system/dashboard-ui/network/ || true && nginx -g \"daemon off;\""]
