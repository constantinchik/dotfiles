---
name: compress-pdf
description: Compress a PDF file to under a target size (default 4MB strict). Use when the user wants to reduce PDF file size, compress a PDF, or make a PDF smaller.
argument-hint: <path-to-pdf> [target-size-mb]
---

# Compress PDF

Compress the given PDF to strictly under the target file size.

- **Input**: `$ARGUMENTS[0]` is the PDF path. `$ARGUMENTS[1]` is optional target size in MB (default: 4).
- **"Strictly under"** means the final file must be under `target_MB * 1,000,000` bytes (macOS base-10 reporting).

## Strategy

The compression works in 3 stages:

### Stage 1: Render pages to PNG via Swift + Quartz

Use a Swift script to render each PDF page to PNG at 150 DPI. This rasterizes all content uniformly.

```swift
import Cocoa
import Quartz

let doc = PDFDocument(url: URL(fileURLWithPath: INPUT_PATH))!
let dpiScale: CGFloat = 150.0 / 72.0

for i in 0..<doc.pageCount {
    let page = doc.page(at: i)!
    let b = page.bounds(for: .mediaBox)
    let w = Int(b.width * dpiScale)
    let h = Int(b.height * dpiScale)
    let img = NSImage(size: NSSize(width: w, height: h))
    img.lockFocus()
    NSColor.white.set()
    NSRect(x: 0, y: 0, width: w, height: h).fill()
    let ctx = NSGraphicsContext.current!.cgContext
    ctx.scaleBy(x: dpiScale, y: dpiScale)
    page.draw(with: .mediaBox, to: ctx)
    img.unlockFocus()
    let td = img.tiffRepresentation!
    let bm = NSBitmapImageRep(data: td)!
    let pngData = bm.representation(using: .png, properties: [:])!
    try! pngData.write(to: URL(fileURLWithPath: "\(OUTPUT_DIR)/page_\(String(format: "%03d", i)).png"))
}
```

### Stage 2: Find optimal scale + JPEG quality with Python + Pillow

Use Pillow to resize PNGs and convert to JPEG with varying quality. Binary search or sweep to find the best scale/quality combo that fits the target.

- Start at scale=1.0 (full 150 DPI) and reduce if needed
- Try JPEG qualities from high to low
- Prefer higher scale with lower quality over lower scale with higher quality (preserves detail)
- Scale 0.50 of 150 DPI = ~75 DPI with 1240x1754px pages is the practical floor for readability

### Stage 3: Assemble PDF with img2pdf

Use `img2pdf` (install via pip if needed) to combine JPEGs into a PDF. This embeds JPEG data directly without re-encoding, so the PDF size closely matches the sum of JPEG sizes.

```python
import img2pdf
letter = img2pdf.mm_to_pt(215.9), img2pdf.mm_to_pt(279.4)
layout = img2pdf.get_layout_fun(letter)
with open(output_pdf, "wb") as f:
    f.write(img2pdf.convert(jpg_paths, layout_fun=layout))
```

If pages are not US Letter, detect the original page size and use that instead.

## Important notes

- Always verify the final size with `os.path.getsize()` and compare against `target_MB * 1_000_000`
- macOS `ls -lh` uses base-10 (1M = 1,000,000 bytes), so use that as the threshold
- Clean up all temp files in `/tmp/` when done
- Output filename: append `_compressed` before `.pdf` extension, or `_<target>mb` (e.g. `_4mb`)
- Report final size, page count, effective DPI, and JPEG quality used
- If Ghostscript (`gs`) is available, try `gs -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/ebook` first as it's faster and preserves text. Fall back to the rasterization approach if gs is not installed.
