#!/bin/bash

# Script to analyze changes in source_map file loading and rustdoc example handling
# This script searches for patterns that indicate changes to these systems

echo "=== SEARCHING FOR SOURCE_MAP FILE LOADING PATTERNS ==="

echo -e "\n1. Files that use source_map for file loading:"
find . -name "*.rs" -exec grep -l "source_map.*load_file\|source_map.*read_file\|\.load_file\|\.read_file" {} \; 2>/dev/null | head -20

echo -e "\n2. SourceMap creation and configuration:"
find . -name "*.rs" -exec grep -l "SourceMap::new\|SourceMap::with_inputs\|FileLoader" {} \; 2>/dev/null | head -20

echo -e "\n3. File loading in rustdoc specifically:"
find ./src/librustdoc -name "*.rs" -exec grep -l "load_file\|read_file\|file_loader" {} \; 2>/dev/null

echo -e "\n=== SEARCHING FOR RUSTDOC EXAMPLE HANDLING PATTERNS ==="

echo -e "\n4. Example scraping and processing:"
find ./src/librustdoc -name "*.rs" -exec grep -l "scrape.*example\|ScrapeExample\|CallData\|CallLocation" {} \; 2>/dev/null

echo -e "\n5. Doc test and example extraction:"
find ./src/librustdoc -name "*.rs" -exec grep -l "doctest\|extract.*example\|HirCollector" {} \; 2>/dev/null

echo -e "\n6. Example-related configuration:"
find ./src/librustdoc -name "*.rs" -exec grep -l "scrape_tests\|target_crates\|example.*option" {} \; 2>/dev/null

echo -e "\n=== ANALYZING CURRENT IMPLEMENTATIONS ==="

echo -e "\n7. Current source map file loading methods:"
grep -n "pub.*load_file\|pub.*read_file\|fn load_file\|fn read_file" ./compiler/rustc_span/src/source_map.rs 2>/dev/null | head -10

echo -e "\n8. Current example handling in rustdoc:"
grep -n "fn.*example\|struct.*Example\|impl.*Example" ./src/librustdoc/scrape_examples.rs 2>/dev/null | head -10

echo -e "\n=== COMMIT PATTERN SEARCH ==="

echo -e "\n9. Searching commit messages for relevant terms:"
git log --oneline --grep="source_map\|SourceMap\|file.*load\|rustdoc.*example\|example.*handling\|doctest" 2>/dev/null | head -20

echo -e "\n10. Searching for file changes in key areas:"
git log --oneline --since="2025-06-01" -- compiler/rustc_span/src/source_map.rs src/librustdoc/scrape_examples.rs src/librustdoc/doctest.rs 2>/dev/null | head -20

echo -e "\nAnalysis complete. Check the output above for relevant patterns."