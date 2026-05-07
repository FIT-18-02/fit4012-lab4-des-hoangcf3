#include <iostream>
#include <string>
#include <bitset>
#include <vector>
#include <algorithm>
#include <cctype>
using namespace std;

string convert_decimal_to_binary(int decimal) {
    return bitset<4>(decimal).to_string();
}

int convert_binary_to_decimal(const string& binary) {
    return stoi(binary, nullptr, 2);
}

string Xor(const string& a, const string& b) {
    string result;
    result.reserve(min(a.size(), b.size()));
    for (size_t i = 0; i < a.size() && i < b.size(); i++) {
        result += (a[i] != b[i]) ? '1' : '0';
    }
    return result;
}

string clean_binary_string(string s) {
    string result;
    for (char c : s) {
        if (c == '0' || c == '1') result += c;
    }
    return result;
}

bool is_binary_string(const string& s) {
    if (s.empty()) return false;
    for (char c : s) {
        if (c != '0' && c != '1') return false;
    }
    return true;
}

string pad_zero_to_64(string input) {
    size_t remainder = input.size() % 64;
    if (remainder != 0) {
        input.append(64 - remainder, '0');
    }
    return input;
}

string permute(const string& input, const int table[], int table_size) {
    string output;
    output.reserve(table_size);
    for (int i = 0; i < table_size; i++) {
        output += input[table[i] - 1];
    }
    return output;
}

const int IP[64] = {
    58,50,42,34,26,18,10,2,
    60,52,44,36,28,20,12,4,
    62,54,46,38,30,22,14,6,
    64,56,48,40,32,24,16,8,
    57,49,41,33,25,17,9,1,
    59,51,43,35,27,19,11,3,
    61,53,45,37,29,21,13,5,
    63,55,47,39,31,23,15,7
};

const int IP_INV[64] = {
    40,8,48,16,56,24,64,32,
    39,7,47,15,55,23,63,31,
    38,6,46,14,54,22,62,30,
    37,5,45,13,53,21,61,29,
    36,4,44,12,52,20,60,28,
    35,3,43,11,51,19,59,27,
    34,2,42,10,50,18,58,26,
    33,1,41,9,49,17,57,25
};

const int PC1[56] = {
    57,49,41,33,25,17,9,
    1,58,50,42,34,26,18,
    10,2,59,51,43,35,27,
    19,11,3,60,52,44,36,
    63,55,47,39,31,23,15,
    7,62,54,46,38,30,22,
    14,6,61,53,45,37,29,
    21,13,5,28,20,12,4
};

const int PC2[48] = {
    14,17,11,24,1,5,
    3,28,15,6,21,10,
    23,19,12,4,26,8,
    16,7,27,20,13,2,
    41,52,31,37,47,55,
    30,40,51,45,33,48,
    44,49,39,56,34,53,
    46,42,50,36,29,32
};

const int SHIFT_TABLE[16] = {
    1, 1, 2, 2, 2, 2, 2, 2,
    1, 2, 2, 2, 2, 2, 2, 1
};

const int E_TABLE[48] = {
    32,1,2,3,4,5,4,5,
    6,7,8,9,8,9,10,11,
    12,13,12,13,14,15,16,17,
    16,17,18,19,20,21,20,21,
    22,23,24,25,24,25,26,27,
    28,29,28,29,30,31,32,1
};

const int P_TABLE[32] = {
    16,7,20,21,29,12,28,17,
    1,15,23,26,5,18,31,10,
    2,8,24,14,32,27,3,9,
    19,13,30,6,22,11,4,25
};

const int S_BOX[8][4][16] = {
    {
        {14,4,13,1,2,15,11,8,3,10,6,12,5,9,0,7},
        {0,15,7,4,14,2,13,1,10,6,12,11,9,5,3,8},
        {4,1,14,8,13,6,2,11,15,12,9,7,3,10,5,0},
        {15,12,8,2,4,9,1,7,5,11,3,14,10,0,6,13}
    },
    {
        {15,1,8,14,6,11,3,4,9,7,2,13,12,0,5,10},
        {3,13,4,7,15,2,8,14,12,0,1,10,6,9,11,5},
        {0,14,7,11,10,4,13,1,5,8,12,6,9,3,2,15},
        {13,8,10,1,3,15,4,2,11,6,7,12,0,5,14,9}
    },
    {
        {10,0,9,14,6,3,15,5,1,13,12,7,11,4,2,8},
        {13,7,0,9,3,4,6,10,2,8,5,14,12,11,15,1},
        {13,6,4,9,8,15,3,0,11,1,2,12,5,10,14,7},
        {1,10,13,0,6,9,8,7,4,15,14,3,11,5,2,12}
    },
    {
        {7,13,14,3,0,6,9,10,1,2,8,5,11,12,4,15},
        {13,8,11,5,6,15,0,3,4,7,2,12,1,10,14,9},
        {10,6,9,0,12,11,7,13,15,1,3,14,5,2,8,4},
        {3,15,0,6,10,1,13,8,9,4,5,11,12,7,2,14}
    },
    {
        {2,12,4,1,7,10,11,6,8,5,3,15,13,0,14,9},
        {14,11,2,12,4,7,13,1,5,0,15,10,3,9,8,6},
        {4,2,1,11,10,13,7,8,15,9,12,5,6,3,0,14},
        {11,8,12,7,1,14,2,13,6,15,0,9,10,4,5,3}
    },
    {
        {12,1,10,15,9,2,6,8,0,13,3,4,14,7,5,11},
        {10,15,4,2,7,12,9,5,6,1,13,14,0,11,3,8},
        {9,14,15,5,2,8,12,3,7,0,4,10,1,13,11,6},
        {4,3,2,12,9,5,15,10,11,14,1,7,6,0,8,13}
    },
    {
        {4,11,2,14,15,0,8,13,3,12,9,7,5,10,6,1},
        {13,0,11,7,4,9,1,10,14,3,5,12,2,15,8,6},
        {1,4,11,13,12,3,7,14,10,15,6,8,0,5,9,2},
        {6,11,13,8,1,4,10,7,9,5,0,15,14,2,3,12}
    },
    {
        {13,2,8,4,6,15,11,1,10,9,3,14,5,0,12,7},
        {1,15,13,8,10,3,7,4,12,5,6,11,0,14,9,2},
        {7,11,4,1,9,12,14,2,0,6,10,13,15,3,5,8},
        {2,1,14,7,4,10,8,13,15,12,9,0,3,5,6,11}
    }
};

string shift_left(const string& input, int shifts) {
    return input.substr(shifts) + input.substr(0, shifts);
}

vector<string> generate_round_keys(const string& key64) {
    vector<string> round_keys;
    string permuted_key = permute(key64, PC1, 56);
    string left = permuted_key.substr(0, 28);
    string right = permuted_key.substr(28, 28);

    for (int i = 0; i < 16; i++) {
        left = shift_left(left, SHIFT_TABLE[i]);
        right = shift_left(right, SHIFT_TABLE[i]);
        string combined = left + right;
        round_keys.push_back(permute(combined, PC2, 48));
    }

    return round_keys;
}

string feistel_function(const string& right32, const string& round_key48) {
    string expanded = permute(right32, E_TABLE, 48);
    string xored = Xor(expanded, round_key48);

    string sbox_output;
    sbox_output.reserve(32);
    for (int i = 0; i < 8; i++) {
        string chunk = xored.substr(i * 6, 6);
        string row_bits;
        row_bits += chunk[0];
        row_bits += chunk[5];
        string col_bits = chunk.substr(1, 4);

        int row = convert_binary_to_decimal(row_bits);
        int col = convert_binary_to_decimal(col_bits);
        int value = S_BOX[i][row][col];
        sbox_output += convert_decimal_to_binary(value);
    }

    return permute(sbox_output, P_TABLE, 32);
}

string des_block(const string& block64, const string& key64, bool decrypt) {
    vector<string> round_keys = generate_round_keys(key64);
    if (decrypt) {
        reverse(round_keys.begin(), round_keys.end());
    }

    string permuted = permute(block64, IP, 64);
    string left = permuted.substr(0, 32);
    string right = permuted.substr(32, 32);

    for (int i = 0; i < 16; i++) {
        string old_right = right;
        string f_result = feistel_function(right, round_keys[i]);
        right = Xor(left, f_result);
        left = old_right;
    }

    string combined = right + left;
    return permute(combined, IP_INV, 64);
}

string des_encrypt_block(const string& block64, const string& key64) {
    return des_block(block64, key64, false);
}

string des_decrypt_block(const string& block64, const string& key64) {
    return des_block(block64, key64, true);
}

string des_encrypt_message(string plaintext, const string& key64) {
    plaintext = pad_zero_to_64(plaintext);
    string ciphertext;

    for (size_t i = 0; i < plaintext.size(); i += 64) {
        ciphertext += des_encrypt_block(plaintext.substr(i, 64), key64);
    }

    return ciphertext;
}

string des_decrypt_message(string ciphertext, const string& key64) {
    ciphertext = pad_zero_to_64(ciphertext);
    string plaintext;

    for (size_t i = 0; i < ciphertext.size(); i += 64) {
        plaintext += des_decrypt_block(ciphertext.substr(i, 64), key64);
    }

    return plaintext;
}

string triple_des_encrypt(const string& plaintext64, const string& k1, const string& k2, const string& k3) {
    string step1 = des_encrypt_block(plaintext64, k1);
    string step2 = des_decrypt_block(step1, k2);
    string step3 = des_encrypt_block(step2, k3);
    return step3;
}

string triple_des_decrypt(const string& ciphertext64, const string& k1, const string& k2, const string& k3) {
    string step1 = des_decrypt_block(ciphertext64, k3);
    string step2 = des_encrypt_block(step1, k2);
    string step3 = des_decrypt_block(step2, k1);
    return step3;
}

int main() {
    ios::sync_with_stdio(false);
    cin.tie(nullptr);

    int mode;
    string text, key, k1, k2, k3;

    if (!(cin >> mode)) {
        cerr << "Invalid mode\n";
        return 1;
    }

    if (mode == 1) {
        cin >> text >> key;
        text = clean_binary_string(text);
        key = clean_binary_string(key);

        if (!is_binary_string(text) || !is_binary_string(key) || key.size() != 64) {
            cerr << "Invalid input for DES encrypt\n";
            return 1;
        }

        cout << des_encrypt_message(text, key) << '\n';
    }
    else if (mode == 2) {
        cin >> text >> key;
        text = clean_binary_string(text);
        key = clean_binary_string(key);

        if (!is_binary_string(text) || !is_binary_string(key) || key.size() != 64) {
            cerr << "Invalid input for DES decrypt\n";
            return 1;
        }

        cout << des_decrypt_message(text, key) << '\n';
    }
    else if (mode == 3) {
        cin >> text >> k1 >> k2 >> k3;
        text = clean_binary_string(text);
        k1 = clean_binary_string(k1);
        k2 = clean_binary_string(k2);
        k3 = clean_binary_string(k3);

        if (!is_binary_string(text) || !is_binary_string(k1) || !is_binary_string(k2) || !is_binary_string(k3) ||
            text.size() != 64 || k1.size() != 64 || k2.size() != 64 || k3.size() != 64) {
            cerr << "Invalid input for TripleDES encrypt\n";
            return 1;
        }

        cout << triple_des_encrypt(text, k1, k2, k3) << '\n';
    }
    else if (mode == 4) {
        cin >> text >> k1 >> k2 >> k3;
        text = clean_binary_string(text);
        k1 = clean_binary_string(k1);
        k2 = clean_binary_string(k2);
        k3 = clean_binary_string(k3);

        if (!is_binary_string(text) || !is_binary_string(k1) || !is_binary_string(k2) || !is_binary_string(k3) ||
            text.size() != 64 || k1.size() != 64 || k2.size() != 64 || k3.size() != 64) {
            cerr << "Invalid input for TripleDES decrypt\n";
            return 1;
        }

        cout << triple_des_decrypt(text, k1, k2, k3) << '\n';
    }
    else {
        cerr << "Unknown mode\n";
        return 1;
    }

    return 0;
}
