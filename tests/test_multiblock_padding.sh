#!/usr/bin/env bash
# Test DES multi-block và zero padding.
# Kiểm tra plaintext dài hơn 64 bit, được chia block đúng,
# và block cuối được zero-pad đúng.

set -euo pipefail

BIN="${BIN:-./des_test}"
KEY="${KEY:-133457799BBCDFF1}"

# 36 hex chars = 18 bytes > 8 bytes và không chia hết cho 8.
# Zero padding sẽ thêm 6 byte 00 để thành 24 bytes = 3 blocks.
PLAINTEXT="${PLAINTEXT:-0123456789ABCDEFFEDCBA98765432100123}"
PADDED_PLAINTEXT="0123456789ABCDEFFEDCBA98765432100123000000000000"

# DES-ECB encrypt từng block với key ở trên:
# Block 1: 0123456789ABCDEF -> 85E813540F0AB405
# Block 2: FEDCBA9876543210 -> 4AB65B3D4B061518
# Block 3: 0123000000000000 -> ACA1333677A59A13
EXPECTED="85E813540F0AB4054AB65B3D4B061518ACA1333677A59A13"

echo "[DES multi-block padding test] compiling..."

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

echo "[DES multi-block padding test] running..."
echo "Plaintext:        $PLAINTEXT"
echo "Padded plaintext: $PADDED_PLAINTEXT"

# Mặc định giả định chương trình hỗ trợ:
#   ./des_test encrypt KEY PLAINTEXT_HEX
#
# Nếu chương trình dùng cú pháp khác, có thể override:
#   ENCRYPT_CMD='...'
if [[ -n "${ENCRYPT_CMD:-}" ]]; then
  OUTPUT="$(eval "$ENCRYPT_CMD")"
else
  OUTPUT="$("$BIN" encrypt "$KEY" "$PLAINTEXT")"
fi

# Chuẩn hóa output: giữ hex, uppercase, lấy 48 hex chars cuối cùng
# vì expected ciphertext có 3 blocks = 24 bytes = 48 hex chars.
ACTUAL="$(echo "$OUTPUT" \
  | tr '[:lower:]' '[:upper:]' \
  | grep -oE '[0-9A-F]+' \
  | tr -d '\n' \
  | tail -c 48)"

echo "Expected: $EXPECTED"
echo "Actual:   $ACTUAL"

if [[ ${#ACTUAL} -ne 48 ]]; then
  echo "FAIL: Không trích xuất được ciphertext 3 block hợp lệ"
  echo "Raw output:"
  echo "$OUTPUT"
  exit 1
fi

if [[ "$ACTUAL" != "$EXPECTED" ]]; then
  echo "FAIL: multi-block hoặc zero padding sai"
  echo
  echo "Kỳ vọng chia block như sau:"
  echo "  0123456789ABCDEF"
  echo "  FEDCBA9876543210"
  echo "  0123000000000000"
  echo
  echo "Raw output:"
  echo "$OUTPUT"
  exit 1
fi

echo "PASS: DES multi-block và zero padding đúng"
exit 0
