FROM mcr.microsoft.com/devcontainers/javascript-node:1-22-bookworm

USER root

RUN apt-get update \
  && apt-get install -y --no-install-recommends postgresql-client jq \
  && rm -rf /var/lib/apt/lists/*

ARG TARGETARCH
RUN case "${TARGETARCH}" in \
    "amd64") SUPABASE_ARCH="amd64" ;; \
    "arm64") SUPABASE_ARCH="arm64" ;; \
    *) echo "Arquitectura no soportada: ${TARGETARCH}" && exit 1 ;; \
  esac \
  && curl -fsSL "https://github.com/supabase/cli/releases/latest/download/supabase_linux_${SUPABASE_ARCH}.tar.gz" -o /tmp/supabase.tar.gz \
  && tar -xzf /tmp/supabase.tar.gz -C /tmp \
  && mv /tmp/supabase /usr/local/bin/supabase \
  && chmod +x /usr/local/bin/supabase \
  && rm -f /tmp/supabase.tar.gz

USER node
