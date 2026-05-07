#!/usr/bin/env bash
set -euo pipefail

# DES official sample:
# P  = 0x0123456789ABCDEF
# K  = 0x133457799BBCDFF1
# CT = 0x85E813540F0AB405

BIN="des_test"
PLAINTEXT="0000000100100011010001010110011110001001101010111100110111101111"
KEY="0001001100110100010101110111100110011011101111001101111111110001"
EXPECTED="1000010111101000000100110101010000001111000010101011010000000101"

g++ -std=c++17 -Wall -Wextra -pedantic des.cpp -o "$BIN"

OUTPUT=$(printf "1\n%s\n%s\n" "$PLAINTEXT" "$KEY" | ./"$BIN")
ACTUAL=$(printf "%s\n" "$OUTPUT" | grep -Eo '[01]{64,}' | tail -n 1)

if [[ "$ACTUAL" != "$EXPECTED" ]]; then
  echo "[FAIL] DES sample encrypt mismatch"
  echo "Expected: $EXPECTED"
  echo "Actual:   $ACTUAL"
  rm -f "$BIN"
  exit 1
fi

echo "[PASS] DES sample encrypt matched expected ciphertext."
rm -f "$BIN"
