# Report 1 page - Lab 4 DES / TripleDES

## Mục tiêu

Mục tiêu của bài lab là triển khai và hiểu hoạt động của DES và TripleDES ở mức block. Chương trình cần hỗ trợ mã hóa và giải mã DES cho block 64-bit, xử lý plaintext nhiều block bằng zero padding, và triển khai TripleDES theo chuỗi `E(K3, D(K2, E(K1, P)))`. Ngoài phần thuật toán, bài lab cũng yêu cầu viết test tự động, tạo log minh chứng và trình bày rõ cách sử dụng chương trình.

## Cách làm / Method

Em chỉnh sửa `des.cpp` để chương trình nhận dữ liệu từ `stdin` theo 4 mode: DES encrypt, DES decrypt, TripleDES encrypt và TripleDES decrypt. Input được xử lý dưới dạng chuỗi nhị phân gồm ký tự `0` và `1`.

Phần DES được triển khai theo cấu trúc Feistel 16 vòng. Chương trình dùng các bảng hoán vị và biến đổi chính gồm Initial Permutation, Inverse Initial Permutation, PC-1, PC-2, Expansion table, S-box và P permutation. Round keys được sinh từ khóa 64-bit bằng PC-1, chia thành hai nửa 28-bit, dịch trái theo lịch dịch của DES, sau đó dùng PC-2 để tạo 16 khóa con 48-bit. Khi giải mã DES, chương trình dùng cùng hàm xử lý block nhưng đảo ngược thứ tự round keys.

Đối với plaintext dài hơn 64 bit, chương trình chia dữ liệu thành các block 64 bit. Nếu block cuối chưa đủ 64 bit, chương trình thêm bit `0` vào cuối block cho đủ độ dài. Mỗi block được mã hóa độc lập, sau đó nối các ciphertext block lại để tạo output cuối cùng.

TripleDES encrypt được cài theo yêu cầu của bài lab: mã hóa với `K1`, giải mã với `K2`, rồi mã hóa với `K3`, tương ứng `E(K3, D(K2, E(K1, P)))`. TripleDES decrypt thực hiện chuỗi ngược lại: `D(K1, E(K2, D(K3, C)))`.

## Kết quả / Result

Chương trình hiện hỗ trợ 4 mode:

- Mode 1: DES encrypt
- Mode 2: DES decrypt
- Mode 3: TripleDES encrypt
- Mode 4: TripleDES decrypt

Output cuối cùng được in dưới dạng chuỗi nhị phân để script test và CI có thể kiểm tra. Các test trong thư mục `tests/` bao gồm: test vector DES mẫu, test round-trip encrypt/decrypt, test multi-block với zero padding, negative test cho ciphertext bị tamper, và negative test cho trường hợp dùng sai key. Log chạy test được lưu trong thư mục `logs/` để làm minh chứng.

## Kết luận / Conclusion

Qua bài lab này, em hiểu rõ hơn cách DES xử lý dữ liệu theo block 64-bit, cách sinh round keys, cách mạng Feistel cho phép dùng cùng cấu trúc cho cả mã hóa và giải mã, và cách TripleDES kết hợp nhiều lần DES để tăng độ phức tạp so với DES đơn. Em cũng hiểu thêm vai trò của test tự động, đặc biệt là các negative test như tamper và wrong key để chứng minh chương trình không chỉ chạy với trường hợp đúng mà còn xử lý được các tình huống sai.

Hạn chế hiện tại là zero padding không cho biết chính xác số bit padding khi giải mã, nên không thể phân biệt chắc chắn bit `0` cuối là dữ liệu thật hay padding. Ngoài ra, chương trình chỉ phục vụ mục đích học tập và minh họa thuật toán, chưa phải công cụ bảo mật dùng trong thực tế. DES hiện cũng là thuật toán cũ và không còn phù hợp cho các hệ thống bảo mật hiện đại. Nếu mở rộng, có thể bổ sung cơ chế padding rõ ràng hơn, hỗ trợ input từ file, thêm mode hoạt động như CBC, và cải thiện format output/log.

## Ethics & Safe use

Chương trình chỉ được dùng cho dữ liệu học tập hoặc dữ liệu giả lập trong phạm vi bài lab. Không sử dụng chương trình để tấn công, can thiệp hoặc kiểm thử trái phép trên hệ thống thật. Nếu có tham khảo tài liệu, mã nguồn hoặc công cụ AI, cần ghi nguồn rõ ràng và trung thực học thuật.
