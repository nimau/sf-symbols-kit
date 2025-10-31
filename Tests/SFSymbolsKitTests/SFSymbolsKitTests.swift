import Testing
import SwiftUI
@testable import SFSymbolsKit

@Test("Symbol naming works correctly")
func symbolNaming() {
    #expect(SFSymbol.circle.name == "circle")
    #expect(SFSymbol.heart_fill.name == "heart.fill")
    #expect(SFSymbol.circle_slash.name == "circle.slash")
}

@Test("Numbered symbols have correct format")
func numberedSymbols() {
    #expect(SFSymbol.circle_01.name == "01.circle")
    #expect(SFSymbol.square_00.name == "00.square")
}

@Test("Deprecated aliases still work")
func deprecatedAliases() {
    // Deprecated alias should return its own name
    #expect(SFSymbol.doc.name == "doc")
}

@Test("SwiftUI image property returns valid Image")
func swiftUIImage() {
    let image = SFSymbol.circle.image
    // Just verify it compiles and returns an Image
    let _ = image
}

#if canImport(UIKit)
@Test("UIKit image property returns UIImage")
func uiKitImage() {
    let image = SFSymbol.circle.uiImage
    #expect(image != nil)
}
#endif

#if canImport(AppKit)
@Test("AppKit image property returns NSImage")
func appKitImage() {
    let image = SFSymbol.circle.nsImage
    #expect(image != nil)
}
#endif

@Test("Common symbols are accessible")
func commonSymbols() {
    // Verify common symbols compile and are accessible
    let symbols = [
        SFSymbol.circle,
        SFSymbol.heart,
        SFSymbol.star,
        SFSymbol.house,
        SFSymbol.gear
    ]
    
    #expect(symbols.count == 5)
}
