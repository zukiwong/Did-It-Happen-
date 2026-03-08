import SwiftUI

struct ArchiveAccessScreen: View {
    let onBack   : () -> Void
    let onSuccess: () -> Void

    @Environment(InvestigationStore.self) private var store
    @State private var passphrase = ""
    @State private var isLoading  = false
    @State private var errorText  : String?

    private let accent = Color(hex: 0xE8A830)

    var body: some View {
        NavigationStack {
          ZStack {
            Color(hex: 0x080808).ignoresSafeArea()
            ambientBlobs

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Icon with gold glow
                    ZStack {
                        Circle()
                            .fill(accent.opacity(0.12))
                            .frame(width: 90, height: 90)
                            .blur(radius: 24)
                        Image(systemName: "lock.shield")
                            .font(.system(size: 44, weight: .ultraLight))
                            .foregroundStyle(accent.opacity(0.80))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 52)
                    .padding(.bottom, 36)

                    Text("访问加密档案")
                        .font(.system(size: 28, weight: .light))
                        .foregroundStyle(Color.white.opacity(0.90))
                        .padding(.bottom, 10)

                    Text("输入你设置的密钥，解密并查看历史观察记录。")
                        .font(.system(size: 15, weight: .light))
                        .foregroundStyle(Color.white.opacity(0.35))
                        .lineSpacing(5)
                        .padding(.bottom, 44)

                    // Input field
                    TextField("输入密钥...", text: $passphrase)
                        .foregroundStyle(Color.white)
                        .font(.system(size: 16))
                        .tint(accent)
                        .padding(18)
                        .background(Color.white.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(passphrase.isEmpty ? Color.white.opacity(0.10) : accent.opacity(0.50), lineWidth: 1)
                        )
                        .submitLabel(.go)
                        .onSubmit { Task { await handleAccess() } }
                        .padding(.bottom, 14)

                    if let err = errorText {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.circle").font(.system(size: 13))
                            Text(err).font(.system(size: 13))
                        }
                        .foregroundStyle(Color.anomalyRed.opacity(0.80))
                        .padding(.bottom, 14)
                    }

                    // CTA button
                    Button { Task { await handleAccess() } } label: {
                        HStack(spacing: 8) {
                            if isLoading {
                                ProgressView().tint(.black)
                            } else {
                                Text("解密访问")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundStyle(Color.black)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(passphrase.isEmpty ? accent.opacity(0.25) : accent)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                    .disabled(passphrase.isEmpty || isLoading)
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 40)
            }
            .scrollDismissesKeyboard(.interactively)
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
          }
          .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    // Soft ambient blobs — warm gold top-left + cool dark right, like splash screen
    private var ambientBlobs: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack {
                // Main warm glow — top center
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: 0xC07010).opacity(0.55), Color(hex: 0x8B4A00).opacity(0.20), .clear],
                            center: .center, startRadius: 0, endRadius: w * 0.7
                        )
                    )
                    .frame(width: w * 1.4, height: w * 1.4)
                    .blur(radius: 70)
                    .offset(x: -w * 0.15, y: -h * 0.10)

                // Secondary amber glow — bottom right
                Circle()
                    .fill(Color(hex: 0xE8A830).opacity(0.10))
                    .frame(width: w * 0.8, height: w * 0.8)
                    .blur(radius: 80)
                    .offset(x: w * 0.40, y: h * 0.55)

                // Dark vignette overlay
                RadialGradient(
                    colors: [.clear, Color.black.opacity(0.55)],
                    center: .center,
                    startRadius: min(w, h) * 0.3,
                    endRadius: max(w, h) * 0.85
                )
                .ignoresSafeArea()
            }
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }

    private func handleAccess() async {
        let phrase = passphrase.trimmingCharacters(in: .whitespaces)
        guard !phrase.isEmpty else { return }
        isLoading = true; errorText = nil
        let success = await store.load(passphrase: phrase)
        isLoading = false
        if success { onSuccess() } else { errorText = "密钥错误或未找到对应记录。" }
    }

}
