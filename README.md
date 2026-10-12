# Dịch Truyện — dịch màn hình khi đọc truyện (giống iTranscreen)

App iOS dịch chữ trên màn hình (Anh → Việt) và hiện bản dịch trong **cửa sổ nổi** khi bạn đọc truyện tranh trên Safari hay bất kỳ app nào.

## Cách hoạt động

```
 ┌──────────── Broadcast Extension (ReplayKit) ────────────┐
 │ quay toàn màn hình → OCR bằng Vision (cứ ~0.6 s/lần)    │
 │ → ghi danh sách dòng chữ + vị trí vào App Group         │
 └──────────────────────────┬──────────────────────────────┘
                            │ Darwin notification
 ┌──────────────────────────▼──── App chính (chạy nền nhờ PiP) ┐
 │ lọc mép màn hình + lọc chữ của chính cửa sổ nổi             │
 │ → gom dòng thành bóng thoại → chờ màn hình đứng yên          │
 │ → dịch (Google / Gemini / DeepSeek, có cache)                │
 │ → vẽ thành khung hình → cửa sổ Picture-in-Picture            │
 └─────────────────────────────────────────────────────────────┘
```

| Thư mục | Nội dung |
|---|---|
| `BroadcastExt/` | Extension quay màn hình + OCR |
| `MangaTrans/Pipeline/` | Lọc, gom bóng thoại, điều phối dịch |
| `MangaTrans/Translation/` | Bộ dịch Google miễn phí, Gemini, DeepSeek |
| `MangaTrans/PiP/` | Cửa sổ nổi Picture-in-Picture |
| `MangaTrans/Views/` | Giao diện SwiftUI |
| `Shared/` | Code dùng chung cho app và extension |

Yêu cầu: iOS 16 trở lên.

## Build

Project Xcode được sinh từ `project.yml` bằng [XcodeGen](https://github.com/yonaskolb/XcodeGen).

### Cách 1 — Có máy Mac

```bash
brew install xcodegen
xcodegen generate
open MangaTrans.xcodeproj
```

1. Chọn target **MangaTrans** → *Signing & Capabilities* → chọn Team. Làm tương tự với target **BroadcastExt**.
2. Nếu báo trùng bundle id, đổi `APP_BUNDLE_ID` và `APP_GROUP_ID` trong `project.yml` rồi chạy lại `xcodegen generate`.
3. Cắm iPhone vào máy rồi bấm Run.

Tài khoản Apple miễn phí cũng dùng được (app hết hạn sau 7 ngày). App Group cần bật cho **cả hai** target.

### Cách 2 — Không có Mac (GitHub Actions)

Mỗi lần push, workflow `.github/workflows/ios.yml` chạy unit test rồi build file **`MangaTrans-unsigned.ipa`**. Vào tab **Actions** → chọn lần chạy → mục **Artifacts** để tải về.

Sau đó cài bằng Sideloadly, AltStore, eSign hoặc TrollStore. Công cụ ký lại phải giữ quyền **App Groups** cho cả app lẫn extension, nếu không app sẽ báo *"App chưa được cấp quyền App Group"*.

## Sử dụng

1. Mở app → chọn bộ dịch (vào **Cài đặt** để nhập API key Gemini/DeepSeek, bấm **Dịch thử** để kiểm tra).
2. Nhấn **Bắt đầu** → cửa sổ nổi hiện lên → chọn **Bắt đầu phát sóng** (Start Broadcast).
3. Mở trang truyện. Mỗi lần dừng cuộn, bản dịch các bóng thoại đang hiện trên màn hình sẽ xuất hiện trong cửa sổ nổi.
4. Dừng: nhấn X trên cửa sổ nổi, hoặc chạm vào thanh đỏ ở góc trên màn hình.

### Mẹo

- Kéo cửa sổ nổi sát mép trên/dưới màn hình. App tự lọc chữ của chính cửa sổ nổi, nhưng để ở mép thì bóng thoại không bị che.
- Nếu việc quét màn hình tự dừng sau vài giây (iOS giới hạn extension khoảng 50 MB RAM), hãy chuyển **Độ chính xác OCR** sang **Nhanh**. App cũng tự chuyển nếu phát hiện lần trước bị tắt giữa chừng.
- Dịch chậm hoặc nhảy liên tục: tăng **Chờ đứng yên**.
- Bị dịch cả thanh công cụ trình duyệt: tăng **Bỏ qua mép dưới**.

## Bộ dịch

| Bộ dịch | Key | Ghi chú |
|---|---|---|
| Google (miễn phí) | Không cần | Endpoint web không chính thức, nhanh, có thể bị giới hạn nếu dùng quá nhiều |
| Gemini | [aistudio.google.com/apikey](https://aistudio.google.com/apikey) | Mặc định `gemini-3.6-flash`; đổi model được trong Cài đặt |
| DeepSeek | [platform.deepseek.com](https://platform.deepseek.com) | Mặc định `deepseek-v4-flash` |

Bộ dịch AI nhận cả ngữ cảnh 8 câu trước để giữ cách xưng hô (ta/ngươi, anh/em…) nhất quán. API key được lưu trong UserDefaults của App Group trên máy.

## Giới hạn hiện tại

- Chỉ nhận dạng chữ tiếng Anh, chữ ngang.
- Cửa sổ nổi chỉ hiển thị bản dịch, không vẽ đè lên bóng thoại (iOS không cho app vẽ đè lên app khác).
- ReplayKit không quay được nội dung có DRM (ví dụ Netflix). Trang web truyện thì quay bình thường.
