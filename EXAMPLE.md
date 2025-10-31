# Example Usage

## Basic Usage

```swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            // Using the type-safe enum
            SFSymbol.circle.image
                .font(.system(size: 50))
            
            SFSymbol.heart_fill.image
                .foregroundColor(.red)
                .font(.system(size: 50))
            
            SFSymbol.star.image
                .font(.system(size: 50))
            
            // The name property gives you the correct symbol name
            Text("Symbol name: \(SFSymbol.circle.name)")
        }
    }
}
```

## Renamed Symbols (doc → document)

The generator handles renamed symbols automatically. For example, `doc` was renamed to `document` in iOS 18:

```swift
import SwiftUI

struct DocumentView: View {
    var body: some View {
        VStack {
            // Use the latest name - will automatically use "doc" on iOS < 18
            // and "document" on iOS 18+
            SFSymbol.document.image
                .font(.system(size: 50))
            
            // The deprecated alias still works but will show a warning
            SFSymbol.doc.image  // ⚠️ 'doc' is deprecated: renamed to 'document'
                .font(.system(size: 50))
            
            // The name property returns the correct name for the current OS
            Text("Symbol name: \(SFSymbol.document.name)")
            // On iOS 17: prints "doc"
            // On iOS 18: prints "document"
        }
    }
}
```

## Availability Checking

All symbols have proper `@available` attributes:

```swift
import SwiftUI

struct ModernSymbolsView: View {
    var body: some View {
        VStack {
            // This symbol is only available in iOS 18+
            // Compiler will enforce availability checking
            if #available(iOS 18.0, macOS 15.0, *) {
                SFSymbol.app_connected_to_app_below_fill.image
                    .font(.system(size: 50))
            }
            
            // This symbol has been available since iOS 13
            SFSymbol.circle.image
                .font(.system(size: 50))
        }
    }
}
```

## List of Symbols

```swift
import SwiftUI

struct SymbolBrowser: View {
    let symbols: [SFSymbol] = [
        .circle,
        .square,
        .triangle,
        .heart,
        .star,
        .folder,
        .document,
        .photo,
        .music_note,
        .video
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))]) {
                ForEach(symbols, id: \.name) { symbol in
                    VStack {
                        symbol.image
                            .font(.system(size: 30))
                        Text(symbol.name)
                            .font(.caption2)
                            .lineLimit(1)
                    }
                    .frame(width: 60, height: 60)
                }
            }
            .padding()
        }
    }
}
```

## Integration with Existing Code

If you have existing code using string literals:

```swift
// Before
Image(systemName: "circle.fill")

// After
SFSymbol.circle_fill.image
```

Benefits:
- ✅ **Type safety**: Typos caught at compile time
- ✅ **Autocomplete**: Xcode suggests all available symbols
- ✅ **Availability checking**: Compiler warns if using symbols not available on target OS
- ✅ **Automatic rename handling**: Code works across iOS versions with renamed symbols

## UIKit Integration

For UIKit-based projects (iOS/tvOS), use the `.uiImage` property:

```swift
import UIKit

class MyViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Use UIImage from SF Symbol
        let imageView = UIImageView()
        imageView.image = SFSymbol.heart_fill.uiImage
        imageView.tintColor = .systemRed
        
        // Configure the image
        let config = UIImage.SymbolConfiguration(pointSize: 50, weight: .bold)
        imageView.image = SFSymbol.star.uiImage?.withConfiguration(config)
        
        view.addSubview(imageView)
    }
}
```

### UIButton with SF Symbol

```swift
import UIKit

let button = UIButton(type: .system)
button.setImage(SFSymbol.plus_circle_fill.uiImage, for: .normal)
button.tintColor = .systemBlue
```

### UITabBarItem with SF Symbol

```swift
import UIKit

let homeTab = UITabBarItem(
    title: "Home",
    image: SFSymbol.house.uiImage,
    selectedImage: SFSymbol.house_fill.uiImage
)

let settingsTab = UITabBarItem(
    title: "Settings",
    image: SFSymbol.gear.uiImage,
    selectedImage: SFSymbol.gear_badge_fill.uiImage
)
```

## Custom Modifiers

### SwiftUI Extension

```swift
extension SFSymbol {
    func styledImage(size: CGFloat = 24, color: Color = .primary) -> some View {
        self.image
            .font(.system(size: size))
            .foregroundColor(color)
    }
}

// Usage
SFSymbol.heart.styledImage(size: 50, color: .red)
```

### UIKit Extension

```swift
import UIKit

extension SFSymbol {
    func styledUIImage(
        pointSize: CGFloat = 24,
        weight: UIImage.SymbolWeight = .regular,
        scale: UIImage.SymbolScale = .default
    ) -> UIImage? {
        let config = UIImage.SymbolConfiguration(
            pointSize: pointSize,
            weight: weight,
            scale: scale
        )
        return self.uiImage?.withConfiguration(config)
    }
}

// Usage
let image = SFSymbol.heart.styledUIImage(pointSize: 50, weight: .bold)
```

## AppKit Integration

For AppKit-based projects (macOS), use the `.nsImage` property:

```swift
import AppKit

class MyViewController: NSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Use NSImage from SF Symbol
        let imageView = NSImageView()
        imageView.image = SFSymbol.heart_fill.nsImage
        imageView.contentTintColor = .systemRed
        
        // Configure the image
        let config = NSImage.SymbolConfiguration(pointSize: 50, weight: .bold)
        imageView.image = SFSymbol.star.nsImage?.withSymbolConfiguration(config)
        
        view.addSubview(imageView)
    }
}
```

### NSButton with SF Symbol

```swift
import AppKit

let button = NSButton()
button.image = SFSymbol.plus_circle_fill.nsImage
button.bezelStyle = .rounded
```

### NSStatusItem with SF Symbol

```swift
import AppKit

let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
if let button = statusItem.button {
    button.image = SFSymbol.gear.nsImage
}
```

### NSToolbarItem with SF Symbol

```swift
import AppKit

let toolbarItem = NSToolbarItem(itemIdentifier: .init("settings"))
toolbarItem.image = SFSymbol.gear.nsImage
toolbarItem.label = "Settings"
```

### Custom NSImage Extension

```swift
import AppKit

extension SFSymbol {
    func styledNSImage(
        pointSize: CGFloat = 24,
        weight: NSFont.Weight = .regular
    ) -> NSImage? {
        let config = NSImage.SymbolConfiguration(pointSize: pointSize, weight: weight)
        return self.nsImage?.withSymbolConfiguration(config)
    }
}

// Usage
let image = SFSymbol.heart.styledNSImage(pointSize: 50, weight: .bold)
```

## Working with Collections

```swift
struct IconPicker: View {
    let favoriteSymbols: [SFSymbol] = [
        .heart_fill,
        .star_fill,
        .bookmark_fill,
        .flag_fill
    ]
    
    @State private var selected: SFSymbol = .heart_fill
    
    var body: some View {
        HStack(spacing: 15) {
            ForEach(favoriteSymbols, id: \.name) { symbol in
                Button {
                    selected = symbol
                } label: {
                    symbol.image
                        .font(.system(size: 30))
                        .foregroundColor(selected.name == symbol.name ? .blue : .gray)
                }
            }
        }
    }
}
```
