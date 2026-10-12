import Foundation

/// Vùng dữ liệu dùng chung giữa app chính và Broadcast Extension.
enum AppGroup {
    /// Đọc từ Info.plist (key `AppGroupID`) để đổi được khi ký lại bằng tài khoản khác.
    static let identifier: String =
        Bundle.main.object(forInfoDictionaryKey: "AppGroupID") as? String ?? "group.com.diepnt.mangatrans"

    /// `false` nếu app chưa được cấp quyền App Group (ký sai entitlements) —
    /// khi đó app và extension không nói chuyện được với nhau.
    static var isAvailable: Bool {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier) != nil
    }

    static var containerURL: URL {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier)
            ?? FileManager.default.temporaryDirectory
    }

    /// Kết quả OCR mới nhất do extension ghi ra.
    static var ocrFileURL: URL { containerURL.appendingPathComponent("ocr-frame.json") }

    static let defaults: UserDefaults = UserDefaults(suiteName: identifier) ?? .standard
}

/// Tên các Darwin notification (thông báo liên tiến trình) giữa app và extension.
enum DarwinName {
    static let ocrUpdated = "com.diepnt.mangatrans.ocr-updated"
    static let broadcastStarted = "com.diepnt.mangatrans.broadcast-started"
    static let broadcastFinished = "com.diepnt.mangatrans.broadcast-finished"
    static let stopRequest = "com.diepnt.mangatrans.stop-request"
}
