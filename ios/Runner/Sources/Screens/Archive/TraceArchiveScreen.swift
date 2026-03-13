import SwiftUI
import PhotosUI

struct TraceArchiveScreen: View {
    let onBack: () -> Void

    @Environment(InvestigationStore.self) private var store
    @State private var selectedGroup    : [EvidenceItem] = []
    @State private var selectedIndex    : Int = 0
    @State private var hasChanges       = false
    @State private var isSaving         = false

    @State private var captureItemId    : String?
    @State private var showCamera       = false
    @State private var showPhotoPicker  = false
    @State private var selectedPhotos   : [PhotosPickerItem] = []
    @State private var isRecording      = false
    @State private var uploadingItemId  : String?

    private var record    : InvestigationRecord? { store.record }
    private var passphrase: String               { store.passphrase ?? "" }

    private var groupedSections: [(category: String, questions: [QuestionItem])] {
        var seen: [String] = []
        for q in kPartnerQuestions { if !seen.contains(q.category) { seen.append(q.category) } }
        return seen.map { cat in (cat, kPartnerQuestions.filter { $0.category == cat }) }
    }

    private var totalCount  : Int { kPartnerQuestions.count }
    private var flagCount   : Int { record?.results.values.filter { $0 == "flagged" }.count ?? 0 }
    private var checkedCount: Int { record?.results.count ?? 0 }
    private var evCount     : Int { record?.evidences.values.reduce(0) { $0 + $1.count } ?? 0 }
    private var riskScore   : Int {
        guard totalCount > 0 else { return 0 }
        return Int(Double(flagCount) / Double(totalCount) * 100)
    }
    private var riskLabel: String {
        switch riskScore {
        case 0..<20:  return "暂无明显异常"
        case 20..<45: return "存在异常观察"
        case 45..<70: return "异常信号较强"
        default:      return "高度疑似出轨"
        }
    }
    // Gold/amber accent — matches Figma design
    private let accent = Color(hex: 0xE8A830)

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color(hex: 0x0C0C0C).ignoresSafeArea()

                ScrollView {
                    LazyVStack(spacing: 0) {
                        heroCard
                            .padding(.horizontal, 16)
                            .padding(.top, 12)
                            .padding(.bottom, 20)

                        listSection
                            .padding(.bottom, 100)
                    }
                }

                saveButton
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
                    Text("观察档案")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.60))
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
            .fullScreenCover(isPresented: $showCamera) {
                CameraView { url in
                    showCamera = false
                    if let url, let itemId = captureItemId {
                        Task { await uploadFile(url: url, itemId: itemId) }
                    }
                }
                .ignoresSafeArea()
            }
            .photosPicker(isPresented: $showPhotoPicker, selection: $selectedPhotos, maxSelectionCount: 10, matching: .images)
            .onChange(of: selectedPhotos) { _, items in
                guard !items.isEmpty, let itemId = captureItemId else { return }
                Task { await handlePhotoPickerItems(items, itemId: itemId) }
            }
        }
        .overlay {
            if !selectedGroup.isEmpty {
                EvidencePreviewOverlay(items: selectedGroup, initialIndex: selectedIndex, passphrase: passphrase) {
                    selectedGroup = []
                }
                .ignoresSafeArea()
            }
        }
    }

    // MARK: - Hero card

    private var heroCard: some View {
        ZStack {
            // Background: dark with warm radial glow top-center
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(hex: 0x1A1008))

            // Radial warm glow
            GeometryReader { geo in
                RadialGradient(
                    colors: [
                        Color(hex: 0xC05010).opacity(0.75),
                        Color(hex: 0x8B3010).opacity(0.45),
                        Color.clear
                    ],
                    center: UnitPoint(x: 0.5, y: 0),
                    startRadius: 0,
                    endRadius: geo.size.width * 0.80
                )
                .clipShape(RoundedRectangle(cornerRadius: 24))
            }

            VStack(spacing: 0) {
                // Risk label
                Text(riskLabel)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.white.opacity(0.70))
                    .padding(.top, 28)
                    .padding(.bottom, 12)

                // Big score number
                HStack(alignment: .top, spacing: 0) {
                    Text("\(riskScore)")
                        .font(.system(size: 88, weight: .semibold, design: .rounded))
                        .foregroundStyle(accent)
                        .lineLimit(1)
                    Text("%")
                        .font(.system(size: 32, weight: .regular))
                        .foregroundStyle(Color.white.opacity(0.70))
                        .padding(.top, 18)
                        .padding(.leading, 4)
                }
                .padding(.bottom, 20)

                // Progress bar with dot indicator
                GeometryReader { geo in
                    let progress = CGFloat(riskScore) / 100.0
                    let dotX = geo.size.width * progress

                    ZStack(alignment: .leading) {
                        // Track
                        Capsule()
                            .fill(Color.white.opacity(0.15))
                            .frame(height: 3)

                        // Fill
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.40), accent],
                                    startPoint: .leading, endPoint: .trailing
                                )
                            )
                            .frame(width: dotX, height: 3)

                        // Dot indicator
                        Circle()
                            .fill(accent)
                            .frame(width: 14, height: 14)
                            .shadow(color: accent.opacity(0.60), radius: 6)
                            .offset(x: max(0, dotX - 7))
                    }
                }
                .frame(height: 14)
                .padding(.horizontal, 20)
                .padding(.bottom, 24)

                // Stats row
                HStack(spacing: 0) {
                    statCell(value: "\(flagCount)", label: "异常项",
                             color: flagCount > 0 ? Color.white : Color.white.opacity(0.40))
                    Rectangle().fill(Color.white.opacity(0.10)).frame(width: 1, height: 36)
                    statCell(value: "\(checkedCount)", label: "已记录", color: Color.white)
                    Rectangle().fill(Color.white.opacity(0.10)).frame(width: 1, height: 36)
                    statCell(value: "\(evCount)", label: "证据文件",
                             color: evCount > 0 ? Color.white : Color.white.opacity(0.40))
                }
                .padding(.bottom, 24)
            }
        }
        .frame(minHeight: 300)
    }

    private func statCell(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 5) {
            Text(value)
                .font(.system(size: 32, weight: .light, design: .rounded))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(Color.white.opacity(0.35))
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - List section

    private var listSection: some View {
        VStack(spacing: 0) {
            ForEach(groupedSections, id: \.category) { section in
                ForEach(section.questions) { question in
                    let qid  = "\(question.id)"
                    let resp = buildResponse(for: question)
                    ArchiveRecordItem(
                        question:        question,
                        response:        resp,
                        passphrase:      passphrase,
                        uploadingItemId: uploadingItemId,
                        isRecording:     isRecording && captureItemId == qid,
                        accent:          accent,
                        onTapEvidence:   { ev, group in selectedGroup = group; selectedIndex = group.firstIndex(where: { $0.id == ev.id }) ?? 0 },
                        onToggleResult:  { toggleResult(itemId: qid) },
                        onCamera:        { captureItemId = qid; DispatchQueue.main.async { showCamera = true } },
                        onPhotoPicker:   { captureItemId = qid; DispatchQueue.main.async { showPhotoPicker = true } },
                        onAudio:         { Task { await handleAudio(itemId: qid) } }
                    )
                }
            }
        }
        .background(Color(hex: 0x111111))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal, 16)
    }

    // MARK: - Save button

    @ViewBuilder
    private var saveButton: some View {
        if hasChanges || isSaving {
            Button {
                Task {
                    isSaving = true
                    await store.save()
                    isSaving = false
                    withAnimation { hasChanges = false }
                }
            } label: {
                HStack(spacing: 8) {
                    if isSaving {
                        ProgressView().tint(.black)
                    } else {
                        Text("保存更新")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.black)
                        Image(systemName: "arrow.right")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color.black.opacity(0.60))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(accent)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .disabled(isSaving)
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
            .background(
                LinearGradient(
                    colors: [Color(hex: 0x0C0C0C), Color(hex: 0x0C0C0C).opacity(0)],
                    startPoint: .bottom, endPoint: .top
                )
                .ignoresSafeArea()
            )
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    // MARK: - Mutations

    private func toggleResult(itemId: String) {
        let current = store.record?.results[itemId]
        let next    = current == "flagged" ? "normal" : "flagged"
        store.markResult(itemId: itemId, status: next)
        withAnimation { hasChanges = true }
    }

    private func handleAudio(itemId: String) async {
        if isRecording && captureItemId == itemId {
            isRecording   = false
            captureItemId = nil
            if let url = EvidenceService.stopRecording() {
                await uploadFile(url: url, itemId: itemId)
            }
        } else {
            EvidenceService.cancelRecording()
            captureItemId = itemId
            let ok = await EvidenceService.startRecording()
            if ok { isRecording = true }
        }
    }

    private func handlePhotoPickerItems(_ items: [PhotosPickerItem], itemId: String) async {
        guard !items.isEmpty else { return }
        for item in items {
            guard let data = try? await item.loadTransferable(type: Data.self) else { continue }
            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString + ".jpg")
            try? data.write(to: url)
            await uploadFile(url: url, itemId: itemId)
        }
        selectedPhotos = []
    }

    private func uploadFile(url: URL, itemId: String) async {
        uploadingItemId = itemId
        let result = await EvidenceService.uploadEvidence(url: url, passphrase: passphrase, itemId: itemId)
        if case .success(let key) = result {
            store.addEvidenceKey(itemId: itemId, fileKey: key)
            store.markResult(itemId: itemId, status: "flagged")
            withAnimation { hasChanges = true }
        }
        uploadingItemId = nil
    }

    private func buildResponse(for question: QuestionItem) -> ArchiveResponse? {
        let qid = "\(question.id)"
        guard let status = record?.results[qid] else { return nil }
        let keys  = record?.evidences[qid] ?? []
        let items = keys.map { key in
            EvidenceItem(
                id: key,
                type: key.contains(".m4a") ? .audio : .image,
                title: question.title,
                timestamp: record?.completedAt ?? .now,
                localURL: nil,
                fileKey: key
            )
        }
        return ArchiveResponse(isAnomaly: status == "flagged", evidences: items)
    }
}

// MARK: - Archive response model

struct ArchiveResponse {
    let isAnomaly: Bool
    let evidences: [EvidenceItem]
}

// MARK: - Archive Record Item

struct ArchiveRecordItem: View {
    let question        : QuestionItem
    let response        : ArchiveResponse?
    let passphrase      : String
    let uploadingItemId : String?
    let isRecording     : Bool
    let accent          : Color
    let onTapEvidence   : (EvidenceItem, [EvidenceItem]) -> Void
    let onToggleResult  : () -> Void
    let onCamera        : () -> Void
    let onPhotoPicker   : () -> Void
    let onAudio         : () -> Void

    @State private var expanded = false

    private var itemId     : String { "\(question.id)" }
    private var isAnomaly  : Bool   { response?.isAnomaly == true }
    private var isChecked  : Bool   { response != nil }
    private var hasEvidence: Bool   { !(response?.evidences.isEmpty ?? true) }
    private var isUploading: Bool   { uploadingItemId == itemId }

    var body: some View {
        VStack(spacing: 0) {
            Button { withAnimation(.spring(duration: 0.22)) { expanded.toggle() } } label: {
                HStack(alignment: .top, spacing: 14) {
                    // Status dot
                    Circle()
                        .fill(isAnomaly ? accent : Color.white.opacity(0.18))
                        .frame(width: 8, height: 8)
                        .padding(.top, 6)

                    VStack(alignment: .leading, spacing: 8) {
                        Text(question.title)
                            .font(.system(size: 16, weight: isAnomaly ? .medium : .regular))
                            .foregroundStyle(isAnomaly ? Color.white : Color.white.opacity(0.35))
                            .lineSpacing(2)
                            .multilineTextAlignment(.leading)

                        if !expanded && (isAnomaly || hasEvidence) {
                            HStack(spacing: 10) {
                                if isAnomaly {
                                    Text("异常")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundStyle(accent)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .overlay(
                                            Capsule().stroke(accent.opacity(0.60), lineWidth: 1)
                                        )
                                }
                                if hasEvidence {
                                    HStack(spacing: 4) {
                                        Image(systemName: "paperclip")
                                            .font(.system(size: 11))
                                        Text("\(response!.evidences.count)")
                                            .font(.system(size: 12))
                                    }
                                    .foregroundStyle(accent.opacity(0.80))
                                }
                            }
                        }
                    }

                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 18)
            }
            .buttonStyle(.plain)

            if expanded {
                expandedDetail
                    .transition(.opacity.combined(with: .move(edge: .top)))

                // Thick closing line when expanded
                Rectangle()
                    .fill(isAnomaly ? accent.opacity(0.50) : Color.white.opacity(0.25))
                    .frame(height: 2)
            } else {
                // Normal thin separator
                Rectangle()
                    .fill(Color.white.opacity(0.07))
                    .frame(height: 1)
                    .padding(.leading, 42)
            }
        }
    }

    @ViewBuilder
    private var expandedDetail: some View {
        VStack(alignment: .leading, spacing: 14) {
            Rectangle()
                .fill(Color.white.opacity(0.06))
                .frame(height: 1)

            // Observation points
            VStack(alignment: .leading, spacing: 8) {
                ForEach(question.points, id: \.self) { point in
                    HStack(alignment: .top, spacing: 10) {
                        Circle()
                            .fill(Color.white.opacity(0.20))
                            .frame(width: 3, height: 3)
                            .padding(.top, 7)
                        Text(point)
                            .font(.system(size: 13))
                            .foregroundStyle(Color.white.opacity(0.45))
                            .lineSpacing(3)
                    }
                }
            }
            .padding(.horizontal, 20)

            // Toggle
            resultToggle
                .padding(.horizontal, 20)

            if isAnomaly {
                evidenceSection
                    .padding(.horizontal, 20)
            }
        }
        .padding(.bottom, 16)
    }

    private var resultToggle: some View {
        HStack(spacing: 2) {
            toggleOption(label: "未见异常", icon: "checkmark.circle",
                         active: !isAnomaly, activeColor: Color(hex: 0x4ADE80)) {
                if isAnomaly { onToggleResult() }
            }
            toggleOption(label: "发现异常", icon: "flag",
                         active: isAnomaly, activeColor: accent) {
                if !isAnomaly { onToggleResult() }
            }
        }
        .padding(3)
        .background(Color.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.08)))
    }

    private func toggleOption(label: String, icon: String, active: Bool, activeColor: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: icon).font(.system(size: 12))
                Text(label).font(.system(size: 13, weight: .medium))
            }
            .foregroundStyle(active ? activeColor : Color.white.opacity(0.25))
            .frame(maxWidth: .infinity)
            .frame(height: 34)
            .background(active ? activeColor.opacity(0.12) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }

    private var evidenceSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("线索存证")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color.white.opacity(0.25))
                    .kerning(1)
                Spacer()
                if isUploading {
                    ProgressView().tint(accent).scaleEffect(0.75)
                } else {
                    HStack(spacing: 8) {
                        uploadBtn("camera.fill", action: onCamera)
                        uploadBtn("photo.on.rectangle", action: onPhotoPicker)
                        RecordingButton(isRecording: isRecording, size: 32, action: onAudio)
                    }
                }
            }

            if hasEvidence, let evs = response?.evidences, !evs.isEmpty {
                FlowLayout(spacing: 6) {
                    ForEach(evs) { ev in
                        ArchiveThumbnail(evidence: ev, passphrase: passphrase) {
                            onTapEvidence(ev, evs)
                        }
                    }
                }
            } else if !isUploading {
                Text("暂无证据，点击右侧按钮上传")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.white.opacity(0.18))
            }
        }
    }

    private func uploadBtn(_ icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundStyle(Color.white.opacity(0.55))
                .frame(width: 32, height: 32)
                .background(Color.white.opacity(0.08))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Archive thumbnail

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
                    Color(hex: 0x0A1208)
                        .overlay(Image(systemName: "mic").font(.system(size: 20))
                            .foregroundStyle(Color(hex: 0x4ADE80)))
                } else if let data = thumbData, let img = UIImage(data: data) {
                    Image(uiImage: img).resizable().scaledToFill()
                } else {
                    Color.white.opacity(0.05)
                        .overlay(Image(systemName: "photo").font(.system(size: 20))
                            .foregroundStyle(Color.white.opacity(0.20)))
                }
            }
            .frame(width: 64, height: 64)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12)
                .stroke(isAudio ? Color(hex: 0x4ADE80).opacity(0.40) : Color.white.opacity(0.15)))
        }
        .task {
            guard !isAudio, thumbData == nil else { return }
            thumbData = await EvidenceService.downloadEvidence(fileKey: evidence.fileKey ?? "", passphrase: passphrase)
        }
    }
}

// MARK: - Flow layout

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
