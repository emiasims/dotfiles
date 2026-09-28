---
name: writing-slides
description: Use when creating slides, making a presentation, building a slide deck, writing a talk, or generating PowerPoint output from markdown
---

# Writing Slides with Quarto

## Overview

Create PowerPoint (`.pptx`) presentations from Quarto markdown (`.qmd`) files. This is a technical reference for syntax, layouts, and Mermaid diagrams. For content strategy (what to say, how many slides, narrative arc), use the brainstorming skill first.

**Render:** `quarto render slides.qmd`

## Content Rules

**No placeholders.** Every slide you write must contain real, final content — real text, real data, real diagram content. Never output placeholder text like "Add details here", "TODO", "Insert image", "[Your content]", or "Lorem ipsum". If you lack information to fill a slide, ask the user rather than inserting a placeholder. The only exception is if the user explicitly asks for a skeleton or template.

**Information density matters.** Slides should feel substantive, not sparse. Follow these guidelines:

- **Bullet slides:** 4-6 bullets minimum for a content slide. Each bullet should be a complete thought (a phrase or short sentence), not a single word. If a slide has only 2-3 short bullets, it's too empty — combine it with another slide or expand the points.
- **Two-column slides:** Both columns should have comparable density. Don't put 2 bullets opposite 5.
- **Diagram slides:** Pair diagrams with a brief explanation or key takeaway — don't leave a diagram alone with just a title.
- **Table slides:** Tables should have enough rows/columns to justify being a table (3+ rows of data). A 2-row table is better as bullets.
- **Speaker notes:** Use these to add depth. Put the narrative, context, and talking points here — this is where supporting detail belongs when the slide itself should stay visual.

If in doubt, err on the side of more content per slide rather than spreading thin content across many slides.

## Quick Reference

| Slide type | Markdown syntax |
|---|---|
| Title slide | Auto-generated from YAML `title`, `author`, `date` |
| Section header | `# Section Name` |
| Content slide | `## Slide Title` |
| Untitled slide | `---` (horizontal rule) |
| Two-column | `:::: {.columns}` with nested `:::  {.column}` divs |
| Blank slide | Slide with only non-breaking space or speaker notes |
| Background image | `## Title {background-image="img.png"}` |

## YAML Front Matter

```yaml
---
title: "Presentation Title"
author: "Author Name"
date: today
format:
  pptx:
    reference-doc: template.pptx  # optional custom template
    incremental: false             # bullet animation
    slide-level: 2                 # heading level that creates slides
---
```

## Slide Structure

- `#` = section title slide (Section Header layout)
- `##` = content slide (Title and Content layout)
- `---` = slide break without title
- Empty lines between elements are **required** to separate paragraphs

## Layouts

**Two columns:**
```markdown
:::: {.columns}

::: {.column}
Left content
:::

::: {.column}
Right content
:::

::::
```

PowerPoint auto-selects layout: "Two Content" for two text columns, "Comparison" if a column has text followed by non-text (image/table), "Content with Caption" for single-column text+image slides.

**Incremental lists:**
```markdown
::: {.incremental}
- First point
- Second point
:::
```
Use `{.nonincremental}` to override a global `incremental: true`.

**Speaker notes:**
```markdown
::: {.notes}
Speaker notes go here.
:::
```

**Figures and images:**
```markdown
![Caption](image.png){width=80%}
```

**Figure panels (side by side):**
```markdown
::: {layout-ncol=2}
![](fig1.png)

![](fig2.png)
:::
```

**Custom layout grid:**
```markdown
::: {layout="[[70,30], [100]]"}
![](a.png)

![](b.png)

![](c.png)
:::
```

## Mermaid Diagrams

Quarto natively renders Mermaid diagrams. For pptx output, they render as **PNG images** (requires Chrome/Chromium; install with `quarto install chromium` if needed).

````markdown
```{mermaid}
%%| fig-width: 6
%%| fig-cap: "System architecture"
flowchart LR
  A[Input] --> B[Process]
  B --> C[Output]
```
````

**Cell options** use `%%|` prefix (Mermaid's comment syntax):
- `%%| fig-width: 6` -- width in inches
- `%%| fig-cap: "Caption"` -- figure caption
- `%%| label: fig-arch` -- cross-reference label
- `%%| file: diagram.mmd` -- include from external file

**Available diagram types:** flowchart, sequence, state, class, ER, gantt, pie, mindmap, timeline, quadrant, gitgraph.

See quarto-pptx-ref.md in this directory for Mermaid syntax examples per diagram type.

## Templates

Extract default template: `quarto pandoc -o template.pptx --print-default-data-file reference.pptx`

Edit in PowerPoint, then reference it. Required layout names in template: Title Slide, Title and Content, Section Header, Two Content, Comparison, Content with Caption, Blank.

## Common Mistakes

| Mistake | Fix |
|---|---|
| Placeholder text in slides | **Never** write "TODO", "[Your content]", etc. Ask the user if you lack information |
| Slides too sparse (2 bullets, no notes) | Aim for 4-6 bullets per content slide; add speaker notes with talking points |
| Missing blank lines between images in layout | Each image must be its own paragraph (blank line above and below) |
| Mermaid diagram blank in pptx | Install Chrome: `quarto install chromium` |
| Diagram slide with no explanation | Add a sentence or key takeaway below or beside the diagram |
| Wrong slide layout chosen | PowerPoint layout is auto-selected based on content structure; use columns div for two-column |
| `#` heading creates unwanted section | Use `##` for regular slides; `#` always creates section headers |
| Background image not showing | Only "stretch" mode supported; image centered on larger axis |

**REQUIRED REFERENCE:** See quarto-pptx-ref.md for complete Mermaid examples, layout mapping details, and a full worked example.
