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
  && mkdir -p /usr/local/lib/supabase \
  && tar -xzf /tmp/supabase.tar.gz -C /usr/local/lib/supabase \
  && chmod +x /usr/local/lib/supabase/supabase /usr/local/lib/supabase/supabase-go \
  && ln -sf /usr/local/lib/supabase/supabase /usr/local/bin/supabase \
  && ln -sf /usr/local/lib/supabase/supabase-go /usr/local/bin/supabase-go \
  && rm -f /tmp/supabase.tar.gz

ENV SUPABASE_GO_BINARY=/usr/local/lib/supabase/supabase-go

USER node
