FROM docker.flipt.io/flipt/flipt:v2

USER root

RUN apk add --no-cache sudo && \
echo "flipt ALL=(root) NOPASSWD: /bin/chown" > /etc/sudoers.d/flipt

COPY --chmod=755 entrypoint.sh /entrypoint.sh

USER flipt

RUN mkdir -p /home/flipt/.config/flipt
COPY config.yml /home/flipt/.config/flipt/config.yml

ENTRYPOINT ["/entrypoint.sh"]