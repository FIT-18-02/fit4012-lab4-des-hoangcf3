#!/usr/bin/env bash
# Test round-trip DES: decrypt(encrypt(plaintext)) = plaintext

set -euo pipefail

BIN="${BIN:-./des_test}"
KEY="${KEY:-133457799BBCDFF1}"
PLAINTEXT="${PLAINTEXT:-0123456789ABCDEF}"

echo "[DES round-trip test] compiling..."

if [[ -n "${BUILD_CMD:-}" ]]; then
  eval "$BUILD_CMD"
elif [[ -f Makefile || -f makefile ]]; then
  make
else
  gcc -Wall -Wextra -std=c11 -O2 ./*.c -o "$BIN"
fi

if [[ ! -x "$BIN" ]]; then
  echo "ERROR: Không tìm thấy executable: $BIN"
  echo "Gợi ý: chạy với BIN=./ten_chuong_trinh hoặc BUILD_CMD='...'"
  exit 1
fi

echo "[DES round-trip test] encrypting..."

# Mặc định giả định chương trình hỗ trợ:
#   ./des_test encrypt KEY PLAINTEXT
#   ./des_test decrypt KEY CIPHERTEXT
#
# Nếu chương trình của em dùng cú pháp khác, có thể override bằng:
#   ENCRYPT_CMD='...'
#   DECRYPT_CMD='...'

if [[ -n "${ENCRYPT_CMD:-}" ]]; then
  ENCRYPT_OUTPUT="$(eval "$ENCRYPT_CMD")"
else
  ENCRYPT_OUTPUT="$("$BIN" encrypt "$KEY" "$PLAINTEXT")"
fi

CIPHERTEXT="$(echo "$ENCRYPT_OUTPUT" \
  | tr '[:lower:]' '[:upper:]' \
  | grep -oE '[0-9A-F]+' \
  | tr -d '\n' \
  | tail -c 16)"

if [[ ${#CIPHERTEXT} -ne 16 ]]; then
  echo "FAIL: Không trích xuất được ciphertext hợp lệ từ output encrypt"
  echo "Raw encrypt output:"
  echo "$ENCRYPT_OUTPUT"
  exit 1
fi

echo "[DES round-trip test] decrypting..."

if [[ -n "${DECRYPT_CMD:-}" ]]; then
  DECRYPT_OUTPUT="$(eval "$DECRYPT_CMD")"
else
  DECRYPT_OUTPUT="$("$BIN" decrypt "$KEY" "$CIPHERTEXT")"
fi

DECRYPTED="$(echo "$DECRYPT_OUTPUT" \
  | tr '[:lower:]' '[:upper:]' \
  | grep -oE '[0-9A-F]+' \
  | tr -d '\n' \
  | tail -c 16)"

EXPECTED="$(echo "$PLAINTEXT" | tr '[:lower:]' '[:upper:]')"

echo "Plaintext:  $EXPECTED"
echo "Ciphertext: $CIPHERTEXT"
echo "Decrypted:  $DECRYPTED"

if [[ "$DECRYPTED" != "$EXPECTED" ]]; then
  echo "FAIL: decrypt(encrypt(plaintext)) != plaintext"
  echo
  echo "Raw encrypt output:"
  echo "$ENCRYPT_OUTPUT"
  echo
  echo "Raw decrypt output:"
  echo "$DECRYPT_OUTPUT"
  exit 1
fi

echo "PASS: DES round-trip encrypt -> decrypt đúng"
exit 0
