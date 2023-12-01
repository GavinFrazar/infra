FROM elasticsearch:8.1.3

USER root

# using the same permissions for certs and config file as the default image does.
COPY --chmod=660 build/certs /usr/share/elasticsearch/config/certs

COPY --chmod=664 elasticsearch.yml role_mapping.yml /usr/share/elasticsearch/config/

RUN chmod 750 /usr/share/elasticsearch/config/certs

# leave role_mapping.yml owned by root:root.
RUN chown elasticsearch:elasticsearch \
    /usr/share/elasticsearch/config/certs \
    /usr/share/elasticsearch/config/elasticsearch.yml


USER elasticsearch

