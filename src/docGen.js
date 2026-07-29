import PizZip from "pizzip";
import Docxtemplater from "docxtemplater";

// ---------------------------------------------------------------------------
// Chuyển số tiền sang chữ tiếng Việt (dùng cho "Vốn điều lệ bằng chữ")
// Lưu ý: đây là chuyển đổi tự động mang tính tham khảo — nên kiểm tra lại
// trước khi nộp hồ sơ chính thức.
// ---------------------------------------------------------------------------
const CHU_SO = ["không", "một", "hai", "ba", "bốn", "năm", "sáu", "bảy", "tám", "chín"];
const DON_VI_NHOM = ["", "nghìn", "triệu", "tỷ"];

function docNhom3(so) {
  const tram = Math.floor(so / 100);
  const chuc = Math.floor((so % 100) / 10);
  const donvi = so % 10;
  let s = "";
  if (tram > 0) {
    s += CHU_SO[tram] + " trăm";
    if (chuc === 0 && donvi > 0) s += " linh";
  }
  if (chuc > 1) {
    s += (s ? " " : "") + CHU_SO[chuc] + " mươi";
    if (donvi === 1) s += " mốt";
    else if (donvi === 5) s += " lăm";
    else if (donvi > 0) s += " " + CHU_SO[donvi];
  } else if (chuc === 1) {
    s += (s ? " " : "") + "mười";
    if (donvi === 1) s += " một";
    else if (donvi === 5) s += " lăm";
    else if (donvi > 0) s += " " + CHU_SO[donvi];
  } else if (chuc === 0 && donvi > 0) {
    s += (s ? " " : "") + CHU_SO[donvi];
  }
  return s.trim();
}

export function soThanhChuTien(n) {
  let so = Math.round(Number(n) || 0);
  if (so === 0) return "Không đồng";
  const amDau = so < 0;
  so = Math.abs(so);

  const nhom = [];
  while (so > 0) {
    nhom.unshift(so % 1000);
    so = Math.floor(so / 1000);
  }
  const total = nhom.length;
  const parts = [];
  nhom.forEach((g, i) => {
    if (g === 0) return;
    const bac = total - i - 1;
    let chu = docNhom3(g);
    if (bac > 0 && bac <= 3) chu += " " + DON_VI_NHOM[bac];
    parts.push(chu);
  });
  let result = parts.join(" ").replace(/\s+/g, " ").trim();
  result = result.charAt(0).toUpperCase() + result.slice(1);
  return (amDau ? "Âm " : "") + result + " đồng";
}

// ---------------------------------------------------------------------------
// Điền file mẫu "Giấy đề nghị đăng ký doanh nghiệp — Công ty TNHH 1 thành
// viên" (public/templates/giay-de-nghi-tnhh-1tv.docx) và tải về máy.
// data phải chứa đủ các khoá: ho_ten, ngay_sinh, gioi_tinh, so_cccd,
// dia_chi_1, xa_phuong_1, tinh_tp_1, dien_thoai, email, ten_cong_ty,
// dia_chi_2, xa_phuong_2, tinh_tp_2, von_dieu_le, von_bang_chu, ngay_lap,
// thang_lap, nam_lap, tinh_lap
// ---------------------------------------------------------------------------
export async function generateBusinessRegistrationDoc(data, filename) {
  const res = await fetch("/templates/giay-de-nghi-tnhh-1tv.docx");
  if (!res.ok) throw new Error("Không tải được file mẫu (kiểm tra lại public/templates/).");
  const arrayBuffer = await res.arrayBuffer();
  const zip = new PizZip(arrayBuffer);
  const doc = new Docxtemplater(zip, { paragraphLoop: true, linebreaks: true });

  try {
    doc.render(data);
  } catch (err) {
    const details = err.properties?.errors?.map((e) => e.properties?.explanation).filter(Boolean).join("; ");
    throw new Error("Lỗi khi điền mẫu" + (details ? `: ${details}` : "."));
  }

  const out = doc.getZip().generate({
    type: "blob",
    mimeType: "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
  });
  const url = URL.createObjectURL(out);
  const a = document.createElement("a");
  a.href = url;
  a.download = filename;
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
  URL.revokeObjectURL(url);
}
