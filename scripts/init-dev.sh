#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="$ROOT_DIR/.env.local"
SUPABASE_DIR="$ROOT_DIR/supabase"

if ! command -v supabase >/dev/null 2>&1; then
  echo "❌ No se encontro la CLI de Supabase en el contenedor." >&2
  exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "❌ No se encontro Docker CLI. Revisa la configuracion del devcontainer." >&2
  exit 1
fi

if ! docker info >/dev/null 2>&1; then
  echo "❌ Docker no esta disponible dentro del contenedor."
  echo "   Verifica que el socket Docker del host este compartido." >&2
  exit 1
fi

if [ ! -f "$SUPABASE_DIR/config.toml" ]; then
  echo "❌ Falta supabase/config.toml." >&2
  exit 1
fi

pushd "$ROOT_DIR" >/dev/null

echo "▶️  Iniciando stack local de Supabase..."
supabase start --workdir "$SUPABASE_DIR" >/dev/null

status_env="$(supabase status --workdir "$SUPABASE_DIR" -o env)"

api_url="$(echo "$status_env" | awk -F= '/^API_URL=/{print $2}')"
anon_key="$(echo "$status_env" | awk -F= '/^ANON_KEY=/{print $2}')"
service_key="$(echo "$status_env" | awk -F= '/^SERVICE_ROLE_KEY=/{print $2}')"
db_url="$(echo "$status_env" | awk -F= '/^DB_URL=/{print $2}')"
studio_url="$(echo "$status_env" | awk -F= '/^STUDIO_URL=/{print $2}')"

if [[ -z "$api_url" || -z "$anon_key" || -z "$service_key" || -z "$db_url" ]]; then
  echo "❌ No se pudieron leer credenciales locales desde supabase status -o env." >&2
  echo "   Ejecuta: supabase status --workdir supabase -o env" >&2
  exit 1
fi

if [ ! -f "$ENV_FILE" ]; then
  cp "$ROOT_DIR/.env.example" "$ENV_FILE"
fi

upsert_env() {
  local key="$1"
  local value="$2"

  if grep -q "^${key}=" "$ENV_FILE"; then
    sed -i "s|^${key}=.*|${key}=${value}|" "$ENV_FILE"
  else
    echo "${key}=${value}" >> "$ENV_FILE"
  fi
}

# Valores minimos para ejecutar app + scripts de base de datos local.
upsert_env "NEXT_PUBLIC_SUPABASE_URL" "$api_url"
upsert_env "NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY" "$anon_key"
upsert_env "SUPABASE_SECRET_KEY" "$service_key"
upsert_env "SUPABASE_DB_URL" "$db_url"

popd >/dev/null

echo "✅ Entorno local listo en .env.local"
echo "   NEXT_PUBLIC_SUPABASE_URL=$api_url"
if [[ -n "$studio_url" ]]; then
  echo "   Supabase Studio: $studio_url"
fi
echo ""
echo "Siguientes pasos:"
echo "  1) npm run dev"
echo "  2) (opcional) bash scripts/apply-migrations.sh"
