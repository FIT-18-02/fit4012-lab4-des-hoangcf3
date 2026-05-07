#!/usr/bin/env bash
set -euo pipefail

BIN="des_test"
PLAINTEXT="0000000100100011010001010110011110001001101010111100110111101111"
KEY="0001001100110100010101110111100110011011101111001101111111110001"
WRONG_KEY="0000000000000000000000000000000000000000000000000000000000000000"

g++ -std=c++17 -Wall -Wextra -pedantic des.cpp -o "$BIN"

ENCRYPT_OUTPUT=$(printf "1\n%s\n%s\n" "$PLAINTEXT" "$KEY" | ./"$BIN")
CIPHERTEXT=$(printf "%s\n" "$ENCRYPT_OUTPUT" | grep -Eo '[01]{64,}' | tail -n 1)

DECRYPT_OUTPUT=$(printf "2\n%s\n%s\n" "$CIPHERTEXT" "$WRONG_KEY" | ./"$BIN")
DECRYPTED=$(printf "%s\n" "$DECRYPT_OUTPUT" | grep -Eo '[01]{64,}' | tail -n 1)

if [[ "$DECRYPTED" == "$PLAINTEXT" ]]; then
  echo "[FAIL] Wrong key unexpectedly recovered original plaintext"
  echo "Plaintext: $PLAINTEXT"
  echo "Decrypted: $DECRYPTED"
  rm -f "$BIN"
  exit 1
fi

echo "[PASS] Wrong-key negative test passed: wrong key did not recover original plaintext."
rm -f "$BIN"
