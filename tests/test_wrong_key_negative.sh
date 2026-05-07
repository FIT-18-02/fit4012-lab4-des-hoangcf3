#!/usr/bin/env bash
# Negative test cho wrong key / incorrect key / sai key.
# Ý tưởng:
#   1. Encrypt plaintext bằng khóa đúng.
#   2. Decrypt ciphertext bằng khóa sai.
#   3. Test PASS nếu kết quả giải mã KHÔNG bằng plaintext ban đầu,
#      hoặc chương trình báo lỗi khi dùng sai khóa.

set -euo pipefail

BIN="des_test"

CORRECT_KEY="${CORRECT_KEY:-133457799BBCDFF1}"
WRONG_KEY="${WRONG_KEY:-0E329232EA6D0D73}"
PLAINTEXT="${PLAINTEXT:-0123456789ABCDEF}"

cleanup() {
  rm -f "$BIN"
}
trap cleanup EXIT

echo "[wrong key negative test] compiling..."
g++ -std=c++17 -Wall -Wextra -pedantic des.cpp -o "$BIN"

extract_last_bits_or_hex() {
  local text="$1"

  # Ưu tiên output dạng binary 64-bit.
  local binary
  binary=$(printf "%s\n" "$text" | grep -oE '[01]{64}' | tail -n 1 || true)
  if [[ -n "$binary" ]]; then
    printf "%s" "$binary"
    return 0
  fi

  # Hoặc output dạng hex 16 ký tự.
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

normalize_expected_plaintext() {
  local value="$1"

  if [[ "$value" =~ ^[01]{64}$ ]]; then
    printf "%s" "$value"
  else
    printf "%s" "$value" | tr '[:lower:]' '[:upper:]'
  fi
}

echo "[wrong key negative test] encrypting with correct key..."

# Mặc định giả định chương trình hỗ trợ:
#   ./des_test encrypt KEY PLAINTEXT
if [[ -n "${ENCRYPT_CMD:-}" ]]; then
  ENCRYPT_OUTPUT="$(eval "$ENCRYPT_CMD")"
else
  ENCRYPT_OUTPUT="$(./"$BIN" encrypt "$CORRECT_KEY" "$PLAINTEXT")"
fi

CIPHERTEXT="$(extract_last_bits_or_hex "$ENCRYPT_OUTPUT")"

echo "Plaintext:       $PLAINTEXT"
echo "Correct key:     $CORRECT_KEY"
echo "Wrong key:       $WRONG_KEY"
echo "Ciphertext:      $CIPHERTEXT"

echo "[wrong key negative test] decrypting with wrong key..."

# Mặc định giả định chương trình hỗ trợ:
#   ./des_test decrypt KEY CIPHERTEXT
set +e
if [[ -n "${DECRYPT_CMD:-}" ]]; then
  DECRYPT_OUTPUT="$(eval "$DECRYPT_CMD" 2>&1)"
else
  DECRYPT_OUTPUT="$(./"$BIN" decrypt "$WRONG_KEY" "$CIPHERTEXT" 2>&1)"
fi
DECRYPT_STATUS=$?
set -e

# Nếu chương trình từ chối khóa sai / input sai thì cũng là PASS.
if [[ "$DECRYPT_STATUS" -ne 0 ]]; then
  echo "[PASS] Decrypt with wrong key was rejected."
  echo "Decrypt output:"
  echo "$DECRYPT_OUTPUT"
  exit 0
fi

DECRYPTED="$(extract_last_bits_or_hex "$DECRYPT_OUTPUT" || true)"
EXPECTED="$(normalize_expected_plaintext "$PLAINTEXT")"

echo "Expected plaintext: $EXPECTED"
echo "Wrong-key decrypt:  $DECRYPTED"

if [[ -z "$DECRYPTED" ]]; then
  echo "[PASS] Wrong-key decrypt did not produce a valid plaintext-looking output."
  echo "Decrypt output:"
  echo "$DECRYPT_OUTPUT"
  exit 0
fi

if [[ "$DECRYPTED" == "$EXPECTED" ]]; then
  echo "[FAIL] Decrypting with wrong key recovered the original plaintext."
  echo
  echo "Encrypt output:"
  echo "$ENCRYPT_OUTPUT"
  echo
  echo "Decrypt output:"
  echo "$DECRYPT_OUTPUT"
  exit 1
fi

echo "[PASS] Wrong key did not recover the original plaintext."
exit 0
