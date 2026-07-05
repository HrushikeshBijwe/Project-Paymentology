#!/usr/bin/env bash
set -euo pipefail

# Usage: generate_ssh_key.sh [key_name] [out_dir] [tfvars]
# Defaults: key_name=${PROJECT_NAME:-paymentology}-ssh-key, out_dir=./.ssh, tfvars=./terraform.tfvars

KEY_NAME="${1:-${PROJECT_NAME:-paymentology}-ssh-key}"
OUT_DIR="${2:-$(pwd)/.ssh}"
TFVARS="${3:-$(pwd)/terraform.tfvars}"

mkdir -p "$OUT_DIR"
PRIVATE="$OUT_DIR/$KEY_NAME"
PUB="$PRIVATE.pub"

if [ ! -f "$PRIVATE" ]; then
  if command -v ssh-keygen >/dev/null 2>&1; then
    echo "Generating SSH key pair at $PRIVATE"
    ssh-keygen -t rsa -b 4096 -f "$PRIVATE" -N "" >/dev/null
  else
    echo "ssh-keygen not found in PATH. Install OpenSSH client." >&2
    exit 1
  fi
else
  echo "SSH private key already exists at $PRIVATE — skipping generation."
fi

if [ ! -f "$PUB" ]; then
  echo "Public key not found at $PUB" >&2
  exit 1
fi

PUB_KEY=$(cat "$PUB")

if [ -f "$TFVARS" ]; then
  if grep -Eq '^[[:space:]]*ssh_public_key[[:space:]]*=' "$TFVARS"; then
    # replace existing line
    sed -E -i.bak "s|^[[:space:]]*ssh_public_key[[:space:]]*=.*|ssh_public_key = \"$PUB_KEY\"|" "$TFVARS"
  else
    printf '\nssh_public_key = "%s"\n' "$PUB_KEY" >> "$TFVARS"
  fi

  if grep -Eq '^[[:space:]]*ssh_key_name[[:space:]]*=' "$TFVARS"; then
    sed -E -i.bak "s|^[[:space:]]*ssh_key_name[[:space:]]*=.*|ssh_key_name = \"$KEY_NAME\"|" "$TFVARS"
  else
    printf 'ssh_key_name = "%s"\n' "$KEY_NAME" >> "$TFVARS"
  fi
else
  cat > "$TFVARS" <<EOF
ssh_public_key = "$PUB_KEY"
ssh_key_name = "$KEY_NAME"
EOF
fi

echo "Done. Private key: $PRIVATE"
echo "Public key injected into $TFVARS"