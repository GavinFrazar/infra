FROM redis:7.2.3

USER root

COPY --chmod=400 redis.conf users.acl /usr/local/etc/redis/

# certs are not in build/certs because each node will be in build/ already.
COPY --chmod=400 certs /usr/local/etc/redis/certs

RUN chown -R redis:redis \
    /usr/local/etc/redis/

USER redis

CMD [ "redis-server", "/usr/local/etc/redis/redis.conf" ]
