-- =============================================================================
-- Bổ sung cột "industries" (danh sách nhiều ngành nghề kinh doanh, dạng JSON)
-- cho bảng customers và orders — thay cho 2 cột industry/industry_detail cũ
-- (giữ nguyên cột cũ, không xoá, chỉ không dùng nữa).
-- Chạy trong Supabase (project NMT-orders) → SQL Editor → Run.
-- =============================================================================

alter table customers add column if not exists industries jsonb not null default '[]'::jsonb;
alter table orders add column if not exists industries jsonb not null default '[]'::jsonb;
