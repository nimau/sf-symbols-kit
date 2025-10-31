# Command-Line Options

## Overview

The SF Symbols Swift Generator supports command-line options to customize the generated code.

## Usage

```bash
swift generate-sf-symbols.swift [options]
```

## Options

### `--output <path>`

Specify the output file path.

**Default:** `./SFSymbol.swift`

```bash
swift generate-sf-symbols.swift --output Sources/SFSymbols.swift
swift generate-sf-symbols.swift --output ~/MyProject/Generated/Symbols.swift
```

### `--enum-name <name>`

Specify the enum name in the generated code.

**Default:** `SFSymbol`

```bash
swift generate-sf-symbols.swift --enum-name AppSymbol
swift generate-sf-symbols.swift --enum-name MyCustomSymbol
```

**Generated code:**
```swift
public enum AppSymbol {
    case circle
    case heart_fill
    // ...
}
```

### `--access <level>`

Specify the access level for the enum and its properties.

**Default:** `public`  
**Valid values:** `public`, `internal`, `private`

```bash
# Public (default) - use in apps
swift generate-sf-symbols.swift --access public

# Internal - use in frameworks/libraries
swift generate-sf-symbols.swift --access internal

# Private - rarely used
swift generate-sf-symbols.swift --access private
```

**Generated code with `--access internal`:**
```swift
internal enum SFSymbol {
    case circle
    
    internal var name: String { ... }
    internal var image: Image { ... }
}
```

### `--sf-symbols-path <path>`

Specify the path to the SF Symbols.app bundle.

**Default:** `/Applications/SF Symbols.app`

```bash
swift generate-sf-symbols.swift --sf-symbols-path "/Custom/Path/SF Symbols.app"
```

**Note:** You can also use the `SFSYMBOLS_APP` environment variable:
```bash
export SFSYMBOLS_APP="/Custom/Path/SF Symbols.app"
swift generate-sf-symbols.swift
```

### `--verbose`

Enable verbose output to see additional generation details.

**Default:** `false`

```bash
swift generate-sf-symbols.swift --verbose
```

**Output includes:**
- Output path
- Enum name
- Access level
- Detailed progress information

### `--help`, `-h`

Show help message and exit.

```bash
swift generate-sf-symbols.swift --help
swift generate-sf-symbols.swift -h
```

## Examples

### Basic Generation

Default settings - public SFSymbol enum:

```bash
swift generate-sf-symbols.swift
```

### Framework/Library

Internal access level with custom output:

```bash
swift generate-sf-symbols.swift \
  --access internal \
  --output Sources/MyFramework/Symbols.swift
```

### Custom Enum Name

Different enum name for avoiding conflicts:

```bash
swift generate-sf-symbols.swift \
  --enum-name AppSymbol \
  --output Sources/AppSymbol.swift
```

### Multiple Apps/Targets

Generate different symbol enums for different targets:

```bash
# iOS app symbols
swift generate-sf-symbols.swift \
  --enum-name iOSSymbol \
  --output iOS/Symbols.swift

# macOS app symbols
swift generate-sf-symbols.swift \
  --enum-name MacSymbol \
  --output macOS/Symbols.swift
```

### Debugging

Verbose output to troubleshoot issues:

```bash
swift generate-sf-symbols.swift --verbose
```

### Custom SF Symbols Version

Use a different SF Symbols app version:

```bash
swift generate-sf-symbols.swift \
  --sf-symbols-path "/Applications/SF Symbols Beta.app"
```

## Common Use Cases

### Internal Framework

For a Swift Package or framework that shouldn't expose symbols publicly:

```bash
swift generate-sf-symbols.swift \
  --enum-name FrameworkSymbol \
  --access internal \
  --output Sources/MyFramework/Symbols.swift
```

**Usage in framework:**
```swift
// Internal use only
internal enum FrameworkSymbol {
    case circle
}

// Consumers can't access FrameworkSymbol directly
```

### Multiple Symbol Sets

Generate different symbol enums for different parts of your app:

```bash
# UI symbols
swift generate-sf-symbols.swift \
  --enum-name UISymbol \
  --output Sources/UI/Symbols.swift

# System symbols  
swift generate-sf-symbols.swift \
  --enum-name SystemSymbol \
  --output Sources/System/Symbols.swift
```

### Continuous Integration

Automate generation in CI/CD:

```bash
#!/bin/bash
# generate-symbols.sh

swift generate-sf-symbols.swift \
  --output Sources/Generated/SFSymbol.swift \
  --access public \
  --verbose

# Verify the file was generated
if [ ! -f "Sources/Generated/SFSymbol.swift" ]; then
    echo "Failed to generate symbols"
    exit 1
fi

echo "Successfully generated symbols"
```

## Configuration File Support (Future)

Currently, all options must be passed via command-line. In the future, we may add support for a configuration file:

```json
{
  "output": "Sources/SFSymbol.swift",
  "enumName": "SFSymbol",
  "accessLevel": "public",
  "sfSymbolsPath": "/Applications/SF Symbols.app",
  "verbose": false
}
```

## Environment Variables

### `SFSYMBOLS_APP`

Override the default SF Symbols app path:

```bash
export SFSYMBOLS_APP="/Custom/Path/SF Symbols.app"
swift generate-sf-symbols.swift
```

Command-line option takes precedence over environment variable:

```bash
export SFSYMBOLS_APP="/Path/A/SF Symbols.app"
swift generate-sf-symbols.swift --sf-symbols-path "/Path/B/SF Symbols.app"
# Uses /Path/B/SF Symbols.app
```

## Validation

The generator validates all inputs:

- **Access level:** Must be `public`, `internal`, or `private`
- **SF Symbols path:** Must exist and be readable
- **Output path:** Parent directory must exist
- **Enum name:** Must be a valid Swift identifier

**Error examples:**
```bash
# Invalid access level
swift generate-sf-symbols.swift --access protected
# ❌ Error: Invalid access level 'protected'. Must be: public, internal, or private

# Missing value
swift generate-sf-symbols.swift --output
# ❌ Error: --output requires a value

# Unknown option
swift generate-sf-symbols.swift --invalid-option
# ❌ Error: Unknown option: --invalid-option
# Use --help for usage information
```

## Tips

1. **Use `--verbose`** when debugging generation issues
2. **Use `--access internal`** for frameworks/libraries
3. **Use custom `--enum-name`** to avoid naming conflicts
4. **Set `SFSYMBOLS_APP`** once instead of repeating `--sf-symbols-path`
5. **Use absolute paths** for `--output` in CI/CD scripts
