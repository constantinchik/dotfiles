#!/usr/bin/env python3
"""
Compress a PDF to under a target size by rasterizing pages to JPEG.
Normalizes all pages to a uniform size (US Letter by default).

Requirements: pip3 install PyMuPDF Pillow img2pdf

Usage: python3 compress_pdf.py <input.pdf> [target_mb] [--page-size letter|a4|original]
"""

import sys
import os
import tempfile
import shutil

def ensure_dependencies():
    """Check and install missing dependencies."""
    missing = []
    for mod, pkg in [("fitz", "PyMuPDF"), ("PIL", "Pillow"), ("img2pdf", "img2pdf")]:
        try:
            __import__(mod)
        except ImportError:
            missing.append(pkg)
    if missing:
        import subprocess
        print(f"Installing: {', '.join(missing)}")
        subprocess.check_call([sys.executable, "-m", "pip", "install", "-q"] + missing)

ensure_dependencies()

import fitz
from PIL import Image
import img2pdf


# Page sizes in points (width, height) and mm
PAGE_SIZES = {
    "letter": {"pts": (612, 792), "mm": (215.9, 279.4)},
    "a4":     {"pts": (595.28, 841.89), "mm": (210, 297)},
}


def detect_majority_size(doc):
    """Detect the most common page size in the document."""
    from collections import Counter
    sizes = Counter()
    for i in range(doc.page_count):
        r = doc[i].rect
        sizes[(round(r.width), round(r.height))] += 1
    return sizes.most_common(1)[0][0]


def compress_pdf(input_path, target_mb=4, page_size="letter"):
    """
    Compress PDF by rasterizing to JPEG and reassembling.

    Args:
        input_path: Path to input PDF
        target_mb: Target max size in MB (macOS base-10, 1MB = 1,000,000 bytes)
        page_size: "letter", "a4", or "original" (use majority page size)

    Returns:
        output_path: Path to compressed PDF
    """
    target_bytes = int(target_mb * 1_000_000)

    # Generate output path
    base, ext = os.path.splitext(input_path)
    output_path = f"{base}_compressed{ext}"

    doc = fitz.open(input_path)
    input_size = os.path.getsize(input_path)
    print(f"Input: {input_size/1_000_000:.2f} MB, {doc.page_count} pages")

    # Determine target page size
    if page_size == "original":
        w_pt, h_pt = detect_majority_size(doc)
        w_mm = w_pt / 72 * 25.4
        h_mm = h_pt / 72 * 25.4
        print(f"Using detected page size: {w_pt} x {h_pt} pts ({w_mm:.0f} x {h_mm:.0f} mm)")
    else:
        ps = PAGE_SIZES[page_size]
        w_pt, h_pt = ps["pts"]
        w_mm, h_mm = ps["mm"]

    tmpdir = tempfile.mkdtemp(prefix="pdfcompress_")

    try:
        best = None

        # Sweep DPI (high to low), then quality (high to low)
        # Prefer higher DPI — it preserves detail better
        for dpi in [150, 130, 120, 110, 100]:
            for quality in [85, 75, 65, 55, 45]:
                size, paths = _render_pages(doc, tmpdir, dpi, quality, w_pt, h_pt)
                print(f"  DPI={dpi}, quality={quality}: {size/1_000_000:.2f} MB")

                if size < target_bytes:
                    best = (dpi, quality, size, paths)
                    break  # Best quality at this DPI, stop quality sweep

            if best and best[0] == dpi:
                break  # Found working combo at highest possible DPI

        if best is None:
            print("ERROR: Cannot compress below target even at lowest settings!")
            return None

        dpi, quality, est_size, jpg_paths = best
        print(f"\nSelected: DPI={dpi}, quality={quality}, est. size={est_size/1_000_000:.2f} MB")

        # Assemble PDF — img2pdf embeds JPEG directly (no re-encoding)
        layout_size = (img2pdf.mm_to_pt(w_mm), img2pdf.mm_to_pt(h_mm))
        layout = img2pdf.get_layout_fun(layout_size)

        with open(output_path, "wb") as f:
            f.write(img2pdf.convert(jpg_paths, layout_fun=layout))

        final_size = os.path.getsize(output_path)

        print(f"\nOutput: {output_path}")
        print(f"Final size: {final_size/1_000_000:.2f} MB ({final_size:,} bytes)")
        print(f"Target: {target_mb} MB ({target_bytes:,} bytes)")
        print(f"Under target: {'YES' if final_size < target_bytes else 'NO'}")
        print(f"Pages: {doc.page_count} | DPI: {dpi} | JPEG quality: {quality}")
        print(f"Page size: {w_mm:.0f} x {h_mm:.0f} mm")

        if final_size >= target_bytes:
            print("WARNING: Final size exceeds target!")
            return None

        return output_path

    finally:
        shutil.rmtree(tmpdir, ignore_errors=True)
        doc.close()


def _render_pages(doc, tmpdir, dpi, quality, target_w_pt, target_h_pt):
    """Render all pages to JPEG at given DPI/quality, normalized to target size."""
    scale = dpi / 72.0
    target_w_px = int(target_w_pt * scale)
    target_h_px = int(target_h_pt * scale)

    jpg_paths = []
    total_size = 0

    for i in range(doc.page_count):
        page = doc[i]
        page_rect = page.rect

        # Scale to fit within target pixel dimensions (maintain aspect ratio)
        sx = target_w_px / page_rect.width
        sy = target_h_px / page_rect.height
        page_scale = min(sx, sy)

        mat = fitz.Matrix(page_scale, page_scale)
        pix = page.get_pixmap(matrix=mat, alpha=False)

        img = Image.frombytes("RGB", [pix.width, pix.height], pix.samples)

        # Center on white canvas of exact target dimensions
        canvas = Image.new("RGB", (target_w_px, target_h_px), (255, 255, 255))
        x_off = (target_w_px - img.width) // 2
        y_off = (target_h_px - img.height) // 2
        canvas.paste(img, (x_off, y_off))

        jpg_path = os.path.join(tmpdir, f"page_{i:03d}.jpg")
        canvas.save(jpg_path, "JPEG", quality=quality, optimize=True)
        total_size += os.path.getsize(jpg_path)
        jpg_paths.append(jpg_path)

    return total_size, jpg_paths


if __name__ == "__main__":
    if len(sys.argv) < 2 or sys.argv[1] in ("-h", "--help"):
        print(f"Usage: {sys.argv[0]} <input.pdf> [target_mb] [--page-size letter|a4|original]")
        sys.exit(0 if "--help" in sys.argv or "-h" in sys.argv else 1)

    input_pdf = sys.argv[1]
    if not os.path.isfile(input_pdf):
        print(f"Error: file not found: {input_pdf}")
        sys.exit(1)
    target = 4.0
    page_size = "letter"

    args = sys.argv[2:]
    i = 0
    while i < len(args):
        if args[i] == "--page-size" and i + 1 < len(args):
            page_size = args[i + 1]
            i += 2
        else:
            try:
                target = float(args[i])
            except ValueError:
                print(f"Unknown argument: {args[i]}")
                sys.exit(1)
            i += 1

    result = compress_pdf(input_pdf, target, page_size)
    sys.exit(0 if result else 1)
