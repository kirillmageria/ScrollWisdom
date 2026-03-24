import Foundation
import StoreKit

@Observable
class StoreManager {
    var products: [Product] = []
    var purchasedProductIDs: Set<String> = []
    var isLoading = false

    // Product identifiers — create these in App Store Connect
    static let monthlyID = "com.scrollwisdom.premium.monthly"
    static let yearlyID = "com.scrollwisdom.premium.yearly"

    // Free topics — available without subscription
    static let freeTopics: Set<WisdomCard.Topic> = [.stoicism, .discipline]
    static let premiumTopics: Set<WisdomCard.Topic> = [.money, .relationships, .leadership]

    var isPremium: Bool {
        !purchasedProductIDs.isEmpty
    }

    var monthlyProduct: Product? {
        products.first { $0.id == Self.monthlyID }
    }

    var yearlyProduct: Product? {
        products.first { $0.id == Self.yearlyID }
    }

    func availableTopics() -> Set<WisdomCard.Topic> {
        if isPremium {
            return Set(WisdomCard.Topic.allCases)
        }
        return Self.freeTopics
    }

    func isTopicFree(_ topic: WisdomCard.Topic) -> Bool {
        Self.freeTopics.contains(topic)
    }

    init() {
        Task { await loadProducts() }
        Task { await updatePurchasedProducts() }
        Task { await listenForTransactions() }
    }

    // MARK: - Load products

    func loadProducts() async {
        isLoading = true
        do {
            products = try await Product.products(for: [Self.monthlyID, Self.yearlyID])
        } catch {
            print("Failed to load products: \(error)")
        }
        isLoading = false
    }

    // MARK: - Purchase

    func purchase(_ product: Product) async throws -> Bool {
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            await updatePurchasedProducts()
            return true
        case .userCancelled:
            return false
        case .pending:
            return false
        @unknown default:
            return false
        }
    }

    // MARK: - Restore

    func restore() async {
        try? await AppStore.sync()
        await updatePurchasedProducts()
    }

    // MARK: - Check active subscriptions

    func updatePurchasedProducts() async {
        var purchased: Set<String> = []

        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result) {
                purchased.insert(transaction.productID)
            }
        }

        await MainActor.run {
            self.purchasedProductIDs = purchased
        }
    }

    // MARK: - Listen for transaction updates

    func listenForTransactions() async {
        for await result in Transaction.updates {
            if let transaction = try? checkVerified(result) {
                await transaction.finish()
                await updatePurchasedProducts()
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    enum StoreError: Error {
        case failedVerification
    }
}
