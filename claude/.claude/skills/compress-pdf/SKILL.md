---
name: compress-pdf
description: Compress a PDF file to under a target size (default 4MB strict). Use when the user wants to reduce PDF file size, compress a PDF, or make a PDF smaller.
argument-hint: <path-to-pdf> [target-size-mb]
---

# Compress PDF

Compress the given PDF to strictly under the target file size.

- **Input**: `$ARGUMENTS[0]` is the PDF path. `$ARGUMENTS[1]` is optional target size in MB (default: 4).
- **"Strictly under"** means the final file must be under `target_MB * 1,000,000` bytes (macOS base-10 reporting).

## How to run

Run the reusable script directly — no probing for gs, Swift, or other tools needed:

```bash
python3 ~/.claude/skills/compress-pdf/compress_pdf.py "<input.pdf>" [target_mb] [--page-size letter|a4|original]
```

The script handles everything:
1. Auto-installs missing dependencies (`PyMuPDF`, `Pillow`, `img2pdf`)
2. Renders pages via PyMuPDF (pure Python, no Swift/Xcode/Ghostscript needed)
3. Normalizes all pages to uniform size (default: US Letter)
4. Sweeps DPI (150 down to 100) and JPEG quality (85 down to 45) to find the best combo under target
5. Assembles final PDF with `img2pdf` (embeds JPEG directly, no re-encoding)
6. Reports final size, page count, DPI, and quality used
7. Cleans up temp files automatically

### Options

- `target_mb`: Target max file size in MB (default: 4)
- `--page-size letter|a4|original`: Normalize all pages to this size (default: letter). Use `original` to detect the majority page size from the input.

### Output

Output file is saved alongside the input as `<name>_compressed.pdf`.

## Important notes

- **Do NOT use Swift/Xcode** — the Xcode license may not be accepted, and Swift compilation is fragile. PyMuPDF handles PDF rendering natively in Python.
- **Do NOT probe for Ghostscript** — it's rarely installed on macOS. Skip straight to the script.
- **PyMuPDF page access**: Use `doc[i]` (subscript), NOT `doc.page(i)` — the latter doesn't exist in current PyMuPDF.
- The script prefers higher DPI with lower JPEG quality over lower DPI with higher quality (preserves detail).
- macOS `ls -lh` uses base-10 (1M = 1,000,000 bytes), so that's the threshold.
- If the user asks to normalize/unify page sizes, use `--page-size letter` (default behavior).
