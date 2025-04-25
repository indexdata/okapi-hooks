FROM debian:bookworm-slim

WORKDIR /app
COPY okapi-hooks.sh .

# create runtime user
RUN adduser \
  --disabled-password \
  --gecos "" \
  --home "/nonexistent" \
  --shell "/sbin/nologin" \
  --no-create-home \
  --uid 65532 \
  hook-user

RUN apt-get update && apt-get install -y curl jq

USER hook-user:hook-user
CMD ["/app/okapi-hooks.sh"]


