#!/bin/sh
#
# Re-encrypt or update agenix secrets in the nix-secrets repo.
#
# usage:
#   update-agenix-secret ssh/airfryer.pem.age                  # edit in $EDITOR
#   update-agenix-secret ssh/airfryer.pem.age ~/.ssh/new.pem   # encrypt from file
#   update-agenix-secret --rekey                                # re-encrypt all

set -eu

identity="$HOME/.config/agenix/agenix.pem"
secrets_dir="${SECRETS_DIR:-$HOME/gh/nix-secrets}"

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
reset='\033[0m'

die() { printf "${red}%s${reset}\n" "$*" >&2; exit 1; }

preflight() {
  [ -f "$identity" ]  || die "Identity key not found at $identity"
  [ -d "$secrets_dir" ] || die "nix-secrets not found at $secrets_dir"
  chmod 600 "$identity"
  recipient="$(mktemp)"
  ssh-keygen -y -f "$identity" > "$recipient" || die "Failed to derive recipient from identity"
  trap 'rm -f "$recipient"' EXIT
}

# Encrypt a plaintext file to an age-encrypted secret.
encrypt() {
  secret_path="$1"
  plaintext_file="$2"
  age -R "$recipient" -o "$secret_path" < "$plaintext_file"
}

# Decrypt, open $EDITOR, and re-encrypt a secret.
edit_secret() {
  secret_path="$secrets_dir/$1"
  [ -f "$secret_path" ] || die "Secret not found: $secret_path"

  tmp="$(mktemp)"
  trap 'rm -f "$tmp"' EXIT

  age -d -i "$identity" "$secret_path" > "$tmp"

  checksum_before="$(shasum -a 256 "$tmp" | cut -d' ' -f1)"
  ${EDITOR:-vi} "$tmp"
  checksum_after="$(shasum -a 256 "$tmp" | cut -d' ' -f1)"

  if [ "$checksum_before" = "$checksum_after" ]; then
    printf "${yellow}No changes made${reset}\n"
    return
  fi

  encrypt "$secret_path" "$tmp"
  printf "${green}Updated %s${reset}\n" "$1"
}

# Encrypt a plaintext file into a secret.
encrypt_secret() {
  secret_rel="$1"
  plaintext_file="$2"
  secret_path="$secrets_dir/$secret_rel"

  [ -f "$plaintext_file" ] || die "Plaintext file not found: $plaintext_file"

  # Check if already up to date
  if [ -f "$secret_path" ]; then
    existing="$(age -d -i "$identity" "$secret_path" 2>/dev/null)" || true
    if [ "$existing" = "$(command cat "$plaintext_file")" ]; then
      printf "${green}%s already up to date${reset}\n" "$secret_rel"
      return
    fi
  fi

  mkdir -p "$(dirname "$secret_path")"
  encrypt "$secret_path" "$plaintext_file"
  printf "${green}Encrypted to %s${reset}\n" "$secret_rel"
}

# Re-encrypt all existing secrets with current recipient.
rekey() {
  printf "${yellow}Re-encrypting all secrets...${reset}\n"

  find "$secrets_dir" -name '*.age' -type f | while read -r secret_path; do
    rel="${secret_path#"$secrets_dir"/}"
    tmp="$(mktemp)"

    if age -d -i "$identity" "$secret_path" > "$tmp" 2>/dev/null; then
      encrypt "$secret_path" "$tmp"
      printf "${green}Rekeyed %s${reset}\n" "$rel"
    else
      printf "${red}Failed to decrypt %s, skipping${reset}\n" "$rel"
    fi

    rm -f "$tmp"
  done

  printf "${green}Done${reset}\n"
}

preflight

case "${1:-}" in
  --rekey)
    rekey
    ;;
  "")
    die "usage: update-agenix-secret <secret-path> [plaintext-file]\n       update-agenix-secret --rekey"
    ;;
  *)
    if [ -n "${2:-}" ]; then
      encrypt_secret "$1" "$2"
    else
      edit_secret "$1"
    fi
    ;;
esac
