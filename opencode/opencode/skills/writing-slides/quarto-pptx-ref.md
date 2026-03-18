# Quarto PowerPoint Reference

## PowerPoint Layout Mapping

The pptx writer auto-selects layouts based on slide content:

| Layout name | Trigger |
|---|---|
| **Title Slide** | First slide, generated from YAML `title`, `author`, `date` |
| **Section Header** | `#` heading (above slide-level) |
| **Title and Content** | `##` heading with content (default for most slides) |
| **Two Content** | Slide with `:::: {.columns}` containing 2+ columns of same-type content |
| **Comparison** | Two-column slide where at least one column has text followed by non-text |
| **Content with Caption** | Non-two-column slide with text followed by non-text (image/table) |
| **Blank** | Slide with only blank content, non-breaking space, or only speaker notes |

## Complete YAML Options

```yaml
---
title: "Title"
subtitle: "Subtitle"
author: "Name"
date: today
format:
  pptx:
    reference-doc: template.pptx   # custom PowerPoint template
    incremental: false              # animate bullet lists
    slide-level: 2                  # heading level for slides
    toc: false                      # table of contents slide
    number-sections: false          # number section headings
    fig-width: 7                    # default figure width (inches)
    fig-height: 5                   # default figure height (inches)
    fig-cap-location: bottom        # top, bottom
    default-image-extension: png    # fallback image format
---
```

## Mermaid Diagram Types with Examples

All diagrams use the `{mermaid}` executable cell. For pptx, they render as PNG via Chrome.

### Flowchart

````markdown
```{mermaid}
%%| fig-width: 7
flowchart TD
  A[Start] --> B{Decision}
  B -->|Yes| C[Action 1]
  B -->|No| D[Action 2]
  C --> E[End]
  D --> E
```
````

Direction options: `TB` (top-bottom), `TD` (top-down), `BT`, `LR` (left-right), `RL`.

Node shapes: `[Rectangle]`, `(Rounded)`, `{Diamond}`, `([Stadium])`, `[[Subroutine]]`, `[(Cylinder)]`, `((Circle))`, `>Asymmetric]`, `{Hexagon}`, `[/Parallelogram/]`.

### Sequence Diagram

````markdown
```{mermaid}
sequenceDiagram
  participant A as Alice
  participant B as Bob
  A->>B: Hello Bob
  B-->>A: Hi Alice
  A->>B: How are you?
  Note right of B: Bob thinks
  B-->>A: Fine thanks!
```
````

Arrow types: `->>` (solid with arrowhead), `-->>` (dotted with arrowhead), `-x` (solid with cross), `--x` (dotted with cross).

### State Diagram

````markdown
```{mermaid}
stateDiagram-v2
  [*] --> Idle
  Idle --> Processing: start
  Processing --> Done: complete
  Processing --> Error: fail
  Error --> Idle: retry
  Done --> [*]
```
````

### Class Diagram

````markdown
```{mermaid}
classDiagram
  class Animal {
    +String name
    +int age
    +makeSound()
  }
  class Dog {
    +fetch()
  }
  Animal <|-- Dog
```
````

### Entity-Relationship Diagram

````markdown
```{mermaid}
erDiagram
  CUSTOMER ||--o{ ORDER : places
  ORDER ||--|{ LINE-ITEM : contains
  PRODUCT ||--o{ LINE-ITEM : "is in"
```
````

Relationship types: `||--||` (one-to-one), `||--o{` (one-to-many), `}o--o{` (many-to-many).

### Gantt Chart

````markdown
```{mermaid}
gantt
  title Project Timeline
  dateFormat YYYY-MM-DD
  section Phase 1
    Task A :a1, 2024-01-01, 30d
    Task B :after a1, 20d
  section Phase 2
    Task C :2024-03-01, 25d
```
````

### Pie Chart

````markdown
```{mermaid}
pie title Distribution
  "Category A" : 45
  "Category B" : 30
  "Category C" : 25
```
````

### Mindmap

````markdown
```{mermaid}
mindmap
  root((Central Topic))
    Branch A
      Leaf 1
      Leaf 2
    Branch B
      Leaf 3
```
````

### Timeline

````markdown
```{mermaid}
timeline
  title Project History
  2020 : Initial concept
  2021 : Prototype
       : First users
  2022 : Launch
  2023 : Scale
```
````

### Gitgraph

````markdown
```{mermaid}
gitgraph
  commit
  commit
  branch develop
  checkout develop
  commit
  commit
  checkout main
  merge develop
  commit
```
````

## Mermaid Cell Options

All options use `%%|` prefix (placed directly after opening fence):

```
%%| label: fig-diagram       # cross-reference ID (must start with fig-)
%%| fig-cap: "Caption text"  # figure caption
%%| fig-width: 6.5           # width in inches
%%| fig-height: 4            # height in inches (optional, auto-calculated)
%%| file: diagram.mmd        # include from external file
%%| echo: true               # show source code (default: false)
```

## Figure and Image Syntax

**Basic image:**
```markdown
![Alt text](image.png)
```

**Sized image:**
```markdown
![](image.png){width=80%}
![](image.png){width=4in}
![](image.png){width=300}  # pixels
```

**Figure with cross-reference:**
```markdown
![Caption](image.png){#fig-myimage}

See @fig-myimage for details.
```

**Subfigures:**
```markdown
::: {#fig-comparison layout-ncol=2}

![Before](before.png){#fig-before}

![After](after.png){#fig-after}

Comparison of results
:::
```

## Custom Layout Patterns

**Equal columns:**
```markdown
::: {layout-ncol=2}
content1

content2
:::
```

**Unequal columns:**
```markdown
::: {layout="[[70,30]]"}
wider content

narrower content
:::
```

**Multiple rows:**
```markdown
::: {layout-nrow=2}
![](a.png)

![](b.png)

![](c.png)

![](d.png)
:::
```

**Complex grid (2 top, 1 spanning bottom):**
```markdown
::: {layout="[[1,1], [1]]"}
![](a.png)

![](b.png)

![](c.png)
:::
```

**Spacing between elements (negative values):**
```markdown
::: {layout="[[40,-20,40]]"}
![](a.png)

![](b.png)
:::
```

## Tables in Slides

**Pipe table:**
```markdown
| Col A | Col B | Col C |
|-------|-------|-------|
| 1     | 2     | 3     |
| 4     | 5     | 6     |
```

**Grid table (supports multi-line cells):**
```markdown
+-------+-------+
| Col A | Col B |
+=======+=======+
| Long  | Short |
| text  |       |
+-------+-------+
```

## Complete Worked Example

```markdown
---
title: "Introducing Our New Architecture"
author: "Jane Smith"
date: today
format:
  pptx:
    reference-doc: company-template.pptx
---

# Background

## The Problem

- Average API response time has increased 3x over the past 18 months, now exceeding 800ms for core endpoints
- Monolithic codebase makes it difficult to onboard new developers — ramp-up time is ~3 months
- Single deployment pipeline means a bug in one module blocks releases for the entire system
- Vertical scaling has hit practical limits; current instance is at 85% memory utilization at peak
- Lack of fault isolation: a failure in the payment module brought down the entire application for 4 hours in Q3

::: {.notes}
Frame this around business impact. The Q3 outage cost us approximately $200K in lost transactions and significantly eroded customer trust. Engineering velocity has dropped — we shipped 40% fewer features this year compared to last year, despite adding two engineers to the team. The scaling ceiling means we cannot handle projected growth for the next holiday season without a fundamental architecture change.
:::

## Current Architecture

All traffic flows through a single monolithic API server. The web UI, mobile clients, and third-party integrations all hit the same service, which handles authentication, business logic, and data access in one process.

```{mermaid}
%%| fig-width: 7
%%| fig-cap: "Current monolithic architecture — single API handles all domains"
flowchart LR
  UI[Web UI] --> API[Monolith API]
  Mobile[Mobile App] --> API
  API --> DB[(PostgreSQL)]
  API --> Cache[(Redis Cache)]
```

::: {.notes}
Point out that every request, whether it's a simple profile lookup or a complex payment flow, goes through the same deployment. This means the payment team can't ship independently of the search team. The database is also a single point of contention — schema migrations require coordinated downtime.
:::

# Proposed Solution

## New Architecture

We propose decomposing the monolith into domain-aligned microservices behind an API gateway. Each service owns its data store and can be deployed, scaled, and monitored independently.

```{mermaid}
%%| fig-width: 7
%%| fig-cap: "Proposed microservices architecture with independent data stores"
flowchart LR
  UI[Web UI] --> GW[API Gateway]
  Mobile[Mobile App] --> GW
  GW --> Auth[Auth Service]
  GW --> Orders[Order Service]
  GW --> Payments[Payment Service]
  GW --> Search[Search Service]
  Auth --> AuthDB[(Auth DB)]
  Orders --> OrderDB[(Order DB)]
  Payments --> PayDB[(Payment DB)]
  Search --> ES[(Elasticsearch)]
```

::: {.notes}
The API gateway handles routing, rate limiting, and authentication token validation. Each service communicates asynchronously via an event bus for cross-cutting concerns (e.g., when an order is placed, the payment service is notified via event, not a synchronous call). This means a failure in Search doesn't affect Payments.
:::

## Side-by-Side Comparison

:::: {.columns}

::: {.column}
**Current (Monolith)**

- Single point of failure — one bad deploy takes down everything
- Teams blocked on shared release cycle (monthly deploys)
- Vertical scaling only; already at 85% capacity
- 3-month onboarding for new developers
- Schema migrations require coordinated downtime
:::

::: {.column}
**Proposed (Microservices)**

- Fault isolation — service failures don't cascade
- Independent deploy cadence per team (daily if needed)
- Horizontal scaling per service based on demand
- Smaller codebases, faster onboarding (~3 weeks per service)
- Each service owns its schema; no cross-service migrations
:::

::::

::: {.notes}
Walk through each row of the comparison. The key selling point for leadership is the move from monthly to daily deploys — this directly translates to faster feature delivery. For engineering, emphasize fault isolation and independent scaling.
:::

## Migration Timeline

```{mermaid}
%%| fig-width: 7
gantt
  title Migration Plan
  dateFormat YYYY-MM-DD
  section Phase 1
    Service A extraction :a1, 2024-03-01, 60d
    Testing              :after a1, 30d
  section Phase 2
    Service B extraction :2024-06-01, 45d
    Integration testing  :2024-07-15, 30d
```

## Key Metrics

| Metric | Current | Target (6 months post-migration) | Improvement |
|--------|---------|-----------------------------------|-------------|
| P95 response time | 800ms | 200ms | 4x faster |
| Uptime | 99.5% (43h downtime/yr) | 99.99% (52min/yr) | 50x fewer outage minutes |
| Deploy frequency | Monthly | Daily per service | 30x more frequent |
| Developer onboarding | ~3 months | ~3 weeks per service | 4x faster |
| Incident blast radius | Full application | Single service | Isolated |

::: {.notes}
These targets are based on benchmarks from comparable migrations at similar-scale companies. The response time improvement comes primarily from eliminating cross-domain queries within the monolith — each service only touches its own data. The uptime improvement comes from fault isolation; we've modeled that 80% of our incidents in the past year would have been contained to a single service under the new architecture.
:::

## {background-image="thankyou.png"}

::: {.notes}
Thank the audience for their time. Reiterate the key ask: approval to proceed with Phase 1 (extracting the Order Service) starting next quarter. Open the floor for questions — anticipate questions about cost, team structure, and timeline risk.
:::
```

## Rendering

```bash
# Render to PowerPoint
quarto render slides.qmd

# Render with specific output name
quarto render slides.qmd -o presentation.pptx

# Preview (opens in default viewer)
quarto preview slides.qmd
```
