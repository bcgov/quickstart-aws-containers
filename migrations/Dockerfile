FROM flyway/flyway:11-alpine

# Copy migrations
COPY ./sql /flyway/sql

# Non-root user
RUN adduser -D app
USER app

# Health check and startup
HEALTHCHECK CMD info
CMD ["info", "migrate", "repair"]
