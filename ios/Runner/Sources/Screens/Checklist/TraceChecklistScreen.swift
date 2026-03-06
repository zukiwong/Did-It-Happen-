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
    @State private var selectedPhoto: PhotosPickerItem?

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
        ZStack(alignment: .bottom) {
            Color(hex: 0x0A0A0A).ignoresSafeArea()
            ambientBackground

            VStack(spacing: 0) {
                topBar
                    .padding(.top, safeAreaTop)

                questionCard
                    .id(currentIndex)
                    .transition(cardTransition)
                    .animation(.spring(duration: 0.35), value: currentIndex)

                Spacer()
            }

            bottomBar
        }
        .photosPicker(isPresented: $showGallery, selection: $selectedPhoto, matching: .images)
        .onChange(of: selectedPhoto) { _, item in
            Task { await handlePhotoPickerItem(item) }
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraView { url in
                showCamera = false
                if let url { Task { await uploadFile(url: url) } }
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

    // MARK: - Top bar

    private var topBar: some View {
        HStack(spacing: 16) {
            Button(action: handlePrev) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Color.white.opacity(0.60))
                    .frame(width: 44, height: 44)
            }

            // Waveform progress
            WaveformProgressView(
                current: currentIndex + 1,
                total:   questions.count,
                accentColor: Color.anomalyRed
            )

            Text("\(currentIndex + 1)/\(questions.count)")
                .font(.mono(10))
                .foregroundStyle(Color.white.opacity(0.30))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Question card

    private var questionCard: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Category + ID
                HStack(spacing: 8) {
                    Text("#\(String(format: "%02d", current.id))")
                        .font(.mono(9))
                        .foregroundStyle(Color.white.opacity(0.20))
                        .kerning(4)
                    Text(current.category)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Color.white.opacity(0.30))
                        .kerning(4)
                }
                .padding(.bottom, 16)

                // Title
                Text(current.title)
                    .font(.system(size: 22, weight: .light))
                    .foregroundStyle(Color.white.opacity(0.90))
                    .lineSpacing(6)
                    .padding(.bottom, 32)

                // Subtitle
                if let sub = current.subtitle {
                    Text(sub)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(Color(hex: 0xFF7D7D).opacity(0.80))
                        .kerning(3)
                        .padding(.bottom, 16)
                }

                // Points
                ForEach(current.points, id: \.self) { point in
                    HStack(alignment: .top, spacing: 12) {
                        Circle()
                            .fill(Color.white.opacity(0.10))
                            .frame(width: 4, height: 4)
                            .padding(.top, 6)
                        Text(point)
                            .font(.system(size: 13, weight: .light))
                            .foregroundStyle(Color.white.opacity(0.50))
                            .lineSpacing(4)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.white.opacity(0.03))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.08)))
                    .padding(.bottom, 8)
                }

                // Tip
                if let tip = current.tip {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.circle")
                            .font(.system(size: 11))
                            .foregroundStyle(Color.white.opacity(0.20))
                        Text(tip)
                            .font(.system(size: 11))
                            .foregroundStyle(Color.white.opacity(0.30))
                            .italic()
                    }
                    .padding(.top, 8)
                }
            }
            .padding(28)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
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
                        .font(.system(size: 11))
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
                                .font(.system(size: 16, weight: .medium))
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
                toolButton(
                    icon:  isRecording ? "stop.circle" : "mic",
                    label: isRecording ? "停止" : "录音",
                    busy:  uploading,
                    highlight: isRecording
                ) { Task { await handleAudio() } }
                toolButton(icon: "flag", label: "标记", busy: uploading || isRecording) { handleFlag() }
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

    private func handlePhotoPickerItem(_ item: PhotosPickerItem?) async {
        guard let item else { return }
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString + ".jpg")
        try? data.write(to: url)
        await uploadFile(url: url)
        selectedPhoto = nil
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

    // MARK: - Safe area helpers
    private var safeAreaTop   : CGFloat { (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.safeAreaInsets.top    ?? 44 }
    private var safeAreaBottom: CGFloat { (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.safeAreaInsets.bottom ?? 34 }
}

// MARK: - Waveform progress

struct WaveformProgressView: View {
    let current     : Int
    let total       : Int
    let accentColor : Color

    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<total, id: \.self) { i in
                let h: CGFloat = i < current ? 16 : 8
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(i < current ? accentColor : Color.white.opacity(0.15))
                    .frame(width: 3, height: h)
                    .animation(.spring(duration: 0.3).delay(Double(i) * 0.02), value: current)
            }
        }
    }
}

// MARK: - Camera view (UIKit wrapper)

struct CameraView: UIViewControllerRepresentable {
    let onCapture: (URL?) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType    = .camera
        picker.delegate      = context.coordinator
        picker.allowsEditing = false
        return picker
    }

    func updateUIViewController(_ vc: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(onCapture: onCapture) }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onCapture: (URL?) -> Void
        init(onCapture: @escaping (URL?) -> Void) { self.onCapture = onCapture }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            picker.dismiss(animated: true)
            guard let image = info[.originalImage] as? UIImage,
                  let data  = image.jpegData(compressionQuality: 0.8) else { onCapture(nil); return }
            let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".jpg")
            try? data.write(to: url)
            onCapture(url)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
            onCapture(nil)
        }
    }
}
