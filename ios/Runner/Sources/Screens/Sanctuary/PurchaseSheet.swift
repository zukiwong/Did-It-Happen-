import SwiftUI
import StoreKit

struct PurchaseSheet: View {
    @ObservedObject var storeService: StoreService
    @Binding var charsRemaining: Int
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(hex: 0x0A0A0A).ignoresSafeArea()

            VStack(spacing: 0) {
                // Handle
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.white.opacity(0.20))
                    .frame(width: 36, height: 4)
                    .padding(.top, 12)

                // Title
                VStack(spacing: 8) {
                    Text("续充对话额度")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.white)
                    Text("当前剩余 \(charsRemaining) 字符")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.white.opacity(0.50))
                }
                .padding(.top, 28)
                .task { await storeService.loadProducts() }

                // Products
                VStack(spacing: 12) {
                    if storeService.isLoadingProducts {
                        ProgressView()
                            .tint(.white)
                            .padding(.vertical, 40)
                    } else if storeService.products.isEmpty {
                        VStack(spacing: 14) {
                            Text(storeService.errorMessage ?? "暂无可用商品")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.white.opacity(0.70))
                                .multilineTextAlignment(.center)

                            Button {
                                Task { await storeService.loadProducts() }
                            } label: {
                                Text("重新加载")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(.black)
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 10)
                                    .background(Color.white)
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(.vertical, 28)
                    } else {
                        ForEach(storeService.products, id: \.id) { product in
                            ProductRow(product: product, isPurchasing: storeService.isPurchasing) {
                                Task {
                                    let ok = await storeService.purchase(product)
                                    if ok {
                                        charsRemaining = QuotaService.remaining
                                        dismiss()
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 32)

                if let err = storeService.errorMessage {
                    Text(err)
                        .font(.system(size: 13))
                        .foregroundStyle(Color(hex: 0xFF6B6B))
                        .padding(.top, 16)
                }

                Spacer()

                Text("购买后额度永久有效，不限时间")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.white.opacity(0.30))
                    .padding(.bottom, 32)
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
    }
}

private struct ProductRow: View {
    let product: Product
    let isPurchasing: Bool
    let onBuy: () -> Void

    var chars: Int {
        product.id.contains("10000") ? 10000 : 3000
    }

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(chars) 字符额度")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white)
                Text("约 \(chars / 150) 轮对话")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.white.opacity(0.50))
            }
            Spacer()
            Button(action: onBuy) {
                if isPurchasing {
                    ProgressView().tint(.black)
                        .frame(width: 64, height: 36)
                } else {
                    Text(product.displayPrice)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.black)
                        .frame(width: 64, height: 36)
                }
            }
            .background(Color.white)
            .clipShape(Capsule())
            .disabled(isPurchasing)
        }
        .padding(16)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
