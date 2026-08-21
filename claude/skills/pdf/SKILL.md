---
name: pdf
description: Use when the user wants to read, extract, or analyze content from PDF files. This includes extracting text and tables, extracting metadata, OCR on scanned PDFs, extracting embedded images, and rendering pages to images for visual analysis. If the user mentions reading a .pdf file, use this skill.
license: Proprietary. LICENSE.txt has complete terms
---

# PDF Reading Guide

## Overview

This guide covers extracting content from PDFs using Python libraries and command-line tools. For advanced features and detailed examples, see reference.md.

A bundled script `scripts/convert_pdf_to_images.py` renders PDF pages to PNGs -- useful for visual inspection, figure extraction, or passing pages to a vision model.

## Quick Start

```python
from pypdf import PdfReader

reader = PdfReader("document.pdf")
print(f"Pages: {len(reader.pages)}")

text = ""
for page in reader.pages:
    text += page.extract_text()
```

## Python Libraries

### pypdf - Text and Metadata

#### Extract Text
```python
from pypdf import PdfReader

reader = PdfReader("document.pdf")
for page in reader.pages:
    print(page.extract_text())
```

#### Extract Metadata
```python
reader = PdfReader("document.pdf")
meta = reader.metadata
print(f"Title: {meta.title}")
print(f"Author: {meta.author}")
print(f"Subject: {meta.subject}")
print(f"Creator: {meta.creator}")
```

### pdfplumber - Text and Table Extraction

Best choice for structured content like tables in academic papers.

#### Extract Text with Layout
```python
import pdfplumber

with pdfplumber.open("document.pdf") as pdf:
    for page in pdf.pages:
        text = page.extract_text()
        print(text)
```

#### Extract Tables
```python
with pdfplumber.open("document.pdf") as pdf:
    for i, page in enumerate(pdf.pages):
        tables = page.extract_tables()
        for j, table in enumerate(tables):
            print(f"Table {j+1} on page {i+1}:")
            for row in table:
                print(row)
```

#### Tables to DataFrames
```python
import pandas as pd

with pdfplumber.open("document.pdf") as pdf:
    all_tables = []
    for page in pdf.pages:
        tables = page.extract_tables()
        for table in tables:
            if table:
                df = pd.DataFrame(table[1:], columns=table[0])
                all_tables.append(df)

if all_tables:
    combined_df = pd.concat(all_tables, ignore_index=True)
```

## Rendering Pages to Images

Use the bundled script to convert PDF pages to PNGs (run from this skill's directory):

```bash
python scripts/convert_pdf_to_images.py <input.pdf> <output_directory/>
```

This produces one PNG per page, capped at 1000px on the longest side. Useful for:
- Visual inspection of complex layouts
- Passing pages to a vision model for figure/chart understanding
- Preprocessing for OCR

Or use pypdfium2 directly for more control (see reference.md).

## Command-Line Tools

### pdftotext (poppler-utils)
```bash
# extract text
pdftotext input.pdf output.txt

# preserve layout (useful for multi-column papers)
pdftotext -layout input.pdf output.txt

# specific page range
pdftotext -f 1 -l 5 input.pdf output.txt
```

### Extract Embedded Images
```bash
# using pdfimages (poppler-utils)
pdfimages -j input.pdf output_prefix

# extracts as output_prefix-000.jpg, output_prefix-001.jpg, etc.
```

## OCR for Scanned PDFs

```python
# requires: pip install pytesseract pdf2image
import pytesseract
from pdf2image import convert_from_path

images = convert_from_path('scanned.pdf')

text = ""
for i, image in enumerate(images):
    text += f"Page {i+1}:\n"
    text += pytesseract.image_to_string(image)
    text += "\n\n"
```

## Quick Reference

| Task | Best Tool | Notes |
|------|-----------|-------|
| Extract text | pdfplumber or pdftotext | pdfplumber for structured; pdftotext -layout for columns |
| Extract tables | pdfplumber | `page.extract_tables()` with custom settings for complex layouts |
| Extract metadata | pypdf | `reader.metadata` |
| Render to images | scripts/convert_pdf_to_images.py or pypdfium2 | bundled script or library for fine control |
| OCR scanned PDFs | pytesseract + pdf2image | convert to images first |
| Extract embedded images | pdfimages (poppler-utils) | fastest method |

## Next Steps

- For pypdfium2 rendering, advanced pdfplumber, and CLI details, see reference.md
