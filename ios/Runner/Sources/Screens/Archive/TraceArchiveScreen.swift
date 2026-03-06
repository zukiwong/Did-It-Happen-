import SwiftUI

struct TraceArchiveScreen: View {
    let onBack: () -> Void

    @Environment(InvestigationStore.self) private var store
    @State private var searchQuery      = ""
    @State private var selectedCategory = "全部"
    @State private var selectedEvidence : EvidenceItem?

    private var record: InvestigationRecord? { store.record }
    private var passphrase: String { store.passphrase ?? "" }

    private var categories: [String] {
        ["全部"] + Array(Set(kPartnerQuestions.map(\.category))).sorted()
    }

    private var filteredQuestions: [QuestionItem] {
        kPartnerQuestions.filter { q in
            let matchCat    = selectedCategory == "全部" || q.category == selectedCategory
            let matchSearch = searchQuery.isEmpty || q.title.localizedCaseInsensitiveContains(searchQuery)
            return matchCat && matchSearch
        }
    }

    var body: some View {
        ZStack {
            Color(hex: 0x050505).ignoresSafeArea()
            archiveBackground

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    archiveHeader
                        .padding(.top, safeAreaTop + 12)
                        .padding(.bottom, 40)

                    filterBar
                        .padding(.bottom, 32)

                    // Question items
                    ForEach(filteredQuestions) { question in
                        let resp = buildResponse(for: question)
                        ArchiveRecordItem(
                            question:   question,
                            response:   resp,
                            passphrase: passphrase,
                            onTapEvidence: { ev in selectedEvidence = ev }
                        )
                        .padding(.bottom, 16)
                    }

                    observationLog
                        .padding(.top, 32)
                        .padding(.bottom, 120)
                }
                .padding(.horizontal, 24)
            }

            // Evidence overlay
            if let ev = selectedEvidence {
                EvidencePreviewOverlay(evidence: ev, passphrase: passphrase) {
                    selectedEvidence = nil
                }
            }

            // Save button
            VStack {
                Spacer()
                saveButton
            }
        }
        .ignoresSafeArea()
    }

    // MARK: - Header

    private var archiveHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.white.opacity(0.60))
            }
            .padding(.bottom, 8)

            HStack(spacing: 12) {
                Image(systemName: "clock").font(.system(size: 18)).foregroundStyle(Color.white.opacity(0.40))
                Text("历史观察档案")
                    .font(.system(size: 24, weight: .light))
                    .foregroundStyle(Color.white.opacity(0.90))
            }
            Text("已验证访问")
                .font(.mono(10, weight: .bold))
                .foregroundStyle(Color.white.opacity(0.20))
                .kerning(4)
        }
    }

    // MARK: - Filter bar

    private var filterBar: some View {
        VStack(spacing: 12) {
            // Search
            HStack {
                Image(systemName: "magnifyingglass").foregroundStyle(Color.white.opacity(0.20))
                TextField("检索历史线索...", text: $searchQuery)
                    .foregroundStyle(Color.white)
                    .font(.system(size: 14))
            }
            .padding(.horizontal, 16).padding(.vertical, 14)
            .background(Color.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.10)))

            // Category chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(categories, id: \.self) { cat in
                        Button { selectedCategory = cat } label: {
                            Text(cat)
                                .font(.system(size: 10, weight: .bold))
                                .kerning(3)
                                .foregroundStyle(selectedCategory == cat ? Color.black : Color.white.opacity(0.40))
                                .padding(.horizontal, 16).padding(.vertical, 8)
                                .background(selectedCategory == cat ? Color.white : Color.white.opacity(0.05))
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(selectedCategory == cat ? Color.clear : Color.white.opacity(0.08)))
                        }
                    }
                }
            }
        }
    }

    // MARK: - Observation log

    private var observationLog: some View {
        VStack(alignment: .leading, spacing: 24) {
            Divider().background(Color.white.opacity(0.08))

            Label("观察日志记录", systemImage: "clock")
                .font(.system(size: 18, weight: .light))
                .foregroundStyle(Color.white.opacity(0.80))

            if let r = record {
                let fmt = DateFormatter(); fmt.dateFormat = "yyyy.MM.dd HH:mm"
                let flagCount = r.results.values.filter { $0 == "flagged" }.count
                let evCount   = r.evidences.values.reduce(0) { $0 + $1.count }

                VStack(alignment: .leading, spacing: 32) {
                    logEntry(date: fmt.string(from: r.completedAt), title: "开始观察记录", isLatest: false)
                    if flagCount > 0 {
                        logEntry(date: fmt.string(from: r.completedAt), title: "发现 \(flagCount) 项异常", isLatest: false)
                    }
                    logEntry(
                        date: fmt.string(from: r.completedAt),
                        title: evCount > 0 ? "已上传 \(evCount) 份加密文件" : "档案已加密锁定",
                        isLatest: true
                    )
                }
                .padding(.leading, 8)
            }
        }
    }

    @ViewBuilder
    private func logEntry(date: String, title: String, isLatest: Bool) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Circle()
                .fill(isLatest ? Color.emerald : Color.white.opacity(0.10))
                .frame(width: 14, height: 14)
                .shadow(color: isLatest ? Color.emerald.opacity(0.5) : .clear, radius: 8)
                .padding(.top, 2)
            VStack(alignment: .leading, spacing: 4) {
                Text(date).font(.mono(10)).foregroundStyle(Color.white.opacity(0.20)).kerning(2)
                Text(title)
                    .font(.system(size: 13, weight: isLatest ? .medium : .light))
                    .foregroundStyle(isLatest ? Color.emerald.opacity(0.90) : Color.white.opacity(0.50))
            }
        }
    }

    // MARK: - Save button

    private var saveButton: some View {
        Button {
            Task { await store.save(); onBack() }
        } label: {
            HStack {
                Text("更新观察结果")
                    .font(.system(size: 11, weight: .black))
                    .kerning(6)
                    .foregroundStyle(Color.black)
                Image(systemName: "arrow.right")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.black)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 64)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 24))
        }
        .padding(.horizontal, 24)
        .padding(.bottom, safeAreaBottom + 24)
        .background(
            LinearGradient(colors: [.black, .clear], startPoint: .bottom, endPoint: .top)
                .ignoresSafeArea()
        )
    }

    // MARK: - Background

    private var archiveBackground: some View {
        GeometryReader { geo in
            RadialGradient(
                colors: [Color(hex: 0x172554).opacity(0.15), .clear],
                center: UnitPoint(x: 0.9, y: 0.1),
                startRadius: 0,
                endRadius: geo.size.width * 1.5
            )
            .ignoresSafeArea()
        }
    }

    // MARK: - Build response

    private func buildResponse(for question: QuestionItem) -> ArchiveResponse? {
        let qid    = "\(question.id)"
        let status = record?.results[qid]
        guard status == "flagged" else { return nil }
        let keys   = record?.evidences[qid] ?? []
        let items  = keys.map { key in
            EvidenceItem(
                id: key,
                type: key.contains(".m4a") ? .audio : .image,
                title: question.title,
                timestamp: record?.completedAt ?? .now,
                localURL: nil,
                fileKey: key
            )
        }
        return ArchiveResponse(isAnomaly: true, evidences: items)
    }

    private var safeAreaTop   : CGFloat { (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.safeAreaInsets.top    ?? 44 }
    private var safeAreaBottom: CGFloat { (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.safeAreaInsets.bottom ?? 34 }
}

// MARK: - Archive response model

struct ArchiveResponse {
    let isAnomaly: Bool
    let evidences: [EvidenceItem]
}

// MARK: - Archive Record Item

struct ArchiveRecordItem: View {
    let question      : QuestionItem
    let response      : ArchiveResponse?
    let passphrase    : String
    let onTapEvidence : (EvidenceItem) -> Void

    @State private var expanded = false

    private var isAnomaly  : Bool { response?.isAnomaly == true }
    private var hasEvidence: Bool { !(response?.evidences.isEmpty ?? true) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header row — tap to expand
            Button { withAnimation(.spring(duration: 0.25)) { expanded.toggle() } } label: {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 8) {
                            Text("#\(String(format: "%02d", question.id))")
                                .font(.mono(8)).foregroundStyle(Color.white.opacity(0.20)).kerning(4)
                            Text(question.category)
                                .font(.system(size: 8, weight: .bold)).foregroundStyle(Color.white.opacity(0.30)).kerning(4)
                                .lineLimit(1)
                        }
                        Text(question.title)
                            .font(.system(size: 14, weight: .light))
                            .foregroundStyle(expanded ? Color.white.opacity(0.90) : Color.white.opacity(0.70))
                            .lineSpacing(4)
                            .multilineTextAlignment(.leading)

                        if !expanded && (isAnomaly || hasEvidence) {
                            HStack(spacing: 8) {
                                if isAnomaly {
                                    Circle().fill(Color.anomalyRed).frame(width: 6, height: 6)
                                }
                                if hasEvidence {
                                    Text("[\(response!.evidences.count) 证据]")
                                        .font(.mono(9)).foregroundStyle(Color.white.opacity(0.30))
                                }
                            }
                        }
                    }
                    Spacer()
                    VStack(spacing: 4) {
                        if isAnomaly && !expanded {
                            Image(systemName: "exclamationmark.circle")
                                .font(.system(size: 14)).foregroundStyle(Color.anomalyRed.opacity(0.60))
                        }
                        Image(systemName: "chevron.down")
                            .font(.system(size: 11))
                            .foregroundStyle(Color.white.opacity(0.20))
                            .rotationEffect(.degrees(expanded ? 180 : 0))
                            .padding(4)
                            .background(Color.white.opacity(0.05))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                }
                .padding(20)
            }
            .buttonStyle(.plain)

            // Expanded content
            if expanded {
                expandedContent
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(expanded ? Color.white.opacity(0.08) : Color.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(expanded ? Color.white.opacity(0.15) : Color.white.opacity(0.07)))
        .shadow(color: expanded ? Color.black.opacity(0.40) : .clear, radius: 20, y: 8)
    }

    @ViewBuilder
    private var expandedContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Divider().background(Color.white.opacity(0.08))

            // Points
            ForEach(question.points, id: \.self) { point in
                HStack(alignment: .top, spacing: 12) {
                    Circle().fill(Color.white.opacity(0.10)).frame(width: 4, height: 4).padding(.top, 6)
                    Text(point)
                        .font(.system(size: 12, weight: .light))
                        .foregroundStyle(Color.white.opacity(0.50))
                        .lineSpacing(3)
                }
                .padding(12)
                .background(Color.white.opacity(0.03))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            // Status badge
            HStack {
                Text("记录定性").font(.mono(9, weight: .bold)).foregroundStyle(Color.white.opacity(0.20)).kerning(4)
                Spacer()
                Label(isAnomaly ? "标记为异常" : "标记为正常",
                      systemImage: isAnomaly ? "flag" : "checkmark.circle")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(isAnomaly ? Color(hex: 0xF87171) : Color.white.opacity(0.30))
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(isAnomaly ? Color.anomalyRed.opacity(0.10) : Color.white.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(isAnomaly ? Color.anomalyRed.opacity(0.30) : Color.white.opacity(0.10)))
            }

            // Evidence thumbnails
            if isAnomaly || hasEvidence, let evs = response?.evidences, !evs.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("线索存证").font(.mono(9, weight: .bold)).foregroundStyle(Color.white.opacity(0.20)).kerning(4)
                    FlowLayout(spacing: 8) {
                        ForEach(evs) { ev in
                            ArchiveThumbnail(evidence: ev, passphrase: passphrase) {
                                onTapEvidence(ev)
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
    }
}

// MARK: - Archive thumbnail (loads image from Supabase)

struct ArchiveThumbnail: View {
    let evidence  : EvidenceItem
    let passphrase: String
    let onTap     : () -> Void

    @State private var thumbData: Data?

    private var isAudio: Bool { evidence.type == .audio }

    var body: some View {
        Button(action: onTap) {
            ZStack {
                if isAudio {
                    Color(hex: 0x0A1A12)
                        .overlay(Image(systemName: "mic").font(.system(size: 20)).foregroundStyle(Color.emerald))
                } else if let data = thumbData, let img = UIImage(data: data) {
                    Image(uiImage: img).resizable().scaledToFill()
                } else {
                    Color.white.opacity(0.05)
                        .overlay(Image(systemName: "photo").font(.system(size: 20)).foregroundStyle(Color.white.opacity(0.20)))
                }
            }
            .frame(width: 64, height: 64)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isAudio ? Color.emerald.opacity(0.40) : Color.white.opacity(0.15))
            )
        }
        .task {
            guard !isAudio, thumbData == nil else { return }
            thumbData = await EvidenceService.downloadEvidence(fileKey: evidence.fileKey ?? "", passphrase: passphrase)
        }
    }
}

// MARK: - Simple flow layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 300
        var x: CGFloat = 0; var y: CGFloat = 0; var rowH: CGFloat = 0
        for sv in subviews {
            let s = sv.sizeThatFits(.unspecified)
            if x + s.width > width && x > 0 { y += rowH + spacing; x = 0; rowH = 0 }
            x += s.width + spacing; rowH = max(rowH, s.height)
        }
        return CGSize(width: width, height: y + rowH)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX; var y = bounds.minY; var rowH: CGFloat = 0
        for sv in subviews {
            let s = sv.sizeThatFits(.unspecified)
            if x + s.width > bounds.maxX && x > bounds.minX { y += rowH + spacing; x = bounds.minX; rowH = 0 }
            sv.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
            x += s.width + spacing; rowH = max(rowH, s.height)
        }
    }
}
