# Getting Started

Authenticate and query the Yelp Fusion API in three steps.

## Initialize the Client

```swift
import CDYelpFusionKit

let client = CDYelpAPIClient(apiKey: "your-api-key-here")
```

## Search for Businesses (Completion Handler)

```swift
client.searchBusinesses(
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
) { response in
    guard let businesses = response?.businesses else { return }
    for business in businesses {
        print(business.name ?? "Unknown")
    }
}
```

## Search for Businesses (Async/Await, iOS 13+)

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
