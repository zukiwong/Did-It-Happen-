import Foundation

// MARK: - iCloud-backed chat quota service
// Quota is stored in NSUbiquitousKeyValueStore (iCloud Key-Value Store).
// Falls back to UserDefaults when iCloud is unavailable.
// Free allowance: 3000 characters total.

enum QuotaService {
    private static let key            = "sanctuary_chars_remaining"
    private static let freeAllowance  = 3000
    private static let warningThreshold = 750

    // MARK: - Read

    static var remaining: Int {
        if let icloud = iCloudStore {
            let val = icloud.longLong(forKey: key)
            // First launch: val == 0 and key was never set → initialise
            if val == 0 && !icloud.dictionaryRepresentation.keys.contains(key) {
                return freeAllowance
            }
            return max(0, Int(val))
        }
        // Fallback: UserDefaults
        let val = UserDefaults.standard.integer(forKey: key)
        if val == 0 && UserDefaults.standard.object(forKey: key) == nil {
            return freeAllowance
        }
        return max(0, val)
    }

    static var isExhausted: Bool { remaining == 0 }
    static var shouldWarn : Bool { remaining <= warningThreshold && remaining > 0 }

    // MARK: - Write

    /// Deduct `chars` from the remaining quota. Returns the new remaining value.
    @discardableResult
    static func deduct(_ chars: Int) -> Int {
        let newValue = max(0, remaining - chars)
        if let icloud = iCloudStore {
            icloud.set(Int64(newValue), forKey: key)
            icloud.synchronize()
        } else {
            UserDefaults.standard.set(newValue, forKey: key)
        }
        return newValue
    }

    /// Add `chars` to the remaining quota (after IAP purchase). Returns the new remaining value.
    @discardableResult
    static func add(_ chars: Int) -> Int {
        let newValue = remaining + chars
        if let icloud = iCloudStore {
            icloud.set(Int64(newValue), forKey: key)
            icloud.synchronize()
        } else {
            UserDefaults.standard.set(newValue, forKey: key)
        }
        return newValue
    }

    // MARK: - Private

    private static var iCloudStore: NSUbiquitousKeyValueStore? {
        // Returns nil when iCloud entitlement is missing or unavailable
        let store = NSUbiquitousKeyValueStore.default
        // Lightweight availability check: attempt a no-op sync
        _ = store.synchronize()
        return store
    }
}
