#!/usr/bin/env bash
# Negative test cho tamper / bit flip.
# Ý tưởng:
#   1. Encrypt plaintext để lấy ciphertext đúng.
#   2. Flip 1 bit trong ciphertext.
#   3. Decrypt ciphertext đã bị sửa.
#   4. Test PASS nếu plaintext giải mã KHÔNG còn bằng plaintext gốc,
#      hoặc chương trình báo lỗi khi decrypt ciphertext bị tamper.

set -euo pipefail

BIN="des_test"

KEY="${KEY:-133457799BBCDFF1}"
PLAINTEXT="${PLAINTEXT:-0123456789ABCDEF}"

cleanup() {
  rm -f "$BIN"
}
trap cleanup EXIT

echo "[tamper negative test] compiling..."
g++ -std=c++17 -Wall -Wextra -pedantic des.cpp -o "$BIN"

extract_last_bits_or_hex() {
  # Lấy chuỗi nhị phân 64-bit hoặc hex 16 ký tự cuối cùng từ output.
  local text="$1"

  local binary
  binary=$(printf "%s\n" "$text" | grep -oE '[01]{64}' | tail -n 1 || true)
  if [[ -n "$binary" ]]; then
    printf "%s" "$binary"
    return 0
  fi

  local hex
  hex=$(printf "%s\n" "$text" \
    | tr '[:lower:]' '[:upper:]' \
    | grep -oE '[0-9A-F]{16}' \
    | tail -n 1 || true)

  if [[ -n "$hex" ]]; then
    printf "%s" "$hex"
    return 0
  fi

  return 1
}

flip_last_bit() {
  local value="$1"
  local last="${value: -1}"
  local prefix="${value:0:${#value}-1}"

  case "$last" in
    0) printf "%s1" "$prefix" ;;
    1) printf "%s0" "$prefix" ;;
    *)
      # Hex: đổi nibble cuối bằng XOR 1.
      local flipped
      flipped=$(printf "%X" $(( 0x$last ^ 1 )))
      printf "%s%s" "$prefix" "$flipped"
      ;;
  esac
}

echo "[tamper negative test] encrypting..."

# Mặc định giả định chương trình hỗ trợ:
#   ./des_test encrypt KEY PLAINTEXT
if [[ -n "${ENCRYPT_CMD:-}" ]]; then
  ENCRYPT_OUTPUT="$(eval "$ENCRYPT_CMD")"
else
  ENCRYPT_OUTPUT="$(./"$BIN" encrypt "$KEY" "$PLAINTEXT")"
fi

CIPHERTEXT="$(extract_last_bits_or_hex "$ENCRYPT_OUTPUT")"
TAMPERED="$(flip_last_bit "$CIPHERTEXT")"

echo "Original ciphertext: $CIPHERTEXT"
echo "Tampered ciphertext: $TAMPERED"

echo "[tamper negative test] decrypting tampered ciphertext..."

# Mặc định giả định chương trình hỗ trợ:
#   ./des_test decrypt KEY CIPHERTEXT
set +e
if [[ -n "${DECRYPT_CMD:-}" ]]; then
  DECRYPT_OUTPUT="$(eval "$DECRYPT_CMD" 2>&1)"
else
  DECRYPT_OUTPUT="$(./"$BIN" decrypt "$KEY" "$TAMPERED" 2>&1)"
fi
DECRYPT_STATUS=$?
set -e

# Nếu chương trình từ chối ciphertext bị sửa thì cũng là PASS.
if [[ "$DECRYPT_STATUS" -ne 0 ]]; then
  echo "[PASS] Tampered ciphertext was rejected by decrypt."
  echo "Decrypt output:"
  echo "$DECRYPT_OUTPUT"
  exit 0
fi

DECRYPTED="$(extract_last_bits_or_hex "$DECRYPT_OUTPUT" || true)"
EXPECTED="$(printf "%s" "$PLAINTEXT" | tr '[:lower:]' '[:upper:]')"

echo "Expected plaintext:  $EXPECTED"
echo "Decrypted tampered:  $DECRYPTED"

if [[ -z "$DECRYPTED" ]]; then
  echo "[PASS] Tampered decrypt did not produce a valid plaintext-looking output."
  echo "Decrypt output:"
  echo "$DECRYPT_OUTPUT"
  exit 0
fi

if [[ "$DECRYPTED" == "$EXPECTED" ]]; then
  echo "[FAIL] Tampered ciphertext decrypted back to the original plaintext."
  echo
  echo "Encrypt output:"
  echo "$ENCRYPT_OUTPUT"
  echo
  echo "Decrypt output:"
  echo "$DECRYPT_OUTPUT"
  exit 1
fi

echo "[PASS] Tampering changed the decrypted plaintext as expected."
exit 0
