# Quản lý đơn hàng NMT

Ứng dụng quản lý khách hàng — đơn hàng — chi phí — báo cáo cho đội ngũ NMT.
React + Vite + Tailwind, dữ liệu lưu trên Supabase (Postgres + Storage).

## 1. Tạo dự án Supabase

1. Vào [supabase.com](https://supabase.com) → **New project** (miễn phí).
2. Sau khi tạo xong, vào **SQL Editor** → **New query** → dán toàn bộ nội dung
   file `supabase/schema.sql` trong repo này → **Run**.
   → Lệnh này tạo đủ 4 bảng (`employees`, `customers`, `orders`, `expenses`)
   và tạo sẵn 3 tài khoản mẫu để đăng nhập thử:

   | Tên đăng nhập | Mật khẩu | Vai trò |
   |---|---|---|
   | `nv1` | `123456` | Nhân viên |
   | `nv2` | `123456` | Nhân viên |
   | `admin` | `123456` | Quản lý |

   **Đổi mật khẩu các tài khoản này ngay sau khi triển khai thật** (sửa trực
   tiếp trong Supabase → Table Editor → bảng `employees`).

3. Tạo 2 Storage bucket để lưu ảnh CCCD và file PDF giấy phép:
   - Vào **Storage** (menu bên trái) → **New bucket**
   - Tạo bucket tên `vnid-photos` → bật **Public bucket** → Save
   - Tạo bucket tên `license-pdfs` → bật **Public bucket** → Save

4. Lấy thông tin kết nối: vào **Project Settings → API**, copy 2 giá trị:
   - **Project URL**
   - **anon public key**

## 2. Cấu hình biến môi trường

### Chạy thử trên máy (local)

Tạo file `.env` ở thư mục gốc dự án với nội dung:

```
VITE_SUPABASE_URL=https://xxxxxxxx.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

(Thay bằng giá trị thật lấy ở bước 4 phía trên)

Sau đó:
```
npm install
npm run dev
```

### Triển khai qua Vercel

1. Đẩy toàn bộ code này lên 1 repo GitHub mới.
2. Vào [vercel.com](https://vercel.com) → **Add New Project** → chọn repo vừa tạo.
3. Ở bước cấu hình, mở **Environment Variables**, thêm:
   - `VITE_SUPABASE_URL` = Project URL
   - `VITE_SUPABASE_ANON_KEY` = anon public key
4. Bấm **Deploy**. Xong, Vercel tự build và cấp link truy cập.

## 3. Cấu trúc tài khoản & phân quyền

- **Nhân viên** (`role = nhan_vien`): quản lý khách hàng & đơn hàng của
  chính mình — Khách hàng, Tạo đơn hàng, Trạng thái đơn hàng, Báo cáo.
- **Quản lý** (`role = admin`): xem toàn bộ khách hàng/đơn hàng, xác nhận
  đơn sau khi nhận giấy phép, ghi nhận doanh thu/chi phí/tiền công, cập
  nhật chi phí phát sinh, báo cáo tổng hợp, chăm sóc sau đơn hàng.

Thêm tài khoản mới: vào Supabase → Table Editor → bảng `employees` → Insert
row, điền `name`, `username`, `password`, `role` (`nhan_vien` hoặc `admin`).

## 4. Lưu ý về bảo mật (quan trọng)

Đây là bản triển khai cho một đội nhóm nội bộ quy mô nhỏ, được đơn giản hoá
để triển khai nhanh:

- Mật khẩu tài khoản đang lưu dạng **văn bản thường** (không mã hoá) trong
  bảng `employees`, và việc đăng nhập được kiểm tra trực tiếp từ trình
  duyệt bằng anon key. Điều này **đủ dùng cho một công cụ nội bộ, ít người
  dùng, không public link ra ngoài**, nhưng **không phù hợp nếu ứng dụng
  công khai trên Internet** cho nhiều người ngoài truy cập.
- Row Level Security (RLS) hiện đang mở hoàn toàn (`using (true)`) — bất kỳ
  ai có anon key (vốn đã lộ trong code frontend) đều đọc/ghi được toàn bộ
  dữ liệu qua Supabase API trực tiếp, không chỉ qua giao diện web.
- **Nếu cần bảo mật chặt chẽ hơn** (ví dụ mở rộng cho nhiều chi nhánh, có
  dữ liệu khách hàng nhạy cảm cần bảo vệ), nên nâng cấp sang **Supabase
  Auth** thật (email/password hoặc magic link) kết hợp RLS policy theo
  `auth.uid()`. Báo lại nếu bạn cần mình hỗ trợ nâng cấp phần này.

## 5. Các thư mục chính

```
├── supabase/schema.sql   → chạy 1 lần trong Supabase SQL Editor
├── src/
│   ├── App.jsx            → toàn bộ giao diện & logic nghiệp vụ
│   ├── supabaseClient.js  → kết nối Supabase
│   ├── main.jsx
│   └── index.css
├── package.json
└── vite.config.js
```
