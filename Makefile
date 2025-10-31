.PHONY: generate generate-package clean clean-all help test

help:
	@echo "SF Symbols Swift Generator"
	@echo "=========================="
	@echo ""
	@echo "Available commands:"
	@echo "  make generate         - Generate SFSymbol.swift to root directory"
	@echo "  make generate-package - Generate SFSymbol.swift to Swift Package"
	@echo "  make test            - Run Swift Package tests"
	@echo "  make clean           - Remove root SFSymbol.swift file"
	@echo "  make clean-all       - Remove all generated files including package"
	@echo "  make help            - Show this help message"
	@echo ""
	@echo "Environment variables:"
	@echo "  SFSYMBOLS_APP        - Path to SF Symbols app (default: /Applications/SF Symbols.app)"

generate:
	@swift generate-sf-symbols.swift

generate-package:
	@echo "Generating SFSymbol.swift for Swift Package..."
	@swift generate-sf-symbols.swift --output Sources/SFSymbolsKit/SFSymbol.swift
	@echo "✅ Package updated successfully"

test:
	@swift test

clean:
	@rm -f SFSymbol.swift
	@echo "✅ Cleaned root SFSymbol.swift"

clean-all:
	@rm -f SFSymbol.swift
	@rm -f Sources/SFSymbolsKit/SFSymbol.swift
	@echo "✅ Cleaned all generated files"
