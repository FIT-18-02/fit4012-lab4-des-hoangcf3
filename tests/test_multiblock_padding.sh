#!/usr/bin/env bash
set -euo pipefail

BIN="des_test"
KEY="0001001100110100010101110111100110011011101111001101111111110001"

# 70-bit plaintext: requires 2 DES blocks after zero padding.
PLAINTEXT="0000000100100011010001010110011110001001101010111100110111101111101010"
EXPECTED_PADDED="${PLAINTEXT}0000000000000000000000000000000000000000000000000000000000"

g++ -std=c++17 -Wall -Wextra -pedantic des.cpp -o "$BIN"

ENCRYPT_OUTPUT=$(printf "1\n%s\n%s\n" "$PLAINTEXT" "$KEY" | ./"$BIN")
CIPHERTEXT=$(printf "%s\n" "$ENCRYPT_OUTPUT" | grep -Eo '[01]{64,}' | tail -n 1)

if [[ ${#CIPHERTEXT} -ne 128 ]]; then
  echo "[FAIL] Multi-block ciphertext should be 128 bits for 70-bit plaintext with zero padding"
  echo "Actual length: ${#CIPHERTEXT}"
  echo "Ciphertext: $CIPHERTEXT"
  rm -f "$BIN"
  exit 1
fi

DECRYPT_OUTPUT=$(printf "2\n%s\n%s\n" "$CIPHERTEXT" "$KEY" | ./"$BIN")
DECRYPTED=$(printf "%s\n" "$DECRYPT_OUTPUT" | grep -Eo '[01]{64,}' | tail -n 1)

if [[ "$DECRYPTED" != "$EXPECTED_PADDED" ]]; then
  echo "[FAIL] Multi-block zero padding round-trip failed"
  echo "Expected padded plaintext: $EXPECTED_PADDED"
  echo "Actual decrypted:          $DECRYPTED"
  rm -f "$BIN"
  exit 1
fi

echo "[PASS] Multi-block DES encryption and zero padding worked."
rm -f "$BIN"
