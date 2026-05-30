# syntax=docker/dockerfile:1

FROM rust:1.95-trixie AS builder

WORKDIR /usr/src

COPY . .

# Cache deps across builds; copy the binary out of the (non-layer) cache mount.
RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/usr/src/target \
    cargo build --release && cp target/release/agg-plus /agg-plus

FROM debian:trixie-slim

LABEL org.opencontainers.image.authors="m@ku1ik.com, kayvan.sylvan@gmail.com, d10n@bitinvert.com"
LABEL org.opencontainers.image.source="https://github.com/d10n/agg-plus"

# certs for HTTPS casts; monospace fonts for the text glyphs agg-plus doesn't embed.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        fonts-jetbrains-mono \
        fonts-firacode \
        fonts-cascadia-code \
        fonts-dejavu \
        fonts-liberation \
        fonts-hack \
        fonts-inconsolata \
        fonts-mononoki \
        fonts-noto-mono \
        fonts-terminus-otb \
        fonts-noto-color-emoji \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /agg-plus /usr/local/bin/agg-plus

WORKDIR /data

ENTRYPOINT [ "/usr/local/bin/agg-plus" ]
