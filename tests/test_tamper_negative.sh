#!/usr/bin/env bash
set -euo pipefail

BIN="des_test"
PLAINTEXT="0000000100100011010001010110011110001001101010111100110111101111"
KEY="0001001100110100010101110111100110011011101111001101111111110001"

g++ -std=c++17 -Wall -Wextra -pedantic des.cpp -o "$BIN"

ENCRYPT_OUTPUT=$(printf "1\n%s\n%s\n" "$PLAINTEXT" "$KEY" | ./"$BIN")
CIPHERTEXT=$(printf "%s\n" "$ENCRYPT_OUTPUT" | grep -Eo '[01]{64,}' | tail -n 1)

# Flip the first bit of ciphertext.
FIRST_BIT="${CIPHERTEXT:0:1}"
if [[ "$FIRST_BIT" == "0" ]]; then
  TAMPERED="1${CIPHERTEXT:1}"
else
  TAMPERED="0${CIPHERTEXT:1}"
fi

DECRYPT_OUTPUT=$(printf "2\n%s\n%s\n" "$TAMPERED" "$KEY" | ./"$BIN")
DECRYPTED=$(printf "%s\n" "$DECRYPT_OUTPUT" | grep -Eo '[01]{64,}' | tail -n 1)

if [[ "$DECRYPTED" == "$PLAINTEXT" ]]; then
  echo "[FAIL] Tampered ciphertext unexpectedly decrypted to original plaintext"
  echo "Plaintext: $PLAINTEXT"
  echo "Tampered:  $TAMPERED"
  rm -f "$BIN"
  exit 1
fi

echo "[PASS] Tamper negative test passed: modified ciphertext did not recover original plaintext."
rm -f "$BIN"
