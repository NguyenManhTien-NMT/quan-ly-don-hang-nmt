-- =============================================================================
-- QUẢN LÝ ĐƠN HÀNG NMT — Schema Supabase
-- Chạy toàn bộ file này trong Supabase Dashboard → SQL Editor → New query → Run
-- =============================================================================

create extension if not exists "uuid-ossp";

-- -----------------------------------------------------------------------------
-- Bảng tài khoản nhân viên / quản lý
-- LƯU Ý BẢO MẬT: mật khẩu đang lưu dạng văn bản thường (đơn giản cho nội bộ
-- quy mô nhỏ). Nếu cần bảo mật cao hơn, nên chuyển sang Supabase Auth.
-- -----------------------------------------------------------------------------
create table if not exists employees (
  id uuid primary key default uuid_generate_v4(),
  name text not null,
  username text unique not null,
  password text not null,
  role text not null check (role in ('nhan_vien','admin')),
  created_at timestamptz default now()
);

-- -----------------------------------------------------------------------------
-- Bảng khách hàng
-- -----------------------------------------------------------------------------
create table if not exists customers (
  id uuid primary key default uuid_generate_v4(),
  name text,
  cccd text,
  phone text not null,
  address text not null,
  ward text,
  industry text,
  referrer text,
  vnid_photo_url text,
  employee_id uuid references employees(id),
  created_at timestamptz default now()
);

-- -----------------------------------------------------------------------------
-- Bảng đơn hàng
-- -----------------------------------------------------------------------------
create table if not exists orders (
  id uuid primary key default uuid_generate_v4(),
  order_code text unique not null,
  customer_id uuid references customers(id),
  employee_id uuid references employees(id),
  procedure_type text not null check (procedure_type in ('mo_hkd','mo_cty','cham_dut_mst')),
  status text not null default 'cho_xu_ly',
  created_at timestamptz default now(),
  received_at timestamptz,
  leader_at timestamptz,
  approved_at timestamptz,
  rejected_at timestamptz,
  overdue_reason text default '',
  license_pdf_url text,
  license_pdf_name text,
  license_sent_at timestamptz,
  confirmed_at timestamptz,
  revenue numeric,
  cost numeric,
  labor_fee numeric,
  completed_at timestamptz,
  care_steps jsonb default '{}'::jsonb
);

-- -----------------------------------------------------------------------------
-- Bảng chi phí phát sinh hàng ngày (Admin cập nhật)
-- -----------------------------------------------------------------------------
create table if not exists expenses (
  id uuid primary key default uuid_generate_v4(),
  date date not null,
  description text not null,
  amount numeric not null,
  created_at timestamptz default now()
);

-- -----------------------------------------------------------------------------
-- Bật Row Level Security + policy đơn giản (cho phép đọc/ghi qua anon key).
-- Phù hợp cho công cụ nội bộ dùng trong công ty. Nếu cần chặt chẽ hơn, thay
-- các policy "true" bên dưới bằng điều kiện theo auth.uid() sau khi tích hợp
-- Supabase Auth thật.
-- -----------------------------------------------------------------------------
alter table employees enable row level security;
alter table customers enable row level security;
alter table orders enable row level security;
alter table expenses enable row level security;

create policy "allow all - employees" on employees for all using (true) with check (true);
create policy "allow all - customers" on customers for all using (true) with check (true);
create policy "allow all - orders" on orders for all using (true) with check (true);
create policy "allow all - expenses" on expenses for all using (true) with check (true);

-- -----------------------------------------------------------------------------
-- Dữ liệu mẫu: 2 tài khoản nhân viên + 1 tài khoản quản lý để đăng nhập thử
-- Đổi mật khẩu này ngay sau khi triển khai thật!
-- -----------------------------------------------------------------------------
insert into employees (name, username, password, role) values
  ('Nguyễn Văn An', 'nv1', '123456', 'nhan_vien'),
  ('Trần Thị Bích', 'nv2', '123456', 'nhan_vien'),
  ('Lê Quản Trị', 'admin', '123456', 'admin');

-- =============================================================================
-- SAU KHI CHẠY XONG FILE NÀY, VÀO Storage (menu bên trái) TẠO 2 BUCKET:
--   1. vnid-photos   → Public bucket: BẬT (để hiển thị ảnh trực tiếp)
--   2. license-pdfs  → Public bucket: BẬT (để tải/xem PDF trực tiếp)
-- (Cách tạo: Storage → New bucket → nhập tên → bật "Public bucket" → Save)
-- =============================================================================
