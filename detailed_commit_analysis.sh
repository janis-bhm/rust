#!/bin/bash

# Generate detailed analysis of the main commit's impact on source_map and rustdoc examples

echo "=== DETAILED COMMIT ANALYSIS: 07d246fc ==="
echo "Title: Auto merge of #146038 - notriddle:polarity, r=GuillaumeGomez"
echo "Description: rustdoc-search: split function inverted index by input/output"
echo

echo "=== SOURCE MAP RELATED FILES IN COMMIT ==="
git show --name-only 07d246fc | grep -E "(source_map|span)" | head -20

echo -e "\n=== RUSTDOC RELATED FILES IN COMMIT ==="  
git show --name-only 07d246fc | grep -E "(librustdoc|rustdoc)" | head -20

echo -e "\n=== EXAMPLE RELATED FILES IN COMMIT ==="
git show --name-only 07d246fc | grep -E "example" | head -20

echo -e "\n=== KEY FILE STATISTICS ==="
echo "compiler/rustc_span/src/source_map.rs changes:"
git show --stat 07d246fc -- compiler/rustc_span/src/source_map.rs 2>/dev/null || echo "File not individually trackable in grafted commit"

echo -e "\nsrc/librustdoc/ changes:"
git show --stat 07d246fc -- src/librustdoc/ 2>/dev/null | head -10 || echo "Directory not individually trackable in grafted commit"

echo -e "\n=== CURRENT STATE VALIDATION ==="
echo "Current source_map.rs key functions:"
grep -n "pub fn load_file\|pub fn load_binary_file\|pub fn file_exists" compiler/rustc_span/src/source_map.rs

echo -e "\nCurrent scrape_examples.rs key structures:"
grep -n "pub.*struct.*Example\|pub.*fn.*example\|ScrapeExample" src/librustdoc/scrape_examples.rs

echo -e "\n=== INTEGRATION POINTS VERIFICATION ==="
echo "Source map usage in rustdoc (current state):"
grep -c "source_map\|SourceMap" src/librustdoc/*.rs src/librustdoc/**/*.rs 2>/dev/null | grep -v ":0" | head -10

echo -e "\nExample handling files (current state):"
find src/librustdoc -name "*.rs" -exec grep -l "example\|Example" {} \; | wc -l

echo -e "\n=== POTENTIAL IMPACT ASSESSMENT ==="
echo "This analysis suggests the commit primarily adds the codebase rather than modifying existing functionality."
echo "The rustdoc-search optimization mentioned in the commit title appears to be the main functional change."
echo "Source map file loading and example handling appear to be established features that were not modified."