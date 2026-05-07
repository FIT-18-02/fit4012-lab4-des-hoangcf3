# Report 1 page - Lab 4 DES / TripleDES

## Mục tiêu
Mục tiêu của bài lab là triển khai và hiểu hoạt động của DES và TripleDES ở mức khối (block), bao gồm:
 - Mã hóa/des mã hóa DES cho block 64-bit.
 - Hỗ trợ mã hóa multi-block với zero-padding.
 - Triển khai TripleDES theo chuỗi E(K3, D(K2, E(K1, P))).

## Cách làm / Method

Chỉnh sửa luồng chính để chương trình nhận input từ stdin theo contract (modes 1..4).
Thêm xử lý chia block 64-bit và zero-padding cho plaintext dài hơn 64 bit.
Thực hiện DES rounds dựa trên round-keys sinh ra từ PC-1/PC-2 và các S-box có sẵn.
Thêm logic TripleDES (encrypt/decrypt) theo yêu cầu.
Cập nhật README, viết test tự động và thêm minh chứng trong thư mục logs/.

## Kết quả / Result
Chương trình hỗ trợ 4 mode: DES encrypt/decrypt và TripleDES encrypt/decrypt.
Multi-block: plaintext dài hơn 64 bit được chia thành các block 64 bit; block cuối được zero-pad.
Tests trong thư mục tests/ bao gồm:
 - sample run
 - round-trip encrypt->decrypt
 - multi-block padding
 - negative test cho tamper
 - negative test cho wrong key

## Kết luận / Conclusion

TODO_STUDENT: Nêu điều học được, hạn chế hiện tại, và hướng mở rộng như decryption / TripleDES / multi-block.
