FROM docker.flipt.io/flipt/flipt:v2

USER root

RUN apk add --no-cache sudo && \
echo "flipt ALL=(root) NOPASSWD: /bin/chown" > /etc/sudoers.d/flipt

COPY --chmod=755 entrypoint.sh /entrypoint.sh

USER flipt

RUN mkdir -p $HOME/.config/flipt
COPY config.yml $HOME/.config/flipt/config.yml

ENTRYPOINT ["/entrypoint.sh"]