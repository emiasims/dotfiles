# PDF Reading Advanced Reference

Advanced features and detailed examples for extracting content from PDFs.

## pypdfium2 (Apache/BSD License)

Python binding for PDFium (Chromium's PDF library). Fast rendering and text extraction.

### Render PDF to Images
```python
import pypdfium2 as pdfium

pdf = pdfium.PdfDocument("document.pdf")

# single page
page = pdf[0]
bitmap = page.render(scale=2.0)
img = bitmap.to_pil()
img.save("page_1.png", "PNG")

# all pages
for i, page in enumerate(pdf):
    bitmap = page.render(scale=1.5)
    img = bitmap.to_pil()
    img.save(f"page_{i+1}.png", "PNG")
```

### Extract Text
```python
import pypdfium2 as pdfium

pdf = pdfium.PdfDocument("document.pdf")
for i, page in enumerate(pdf):
    text = page.get_text()
    print(f"Page {i+1} text length: {len(text)} chars")
```

## pdfplumber Advanced Features

### Text with Precise Coordinates
```python
import pdfplumber

with pdfplumber.open("document.pdf") as pdf:
    page = pdf.pages[0]

    # every character with coordinates
    chars = page.chars
    for char in chars[:10]:
        print(f"Char: '{char['text']}' at x:{char['x0']:.1f} y:{char['y0']:.1f}")

    # text within a bounding box (left, top, right, bottom)
    bbox_text = page.within_bbox((100, 100, 400, 200)).extract_text()
```

### Advanced Table Extraction
```python
import pdfplumber

with pdfplumber.open("complex_table.pdf") as pdf:
    page = pdf.pages[0]

    # custom settings for complex layouts
    table_settings = {
        "vertical_strategy": "lines",
        "horizontal_strategy": "lines",
        "snap_tolerance": 3,
        "intersection_tolerance": 15
    }
    tables = page.extract_tables(table_settings)

    # visual debugging
    img = page.to_image(resolution=150)
    img.save("debug_layout.png")
```

## Advanced Command-Line Tools

### poppler-utils

#### Text with Bounding Box Coordinates
```bash
# XML output with precise coordinates for each text element
pdftotext -bbox-layout document.pdf output.xml
```

#### High-Resolution Image Conversion
```bash
# PNG at specific resolution
pdftoppm -png -r 300 document.pdf output_prefix

# specific page range at high resolution
pdftoppm -png -r 600 -f 1 -l 3 document.pdf high_res_pages

# JPEG with quality setting
pdftoppm -jpeg -jpegopt quality=85 -r 200 document.pdf jpeg_output
```

#### Extract Embedded Images
```bash
# with metadata, preserving page info
pdfimages -j -p document.pdf page_images

# list image info without extracting
pdfimages -list document.pdf

# extract in original format
pdfimages -all document.pdf images/img
```

## Extracting Figures from Academic Papers

### Method 1: pdfimages (fastest for embedded images)
```bash
pdfimages -all document.pdf images/img
```

### Method 2: Render and crop with pypdfium2
```python
import pypdfium2 as pdfium
from PIL import Image

pdf = pdfium.PdfDocument("paper.pdf")

for page_num, page in enumerate(pdf):
    # high-res render to preserve figure quality
    bitmap = page.render(scale=3.0)
    img = bitmap.to_pil()
    img.save(f"page_{page_num + 1}_hires.png", "PNG")

    # crop a known figure region (left, upper, right, lower)
    # figure = img.crop((100, 200, 800, 600))
    # figure.save(f"figure_{page_num + 1}.png", "PNG")
```

## Performance Tips

### Large PDFs
- Process pages individually with pypdfium2 rather than loading the entire document
- Use `pdftotext` for fast bulk text extraction

### Text Extraction
- `pdftotext -bbox-layout` is fastest for plain text
- pdfplumber is best for structured data and tables
- Avoid `pypdf.extract_text()` for very large documents

### Image Extraction
- `pdfimages` is much faster than rendering pages and cropping
- Use low resolution for previews, high resolution for final output

### Memory Management
```python
# process pages in chunks for large documents
from pypdf import PdfReader

def extract_text_chunked(pdf_path, chunk_size=10):
    reader = PdfReader(pdf_path)
    total_pages = len(reader.pages)
    all_text = []

    for start in range(0, total_pages, chunk_size):
        end = min(start + chunk_size, total_pages)
        chunk_text = ""
        for i in range(start, end):
            chunk_text += reader.pages[i].extract_text()
        all_text.append(chunk_text)

    return "\n".join(all_text)
```

## Troubleshooting

### Text Extraction Returns Garbage or Empty String
The PDF is likely scanned/image-based. Fall back to OCR:
```python
import pytesseract
from pdf2image import convert_from_path

def extract_text_with_ocr(pdf_path):
    images = convert_from_path(pdf_path)
    text = ""
    for i, image in enumerate(images):
        text += pytesseract.image_to_string(image)
    return text
```

### Multi-Column Layout Merges Columns
Use `pdftotext -layout` to preserve spatial layout, or use pdfplumber's character-level coordinates to reconstruct columns manually.

## License Information

- **pypdf**: BSD License
- **pdfplumber**: MIT License
- **pypdfium2**: Apache/BSD License
- **poppler-utils**: GPL-2 License
