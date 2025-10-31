#!/usr/bin/env swift

import Foundation

// MARK: - Data Models

struct PlatformVersions {
    var iOS: String?
    var macOS: String?
    var tvOS: String?
    var watchOS: String?
    var visionOS: String?
    
    var isEmpty: Bool {
        iOS == nil && macOS == nil && tvOS == nil && watchOS == nil && visionOS == nil
    }
    
    func availabilityString() -> String {
        var parts: [String] = []
        if let iOS = iOS { parts.append("iOS \(iOS)") }
        if let macOS = macOS { parts.append("macOS \(macOS)") }
        if let tvOS = tvOS { parts.append("tvOS \(tvOS)") }
        if let watchOS = watchOS { parts.append("watchOS \(watchOS)") }
        if let visionOS = visionOS { parts.append("visionOS \(visionOS)") }
        parts.append("*")
        return parts.joined(separator: ", ")
    }
}

struct SymbolGroup {
    let latestName: String
    let aliases: [String]  // Does not include latestName
    let introduced: PlatformVersions
    let timeline: [(year: String, name: String)]  // Sorted by year ascending
}

struct SymbolCase {
    let identifier: String
    let symbolName: String
    let availability: PlatformVersions
    let isAlias: Bool
    let aliasOf: String?  // Swift identifier of the canonical case
    let timeline: [(year: String, name: String)]
}

// MARK: - Configuration

struct Config {
    var sfSymbolsAppPath: String
    var outputPath: String
    var enumName: String
    var accessLevel: String
    var verbose: Bool
    
    static let `default` = Config(
        sfSymbolsAppPath: ProcessInfo.processInfo.environment["SFSYMBOLS_APP"] ?? "/Applications/SF Symbols.app",
        outputPath: "./SFSymbol.swift",
        enumName: "SFSymbol",
        accessLevel: "public",
        verbose: false
    )
}

var config = Config.default

// MARK: - Error Handling

func exitWithError(_ message: String, file: String = #file, line: Int = #line) -> Never {
    print("❌ Error: \(message)")
    exit(1)
}

// MARK: - Command-Line Parsing

func printUsage() {
    print("""
    SF Symbols Swift Generator
    
    Usage: swift generate-sf-symbols.swift [options]
    
    Options:
      --output <path>          Output file path (default: ./SFSymbol.swift)
      --enum-name <name>       Enum name (default: SFSymbol)
      --access <level>         Access level: public, internal, private (default: public)
      --sf-symbols-path <path> Path to SF Symbols.app (default: /Applications/SF Symbols.app)
      --verbose                Enable verbose output
      --help, -h               Show this help message
    
    Environment Variables:
      SFSYMBOLS_APP           Override SF Symbols app path
    
    Examples:
      swift generate-sf-symbols.swift
      swift generate-sf-symbols.swift --output Sources/SFSymbol.swift
      swift generate-sf-symbols.swift --enum-name MySymbol --access internal
      swift generate-sf-symbols.swift --verbose
    """)
}

func parseArguments() -> Config {
    var config = Config.default
    let args = CommandLine.arguments.dropFirst() // Skip script name
    var i = args.startIndex
    
    while i < args.endIndex {
        let arg = args[i]
        
        switch arg {
        case "--help", "-h":
            printUsage()
            exit(0)
            
        case "--output":
            i = args.index(after: i)
            guard i < args.endIndex else {
                exitWithError("--output requires a value")
            }
            config.outputPath = args[i]
            
        case "--enum-name":
            i = args.index(after: i)
            guard i < args.endIndex else {
                exitWithError("--enum-name requires a value")
            }
            config.enumName = args[i]
            
        case "--access":
            i = args.index(after: i)
            guard i < args.endIndex else {
                exitWithError("--access requires a value")
            }
            let level = args[i]
            guard ["public", "internal", "private"].contains(level) else {
                exitWithError("Invalid access level '\(level)'. Must be: public, internal, or private")
            }
            config.accessLevel = level
            
        case "--sf-symbols-path":
            i = args.index(after: i)
            guard i < args.endIndex else {
                exitWithError("--sf-symbols-path requires a value")
            }
            config.sfSymbolsAppPath = args[i]
            
        case "--verbose":
            config.verbose = true
            
        default:
            exitWithError("Unknown option: \(arg)\nUse --help for usage information")
        }
        
        i = args.index(after: i)
    }
    
    return config
}

// MARK: - File Loading

func loadPlist(at url: URL) -> [String: Any] {
    guard FileManager.default.fileExists(atPath: url.path) else {
        exitWithError("File not found: \(url.path)\nPlease ensure SF Symbols app is installed or set SFSYMBOLS_APP environment variable.")
    }
    
    guard let dict = NSDictionary(contentsOf: url) as? [String: Any] else {
        exitWithError("Failed to parse plist at: \(url.path)")
    }
    
    return dict
}

func loadStringsFile(at url: URL) -> [String: String] {
    guard FileManager.default.fileExists(atPath: url.path) else {
        exitWithError("File not found: \(url.path)")
    }
    
    if let dict = NSDictionary(contentsOf: url) as? [String: String] {
        return dict
    }
    
    // Fallback: manual parsing for .strings files
    guard let content = try? String(contentsOf: url, encoding: .utf8) else {
        exitWithError("Failed to read strings file at: \(url.path)")
    }
    
    var result: [String: String] = [:]
    let lines = content.components(separatedBy: .newlines)
    
    for line in lines {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty || trimmed.hasPrefix("//") || trimmed.hasPrefix("/*") {
            continue
        }
        
        // Parse "key" = "value";
        let pattern = #"\"([^\"]+)\"\s*=\s*\"([^\"]+)\"\s*;"#
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: trimmed, range: NSRange(trimmed.startIndex..., in: trimmed)) {
            if let keyRange = Range(match.range(at: 1), in: trimmed),
               let valueRange = Range(match.range(at: 2), in: trimmed) {
                let key = String(trimmed[keyRange])
                let value = String(trimmed[valueRange])
                result[key] = value
            }
        }
    }
    
    return result
}

// MARK: - Metadata Parsing

func parseAvailability(config: Config) -> (symbols: [String: String], yearToRelease: [String: PlatformVersions]) {
    let url = URL(fileURLWithPath: config.sfSymbolsAppPath)
        .appendingPathComponent("Contents/Resources/Metadata/name_availability.plist")
    
    let plist = loadPlist(at: url)
    
    guard let symbols = plist["symbols"] as? [String: String] else {
        exitWithError("Missing 'symbols' key in name_availability.plist")
    }
    
    guard let yearToReleaseRaw = plist["year_to_release"] as? [String: [String: String]] else {
        exitWithError("Missing 'year_to_release' key in name_availability.plist")
    }
    
    var yearToRelease: [String: PlatformVersions] = [:]
    for (year, platforms) in yearToReleaseRaw {
        yearToRelease[year] = PlatformVersions(
            iOS: platforms["iOS"],
            macOS: platforms["macOS"],
            tvOS: platforms["tvOS"],
            watchOS: platforms["watchOS"],
            visionOS: platforms["visionOS"]
        )
    }
    
    return (symbols, yearToRelease)
}

func parseAliases(config: Config) -> [String: String] {
    let metadataURL = URL(fileURLWithPath: config.sfSymbolsAppPath)
        .appendingPathComponent("Contents/Resources/Metadata")
    
    let nameAliasesURL = metadataURL.appendingPathComponent("name_aliases.strings")
    let legacyAliasesURL = metadataURL.appendingPathComponent("legacy_aliases.strings")
    
    var aliases: [String: String] = [:]
    
    // Load legacy aliases first
    let legacyAliases = loadStringsFile(at: legacyAliasesURL)
    aliases.merge(legacyAliases) { _, new in new }
    
    // Load name aliases (these override legacy)
    let nameAliases = loadStringsFile(at: nameAliasesURL)
    aliases.merge(nameAliases) { _, new in new }
    
    return aliases
}

func getSFSymbolsVersion(config: Config) -> String {
    let url = URL(fileURLWithPath: config.sfSymbolsAppPath)
        .appendingPathComponent("Contents/Info.plist")
    
    let plist = loadPlist(at: url)
    return plist["CFBundleShortVersionString"] as? String ?? "Unknown"
}

// MARK: - Alias Resolution

func resolveCanonicalName(_ name: String, aliases: [String: String], visited: inout Set<String>) -> String {
    if visited.contains(name) {
        print("⚠️  Warning: Cycle detected in alias chain for '\(name)'")
        return name
    }
    
    visited.insert(name)
    
    if let target = aliases[name] {
        return resolveCanonicalName(target, aliases: aliases, visited: &visited)
    }
    
    return name
}

func buildSymbolGroups(symbols: [String: String], aliases: [String: String], yearToRelease: [String: PlatformVersions]) -> [SymbolGroup] {
    // Resolve all canonical names
    var canonicalMap: [String: String] = [:]
    var allNames = Set(symbols.keys)
    allNames.formUnion(aliases.keys)
    allNames.formUnion(aliases.values)
    
    for name in allNames {
        var visited = Set<String>()
        canonicalMap[name] = resolveCanonicalName(name, aliases: aliases, visited: &visited)
    }
    
    // Group by canonical name
    var groups: [String: Set<String>] = [:]
    for name in allNames {
        let canonical = canonicalMap[name]!
        groups[canonical, default: []].insert(name)
    }
    
    // Build SymbolGroup objects
    var result: [SymbolGroup] = []
    
    for (latestName, nameSet) in groups {
        // Get all aliases (exclude the latest name itself)
        let aliases = nameSet.filter { $0 != latestName }.sorted()
        
        // Build timeline
        var timeline: [(year: String, name: String)] = []
        for name in nameSet {
            if let year = symbols[name] {
                timeline.append((year, name))
            }
        }
        timeline.sort { $0.year < $1.year }
        
        // Find earliest year for availability
        let earliestYear = timeline.first?.year ?? symbols[latestName] ?? "2019"
        
        guard let introduced = yearToRelease[earliestYear] else {
            print("⚠️  Warning: No release versions found for year '\(earliestYear)' (symbol: \(latestName))")
            continue
        }
        
        result.append(SymbolGroup(
            latestName: latestName,
            aliases: aliases,
            introduced: introduced,
            timeline: timeline
        ))
    }
    
    return result
}

// MARK: - Swift Identifier Sanitization

let swiftKeywords: Set<String> = [
    "associatedtype", "class", "deinit", "enum", "extension", "fileprivate", "func", "import",
    "init", "inout", "internal", "let", "open", "operator", "private", "precedencegroup",
    "protocol", "public", "rethrows", "static", "struct", "subscript", "typealias", "var",
    "break", "case", "catch", "continue", "default", "defer", "do", "else", "fallthrough",
    "for", "guard", "if", "in", "repeat", "return", "throw", "switch", "where", "while",
    "as", "false", "is", "nil", "self", "Self", "super", "throws", "true", "try",
    "Any", "Type"
]

func sanitizeIdentifier(_ name: String) -> String {
    var result = name
    
    // Special handling for numbered symbols (e.g., "01.circle" -> "circle_01")
    // Check if name starts with digits followed by a dot
    if let dotIndex = name.firstIndex(of: ".") {
        let prefix = name[..<dotIndex]
        if prefix.allSatisfy({ $0.isNumber }) {
            // Move the number to the end
            let number = String(prefix)
            let rest = String(name[name.index(after: dotIndex)...])
            result = rest + "_" + number
        }
    }
    
    // Replace periods and other special chars with underscores
    result = result.map { char in
        if char.isLetter || char.isNumber {
            return String(char)
        } else {
            return "_"
        }
    }.joined()
    
    // Collapse multiple underscores
    while result.contains("__") {
        result = result.replacingOccurrences(of: "__", with: "_")
    }
    
    // Remove leading/trailing underscores
    result = result.trimmingCharacters(in: CharacterSet(charactersIn: "_"))
    
    // If it still starts with a digit (edge case), prefix with "n"
    if let first = result.first, first.isNumber {
        result = "n" + result
    }
    
    // If result is empty, use placeholder
    if result.isEmpty {
        result = "symbol"
    }
    
    // Prefix with underscore if Swift keyword
    if swiftKeywords.contains(result) {
        result = "_" + result
    }
    
    return result
}

func generateIdentifiers(for groups: [SymbolGroup]) -> (cases: [SymbolCase], identifierMap: [String: String]) {
    var cases: [SymbolCase] = []
    var identifierCounts: [String: Int] = [:]
    var identifierMap: [String: String] = [:]
    
    for group in groups {
        // Generate identifier for latest name
        let baseIdentifier = sanitizeIdentifier(group.latestName)
        let count = identifierCounts[baseIdentifier, default: 0]
        identifierCounts[baseIdentifier] = count + 1
        
        let latestIdentifier: String
        if count == 0 {
            latestIdentifier = baseIdentifier
        } else {
            latestIdentifier = "\(baseIdentifier)__\(count + 1)"
        }
        
        identifierMap[latestIdentifier] = group.latestName
        
        cases.append(SymbolCase(
            identifier: latestIdentifier,
            symbolName: group.latestName,
            availability: group.introduced,
            isAlias: false,
            aliasOf: nil,
            timeline: group.timeline
        ))
        
        // Generate identifiers for aliases
        for alias in group.aliases {
            let aliasBaseIdentifier = sanitizeIdentifier(alias)
            let aliasCount = identifierCounts[aliasBaseIdentifier, default: 0]
            identifierCounts[aliasBaseIdentifier] = aliasCount + 1
            
            let aliasIdentifier: String
            if aliasCount == 0 {
                aliasIdentifier = aliasBaseIdentifier
            } else {
                aliasIdentifier = "\(aliasBaseIdentifier)__\(aliasCount + 1)"
            }
            
            identifierMap[aliasIdentifier] = alias
            
            cases.append(SymbolCase(
                identifier: aliasIdentifier,
                symbolName: alias,
                availability: group.introduced,
                isAlias: true,
                aliasOf: latestIdentifier,
                timeline: group.timeline
            ))
        }
    }
    
    return (cases.sorted { $0.identifier < $1.identifier }, identifierMap)
}

// MARK: - Code Generation

func generateSwiftCode(cases: [SymbolCase], yearToRelease: [String: PlatformVersions], version: String, config: Config) -> String {
    let timestamp = ISO8601DateFormatter().string(from: Date())
    
    var output = """
    // This file is auto-generated. Do not edit.
    // Generated on: \(timestamp)
    // SF Symbols version: \(version)
    
    import SwiftUI
    
    #if canImport(UIKit)
    import UIKit
    #endif
    
    #if canImport(AppKit)
    import AppKit
    #endif
    
    \(config.accessLevel) enum \(config.enumName): Sendable {
    
    """
    
    // Generate cases
    for symbolCase in cases {
        let availabilityAttr = symbolCase.availability.availabilityString()
        
        if symbolCase.isAlias, let aliasOf = symbolCase.aliasOf {
            output += "    @available(\(availabilityAttr))\n"
            output += "    @available(*, deprecated, renamed: \"\(aliasOf)\")\n"
            output += "    case \(symbolCase.identifier)\n"
        } else {
            output += "    @available(\(availabilityAttr))\n"
            output += "    case \(symbolCase.identifier)\n"
        }
        output += "    \n"
    }
    
    // Generate name property
    output += """
        \(config.accessLevel) var name: String {
            switch self {
    
    """
    
    for symbolCase in cases {
        if symbolCase.isAlias {
            // Alias cases return their literal name
            output += "            case .\(symbolCase.identifier): return \"\(symbolCase.symbolName)\"\n"
        } else if symbolCase.timeline.count > 1 {
            // Cases with renames use dynamic availability checks
            output += "            case .\(symbolCase.identifier):\n"
            
            // Sort timeline descending by year
            let sortedTimeline = symbolCase.timeline.sorted { $0.year > $1.year }
            
            for (index, entry) in sortedTimeline.enumerated() {
                if index == sortedTimeline.count - 1 {
                    // Last (oldest) entry is the fallback
                    output += "                return \"\(entry.name)\"\n"
                } else {
                    // Generate #available check
                    if let versions = yearToRelease[entry.year] {
                        let availStr = versions.availabilityString()
                        output += "                if #available(\(availStr)) {\n"
                        output += "                    return \"\(entry.name)\"\n"
                        output += "                }\n"
                    }
                }
            }
        } else {
            // Simple case with no renames
            output += "            case .\(symbolCase.identifier): return \"\(symbolCase.symbolName)\"\n"
        }
    }
    
    output += """
            }
        }
        
        @available(iOS 13.0, macOS 11.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
        \(config.accessLevel) var image: Image {
            Image(systemName: self.name)
        }
        
        #if canImport(UIKit)
        @available(iOS 13.0, tvOS 13.0, visionOS 1.0, *)
        \(config.accessLevel) var uiImage: UIImage? {
            UIImage(systemName: self.name)
        }
        #endif
        
        #if canImport(AppKit)
        @available(macOS 11.0, *)
        \(config.accessLevel) var nsImage: NSImage? {
            NSImage(systemSymbolName: self.name, accessibilityDescription: nil)
        }
        #endif
    }
    
    """
    
    return output
}

// MARK: - Main

func main() {
    // Parse command-line arguments
    let config = parseArguments()
    
    print("🔍 SF Symbols Swift Generator")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("SF Symbols app path: \(config.sfSymbolsAppPath)")
    
    if config.verbose {
        print("Output path: \(config.outputPath)")
        print("Enum name: \(config.enumName)")
        print("Access level: \(config.accessLevel)")
    }
    
    // Load metadata
    print("\n📦 Loading metadata...")
    let (symbols, yearToRelease) = parseAvailability(config: config)
    let aliases = parseAliases(config: config)
    let version = getSFSymbolsVersion(config: config)
    
    print("   • SF Symbols version: \(version)")
    print("   • Total symbols: \(symbols.count)")
    print("   • Total aliases: \(aliases.count)")
    print("   • Release years: \(yearToRelease.count)")
    
    // Build symbol groups
    print("\n🔗 Resolving symbol groups...")
    let groups = buildSymbolGroups(symbols: symbols, aliases: aliases, yearToRelease: yearToRelease)
    print("   • Unique symbol groups: \(groups.count)")
    
    // Generate identifiers
    print("\n✏️  Generating Swift identifiers...")
    let (cases, _) = generateIdentifiers(for: groups)
    let latestCases = cases.filter { !$0.isAlias }
    let aliasCases = cases.filter { $0.isAlias }
    print("   • Latest cases: \(latestCases.count)")
    print("   • Alias cases: \(aliasCases.count)")
    print("   • Total cases: \(cases.count)")
    
    // Generate Swift code
    print("\n📝 Generating Swift code...")
    let swiftCode = generateSwiftCode(cases: cases, yearToRelease: yearToRelease, version: version, config: config)
    
    // Write to file
    print("\n💾 Writing to \(config.outputPath)...")
    do {
        try swiftCode.write(toFile: config.outputPath, atomically: true, encoding: .utf8)
        let filename = (config.outputPath as NSString).lastPathComponent
        print("   ✅ Successfully generated \(filename)")
        print("\n🎉 Done! You can now use the \(config.enumName) enum in your project.")
    } catch {
        exitWithError("Failed to write output file: \(error.localizedDescription)")
    }
}

main()
