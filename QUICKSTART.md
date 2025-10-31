# Quick Start Guide

## Generate the Enum

### Default Generation

```bash
# Clone/download this repository
cd sf-symbols-swift-generator

# Generate SFSymbol.swift with defaults
swift generate-sf-symbols.swift
# or
make generate
```

### Custom Generation

```bash
# Custom enum name and output path
swift generate-sf-symbols.swift --enum-name AppSymbol --output Sources/AppSymbol.swift

# Internal access level for framework/library
swift generate-sf-symbols.swift --access internal

# Combine options
swift generate-sf-symbols.swift \
  --enum-name MySymbols \
  --access internal \
  --output Sources/Symbols.swift \
  --verbose
```

## Add to Your Xcode Project

1. Drag `SFSymbol.swift` into your Xcode project
2. Make sure "Copy items if needed" is checked
3. Add to your target(s)

## Use in Your Code

### Before (String Literals)
```swift
Image(systemName: "circle.fill")
Image(systemName: "heart")
Image(systemName: "01.circle")
Image(systemName: "circle.slash")
Image(systemName: "doc.text")  // ⚠️ Renamed to "document.text" in iOS 18!
```

### After (Type-Safe Enum)
```swift
SFSymbol.circle_fill.image
SFSymbol.heart.image
SFSymbol.circle_01.image       // Numbered symbols have number as suffix
SFSymbol.circle_slash.image    // Dots become underscores
SFSymbol.document_text.image   // ✅ Works on all OS versions automatically!
```

## Key Features

### ✅ Type Safety
```swift
// Compile-time error - no such symbol
SFSymbol.circl.image  // ❌ Error: Type 'SFSymbol' has no member 'circl'

// Works perfectly
SFSymbol.circle.image  // ✅
```

### ✅ Autocomplete
Type `SFSymbol.` and Xcode shows all 8,592 available symbols with fuzzy search.

### ✅ Availability Checking
```swift
// Compiler enforces availability
SFSymbol.app_connected_to_app_below_fill.image  
// ⚠️ Warning: Only available from iOS 18.0

// Proper usage
if #available(iOS 18.0, *) {
    SFSymbol.app_connected_to_app_below_fill.image
}
```

### ✅ Automatic Symbol Renames
```swift
// Use the latest name everywhere
let symbol = SFSymbol.document

// On iOS 17: symbol.name returns "doc"
// On iOS 18+: symbol.name returns "document"
// Your app works on both versions!
```

### ✅ Deprecated Aliases
```swift
// Old code still works, but with deprecation warning
SFSymbol.doc.image
// ⚠️ 'doc' is deprecated: renamed to 'document'

// Easy migration path suggested by Xcode
SFSymbol.document.image  // ✅ Use this instead
```

## Common Patterns

### SwiftUI Image with Styling
```swift
SFSymbol.heart_fill.image
    .foregroundColor(.red)
    .font(.system(size: 50))
```

### UIKit Image (iOS/tvOS/visionOS)
```swift
import UIKit

let imageView = UIImageView()
imageView.image = SFSymbol.heart_fill.uiImage
imageView.tintColor = .systemRed

let config = UIImage.SymbolConfiguration(pointSize: 50, weight: .bold)
imageView.image = imageView.image?.withConfiguration(config)
```

### AppKit Image (macOS)
```swift
import AppKit

let imageView = NSImageView()
imageView.image = SFSymbol.heart_fill.nsImage
imageView.contentTintColor = .systemRed

let config = NSImage.SymbolConfiguration(pointSize: 50, weight: .bold)
imageView.image = imageView.image?.withSymbolConfiguration(config)
```

### Conditional Symbol Usage
```swift
let symbol: SFSymbol = isPremium ? .star_fill : .star

symbol.image
    .foregroundColor(.yellow)
```

### List/Array of Symbols
```swift
let icons: [SFSymbol] = [.house, .gear, .person, .envelope]

ForEach(icons, id: \.name) { symbol in
    symbol.image
}
```

### Get Symbol Name String
```swift
let symbolName = SFSymbol.circle.name  // "circle"
Image(systemName: symbolName)
```

## Regenerate for New SF Symbols Versions

When Apple releases a new SF Symbols version:

```bash
# 1. Install the new SF Symbols app from Apple
# 2. Regenerate the enum
make generate

# 3. Replace the old SFSymbol.swift in your Xcode project
#    with the newly generated one
```

That's it! All new symbols are immediately available with proper availability annotations.

## Statistics (SF Symbols 7.0)

- 7,698 unique symbols
- 894 renamed symbols (with deprecated aliases)
- Full iOS 13-18, macOS 10.15-15, tvOS 13-18, watchOS 6-11, visionOS 1-2 coverage
- Automatic backwards compatibility for renamed symbols

## Need Help?

- See [EXAMPLE.md](EXAMPLE.md) for detailed usage examples
- See [README.md](README.md) for full documentation
- See [TODO.md](TODO.md) for planned features
