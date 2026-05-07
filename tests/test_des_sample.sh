#!/usr/bin/env bash
# Test DES mẫu từ code gốc.
# Compile chương trình, chạy, rồi đối chiếu ciphertext mong đợi.

set -euo pipefail

BIN="${BIN:-./des_test}"
EXPECTED="85E813540F0AB405"
KEY="133457799BBCDFF1"
PLAINTEXT="0123456789ABCDEF"

echo "[DES sample test] compiling..."

if [[ -n "${BUILD_CMD:-}" ]]; then
  eval "$BUILD_CMD"
elif [[ -f Makefile || -f makefile ]]; then
  make
else
  # Mặc định compile tất cả file C trong thư mục hiện tại.
  gcc -Wall -Wextra -std=c11 -O2 ./*.c -o "$BIN"
fi

if [[ ! -x "$BIN" ]]; then
  echo "ERROR: Không tìm thấy executable: $BIN"
  echo "Gợi ý: chạy với BIN=./ten_chuong_trinh hoặc BUILD_CMD='...'"
  exit 1
fi

echo "[DES sample test] running..."

OUTPUT="$("$BIN" "$KEY" "$PLAINTEXT")"

# Chuẩn hóa output: chỉ giữ ký tự hex, chuyển sang uppercase,
# rồi lấy 16 ký tự hex cuối cùng làm ciphertext.
ACTUAL="$(echo "$OUTPUT" \
  | tr '[:lower:]' '[:upper:]' \
  | grep -oE '[0-9A-F]+' \
  | tr -d '\n' \
  | tail -c 16)"

echo "Expected: $EXPECTED"
echo "Actual:   $ACTUAL"

if [[ "$ACTUAL" != "$EXPECTED" ]]; then
  echo "FAIL: ciphertext không khớp"
  echo "Raw output:"
  echo "$OUTPUT"
  exit 1
fi

echo "PASS: DES sample ciphertext đúng"
exit 0
