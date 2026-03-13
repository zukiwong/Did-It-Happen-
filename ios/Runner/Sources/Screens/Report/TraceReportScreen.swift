import SwiftUI
import AVFoundation
import StoreKit

struct TraceReportScreen: View {
    let onBack: () -> Void

    @Environment(InvestigationStore.self) private var store
    @State private var passphrase    = ""
    @State private var isSaved       = false
    @State private var saveError     : String?
    @State private var isLocking     = false
    @State private var selectedGroup: [EvidenceItem] = []
    @State private var selectedIndex: Int = 0

    // Derived
    private var record  : InvestigationRecord? { store.record }
    private var results : [String: String]     { record?.results ?? [:] }
    private var flaggedCount: Int { results.values.filter { $0 == "flagged" }.count }

    @Environment(\.requestReview) private var requestReview

    var body: some View {
        NavigationStack {
          ZStack {
            Color(hex: 0x0C0C0C).ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    heroCard
                        .padding(.top, 16)

                    keySection
                        .padding(.bottom, 120)
                }
                .padding(.horizontal, 16)
            }

            if !selectedGroup.isEmpty {
                EvidencePreviewOverlay(
                    items: selectedGroup,
                    initialIndex: selectedIndex,
                    passphrase: store.passphrase ?? ""
                ) {
                    selectedGroup = []
                }
            }
          }
          .navigationBarTitleDisplayMode(.inline)
          .toolbar {
              ToolbarItem(placement: .navigationBarLeading) {
                  Button(action: onBack) {
                      Image(systemName: "chevron.left")
                          .font(.system(size: 17, weight: .medium))
                          .foregroundStyle(Color.white.opacity(0.60))
                  }
              }
              ToolbarItem(placement: .principal) {
                  Text("观察报告")
                      .font(.system(size: 15, weight: .semibold))
                      .foregroundStyle(Color.white.opacity(0.60))
              }
          }
          .toolbarColorScheme(.dark, for: .navigationBar)
          .onAppear {
              // Request review after user completes a checklist
              DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                  requestReview()
              }
          }
        }
    }

    // MARK: - Hero card (number + evidence list in one gradient card)

    private var heroCard: some View {
        let total = kPartnerQuestions.count
        let scoreColor: Color = flaggedCount == 0 ? Color.emerald
                              : flaggedCount * 3 <= total ? Color(hex: 0xFBBF24)
                              : Color.anomalyRed
        let statusLabel: String = flaggedCount == 0 ? "未发现异常"
                                : flaggedCount * 3 <= total ? "存在异常" : "异常较多"
        let allEvidence = buildEvidenceItems()
        var seen: [String: Int] = [:]
        var groups: [[EvidenceItem]] = []
        for ev in allEvidence {
            if let idx = seen[ev.title] { groups[idx].append(ev) }
            else { seen[ev.title] = groups.count; groups.append([ev]) }
        }

        return ZStack {
            RoundedRectangle(cornerRadius: 24).fill(Color(hex: 0x1A1008))

            GeometryReader { geo in
                RadialGradient(
                    colors: [
                        Color(hex: 0xC05010).opacity(0.75),
                        Color(hex: 0x8B3010).opacity(0.45),
                        .clear
                    ],
                    center: UnitPoint(x: 0.5, y: 0),
                    startRadius: 0,
                    endRadius: geo.size.width * 0.80
                )
                .clipShape(RoundedRectangle(cornerRadius: 24))
            }

            VStack(alignment: .leading, spacing: 0) {
                // Status label
                Text(statusLabel)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.white.opacity(0.70))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 28)
                    .padding(.bottom, 8)

                // Big number
                HStack(alignment: .top, spacing: 0) {
                    Text("\(flaggedCount)")
                        .font(.system(size: 88, weight: .semibold, design: .rounded))
                        .foregroundStyle(scoreColor)
                    Text(" / \(total)")
                        .font(.system(size: 32, weight: .regular))
                        .foregroundStyle(Color.white.opacity(0.70))
                        .padding(.top, 18)
                        .padding(.leading, 4)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 28)

                // Divider into evidence area
                Divider()
                    .background(Color.white.opacity(0.10))

                // Evidence header
                HStack {
                    Label("关键证据库", systemImage: "folder")
                        .font(.system(size: 15, weight: .light))
                        .foregroundStyle(Color.white.opacity(0.60))
                    Spacer()
                    if !allEvidence.isEmpty {
                        Text("共 \(allEvidence.count) 项")
                            .font(.mono(11))
                            .foregroundStyle(Color.white.opacity(0.35))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)

                // Evidence rows or empty state
                if groups.isEmpty {
                    HStack {
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: "folder.badge.plus")
                                .font(.system(size: 24))
                                .foregroundStyle(Color.white.opacity(0.20))
                            Text("暂无证据文件")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.white.opacity(0.25))
                        }
                        .padding(.vertical, 24)
                        Spacer()
                    }
                } else {
                    VStack(spacing: 0) {
                        ForEach(Array(groups.enumerated()), id: \.offset) { idx, group in
                            EvidenceRow(group: group) {
                                selectedGroup = group
                                selectedIndex = 0
                            }
                            if idx < groups.count - 1 {
                                Divider()
                                    .background(Color.white.opacity(0.06))
                                    .padding(.horizontal, 20)
                            }
                        }
                    }
                }

                Spacer().frame(height: 8)
            }
        }
    }

    // MARK: - Timeline

    private var timelineSection: some View {
        let entries = buildTimelineEntries()
        return VStack(alignment: .leading, spacing: 0) {
            // Header outside the box
            Label("观察日志记录", systemImage: "clock")
                .font(.system(size: 15, weight: .light))
                .foregroundStyle(Color.white.opacity(0.50))
                .padding(.bottom, 10)

            // Entries inside the box
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(entries.enumerated()), id: \.offset) { idx, entry in
                    HStack(alignment: .top, spacing: 16) {
                        Circle()
                            .fill(entry.isLatest ? Color.emerald : Color.white.opacity(0.15))
                            .frame(width: 10, height: 10)
                            .shadow(color: entry.isLatest ? Color.emerald.opacity(0.5) : .clear, radius: 6)
                            .padding(.top, 4)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.date)
                                .font(.mono(12))
                                .foregroundStyle(Color.white.opacity(0.30))
                            Text(entry.title)
                                .font(.system(size: 15, weight: entry.isLatest ? .medium : .regular))
                                .foregroundStyle(entry.isLatest ? Color.emerald.opacity(0.90) : Color.white.opacity(0.70))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)

                    if idx < entries.count - 1 {
                        Divider()
                            .background(Color.white.opacity(0.06))
                            .padding(.horizontal, 20)
                    }
                }
            }
            .background(Color(hex: 0x111111))
            .clipShape(RoundedRectangle(cornerRadius: 20))
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
                        .font(.system(size: 13))
                        .foregroundStyle(Color.white.opacity(0.30))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            } else {
                Label("设置档案密钥", systemImage: "lock")
                    .font(.system(size: 18, weight: .light))
                    .foregroundStyle(Color.white.opacity(0.80))

                Text("设置一个只有你知道的密钥，用于加密和解密你的观察档案。可以是任意文字或数字组合。")
                    .font(.system(size: 17, weight: .light))
                    .foregroundStyle(Color.white.opacity(0.40))
                    .lineSpacing(5)

                // Input field
                TextField("输入密钥...", text: $passphrase)
                    .foregroundStyle(Color.white)
                    .padding(16)
                    .background(Color.white.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.15)))

                if let err = saveError {
                    Text(err)
                        .font(.system(size: 13))
                        .foregroundStyle(Color.anomalyRed.opacity(0.80))
                }

                // Save button
                Button {
                    Task { await handleSave() }
                } label: {
                    HStack {
                        if isLocking { ProgressView().tint(.black) }
                        Text(isLocking ? "加密中..." : "加密并保存")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(Color.black)
                        Image(systemName: "lock.fill")
                            .font(.system(size: 15))
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

        // Upload pending files (respect total limit)
        for pending in store.pendingFiles {
            guard !store.isEvidenceFull else { break }
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

// MARK: - Evidence Row

struct EvidenceRow: View {
    let group : [EvidenceItem]
    let onTap : () -> Void

    private var representative: EvidenceItem { group[0] }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                Circle()
                    .fill(Color(hex: 0xE8A830))
                    .frame(width: 8, height: 8)
                Text(representative.title)
                    .font(.system(size: 15, weight: .light))
                    .foregroundStyle(Color.white.opacity(0.80))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                Spacer()
                if group.count > 1 {
                    Text("\(group.count)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.white.opacity(0.60))
                        .frame(minWidth: 20, minHeight: 20)
                        .background(Color.white.opacity(0.12))
                        .clipShape(Capsule())
                }
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.white.opacity(0.20))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }
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
                        .font(.system(size: 13, weight: .medium))
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
    let items       : [EvidenceItem]
    let initialIndex: Int
    let passphrase  : String
    let onClose     : () -> Void

    @State private var currentIndex: Int = 0

    var body: some View {
        ZStack {
            // Full-screen swipeable pages
            TabView(selection: $currentIndex) {
                ForEach(Array(items.enumerated()), id: \.element.id) { idx, ev in
                    EvidenceSingleCard(evidence: ev, passphrase: passphrase)
                        .tag(idx)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()

            // Close button — top right, system style
            VStack {
                HStack {
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundStyle(Color.white.opacity(0.60))
                            .symbolRenderingMode(.hierarchical)
                    }
                    .padding(.trailing, 20)
                }
                .padding(.top, 60)
                Spacer()
            }

            // Page dots — bottom center
            if items.count > 1 {
                VStack {
                    Spacer()
                    HStack(spacing: 6) {
                        ForEach(0..<items.count, id: \.self) { i in
                            Capsule()
                                .fill(i == currentIndex ? Color.white.opacity(0.85) : Color.white.opacity(0.30))
                                .frame(width: i == currentIndex ? 16 : 6, height: 6)
                                .animation(.easeOut(duration: 0.2), value: currentIndex)
                        }
                    }
                    .padding(.bottom, 48)
                }
            }
        }
        .onAppear { currentIndex = initialIndex }
    }
}

// Single full-screen page
struct EvidenceSingleCard: View {
    let evidence  : EvidenceItem
    let passphrase: String

    @State private var loading   = true
    @State private var error     = false
    @State private var imageData : Data?
    @State private var audioURL  : URL?
    @State private var isPlaying = false
    @State private var player    : AVAudioPlayerWrapper?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if evidence.type == .image {
                if loading {
                    ProgressView().tint(.white)
                } else if error || imageData == nil {
                    VStack(spacing: 10) {
                        Image(systemName: "exclamationmark.circle")
                            .font(.system(size: 36))
                            .foregroundStyle(Color.anomalyRed.opacity(0.60))
                        Text("无法解密文件")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.white.opacity(0.40))
                    }
                } else if let data = imageData, let img = UIImage(data: data) {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            } else {
                VStack(spacing: 28) {
                    Image(systemName: "mic")
                        .font(.system(size: 44))
                        .foregroundStyle(Color.emerald)
                        .frame(width: 96, height: 96)
                        .background(Color(hex: 0x0D2B1A))
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .overlay(RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.emerald.opacity(0.40), lineWidth: 1.5))
                    if loading {
                        ProgressView().tint(Color.emerald)
                    } else if !error, audioURL != nil {
                        Button {
                            isPlaying ? player?.pause() : player?.play()
                            isPlaying.toggle()
                        } label: {
                            Text(isPlaying ? "暂停" : "播放录音")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(Color.black)
                                .frame(width: 200, height: 52)
                                .background(Color.white)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
        }
        .task { await loadContent() }
    }

    private func loadContent() async {
        if let url = evidence.localURL {
            if evidence.type == .image, let data = try? Data(contentsOf: url) {
                imageData = data; loading = false; return
            } else if evidence.type == .audio {
                audioURL = url; setupPlayer(url: url); loading = false; return
            }
        }
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

// MARK: - Cinematic visual (animated)

struct ReportCinematicVisual: View {
    @State private var leftY:    CGFloat = -25
    @State private var rightY:   CGFloat =  25
    @State private var pulse:    CGFloat =  1.0
    @State private var pulseOp:  Double  =  0.6
    @State private var lightX:   CGFloat = -200
    @State private var appeared  = false

    var body: some View {
        ZStack {
            Color.clear

            // Connection line
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.white.opacity(0.10))
                        .frame(height: 1)
                        .frame(maxWidth: 200)
                        .frame(maxWidth: .infinity, alignment: .center)

                    // Traveling light
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.clear, Color.white.opacity(0.50), .clear],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .frame(width: 40, height: 1)
                        .offset(x: geo.size.width / 2.0 - 100 + lightX)
                }
                .frame(maxHeight: .infinity)
            }

            // Left sphere
            OrbitingSphere(reverse: false)
                .offset(y: leftY)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 40)

            // Center pulse
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.20), lineWidth: 1)
                    .frame(width: 8, height: 8)
                    .scaleEffect(pulse)
                    .opacity(Double(1 - (pulse - 1) / 2))
                Circle()
                    .fill(Color.white)
                    .frame(width: 8, height: 8)
                    .opacity(pulseOp)
                    .shadow(color: .white, radius: 8)
            }

            // Right sphere
            OrbitingSphere(reverse: true)
                .offset(y: rightY)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 40)
        }
        .clipShape(RoundedRectangle(cornerRadius: 0))
        .onAppear {
            guard !appeared else { return }
            appeared = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 10).repeatForever(autoreverses: true)) {
                    leftY  =  25
                    rightY = -25
                }
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    pulseOp = 1.0
                }
                withAnimation(.easeOut(duration: 2).repeatForever(autoreverses: false)) {
                    pulse = 3.0
                }
                withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                    lightX = 200
                }
            }
        }
    }
}

struct OrbitingSphere: View {
    let reverse: Bool
    // Left sphere: warm orange-red; Right sphere: gold
    private var coreInner: Color { reverse ? Color(hex: 0xFFD36B) : Color(hex: 0xFF8A3D) }
    private var coreOuter: Color { reverse ? Color(hex: 0xFFB800) : Color(hex: 0xFF6FAF) }

    @State private var rotation:    Double   = 0
    @State private var glowScale:   CGFloat  = 1.0
    @State private var glowOpacity: Double   = 0.30
    @State private var haloScale:   CGFloat  = 1.0
    @State private var haloOpacity: Double   = 0.25
    @State private var appeared = false

    var body: some View {
        ZStack {
            // Outermost expanding halo ring — diffuses outward and fades
            Circle()
                .stroke(coreInner.opacity(haloOpacity), lineWidth: 0.8)
                .frame(width: 100, height: 100)
                .scaleEffect(haloScale)
                .blur(radius: 2)

            // Soft radial glow behind the sphere
            Circle()
                .fill(
                    RadialGradient(
                        colors: [coreInner.opacity(glowOpacity), coreOuter.opacity(glowOpacity * 0.4), .clear],
                        center: .center, startRadius: 0, endRadius: 44
                    )
                )
                .frame(width: 88, height: 88)
                .scaleEffect(glowScale)

            // Rotating ring — delicate, slightly tinted
            Circle()
                .stroke(coreOuter.opacity(0.30), lineWidth: 1)
                .frame(width: 72, height: 72)
                .rotationEffect(.degrees(rotation))

            // Inner fill circle — colored glow
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [coreInner.opacity(0.55), coreOuter.opacity(0.20), .clear],
                            center: .center, startRadius: 0, endRadius: 28
                        )
                    )
                    .frame(width: 56, height: 56)
                // Inner ring border
                Circle()
                    .stroke(coreInner.opacity(0.40), lineWidth: 1)
                    .frame(width: 56, height: 56)
                // Center dot
                Circle()
                    .fill(coreInner)
                    .frame(width: 6, height: 6)
                    .shadow(color: coreInner.opacity(0.90), radius: 10)
            }
        }
        .onAppear {
            guard !appeared else { return }
            appeared = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                    rotation = reverse ? -360 : 360
                }
                withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                    glowScale   = 1.25
                    glowOpacity = 0.55
                }
                withAnimation(.easeOut(duration: 2.8).repeatForever(autoreverses: false)) {
                    haloScale   = 1.7
                    haloOpacity = 0.0
                }
            }
        }
    }
}
