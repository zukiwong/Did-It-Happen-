import SwiftUI
import PhotosUI

struct TraceChecklistScreen: View {
    let onBack: () -> Void
    let onNext: () -> Void

    @Environment(InvestigationStore.self) private var store
    @State private var currentIndex = 0
    @State private var anomalyMode  = false
    @State private var direction    = 0    // 1 forward, -1 backward
    @State private var uploading    = false
    @State private var isRecording  = false
    @State private var showCamera   = false
    @State private var showGallery  = false
    @State private var selectedPhotos: [PhotosPickerItem] = []

    private var questions: [QuestionItem] {
        store.record?.entryType == "self" ? kSelfQuestions : kPartnerQuestions
    }
    private var current: QuestionItem { questions[currentIndex] }
    private var isLast : Bool { currentIndex == questions.count - 1 }
    private var itemId : String { "\(current.id)" }
    private var isFlagged: Bool {
        store.record?.results[itemId] == "flagged" ||
        store.pendingFiles.contains { $0.itemId == itemId }
    }
    private var uploadCount: Int {
        let staged   = store.pendingFiles.filter { $0.itemId == itemId }.count
        let uploaded = store.record?.evidences[itemId]?.count ?? 0
        return staged + uploaded
    }

    var body: some View {
        NavigationStack {
          ZStack(alignment: .bottom) {
            Color(hex: 0x0A0A0A).ignoresSafeArea()
            ambientBackground

            questionCard
                .id(currentIndex)
                .transition(cardTransition)
                .animation(.spring(duration: 0.35), value: currentIndex)
                .frame(maxHeight: .infinity)

            bottomBar
          }
          .navigationBarTitleDisplayMode(.inline)
          .toolbar {
              ToolbarItem(placement: .navigationBarLeading) {
                  Button(action: onBack) {
                      Image(systemName: "xmark")
                          .font(.system(size: 15, weight: .medium))
                          .foregroundStyle(Color.white.opacity(0.60))
                          .padding(8)
                          .contentShape(Circle())
                  }
                  .buttonStyle(.plain)
              }
              ToolbarItem(placement: .principal) {
                  ScrubbableProgressView(
                      current: $currentIndex,
                      total:   questions.count,
                      accentColor: Color.anomalyRed
                  )
                  .frame(width: 220)
              }
          }
          .toolbarColorScheme(.dark, for: .navigationBar)
          .photosPicker(isPresented: $showGallery, selection: $selectedPhotos, maxSelectionCount: 10, matching: .images)
          .onChange(of: selectedPhotos) { _, items in
              Task { await handlePhotoPickerItems(items) }
          }
          .fullScreenCover(isPresented: $showCamera) {
              CameraView { url in
                  showCamera = false
                  if let url { Task { await uploadFile(url: url) } }
              }
              .ignoresSafeArea()
          }
        }
    }

    // MARK: - Ambient background

    private var ambientBackground: some View {
        GeometryReader { geo in
            RadialGradient(
                colors: [Color(hex: 0x1D3557).opacity(0.15), .clear],
                center: UnitPoint(x: 0.8, y: 0.1),
                startRadius: 0,
                endRadius: geo.size.width * 0.8
            )
            .ignoresSafeArea()
        }
    }

    // MARK: - Question card

    private var questionCard: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Category + ID
                HStack(spacing: 6) {
                    Text("#\(String(format: "%02d", current.id))")
                        .font(.mono(13))
                        .foregroundStyle(Color.white.opacity(0.30))
                    Text(current.category)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.45))
                }
                .padding(.bottom, 14)

                // Title
                Text(current.title)
                    .font(.system(size: 28, weight: .light))
                    .foregroundStyle(Color.white)
                    .lineSpacing(6)
                    .padding(.bottom, 32)

                // Subtitle
                if let sub = current.subtitle {
                    Text(sub)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color(hex: 0xFF7D7D).opacity(0.80))
                        .kerning(2)
                        .padding(.bottom, 14)
                }

                // Points
                ForEach(current.points, id: \.self) { point in
                    HStack(alignment: .top, spacing: 12) {
                        Circle()
                            .fill(Color.anomalyRed.opacity(0.70))
                            .frame(width: 5, height: 5)
                            .padding(.top, 8)
                        Text(point)
                            .font(.system(size: 17, weight: .light))
                            .foregroundStyle(Color.white.opacity(0.80))
                            .lineSpacing(4)
                    }
                    .padding(.vertical, 14)
                    .padding(.horizontal, 16)
                    .background(Color(hex: 0x1C1C1E))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.10)))
                    .padding(.bottom, 8)
                }

                // Tip
                if let tip = current.tip {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.circle")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.anomalyRed)
                        Text(tip)
                            .font(.system(size: 14))
                            .foregroundStyle(Color.anomalyRed)
                            .italic()
                    }
                    .padding(.top, 8)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 160)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollContentBackground(.hidden)
    }

    private var cardTransition: AnyTransition {
        .asymmetric(
            insertion:  .move(edge: direction >= 0 ? .trailing : .leading).combined(with: .opacity),
            removal:    .move(edge: direction >= 0 ? .leading  : .trailing).combined(with: .opacity)
        )
    }

    // MARK: - Bottom bar

    private var bottomBar: some View {
        VStack(spacing: 8) {
            if anomalyMode {
                // Expanded tool panel
                if uploadCount > 0 {
                    Label("\(uploadCount) 个文件已添加", systemImage: "checkmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.emerald.opacity(0.60))
                }
                anomalyToolPanel
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                // Normal: anomaly toggle + next button
                HStack(spacing: 12) {
                    // Red anomaly button
                    Button { withAnimation(.spring(duration: 0.3)) { anomalyMode = true } } label: {
                        Image(systemName: "exclamationmark.circle")
                            .font(.system(size: 22))
                            .foregroundStyle(Color.anomalyRed)
                            .frame(width: 60, height: 72)
                            .background(Color.anomalyRed.opacity(0.10))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.anomalyRed.opacity(0.50)))
                    }

                    // Next button
                    Button(action: handleNext) {
                        HStack {
                            Text(isLast ? "完成检查" : (isFlagged ? "已标记，下一题" : "未见异常"))
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(Color.white)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.white.opacity(0.50))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 72)
                        .background(Color.white.opacity(0.10))
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.20)))
                    }
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, safeAreaBottom + 8)
        .padding(.top, 48)
        .background(
            LinearGradient(colors: [.black, .clear], startPoint: .bottom, endPoint: .top)
        )
        .animation(.spring(duration: 0.3), value: anomalyMode)
    }

    private var anomalyToolPanel: some View {
        HStack(spacing: 0) {
            // Tool buttons
            Group {
                toolButton(icon: "camera", label: "拍照",   busy: uploading || isRecording) { showCamera = true }
                toolButton(icon: "photo",  label: "相册",   busy: uploading || isRecording) { showGallery = true }
                // Recording button with live audio visualisation
                VStack(spacing: 3) {
                    RecordingButton(isRecording: isRecording, size: 40) {
                        Task { await handleAudio() }
                    }
                    .opacity(uploading ? 0.4 : 1.0)
                    .disabled(uploading)
                    Text(isRecording ? "停止" : "录音")
                        .font(.system(size: 10))
                        .foregroundStyle(isRecording ? Color.anomalyRed : Color.white.opacity(0.50))
                }
                .frame(maxWidth: .infinity)
                toolButton(icon: isFlagged ? "flag.fill" : "flag", label: isFlagged ? "已标记" : "标记", busy: uploading || isRecording, highlight: isFlagged) { handleFlag() }
            }
            .frame(maxWidth: .infinity)

            // Divider
            Rectangle()
                .fill(Color.white.opacity(0.10))
                .frame(width: 1, height: 40)

            // Collapse
            Button { withAnimation(.spring(duration: 0.3)) { anomalyMode = false } } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.white.opacity(0.40))
                    .padding(.horizontal, 16)
                    .frame(height: 72)
            }
        }
        .frame(height: 72)
        .background(Color(hex: 0x450A0A).opacity(0.40))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.anomalyRed.opacity(0.30)))
    }

    @ViewBuilder
    private func toolButton(
        icon: String, label: String, busy: Bool, highlight: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(highlight ? Color.anomalyRed : Color.white.opacity(0.90))
                    .frame(width: 40, height: 40)
                    .background(highlight ? Color.anomalyRed.opacity(0.20) : Color.white.opacity(0.10))
                    .clipShape(Circle())
                Text(label)
                    .font(.system(size: 10))
                    .foregroundStyle(highlight ? Color.anomalyRed : Color.white.opacity(0.50))
            }
        }
        .disabled(busy)
        .opacity(busy ? 0.4 : 1.0)
    }

    // MARK: - Handlers

    private func handleNext() {
        if !isFlagged {
            store.markResult(itemId: itemId, status: "normal")
        }
        if isLast { onNext() } else {
            withAnimation { direction = 1; anomalyMode = false; currentIndex += 1 }
        }
    }

    private func handleFlag() {
        store.markResult(itemId: itemId, status: "flagged")
        if isLast { onNext() } else {
            withAnimation { direction = 1; anomalyMode = false; currentIndex += 1 }
        }
    }

    private func handlePrev() {
        if currentIndex > 0 {
            withAnimation { direction = -1; anomalyMode = false; currentIndex -= 1 }
        } else { onBack() }
    }

    private func handleAudio() async {
        if isRecording {
            isRecording = false
            if let url = EvidenceService.stopRecording() {
                await uploadFile(url: url)
            }
        } else {
            let ok = await EvidenceService.startRecording()
            if ok { isRecording = true }
        }
    }

    private func handlePhotoPickerItems(_ items: [PhotosPickerItem]) async {
        guard !items.isEmpty else { return }
        for item in items {
            guard let data = try? await item.loadTransferable(type: Data.self) else { continue }
            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString + ".jpg")
            try? data.write(to: url)
            await uploadFile(url: url)
        }
        selectedPhotos = []
    }

    private func uploadFile(url: URL) async {
        let passphrase = store.passphrase ?? ""
        if passphrase.isEmpty {
            store.stagePendingFile(itemId: itemId, url: url)
            store.markResult(itemId: itemId, status: "flagged")
            return
        }
        uploading = true
        let result = await EvidenceService.uploadEvidence(url: url, passphrase: passphrase, itemId: itemId)
        if case .success(let key) = result {
            store.addEvidenceKey(itemId: itemId, fileKey: key)
            store.markResult(itemId: itemId, status: "flagged")
        }
        uploading = false
    }

    private var safeAreaBottom: CGFloat { (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.safeAreaInsets.bottom ?? 34 }
}

// MARK: - Waveform progress

struct WaveformProgressView: View {
    let current     : Int
    let total       : Int
    let accentColor : Color

    var body: some View {
        GeometryReader { geo in
            let spacing: CGFloat = 1
            let barWidth = (geo.size.width - spacing * CGFloat(total - 1)) / CGFloat(total)
            HStack(alignment: .bottom, spacing: spacing) {
                ForEach(0..<total, id: \.self) { i in
                    let isActive = i == current - 1
                    let isPast   = i < current - 1
                    let wave     = 4 + abs(sin(Double(i) * 0.8) * 12)
                    let h: CGFloat = isActive ? 24 : (isPast ? 8 : CGFloat(wave))
                    let color: Color = isActive ? accentColor
                                     : isPast   ? Color(hex: 0xEF4444)
                                     : Color.white.opacity(0.10)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(color)
                        .frame(width: max(1, barWidth), height: h)
                        .animation(.easeOut(duration: 0.3), value: current)
                }
            }
        }
        .frame(height: 24)
    }
}

// MARK: - Scrubbable progress (drag to jump to any question)

struct ScrubbableProgressView: View {
    @Binding var current: Int
    let total      : Int
    let accentColor: Color

    @GestureState private var isDragging = false

    var body: some View {
        GeometryReader { geo in
            let spacing: CGFloat = 1
            let barWidth = (geo.size.width - spacing * CGFloat(total - 1)) / CGFloat(total)

            HStack(alignment: .bottom, spacing: spacing) {
                ForEach(0..<total, id: \.self) { i in
                    let isActive = i == current
                    let isPast   = i < current
                    let wave     = 4 + abs(sin(Double(i) * 0.8) * 12)
                    let h: CGFloat = isActive ? 24 : (isPast ? 8 : CGFloat(wave))
                    let color: Color = isActive ? accentColor
                                     : isPast   ? accentColor.opacity(0.45)
                                     : Color.white.opacity(0.10)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(color)
                        .frame(width: max(1, barWidth), height: h)
                        .animation(.easeOut(duration: 0.2), value: current)
                }
            }
            .contentShape(Rectangle())
            .simultaneousGesture(
                DragGesture(minimumDistance: 4, coordinateSpace: .local)
                    .onChanged { value in
                        let idx = Int((value.location.x / geo.size.width) * CGFloat(total))
                        let clamped = max(0, min(total - 1, idx))
                        if clamped != current {
                            withAnimation(.easeOut(duration: 0.2)) { current = clamped }
                        }
                    }
            )
        }
        .frame(height: 24)
    }
}

// MARK: - Camera view (UIKit wrapper)

struct CameraView: UIViewControllerRepresentable {
    let onCapture: (URL?) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(onCapture: onCapture) }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType    = .camera
        picker.allowsEditing = false
        picker.delegate      = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onCapture: (URL?) -> Void
        init(onCapture: @escaping (URL?) -> Void) { self.onCapture = onCapture }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            guard let image = info[.originalImage] as? UIImage,
                  let data  = image.jpegData(compressionQuality: 0.8) else { onCapture(nil); return }
            let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".jpg")
            try? data.write(to: url)
            onCapture(url)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            onCapture(nil)
        }
    }
}
