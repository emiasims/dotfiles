---
name: writing-revealjs
description: Use when creating Quarto revealjs HTML presentations -- slide syntax, layouts, themes, animations, diagrams, and interactive features in .qmd files
---

# Writing Revealjs Presentations

Create HTML presentations from Quarto `.qmd` files using the `revealjs` format. This is a technical reference for syntax, layouts, and revealjs-specific features. For content strategy (what to say, narrative arc, slide count), load the presentation planning skill first.

**Render:** `quarto render slides.qmd`
**Preview:** `quarto preview slides.qmd` (live reload during development)

Only render when the user requests it.

## Content Rules

**No placeholders.** Every slide must contain real, final content. Never write "TODO", "[Your content]", "Add details here", or similar. If information is missing, ask the user.

**Information density matters.**

- **Bullet slides:** 4-6 bullets minimum. Each bullet is a complete thought, not a single word.
- **Two-column slides:** Both columns should have comparable density.
- **Diagram slides:** Pair diagrams with a brief explanation or key takeaway -- never leave a diagram alone with just a title.
- **Table slides:** 3+ rows of data to justify being a table. Smaller data is better as bullets.
- **Speaker notes:** Use these for narrative, context, and talking points. The slide is the visual aid; the notes are the actual talk.

If in doubt, more content per slide rather than spreading thin content across many slides.

## Quick Reference

| Slide type | Markdown syntax |
|---|---|
| Title slide | Auto-generated from YAML `title`, `author`, `date` |
| Section header | `# Section Name` |
| Content slide | `## Slide Title` |
| Untitled slide | `---` (horizontal rule) |
| Two-column | `:::: {.columns}` with nested `::: {.column}` divs |
| Speaker notes | `::: {.notes}` ... `:::` |
| Pause (reveal next) | `. . .` (three dots separated by spaces) |
| Incremental list | `::: {.incremental}` ... `:::` |
| Non-incremental list | `::: {.nonincremental}` ... `:::` |
| Background image | `## Title {background-image="img.png"}` |
| Background color | `## Title {background-color="aquamarine"}` |
| Smaller text | `## Title {.smaller}` |
| Scrollable slide | `## Title {.scrollable}` |

## YAML Front Matter

Minimal working template:

```yaml
---
title: "Presentation Title"
author: "Author Name"
date: today
format:
  revealjs:
    theme: default
    slide-number: true
    footer: "Footer text"
---
```

### Key Options

| Option | Default | Effect |
|---|---|---|
| `theme` | `default` | Visual theme (see reference/theming.md for full list) |
| `incremental` | `false` | All lists reveal one item at a time |
| `slide-level` | `2` | Heading level that creates slides |
| `slide-number` | `false` | Show slide numbers (`true`, `c/t`, `c`, `h/v`) |
| `footer` | none | Text shown at bottom of every slide |
| `logo` | none | Image shown at bottom-right of every slide |
| `smaller` | `false` | Use smaller typeface globally |
| `scrollable` | `false` | Allow scrolling on overflowing slides |
| `embed-resources` | `false` | Self-contained HTML (no external files) |
| `transition` | `none` | Slide transition effect (see reference/animations.md) |
| `auto-stretch` | `true` | Single images auto-fill remaining space |
| `width` | `1050` | Presentation width in pixels |
| `height` | `700` | Presentation height in pixels |
| `center` | `false` | Vertically center slide content |

## Slide Structure

- `#` heading = section title slide (large centered text, used to divide major sections)
- `##` heading = content slide (title bar + content area)
- `---` = slide break without a title
- Empty lines between elements are required to separate paragraphs and block elements

The title slide is auto-generated from YAML metadata. To skip it, omit `title` and `author` from the YAML.

## Slide Backgrounds

Five background types. Apply via attributes on the slide heading.

**Color:**
```markdown
## Slide Title {background-color="#1a1a2e"}
```

**Gradient:**
```markdown
## Slide Title {background-gradient="linear-gradient(to bottom, #283b95, #17b2c3)"}
```

**Image:**
```markdown
## Slide Title {background-image="image.png" background-size="cover" background-opacity="0.5"}
```

**Video:**
```markdown
## Slide Title {background-video="video.mp4" background-video-loop="true" background-video-muted="true"}
```

**IFrame:**
```markdown
## Slide Title {background-iframe="https://example.com"}
```

**Title slide background** uses a different pattern -- attributes go under `title-slide-attributes` in YAML with a `data-` prefix:

```yaml
title-slide-attributes:
  data-background-image: /path/to/image.png
  data-background-size: contain
  data-background-opacity: "0.5"
```

If your background is dark and your theme is light (or vice versa), set `background-color` explicitly so text remains readable.

## Columns and Layout

**Two columns:**
```markdown
:::: {.columns}

::: {.column width="40%"}
Left content
:::

::: {.column width="60%"}
Right content
:::

::::
```

**Stretch image** to fill remaining space:
```markdown
![](image.png){.r-stretch}
```
Single top-level images auto-stretch by default. Disable per-slide with `{.nostretch}` on the heading or per-image with `{.nostretch}` on the image. Disable globally with `auto-stretch: false`.

**Fit text** to fill slide width:
```markdown
::: {.r-fit-text}
Big Text
:::
```

**Absolute positioning:**
```markdown
![](image.png){.absolute top=200 left=0 width="350" height="300"}
```
Values are in pixels relative to the 1050x700 default slide size.

**Center a slide vertically:**
```markdown
## Slide Title {.center}
```

## Mermaid Diagrams

Quarto natively renders Mermaid diagrams. In revealjs output they render as SVG -- no Chromium install needed (unlike pptx).

````markdown
```{mermaid}
%%| fig-width: 8
%%| fig-cap: "System architecture"
flowchart LR
  A[Input] --> B[Process]
  B --> C[Output]
```
````

**Cell options** (use `%%|` prefix):

| Option | Effect |
|---|---|
| `%%| fig-width: 6` | Width in inches |
| `%%| fig-cap: "Caption"` | Figure caption |
| `%%| label: fig-arch` | Cross-reference label |
| `%%| file: diagram.mmd` | Include from external file |

**Available diagram types:** flowchart, sequence, state, class, ER, gantt, pie, mindmap, timeline, quadrant, gitgraph.

## Code Blocks

Revealjs presentations don't echo code by default (to maximize visual space). Override with `echo: true`.

**Syntax highlighting with line numbers:**
````markdown
```{.python code-line-numbers="6-8"}
import numpy as np
r = np.arange(0, 2, 0.01)
theta = 2 * np.pi * r
fig, ax = plt.subplots(subplot_kw={'projection': 'polar'})
ax.plot(theta, r)
ax.set_rticks([0.5, 1, 1.5, 2])
ax.grid(True)
plt.show()
```
````

**Progressive line highlighting** -- separate ranges with `|`:
````markdown
```{.python code-line-numbers="|6|9"}
```
````
This shows all lines first, then highlights line 6, then line 9.

**Code block height** -- default max is 500px with scroll. Increase globally:
```yaml
format:
  revealjs:
    code-block-height: 650px
```

**Executable code** (if a language kernel is available):
````markdown
```{python}
#| echo: true
#| output-location: slide
import matplotlib.pyplot as plt
plt.plot([1, 2, 3], [1, 4, 9])
plt.show()
```
````

`output-location` options: `fragment` (reveal on next step), `slide` (next slide), `column` (side by side), `column-fragment`.

## Tabsets

```markdown
::: {.panel-tabset}

### Tab A
Content for Tab A

### Tab B
Content for Tab B

:::
```

Only the first tab is visible when printing to PDF.

## Asides and Footnotes

**Aside** (peripheral content, small font at bottom):
```markdown
::: aside
Additional commentary shown at the bottom of the slide.
:::
```

**Footnote:**
```markdown
- Point one ^[This is a footnote]
```

## Rendering

- **Build:** `quarto render slides.qmd`
- **Live preview:** `quarto preview slides.qmd` (auto-reloads on save)
- **Self-contained:** Add `embed-resources: true` to YAML for a single distributable HTML file. Note: this is incompatible with the chalkboard plugin.

## Common Mistakes

| Mistake | Fix |
|---|---|
| Placeholder text in slides | Ask the user for real content. Never write "TODO" or "[Your content]" |
| Slides too sparse (2 bullets) | 4-6 bullets per content slide. Add speaker notes for depth |
| Pause syntax wrong (`...`) | Three dots with spaces: `. . .` |
| Title slide background not showing | Use `title-slide-attributes` with `data-` prefix in YAML |
| Auto-stretch breaks scrollable slides | Add `.nostretch` to the slide heading or disable `auto-stretch` globally |
| Hidden slides still count in progress bar | Use `visibility="uncounted"` to exclude from numbering |
| Mermaid blank in speaker notes view | Speaker notes can't load external JS. Mermaid renders fine on the main slide |
| Dark background with light theme | Set `background-color` explicitly so text color adjusts |
| Tabsets missing in PDF | Only the first tab prints. Put critical content in the first tab |

## Advanced Features

These are covered in reference files. Read them only when the presentation design calls for it.

- **Transitions and auto-animate:** See reference/animations.md
- **Fragments (progressive reveal):** See reference/animations.md
- **Theming and custom Sass:** See reference/theming.md -- only access with user's permission
- **Presenting tools, PDF export, plugins:** See reference/presenting.md
