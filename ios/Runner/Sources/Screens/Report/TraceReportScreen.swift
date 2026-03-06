import SwiftUI
import AVFoundation

struct TraceReportScreen: View {
    let onBack: () -> Void

    @Environment(InvestigationStore.self) private var store
    @State private var passphrase    = ""
    @State private var isSaved       = false
    @State private var saveError     : String?
    @State private var isLocking     = false
    @State private var selectedEvidence: EvidenceItem?

    // Derived
    private var record  : InvestigationRecord? { store.record }
    private var results : [String: String]     { record?.results ?? [:] }
    private var flaggedCount: Int { results.values.filter { $0 == "flagged" }.count }

    var body: some View {
        ZStack {
            Color(hex: 0x050505).ignoresSafeArea()
            reportBackground

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    header
                        .padding(.top, safeAreaTop + 12)

                    cinematicVisual
                        .padding(.top, 24)

                    statsRow
                        .padding(.top, 16)
                        .padding(.bottom, 56)

                    infoCards
                        .padding(.bottom, 56)

                    evidenceSection
                        .padding(.bottom, 56)

                    timelineSection
                        .padding(.bottom, 64)

                    keySection
                        .padding(.bottom, 120)
                }
                .padding(.horizontal, 28)
            }

            if let ev = selectedEvidence {
                EvidencePreviewOverlay(evidence: ev, passphrase: store.passphrase ?? "") {
                    selectedEvidence = nil
                }
            }
        }
        .ignoresSafeArea()
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.white.opacity(0.60))
            }
            Spacer()
            Text("痕迹观察报告")
                .font(.mono(10, weight: .bold))
                .foregroundStyle(Color.white.opacity(0.30))
                .kerning(4)
        }
    }

    // MARK: - Cinematic visual

    private var reportBackground: some View {
        GeometryReader { geo in
            ZStack {
                RadialGradient(
                    colors: [Color(hex: 0x1a0a2e).opacity(0.6), .clear],
                    center: UnitPoint(x: 0.2, y: 0.1),
                    startRadius: 0,
                    endRadius: geo.size.width * 1.2
                )
                RadialGradient(
                    colors: [Color(hex: 0x0d1f3c).opacity(0.4), .clear],
                    center: UnitPoint(x: 0.8, y: 0.4),
                    startRadius: 0,
                    endRadius: geo.size.width
                )
            }
            .ignoresSafeArea()
        }
    }

    private var cinematicVisual: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.03))
                .frame(height: 200)
                .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.08)))

            VStack(spacing: 12) {
                Image(systemName: "eye.trianglebadge.exclamationmark")
                    .font(.system(size: 40))
                    .foregroundStyle(Color.white.opacity(0.15))
                Text("TRACE ANALYSIS COMPLETE")
                    .font(.mono(9, weight: .bold))
                    .foregroundStyle(Color.white.opacity(0.20))
                    .kerning(4)
            }
        }
    }

    private var statsRow: some View {
        HStack(spacing: 16) {
            statCard(value: "\(flaggedCount)", label: "异常项", color: .anomalyRed)
            statCard(value: "\(kPartnerQuestions.count - flaggedCount)", label: "正常项", color: Color.white.opacity(0.40))
            statCard(value: "\(store.pendingFiles.count + (record?.evidences.values.reduce(0) { $0 + $1.count } ?? 0))", label: "证据文件", color: .emerald)
        }
    }

    @ViewBuilder
    private func statCard(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 28, weight: .light))
                .foregroundStyle(color)
            Text(label)
                .font(.mono(9))
                .foregroundStyle(Color.white.opacity(0.30))
                .kerning(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.white.opacity(0.03))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.08)))
    }

    // MARK: - Info cards

    private var infoCards: some View {
        let behaviorItems = flaggedTitles(categories: ["行为变化与异常", "社交与聊天痕迹", "短视频与社交平台痕迹"])
        let clueItems     = flaggedTitles(categories: ["消费与地址痕迹", "行程与位置痕迹"])
        let deviceItems   = flaggedTitles(categories: ["应用与设备痕迹"])

        return VStack(spacing: 16) {
            infoCard(title: "核心行为模式", icon: "waveform.path", items: behaviorItems, hint: "未发现行为异常")
            HStack(spacing: 16) {
                infoCard(title: "关键线索", icon: "square.3.layers.3d", items: clueItems, hint: "未发现异常线索")
                infoCard(title: "关联设备", icon: "laptopcomputer", items: deviceItems, hint: "未发现设备异常")
            }
        }
    }

    @ViewBuilder
    private func infoCard(title: String, icon: String, items: [String], hint: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color.white.opacity(0.50))
                .labelStyle(.titleAndIcon)

            if items.isEmpty {
                Text(hint)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.white.opacity(0.20))
            } else {
                ForEach(items, id: \.self) { item in
                    HStack(spacing: 8) {
                        Circle().fill(Color.anomalyRed).frame(width: 4, height: 4)
                        Text(item)
                            .font(.system(size: 12, weight: .light))
                            .foregroundStyle(Color.white.opacity(0.70))
                            .lineLimit(2)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.08)))
    }

    // MARK: - Evidence section

    private var evidenceSection: some View {
        let allEvidence = buildEvidenceItems()
        return VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("关键证据库", systemImage: "folder")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.60))
                Spacer()
                Text("Items: \(allEvidence.count)")
                    .font(.mono(11))
                    .foregroundStyle(Color.white.opacity(0.40))
                    .padding(.horizontal, 8).padding(.vertical, 2)
                    .background(Color.white.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.white.opacity(0.10)))
            }

            if allEvidence.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "folder.badge.plus").font(.system(size: 28)).foregroundStyle(Color.white.opacity(0.20))
                        Text("暂无证据文件").font(.system(size: 13)).foregroundStyle(Color.white.opacity(0.30))
                    }
                    .padding(.vertical, 32)
                    Spacer()
                }
                .background(Color.white.opacity(0.03))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(allEvidence) { ev in
                        EvidenceCard(evidence: ev) { selectedEvidence = ev }
                    }
                }
            }
        }
    }

    // MARK: - Timeline

    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            Divider().background(Color.white.opacity(0.08))
                .padding(.bottom, 8)

            Label("观察日志记录", systemImage: "clock")
                .font(.system(size: 18, weight: .light))
                .foregroundStyle(Color.white.opacity(0.80))

            let entries = buildTimelineEntries()
            ForEach(Array(entries.enumerated()), id: \.offset) { _, entry in
                HStack(alignment: .top, spacing: 16) {
                    Circle()
                        .fill(entry.isLatest ? Color.emerald : Color.white.opacity(0.10))
                        .frame(width: 12, height: 12)
                        .shadow(color: entry.isLatest ? Color.emerald.opacity(0.5) : .clear, radius: 6)
                        .padding(.top, 3)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.date)
                            .font(.mono(10))
                            .foregroundStyle(Color.white.opacity(0.20))
                            .kerning(2)
                        Text(entry.title)
                            .font(.system(size: 13, weight: entry.isLatest ? .medium : .light))
                            .foregroundStyle(entry.isLatest ? Color.emerald.opacity(0.90) : Color.white.opacity(0.50))
                    }
                }
            }
        }
    }

    // MARK: - Key section

    private var keySection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Divider().background(Color.white.opacity(0.08))

            if isSaved {
                // Saved state
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(Color.emerald)
                    Text("档案已加密锁定")
                        .font(.system(size: 16, weight: .light))
                        .foregroundStyle(Color.white.opacity(0.70))
                    Text("凭密钥可在「查看历史记录」中解密访问")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.white.opacity(0.30))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            } else {
                Text("设置档案密钥")
                    .font(.system(size: 18, weight: .light))
                    .foregroundStyle(Color.white.opacity(0.80))

                Text("设置一个只有你知道的密钥，用于加密和解密你的观察档案。可以是任意文字或数字组合。")
                    .font(.system(size: 13, weight: .light))
                    .foregroundStyle(Color.white.opacity(0.40))
                    .lineSpacing(4)

                // Input field
                TextField("输入密钥...", text: $passphrase)
                    .foregroundStyle(Color.white)
                    .padding(16)
                    .background(Color.white.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.15)))

                if let err = saveError {
                    Text(err)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.anomalyRed.opacity(0.80))
                }

                // Save button
                Button {
                    Task { await handleSave() }
                } label: {
                    HStack {
                        if isLocking { ProgressView().tint(.black) }
                        Text(isLocking ? "加密中..." : "加密并锁定档案")
                            .font(.system(size: 13, weight: .bold))
                            .kerning(3)
                            .foregroundStyle(Color.black)
                        Image(systemName: "lock.fill")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.black)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(passphrase.isEmpty ? Color.white.opacity(0.20) : Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .disabled(passphrase.isEmpty || isLocking)
            }
        }
    }

    // MARK: - Save handler

    private func handleSave() async {
        let phrase = passphrase.trimmingCharacters(in: .whitespaces)
        guard !phrase.isEmpty else { return }
        isLocking = true
        saveError = nil
        store.setPassphrase(phrase)

        // Upload pending files
        for pending in store.pendingFiles {
            let result = await EvidenceService.uploadEvidence(url: pending.url, passphrase: phrase, itemId: pending.itemId)
            if case .success(let key) = result {
                store.addEvidenceKey(itemId: pending.itemId, fileKey: key)
            }
        }
        store.clearPendingFiles()

        let status = await store.save()
        isLocking = false
        if status == .success {
            isSaved = true
        } else {
            saveError = status == .passphraseConflict ? "该密钥已被其他档案使用，请换一个。" : "保存失败，请检查网络连接。"
        }
    }

    // MARK: - Helpers

    private func flaggedTitles(categories: [String]) -> [String] {
        kPartnerQuestions
            .filter { categories.contains($0.category) && results["\($0.id)"] == "flagged" }
            .map { $0.title }
    }

    private func buildEvidenceItems() -> [EvidenceItem] {
        var items: [EvidenceItem] = []
        // Pending (local)
        for p in store.pendingFiles {
            let isAudio = p.url.pathExtension.lowercased() == "m4a"
            items.append(EvidenceItem(
                id: p.id.uuidString, type: isAudio ? .audio : .image,
                title: kPartnerQuestions.first { "\($0.id)" == p.itemId }?.title ?? "证据 #\(p.itemId)",
                timestamp: Date(), localURL: p.url, fileKey: nil
            ))
        }
        // Uploaded
        for (itemId, keys) in record?.evidences ?? [:] {
            let title = kPartnerQuestions.first { "\($0.id)" == itemId }?.title ?? "证据 #\(itemId)"
            for key in keys {
                items.append(EvidenceItem(
                    id: key, type: key.contains(".m4a") ? .audio : .image,
                    title: title, timestamp: record?.completedAt ?? .now,
                    localURL: nil, fileKey: key
                ))
            }
        }
        return items
    }

    private func buildTimelineEntries() -> [(date: String, title: String, isLatest: Bool)] {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy.MM.dd HH:mm"
        var entries: [(String, String, Bool)] = []
        if let r = record {
            entries.append((fmt.string(from: r.completedAt), "开始观察记录", false))
            let flagCount = r.results.values.filter { $0 == "flagged" }.count
            if flagCount > 0 {
                entries.append((fmt.string(from: r.completedAt), "发现 \(flagCount) 项异常", false))
            }
            let evCount = r.evidences.values.reduce(0) { $0 + $1.count }
            if evCount > 0 {
                entries.append((fmt.string(from: r.completedAt), "已上传 \(evCount) 份加密文件", true))
            } else {
                entries.append((fmt.string(from: .now), "正在等待档案锁定", true))
            }
        }
        return entries
    }

    private var safeAreaTop: CGFloat {
        (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.safeAreaInsets.top ?? 44
    }
}

// MARK: - Evidence models

enum EvidenceType { case image, audio }

struct EvidenceItem: Identifiable {
    let id        : String
    let type      : EvidenceType
    let title     : String
    let timestamp : Date
    let localURL  : URL?
    let fileKey   : String?

    var timestampString: String {
        let f = DateFormatter(); f.dateFormat = "yyyy.MM.dd HH:mm"; return f.string(from: timestamp)
    }
    var isPending: Bool { localURL != nil }
}

// MARK: - Evidence Card

struct EvidenceCard: View {
    let evidence: EvidenceItem
    let onTap   : () -> Void

    @State private var thumbImage: UIImage?

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                // Thumbnail
                ZStack {
                    if let img = thumbImage {
                        Image(uiImage: img)
                            .resizable().scaledToFill()
                            .frame(maxWidth: .infinity).frame(height: 120)
                            .clipped()
                    } else if evidence.type == .audio {
                        Color(hex: 0x0A1A12)
                            .frame(maxWidth: .infinity).frame(height: 120)
                            .overlay(
                                Image(systemName: "mic").font(.system(size: 28))
                                    .foregroundStyle(Color.emerald)
                            )
                    } else {
                        Color.white.opacity(0.04)
                            .frame(maxWidth: .infinity).frame(height: 120)
                            .overlay(
                                Image(systemName: "photo").font(.system(size: 28))
                                    .foregroundStyle(Color.white.opacity(0.20))
                            )
                    }
                }
                .clipShape(UnevenRoundedRectangle(topLeadingRadius: 16, topTrailingRadius: 16))

                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(evidence.title)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.white.opacity(0.80))
                        .lineLimit(1)
                    Text(evidence.timestampString)
                        .font(.mono(10))
                        .foregroundStyle(Color.white.opacity(0.40))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
            }
            .background(Color.white.opacity(0.04))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.08)))
        }
        .task {
            if evidence.type == .image, let url = evidence.localURL,
               let data = try? Data(contentsOf: url) {
                thumbImage = UIImage(data: data)
            }
        }
    }
}

// MARK: - Evidence preview overlay

struct EvidencePreviewOverlay: View {
    let evidence  : EvidenceItem
    let passphrase: String
    let onClose   : () -> Void

    @State private var loading    = true
    @State private var error      = false
    @State private var imageData  : Data?
    @State private var audioURL   : URL?
    @State private var isPlaying  = false
    @State private var player     : AVAudioPlayerWrapper?

    var body: some View {
        ZStack {
            Color.black.opacity(0.95).ignoresSafeArea()
                .onTapGesture { onClose() }

            VStack(spacing: 0) {
                // Preview area
                ZStack {
                    if evidence.type == .image {
                        imagePreview
                    } else {
                        audioPreview
                    }
                    // Close button
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: onClose) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 16))
                                    .foregroundStyle(Color.white.opacity(0.60))
                                    .frame(width: 40, height: 40)
                                    .background(Color.black.opacity(0.40))
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.10)))
                            }
                            .padding(24)
                        }
                        Spacer()
                    }
                }
                .aspectRatio(1, contentMode: .fit)
                .clipShape(UnevenRoundedRectangle(topLeadingRadius: 32, topTrailingRadius: 32))

                // Info
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "lock")
                            .font(.system(size: 11))
                            .foregroundStyle(loading ? Color.white.opacity(0.40) : (error ? Color.anomalyRed : Color.emerald))
                        Text(loading ? "正在解密..." : (error ? "解密失败" : "已通过加密存储"))
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(loading ? Color.white.opacity(0.40) : (error ? Color.anomalyRed : Color.emerald))
                            .kerning(3)
                    }
                    Divider().background(Color.white.opacity(0.08))
                    Text(evidence.timestampString)
                        .font(.mono(11))
                        .foregroundStyle(Color.white.opacity(0.40))
                        .kerning(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(28)
            }
            .background(Color.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 32))
            .overlay(RoundedRectangle(cornerRadius: 32).stroke(Color.white.opacity(0.10)))
            .padding(24)
        }
        .task { await loadContent() }
    }

    @ViewBuilder
    private var imagePreview: some View {
        if loading {
            Color.white.opacity(0.05)
                .overlay(ProgressView().tint(.white))
        } else if error || imageData == nil {
            Color.white.opacity(0.05)
                .overlay(
                    VStack(spacing: 8) {
                        Image(systemName: "exclamationmark.circle").font(.system(size: 32)).foregroundStyle(Color.anomalyRed.opacity(0.50))
                        Text("无法解密文件").font(.system(size: 13)).foregroundStyle(Color.white.opacity(0.40))
                    }
                )
        } else if let data = imageData, let img = UIImage(data: data) {
            Image(uiImage: img).resizable().scaledToFill()
        }
    }

    @ViewBuilder
    private var audioPreview: some View {
        Color(hex: 0x0A1A12)
            .overlay(
                VStack(spacing: 24) {
                    Image(systemName: "mic")
                        .font(.system(size: 36))
                        .foregroundStyle(Color.emerald)
                        .frame(width: 80, height: 80)
                        .background(Color(hex: 0x0D2B1A))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.emerald.opacity(0.40), lineWidth: 1.5))

                    if loading {
                        ProgressView().tint(Color.emerald)
                    } else if !error, audioURL != nil {
                        Button {
                            isPlaying ? player?.pause() : player?.play()
                            isPlaying.toggle()
                        } label: {
                            Text(isPlaying ? "暂停" : "播放录音")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Color.black)
                                .frame(width: 200, height: 52)
                                .background(Color.white)
                                .clipShape(Capsule())
                        }
                    }
                }
            )
    }

    private func loadContent() async {
        // Try local first
        if let url = evidence.localURL {
            if evidence.type == .image, let data = try? Data(contentsOf: url) {
                imageData = data; loading = false; return
            } else if evidence.type == .audio {
                audioURL  = url; setupPlayer(url: url); loading = false; return
            }
        }
        // Download from Supabase
        guard let key = evidence.fileKey else { loading = false; error = true; return }
        guard let data = await EvidenceService.downloadEvidence(fileKey: key, passphrase: passphrase) else {
            loading = false; error = true; return
        }
        if evidence.type == .image {
            imageData = data; loading = false
        } else {
            let tmpURL = FileManager.default.temporaryDirectory
                .appendingPathComponent("preview_\(key.hashCode).m4a")
            try? data.write(to: tmpURL)
            audioURL = tmpURL; setupPlayer(url: tmpURL); loading = false
        }
    }

    private func setupPlayer(url: URL) {
        player = AVAudioPlayerWrapper(url: url)
    }
}

// Simple AVAudioPlayer wrapper
class AVAudioPlayerWrapper {
    private var player: AVAudioPlayer?
    init(url: URL) { player = try? AVAudioPlayer(contentsOf: url) }
    func play()  { player?.play()  }
    func pause() { player?.pause() }
}

extension String {
    var hashCode: Int { abs(hashValue) }
}
