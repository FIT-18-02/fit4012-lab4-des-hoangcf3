# FIT4012 - Lab 4: DES / TripleDES

Repo này là bài thực hành Lab 4 về DES và TripleDES. Chương trình được viết bằng C++17, nhận dữ liệu nhị phân từ `stdin`, hỗ trợ DES encrypt/decrypt, TripleDES encrypt/decrypt, multi-block và zero padding.

## 1. Cấu trúc repo

```text
.
├── .github/
│   ├── scripts/
│   │   └── check_submission.sh
│   └── workflows/
│       └── ci.yml
├── logs/
│   ├── .gitkeep
│   ├── README.md
│   └── test-output.txt
├── scripts/
│   └── run_sample.sh
├── tests/
│   ├── test_des_sample.sh
│   ├── test_encrypt_decrypt_roundtrip.sh
│   ├── test_multiblock_padding.sh
│   ├── test_tamper_negative.sh
│   └── test_wrong_key_negative.sh
├── .gitignore
├── CMakeLists.txt
├── Makefile
├── README.md
├── des.cpp
└── report-1page.md
```

## 2. Cách chạy chương trình

### Cách 1: Dùng Makefile

```bash
make
./des
```

### Cách 2: Biên dịch trực tiếp

```bash
g++ -std=c++17 -Wall -Wextra -pedantic des.cpp -o des
./des
```

### Cách 3: Dùng CMake

```bash
cmake -S . -B build
cmake --build build
./build/des
```

## 3. Input / Đầu vào

Chương trình nhận dữ liệu từ `stdin`. Dữ liệu đầu vào là chuỗi nhị phân chỉ gồm ký tự `0` và `1`.

Mode đầu tiên xác định thao tác cần chạy:

```text
1 = DES encrypt
2 = DES decrypt
3 = TripleDES encrypt
4 = TripleDES decrypt
```

### Mode 1: DES encrypt

Nhập lần lượt:

```text
1
plaintext nhị phân
key 64-bit
```

Plaintext có thể dài hơn 64 bit. Nếu dài hơn 64 bit, chương trình chia plaintext thành nhiều block 64 bit. Nếu block cuối thiếu bit, chương trình thêm `0` vào cuối block cho đủ 64 bit.

### Mode 2: DES decrypt

Nhập lần lượt:

```text
2
ciphertext nhị phân
key 64-bit
```

Ciphertext được xử lý theo từng block 64 bit. Giải mã DES sử dụng cùng thuật toán Feistel nhưng round keys được dùng theo thứ tự đảo ngược.

### Mode 3: TripleDES encrypt

Nhập lần lượt:

```text
3
plaintext 64-bit
K1 64-bit
K2 64-bit
K3 64-bit
```

TripleDES encrypt được thực hiện theo chuỗi:

```text
C = E(K3, D(K2, E(K1, P)))
```

### Mode 4: TripleDES decrypt

Nhập lần lượt:

```text
4
ciphertext 64-bit
K1 64-bit
K2 64-bit
K3 64-bit
```

TripleDES decrypt được thực hiện theo chuỗi ngược lại:

```text
P = D(K1, E(K2, D(K3, C)))
```

## 4. Output / Đầu ra

Chương trình in kết quả cuối cùng ra `stdout` dưới dạng chuỗi nhị phân.

- Với DES encrypt, output là ciphertext nhị phân.
- Với DES decrypt, output là plaintext nhị phân sau khi giải mã.
- Với TripleDES encrypt, output là ciphertext 64-bit.
- Với TripleDES decrypt, output là plaintext 64-bit.
- Chương trình không cần in round keys trong output cuối cùng.
- Dòng output cuối cùng luôn chứa chuỗi nhị phân hợp lệ để test script hoặc CI có thể tách ra kiểm tra.

Ví dụ chạy DES encrypt:

```bash
printf "1\n0000000100100011010001010110011110001001101010111100110111101111\n0001001100110100010101110111100110011011101111001101111111110001\n" | ./des
```

Output mong đợi:

```text
1000010111101000000100110101010000001111000010101011010000000101
```

## 5. Padding đang dùng

Chương trình dùng zero padding cho DES multi-block.

Quy trình:

1. Nếu plaintext dài hơn 64 bit, chương trình chia plaintext thành các block 64 bit.
2. Nếu block cuối chưa đủ 64 bit, chương trình thêm ký tự `0` vào cuối block.
3. Mỗi block 64 bit được mã hóa độc lập bằng DES.
4. Các ciphertext block được nối lại thành ciphertext cuối cùng.

Ví dụ:

```text
plaintext = 1010
sau zero padding = 1010000000000000000000000000000000000000000000000000000000000000
```

Hạn chế của zero padding là khi giải mã, chương trình không thể phân biệt chắc chắn các bit `0` cuối là dữ liệu thật hay padding được thêm vào. Vì vậy cách này chỉ phù hợp cho bài học nhập môn để minh họa xử lý block, không phải thiết kế an toàn hoàn chỉnh cho môi trường thực tế.

## 6. Tests bắt buộc

Repo có 5 test chính:

- `tests/test_des_sample.sh`
- `tests/test_encrypt_decrypt_roundtrip.sh`
- `tests/test_multiblock_padding.sh`
- `tests/test_tamper_negative.sh`
- `tests/test_wrong_key_negative.sh`

Ý nghĩa từng test:

| Test | Mục đích |
|---|---|
| `test_des_sample.sh` | Kiểm tra DES encrypt với vector mẫu chuẩn |
| `test_encrypt_decrypt_roundtrip.sh` | Kiểm tra encrypt rồi decrypt trả về plaintext ban đầu |
| `test_multiblock_padding.sh` | Kiểm tra plaintext dài hơn 64 bit, chia nhiều block và zero padding |
| `test_tamper_negative.sh` | Kiểm tra ciphertext bị sửa bit thì không giải mã ra plaintext gốc |
| `test_wrong_key_negative.sh` | Kiểm tra dùng sai key thì không giải mã ra plaintext gốc |

Cách chạy test:

```bash
chmod +x tests/*.sh

bash tests/test_des_sample.sh
bash tests/test_encrypt_decrypt_roundtrip.sh
bash tests/test_multiblock_padding.sh
bash tests/test_tamper_negative.sh
bash tests/test_wrong_key_negative.sh
```

Hoặc chạy toàn bộ:

```bash
for t in tests/*.sh; do
  echo "== $t =="
  bash "$t"
done
```

## 7. Logs / Minh chứng

Thư mục `logs/` dùng để lưu minh chứng chạy chương trình và test.

Ví dụ tạo log:

```bash
mkdir -p logs

{
  echo "Running DES/TripleDES Lab 4 tests"
  echo

  for t in tests/*.sh; do
    echo "== $t =="
    bash "$t"
    echo
  done
} > logs/test-output.txt
```

File `logs/test-output.txt` là minh chứng rằng chương trình đã được compile và các test đã chạy.

## 8. Ethics & Safe use

- Chương trình chỉ dùng cho mục đích học tập trong Lab 4.
- Chỉ kiểm thử với dữ liệu giả lập hoặc dữ liệu học tập.
- Không dùng chương trình để tấn công, can thiệp hoặc phân tích trái phép hệ thống thật.
- Không trình bày chương trình này như một công cụ bảo mật sẵn sàng cho môi trường production.
- DES là thuật toán cũ và không còn phù hợp cho bảo mật hiện đại.
- Nếu có tham khảo mã nguồn, tài liệu hoặc AI, cần ghi rõ trong report.

## 9. Checklist nộp bài

Trước khi nộp, repo cần có:

- `des.cpp`
- `README.md` hoàn chỉnh
- `report-1page.md` hoàn chỉnh
- `tests/` với ít nhất 5 test
- negative test cho `tamper`
- negative test cho `wrong key`
- `logs/` có ít nhất 1 file minh chứng thật
- không còn dòng placeholder chưa hoàn thiện
- DES multi-block và zero padding chạy đúng
- TripleDES encrypt/decrypt chạy đúng

Có thể kiểm tra placeholder bằng:

```bash
grep -R "TODO_STUDENT" .
```

Nếu lệnh trên còn trả kết quả thì cần sửa hết trước khi nộp.

## 10. Lưu ý về CI

CI không chỉ kiểm tra file có tồn tại mà còn kiểm tra nội dung README, report, test, logs và chương trình thực sự chạy đúng.

Các phần quan trọng cần pass:

- chương trình nhận input từ `stdin`;
- DES encrypt/decrypt hoạt động đúng;
- DES multi-block có zero padding;
- TripleDES encrypt/decrypt đúng thứ tự;
- có đủ negative tests;
- có log minh chứng;
- không còn placeholder chưa hoàn thiện.
