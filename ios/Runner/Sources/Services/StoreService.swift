import StoreKit

// MARK: - StoreKit 2 IAP service

@MainActor
final class StoreService: ObservableObject {
    static let shared = StoreService()

    // Product IDs must match App Store Connect
    static let productID3000  = "com.zukiwong.didItHappen.tokens3000"
    static let productID10000 = "com.zukiwong.didItHappen.tokens10000"

    @Published var products: [Product] = []
    @Published var isLoadingProducts = false
    @Published var isPurchasing = false
    @Published var errorMessage: String? = nil

    private init() {}

    // MARK: - Load products

    func loadProducts() async {
        guard !isLoadingProducts else { return }

        isLoadingProducts = true
        errorMessage = nil
        defer { isLoadingProducts = false }

        print("[StoreService] loadProducts called")
        print("[StoreService] bundle identifier: \(Bundle.main.bundleIdentifier ?? "nil")")
        do {
            let ids: Set<String> = [Self.productID3000, Self.productID10000]
            print("[StoreService] requesting product IDs: \(ids)")
            let fetched = try await Product.products(for: ids)
            print("[StoreService] fetched \(fetched.count) products: \(fetched.map(\.id))")
            products = fetched.sorted { $0.price < $1.price }

            if fetched.isEmpty {
                errorMessage = "未获取到任何商品。请确认当前 Scheme 的 StoreKit Configuration 已指向 Store.storekit，然后停止并重新运行 App。"
            }
        } catch {
            print("[StoreService] loadProducts error: \(error)")
            errorMessage = "无法加载商品信息"
        }
    }

    // MARK: - Purchase

    /// Returns true if purchase succeeded and quota was added.
    func purchase(_ product: Product) async -> Bool {
        isPurchasing = true
        defer { isPurchasing = false }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                // Add quota based on product
                let chars = charsFor(productID: product.id)
                QuotaService.add(chars)
                await transaction.finish()
                return true
            case .userCancelled:
                return false
            case .pending:
                errorMessage = "购买待确认，请稍候"
                return false
            @unknown default:
                return false
            }
        } catch {
            errorMessage = "购买失败：\(error.localizedDescription)"
            return false
        }
    }

    // MARK: - Helpers

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let value):
            return value
        }
    }

    private func charsFor(productID: String) -> Int {
        switch productID {
        case Self.productID3000:  return 3000
        case Self.productID10000: return 10000
        default: return 0
        }
    }
}

enum StoreError: Error {
    case failedVerification
}
