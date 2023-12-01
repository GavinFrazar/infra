FROM container-registry.oracle.com/database/express:21.3.0-xe
COPY --chmod=777 *.sh /opt/oracle/
COPY --chmod=777 scripts/ /opt/oracle/scripts/startup/
COPY --chmod=777 build/certs/ /certs/
ENTRYPOINT ["/opt/oracle/entrypoint.sh"]
