# Analysis of source_map and rustdoc changes

## Repository Context
This analysis is based on the Rust repository (`janis-bhm/rust`) to identify commits that:
1. Modified which files are loaded into the source_map file in the session of rustdoc
2. Changed how examples are handled in rustdoc

## Current State Analysis

### SourceMap File Loading Mechanism

The current implementation in `compiler/rustc_span/src/source_map.rs` shows:

#### Key File Loading Methods:
1. **`load_file()`** (line 241): Loads UTF-8 source files
   - Uses `self.file_loader.read_file(path)`
   - Creates `SourceFile` with normalization
   - Path: `path` -> `file_loader.read_file()` -> `new_source_file()`

2. **`load_binary_file()`** (line 251): Loads binary files
   - Uses `self.file_loader.read_binary_file(path)`
   - No normalization (preserves original content)
   - Also adds to SourceMap for dep-info tracking

3. **FileLoader trait** (lines 96-108): Abstraction for file operations
   - `file_exists()`: Check file existence
   - `read_file()`: Read UTF-8 content
   - `read_binary_file()`: Read binary content

#### RealFileLoader Implementation:
- **`read_file()`** (line 118): Standard file reading with size limits
  - Checks `SourceFile::MAX_FILE_SIZE` limit
  - Uses `file.read_to_string()` for UTF-8 content
  
- **`read_binary_file()`** (line 133): Optimized binary reading
  - Uses `Arc::new_uninit_slice()` for memory efficiency
  - Fallback to `Vec` if needed
  - Handles partial reads and file size changes

### Rustdoc Example Handling

Current implementation in `src/librustdoc/`:

1. **`scrape_examples.rs`**: Main example scraping functionality
   - Analyzes crates to find call sites for documentation examples
   - Uses `ScrapeExamplesOptions` for configuration
   - Processes target crates specified via CLI

2. **`doctest.rs`**: Documentation test handling
   - Handles extraction and running of doc tests
   - Contains `HirCollector` for HIR analysis
   - Manages temporary files and compilation

3. **Example scraping process**:
   - Target crates are analyzed for function calls
   - Call sites are extracted as potential examples
   - Examples are formatted and included in documentation

## Commit Analysis

Based on the available git history, there is one main commit:

### Commit 07d246fc (2025-08-31)
**Title**: "Auto merge of #146038 - notriddle:polarity, r=GuillaumeGomez"
**Description**: "rustdoc-search: split function inverted index by input/output"

**Analysis**: This commit appears to be adding the entire codebase (grafted commit), making it difficult to determine specific changes. The commit message indicates it's related to rustdoc search optimization, specifically splitting function inverted index by input/output for better search performance.

**Files Modified**:
- `compiler/rustc_span/src/source_map.rs` (1363+ lines)
- `src/librustdoc/*` (multiple files)
- Various example files in `compiler/rustc_codegen_cranelift/example/`

## Source Map Usage in Rustdoc

**Key Integration Points Found**:

1. **`src/librustdoc/html/sources.rs`**: 
   - Uses `sess.source_map().lookup_source_file(span.lo())` to locate source files
   - Renders source code for documentation

2. **`src/librustdoc/scrape_examples.rs`**:
   - Uses `tcx.sess.source_map()` to extract call site examples
   - `source_map.lookup_char_pos()` for position mapping
   - `source_map.span_extend_to_prev_char()` for span manipulation

3. **`src/librustdoc/doctest/rust.rs`**:
   - Contains `HirCollector` with `source_map: Arc<SourceMap>`
   - Uses source map for filename resolution and span operations
   - `tcx.sess.psess.clone_source_map()` for test collection

4. **`src/librustdoc/passes/lint/check_code_block_syntax.rs`**:
   - Creates new SourceMap instances for syntax checking
   - `Arc::new(SourceMap::new(FilePathMapping::empty()))`

5. **`src/librustdoc/core.rs`**:
   - Accepts optional SourceMap parameter for error formatting
   - Used for JSON error output configuration

## Comprehensive Analysis Results

### Source Map File Loading Changes
**Status**: No specific changes identified in the last 3 months due to limited git history (grafted commit).

**Current Architecture & Integration Points**:

1. **Core File Loading API** (`compiler/rustc_span/src/source_map.rs`):
   - `load_file()` - UTF-8 text file loading with normalization
   - `load_binary_file()` - Binary file loading without normalization  
   - `FileLoader` trait abstraction for pluggable file loading
   - `RealFileLoader` implementation using std::fs

2. **Rustdoc Integration Points**:
   - **Source rendering** (`src/librustdoc/html/sources.rs`): Uses `sess.source_map().lookup_source_file()` 
   - **Example scraping** (`src/librustdoc/scrape_examples.rs`): Uses source map for call site location
   - **Doc testing** (`src/librustdoc/doctest/rust.rs`): Maintains `Arc<SourceMap>` for span operations
   - **Syntax checking** (`src/librustdoc/passes/lint/check_code_block_syntax.rs`): Creates dedicated SourceMap instances

3. **Key Usage Patterns**:
   - `tcx.sess.source_map()` - Access session's source map
   - `source_map.lookup_char_pos()` - Position mapping  
   - `source_map.span_extend_*()` - Span manipulation
   - `SourceMap::new(FilePathMapping::empty())` - Isolated instances

### Rustdoc Example Handling Changes
**Status**: No specific changes identified in the last 3 months due to limited git history.

**Current Architecture & Mechanisms**:

1. **Example Scraping System** (`src/librustdoc/scrape_examples.rs`):
   - `ScrapeExamplesOptions` configuration structure
   - `CallData` and `CallLocation` for example metadata
   - HIR visitor pattern for call site discovery
   - Target crate filtering via CLI options

2. **Doc Test Processing** (`src/librustdoc/doctest/`):
   - `HirCollector` for AST/HIR analysis
   - `DocTestBuilder` for test compilation
   - Markdown example extraction and validation
   - Test runner integration

3. **Integration Flow**:
   ```
   Source Files → SourceMap → Span Analysis → Call Site Detection → Example Extraction → Documentation Generation
   ```

### Files With High Integration Density

**Source Map Heavy Users**:
- `src/librustdoc/scrape_examples.rs` (4 direct source_map calls)
- `src/librustdoc/doctest/rust.rs` (5+ source_map operations)
- `src/librustdoc/html/sources.rs` (source file rendering)
- `src/librustdoc/passes/lint/check_code_block_syntax.rs` (dedicated instances)

**Example Processing Centers**:
- `src/librustdoc/scrape_examples.rs` (main scraping logic)
- `src/librustdoc/doctest/` (entire module focused on examples)
- `src/librustdoc/config.rs` (CLI configuration)
- `src/librustdoc/html/render/mod.rs` (output generation)

## Recommendations

To get a complete analysis of changes in the last 3 months, would need:
1. Access to the full git history (not grafted)
2. Direct access to the upstream rust-lang/rust repository
3. Specific date range analysis (June 1 - September 1, 2025)

## Technical Details

### Source Map Architecture
```rust
SourceMap {
    files: RwLock<SourceMapFiles>,
    file_loader: IntoDynSyncSend<Box<dyn FileLoader + Sync + Send>>,
    path_mapping: FilePathMapping,
    hash_kind: SourceFileHashAlgorithm,
    checksum_hash_kind: Option<SourceFileHashAlgorithm>,
}
```

### Example Scraping Architecture
```rust
ScrapeExamplesOptions {
    output_path: PathBuf,
    target_crates: Vec<String>,
    scrape_tests: bool,
}
```

### Detailed Commit 07d246fc Analysis

**Commit Impact Assessment**:
- **Source Map Files**: `compiler/rustc_span/src/source_map.rs` added (1363+ lines) - appears to be initial codebase addition
- **Rustdoc Files**: Entire `src/librustdoc/` directory added - appears to be initial codebase addition  
- **Example Files**: Various example files in `compiler/rustc_codegen_cranelift/example/` added

**Key Findings**:
1. This appears to be a grafted commit that introduces the entire codebase rather than incremental changes
2. The commit message mentions "rustdoc-search: split function inverted index by input/output" which is a search optimization
3. No evidence of specific modifications to source_map file loading mechanisms or rustdoc example handling
4. Both systems appear to be mature, established features in their current form

### Summary & Conclusions

**Source Map File Loading**: The current implementation provides a robust, abstracted file loading system through the `FileLoader` trait with `RealFileLoader` handling standard filesystem operations. Integration with rustdoc occurs at multiple points for source rendering, example scraping, and doc testing.

**Rustdoc Example Handling**: A comprehensive system built around `ScrapeExamplesOptions`, HIR visitor patterns, and source map integration for extracting call sites as documentation examples.

**Limitation**: This analysis is constrained by the repository's grafted git history, preventing identification of incremental changes within the specified 3-month timeframe. The findings represent the current state rather than change tracking.

**Recommendation**: For complete change tracking, access to the full upstream rust-lang/rust repository history would be required to identify specific commits modifying these systems between June 1 - September 1, 2025.

## Date: 2025-09-01
## Repository: janis-bhm/rust  
## Analysis Method: Git analysis + Source code review + Pattern search
## Status: Complete (limited by grafted history)