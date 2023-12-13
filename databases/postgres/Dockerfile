# Use the official PostgreSQL image as the base image
FROM postgres:16

#COPY scripts/ /scripts

COPY --chmod=600 build/certs/ /certs/
COPY postgres.conf /etc/postgresql/postgresql.conf
COPY pg_hba.conf /etc/postgresql/pg_hba.conf
RUN chown -R postgres:postgres \
    /certs \
    /etc/postgresql/postgresql.conf \
    /etc/postgresql/pg_hba.conf

# Set environment variables for the database
ENV POSTGRES_DB=postgres
ENV POSTGRES_USER=alice
ENV POSTGRES_PASSWORD=soopersekrit

# Expose the PostgreSQL port
EXPOSE 5432

# Run the rest of the commands as the `postgres` user
USER postgres

CMD [ "-c", "config_file=/etc/postgresql/postgresql.conf" ]
