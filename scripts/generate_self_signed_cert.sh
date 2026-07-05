#!/usr/bin/env bash
set -euo pipefail

# Usage: generate_self_signed_cert.sh [common_name] [out_dir] [tfvars]
# Defaults: common_name=localhost, out_dir=./.certs, tfvars=./terraform.tfvars

COMMON_NAME="${1:-localhost}"
OUT_DIR="${2:-$(pwd)/.certs}"
TFVARS="${3:-$(pwd)/terraform.tfvars}"

mkdir -p "$OUT_DIR"
KEY="$OUT_DIR/$COMMON_NAME.key.pem"
CERT="$OUT_DIR/$COMMON_NAME.cert.pem"

if [ ! -f "$KEY" ] || [ ! -f "$CERT" ]; then
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout "$KEY" -out "$CERT" -subj "/CN=$COMMON_NAME"
else
  echo "Using existing cert/key in $OUT_DIR"
fi

CERT_PEM=$(sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/\\n/g' "$CERT")
KEY_PEM=$(sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/\\n/g' "$KEY")

if [ -f "$TFVARS" ]; then
  if grep -Eq '^[[:space:]]*tls_certificate_pem[[:space:]]*=' "$TFVARS"; then
    sed -E -i.bak "s|^[[:space:]]*tls_certificate_pem[[:space:]]*=.*|tls_certificate_pem = \"$CERT_PEM\"|" "$TFVARS"
  else
    printf '\n tls_certificate_pem = "%s"\n' "$CERT_PEM" >> "$TFVARS"
  fi

  if grep -Eq '^[[:space:]]*tls_private_key_pem[[:space:]]*=' "$TFVARS"; then
    sed -E -i.bak "s|^[[:space:]]*tls_private_key_pem[[:space:]]*=.*|tls_private_key_pem = \"$KEY_PEM\"|" "$TFVARS"
  else
    printf 'tls_private_key_pem = "%s"\n' "$KEY_PEM" >> "$TFVARS"
  fi
else
  cat > "$TFVARS" <<EOF
tls_certificate_pem = "$CERT_PEM"
tls_private_key_pem = "$KEY_PEM"
EOF
fi

echo "Done. Generated cert: $CERT and key: $KEY and injected into $TFVARS"