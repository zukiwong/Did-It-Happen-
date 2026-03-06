import SwiftUI

struct ArchiveAccessScreen: View {
    let onBack   : () -> Void
    let onSuccess: () -> Void

    @Environment(InvestigationStore.self) private var store
    @State private var passphrase = ""
    @State private var isLoading  = false
    @State private var errorText  : String?

    var body: some View {
        ZStack {
            Color(hex: 0x050505).ignoresSafeArea()
            background

            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20))
                            .foregroundStyle(Color.white.opacity(0.60))
                    }
                    Spacer()
                }
                .padding(.top, safeAreaTop + 12)

                Spacer()

                // Icon
                Image(systemName: "lock.shield")
                    .font(.system(size: 56, weight: .ultraLight))
                    .foregroundStyle(Color.white.opacity(0.20))
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 32)

                Text("访问加密档案")
                    .font(.system(size: 28, weight: .light))
                    .foregroundStyle(Color.white.opacity(0.90))
                    .padding(.bottom, 8)

                Text("输入你设置的密钥，解密并查看历史观察记录。")
                    .font(.system(size: 14, weight: .light))
                    .foregroundStyle(Color.white.opacity(0.40))
                    .lineSpacing(4)
                    .padding(.bottom, 40)

                // Input
                TextField("输入密钥...", text: $passphrase)
                    .foregroundStyle(Color.white)
                    .font(.system(size: 16))
                    .padding(18)
                    .background(Color.white.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.15)))
                    .submitLabel(.go)
                    .onSubmit { Task { await handleAccess() } }
                    .padding(.bottom, 12)

                if let err = errorText {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.circle").font(.system(size: 12))
                        Text(err).font(.system(size: 12))
                    }
                    .foregroundStyle(Color.anomalyRed.opacity(0.80))
                    .padding(.bottom, 12)
                }

                // Access button
                Button { Task { await handleAccess() } } label: {
                    HStack {
                        if isLoading { ProgressView().tint(.black) }
                        Text(isLoading ? "解密中..." : "解密访问")
                            .font(.system(size: 13, weight: .bold))
                            .kerning(3)
                            .foregroundStyle(Color.black)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(passphrase.isEmpty ? Color.white.opacity(0.20) : Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .disabled(passphrase.isEmpty || isLoading)

                Spacer()
            }
            .padding(.horizontal, 28)
        }
        .ignoresSafeArea()
    }

    private var background: some View {
        GeometryReader { geo in
            RadialGradient(
                colors: [Color(hex: 0x172554).opacity(0.20), .clear],
                center: UnitPoint(x: 0.8, y: 0.2),
                startRadius: 0,
                endRadius: geo.size.width
            )
            .ignoresSafeArea()
        }
    }

    private func handleAccess() async {
        let phrase = passphrase.trimmingCharacters(in: .whitespaces)
        guard !phrase.isEmpty else { return }
        isLoading = true; errorText = nil
        let success = await store.load(passphrase: phrase)
        isLoading = false
        if success { onSuccess() } else { errorText = "密钥错误或未找到对应记录。" }
    }

    private var safeAreaTop: CGFloat {
        (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.safeAreaInsets.top ?? 44
    }
}
