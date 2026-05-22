FROM nats:2.11-alpine

COPY nats-server.conf /etc/nats/nats-server.conf

EXPOSE 4222 8222

CMD ["-c", "/etc/nats/nats-server.conf"]
