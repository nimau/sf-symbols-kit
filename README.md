# SF Symbols Swift Generator

A Swift script that automatically generates a type-safe Swift enum for all SF Symbols, complete with availability annotations and deprecated aliases.

**Two ways to use:**
1. **Swift Package (SFSymbolsKit)** - Add pre-generated symbols to your project via SPM
2. **Generator Script** - Customize and generate your own enum

## Overview

This tool parses metadata from the SF Symbols app and generates a comprehensive Swift enum that provides:

- **Type-safe symbol access**: Use enum cases instead of string literals
- **Automatic availability checking**: `@available()` annotations for each symbol based on iOS/macOS/tvOS/watchOS/visionOS versions
- **Deprecated aliases**: Old symbol names are preserved as deprecated aliases that point to their renamed versions
- **Correct symbol names**: `.name` property returns the appropriate symbol name for the current OS
- **SwiftUI integration**: `.image` property returns `Image(systemName:)` for easy use
- **UIKit integration**: `.uiImage` property returns `UIImage?(systemName:)` (iOS/tvOS/visionOS)
- **AppKit integration**: `.nsImage` property returns `NSImage?(systemSymbolName:)` (macOS only)

## Features

### Naming Convention

Symbol names are converted to Swift identifiers using the following rules:

- **Dots become underscores**: `circle.fill` → `circle_fill`
- **Numbered symbols**: `01.circle` → `circle_01` (number moves to end)
- **Keywords prefixed**: `repeat` → `_repeat`
- **Plain symbols**: `circle` → `circle`

Examples:
- `circle` → `.circle`
- `circle.slash` → `.circle_slash`
- `01.circle` → `.circle_01`
- `heart.fill` → `.heart_fill`
- `doc` → `.doc` (deprecated, renamed to `.document`)

### Generated Enum Structure

```swift
enum SFSymbol {
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
    case circle
    
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
    case document
    
    // Deprecated alias for renamed symbol
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
    @available(*, deprecated, renamed: "document")
    case doc
    
    var name: String {
        // Returns correct symbol name
    }
    
    var image: Image {
        // Returns Image(systemName: name)
    }
    
    #if canImport(UIKit)
    var uiImage: UIImage? {
        // Returns UIImage(systemName: name)
    }
    #endif
    
    #if canImport(AppKit)
    var nsImage: NSImage? {
        // Returns NSImage(systemSymbolName: name)
    }
    #endif
}
```

## Data Sources

The script extracts data from SF Symbols app metadata files:

- **`name_availability.plist`**: Symbol introduction versions and year-to-release mappings
- **`name_aliases.strings`**: Current symbol renames (e.g., `doc` → `document`)
- **`legacy_aliases.strings`**: Legacy symbol renames

## Installation

### Option 1: Swift Package Manager (Recommended)

Add SFSymbolsKit to your project using Swift Package Manager:

**In Xcode:**
1. File → Add Package Dependencies
2. Enter the repository URL: `https://github.com/yourname/sf-symbols-swift-generator`
3. Select "Up to Next Major Version" starting from `1.0.0`
4. Add to your target

**In Package.swift:**
```swift
dependencies: [
    .package(url: "https://github.com/yourname/sf-symbols-swift-generator", from: "1.0.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: ["SFSymbolsKit"]
    )
]
```

**Usage:**
```swift
import SwiftUI
import SFSymbolsKit

struct ContentView: View {
    var body: some View {
        VStack {
            SFSymbol.heart_fill.image
                .foregroundColor(.red)
            
            SFSymbol.star.image
            
            // UIKit (iOS/tvOS/visionOS)
            // let image = SFSymbol.gear.uiImage
            
            // AppKit (macOS)
            // let image = SFSymbol.gear.nsImage
        }
    }
}
```

**Platform Support:**
- iOS 13.0+
- macOS 10.15+
- tvOS 13.0+
- watchOS 6.0+
- visionOS 1.0+

### Option 2: Generate Your Own

Use the generator script to create a custom enum for your project.

**Requirements:**
- macOS with SF Symbols app installed (`/Applications/SF Symbols.app`)
- Swift 5.9+ (for the generator script)
- Xcode or Swift toolchain

## Usage

### Basic Usage

```bash
# Run the generator script with default options
swift generate-sf-symbols.swift

# Or use make
make generate

# Output will be written to SFSymbol.swift
```

### Command-Line Options

Customize the generation with command-line arguments:

```bash
# Custom output path
swift generate-sf-symbols.swift --output Sources/SFSymbols.swift

# Custom enum name
swift generate-sf-symbols.swift --enum-name AppSymbol

# Custom access level (public, internal, private)
swift generate-sf-symbols.swift --access internal

# Custom SF Symbols app path
swift generate-sf-symbols.swift --sf-symbols-path "/path/to/SF Symbols.app"

# Verbose output
swift generate-sf-symbols.swift --verbose

# Combine multiple options
swift generate-sf-symbols.swift --enum-name MySymbols --access internal --output Sources/Symbols.swift

# Show help
swift generate-sf-symbols.swift --help
```

### Available Options

| Option | Description | Default |
|--------|-------------|----------|
| `--output <path>` | Output file path | `./SFSymbol.swift` |
| `--enum-name <name>` | Enum name | `SFSymbol` |
| `--access <level>` | Access level (public/internal/private) | `public` |
| `--sf-symbols-path <path>` | Path to SF Symbols.app | `/Applications/SF Symbols.app` |
| `--verbose` | Enable verbose output | `false` |
| `--help, -h` | Show help message | - |

The generated `SFSymbol.swift` file can then be added to any iOS/macOS/tvOS/watchOS project.

For detailed usage examples, see [EXAMPLE.md](EXAMPLE.md).

### Example Output

When run with SF Symbols 7.0:
- **7,698** unique symbol cases (latest names)
- **894** deprecated alias cases (for renamed symbols)
- **8,592** total enum cases
- **~38,500** lines of generated Swift code
- Full per-platform availability annotations
- Dynamic name resolution for renamed symbols

## Regenerating for New SF Symbols Versions

When Apple releases a new version of SF Symbols:

1. Download and install the latest SF Symbols app
2. Run the generator script again
3. Replace the old `SFSymbol.swift` in your project with the newly generated version

## Future Enhancements

- [x] Support for UIKit's `UIImage` (via `.uiImage` property)
- [x] Support for AppKit's `NSImage` (via `.nsImage` property)
- [x] Swift Package with pre-generated symbols
- [x] Command-line options for customizing output
- [ ] Symbol categories and grouping
- [ ] Multi-version support (generate different enums for different deployment targets)

## License

MIT License - Feel free to use in your projects

## Credits

SF Symbols is a trademark of Apple Inc.
This tool is not affiliated with or endorsed by Apple Inc.
