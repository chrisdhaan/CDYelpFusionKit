# Getting Started

Authenticate and query the Yelp Fusion API in three steps.

## Initialize the Client

```swift
import CDYelpFusionKit

let client = CDYelpAPIClient(apiKey: "your-api-key-here")
```

## Search for Businesses

CDYelpFusionKit's API surface is `async throws` only (iOS 15.0+, macOS 12.0+, tvOS 15.0+, watchOS 8.0+, visionOS 1.0+). There are no completion-handler overloads.

```swift
Task {
    do {
        let response = try await client.searchBusinesses(
            byTerm: "coffee",
            location: "San Francisco",
            latitude: nil,
            longitude: nil,
            radius: nil,
            categories: nil,
            locale: nil,
            limit: 10,
            offset: nil,
            sortBy: .bestMatch,
            priceTiers: nil,
            openNow: nil,
            openAt: nil,
            attributes: nil
        )
        let businesses = response.businesses ?? []
        print("Found \(businesses.count) businesses")
    } catch {
        print("Search failed: \(error)")
    }
}
```
