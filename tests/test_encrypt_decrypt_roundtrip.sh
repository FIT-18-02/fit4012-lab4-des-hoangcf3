#!/usr/bin/env bash
set -euo pipefail

BIN="des_test"
PLAINTEXT="0000000100100011010001010110011110001001101010111100110111101111"
KEY="0001001100110100010101110111100110011011101111001101111111110001"

g++ -std=c++17 -Wall -Wextra -pedantic des.cpp -o "$BIN"

ENCRYPT_OUTPUT=$(printf "1\n%s\n%s\n" "$PLAINTEXT" "$KEY" | ./"$BIN")
CIPHERTEXT=$(printf "%s\n" "$ENCRYPT_OUTPUT" | grep -Eo '[01]{64,}' | tail -n 1)

DECRYPT_OUTPUT=$(printf "2\n%s\n%s\n" "$CIPHERTEXT" "$KEY" | ./"$BIN")
DECRYPTED=$(printf "%s\n" "$DECRYPT_OUTPUT" | grep -Eo '[01]{64,}' | tail -n 1)

if [[ "$DECRYPTED" != "$PLAINTEXT" ]]; then
  echo "[FAIL] DES round-trip failed"
  echo "Plaintext: $PLAINTEXT"
  echo "Ciphertext: $CIPHERTEXT"
  echo "Decrypted: $DECRYPTED"
  rm -f "$BIN"
  exit 1
fi

echo "[PASS] DES encrypt/decrypt round-trip returned original plaintext."
rm -f "$BIN"
