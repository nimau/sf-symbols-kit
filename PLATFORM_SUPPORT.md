# Platform Support Overview

## Complete Framework Coverage

The SF Symbols Swift Generator now provides **complete platform coverage** across all Apple frameworks:

| Platform | Framework | Property | Type | Availability |
|----------|-----------|----------|------|--------------|
| **All** | SwiftUI | `.image` | `Image` | iOS 13+, macOS 10.15+, tvOS 13+, watchOS 6+, visionOS 1+ |
| **iOS** | UIKit | `.uiImage` | `UIImage?` | iOS 13+ |
| **tvOS** | UIKit | `.uiImage` | `UIImage?` | tvOS 13+ |
| **visionOS** | UIKit | `.uiImage` | `UIImage?` | visionOS 1+ |
| **macOS** | AppKit | `.nsImage` | `NSImage?` | macOS 11+ |
| **watchOS** | SwiftUI | `.image` | `Image` | watchOS 6+ |

## Usage by Platform

### SwiftUI (Universal)

Works on **all platforms**:

```swift
import SwiftUI

SFSymbol.heart_fill.image
    .foregroundColor(.red)
    .font(.system(size: 50))
```

### iOS / tvOS / visionOS

UIKit integration:

```swift
import UIKit

let imageView = UIImageView()
imageView.image = SFSymbol.heart_fill.uiImage
imageView.tintColor = .systemRed

let config = UIImage.SymbolConfiguration(pointSize: 50, weight: .bold)
imageView.image = imageView.image?.withConfiguration(config)
```

### macOS

AppKit integration:

```swift
import AppKit

let imageView = NSImageView()
imageView.image = SFSymbol.heart_fill.nsImage
imageView.contentTintColor = .systemRed

let config = NSImage.SymbolConfiguration(pointSize: 50, weight: .bold)
imageView.image = imageView.image?.withSymbolConfiguration(config)
```

### watchOS

SwiftUI only (UIKit not available):

```swift
import SwiftUI

SFSymbol.heart_fill.image
    .foregroundColor(.red)
```

## Cross-Platform Code

### Conditional Compilation

```swift
#if canImport(UIKit)
// iOS, tvOS, visionOS
let image = SFSymbol.heart_fill.uiImage
#elseif canImport(AppKit)
// macOS
let image = SFSymbol.heart_fill.nsImage
#endif
```

### Universal SwiftUI

```swift
// Works everywhere without conditionals
struct ContentView: View {
    var body: some View {
        SFSymbol.heart_fill.image
            .font(.system(size: 50))
    }
}
```

## Platform-Specific Features

### iOS 15+ Multi-Color Symbols

```swift
import UIKit

if #available(iOS 15.0, *) {
    let config = UIImage.SymbolConfiguration.preferringMulticolor()
    let image = SFSymbol.rainbow.uiImage?.withConfiguration(config)
}
```

### macOS 12+ Multi-Color Symbols

```swift
import AppKit

if #available(macOS 12.0, *) {
    let config = NSImage.SymbolConfiguration.preferringMulticolor()
    let image = SFSymbol.rainbow.nsImage?.withSymbolConfiguration(config)
}
```

### Variable Values (iOS 16+, macOS 13+)

```swift
// iOS
if #available(iOS 16.0, *) {
    let config = UIImage.SymbolConfiguration(variableValue: 0.75)
    let image = SFSymbol.wifi.uiImage?.withConfiguration(config)
}

// macOS
if #available(macOS 13.0, *) {
    let config = NSImage.SymbolConfiguration(variableValue: 0.75)
    let image = SFSymbol.wifi.nsImage?.withSymbolConfiguration(config)
}
```

## Common Use Cases by Platform

### iOS App

```swift
// Tab Bar
tabBarItem.image = SFSymbol.house.uiImage
tabBarItem.selectedImage = SFSymbol.house_fill.uiImage

// Navigation Bar
navigationItem.rightBarButtonItem = UIBarButtonItem(
    image: SFSymbol.gear.uiImage,
    style: .plain,
    target: self,
    action: #selector(showSettings)
)

// Button
button.setImage(SFSymbol.plus_circle_fill.uiImage, for: .normal)
```

### macOS App

```swift
// Menu Bar
statusItem.button?.image = SFSymbol.cloud.nsImage

// Toolbar
toolbarItem.image = SFSymbol.gear.nsImage

// Menu Item
menuItem.image = SFSymbol.gear.nsImage

// Button
button.image = SFSymbol.plus_circle_fill.nsImage
```

### Cross-Platform SwiftUI App

```swift
struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                Label("Home", systemImage: SFSymbol.house.name)
                Label("Settings", systemImage: SFSymbol.gear.name)
            }
            .navigationTitle("App")
            #if os(iOS)
            .navigationBarItems(trailing: 
                Button(action: showInfo) {
                    SFSymbol.info_circle.image
                }
            )
            #elseif os(macOS)
            .toolbar {
                Button(action: showInfo) {
                    SFSymbol.info_circle.image
                }
            }
            #endif
        }
    }
}
```

## Documentation

- **[UIKIT_SUPPORT.md](UIKIT_SUPPORT.md)** - Complete UIKit guide (iOS/tvOS/visionOS)
- **[APPKIT_SUPPORT.md](APPKIT_SUPPORT.md)** - Complete AppKit guide (macOS)
- **[EXAMPLE.md](EXAMPLE.md)** - Usage examples for all frameworks
- **[QUICKSTART.md](QUICKSTART.md)** - Fast-path guide with all platforms

## Summary

✅ **All Apple platforms supported**  
✅ **All major frameworks supported**  
✅ **Type-safe across all platforms**  
✅ **Conditional compilation handled automatically**  
✅ **8,592 symbols available everywhere**

Choose the right property for your platform:
- **SwiftUI?** Use `.image` (works everywhere)
- **UIKit?** Use `.uiImage` (iOS, tvOS, visionOS)
- **AppKit?** Use `.nsImage` (macOS)
