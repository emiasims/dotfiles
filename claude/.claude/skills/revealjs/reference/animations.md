# Animations and Progressive Reveal

## Contents

- [Slide Transitions](#slide-transitions)
- [Auto-Animate](#auto-animate)
- [Fragments](#fragments)

---

## Slide Transitions

Animated effects when moving between slides. Disabled by default.

### Available Types

| Transition | Effect |
|---|---|
| `none` | Instant switch (default) |
| `fade` | Cross fade |
| `slide` | Slide horizontally |
| `convex` | Slide at a convex angle |
| `concave` | Slide at a concave angle |
| `zoom` | Incoming slide grows from center |

### Global Configuration

```yaml
format:
  revealjs:
    transition: slide
    background-transition: fade
    transition-speed: fast  # default, fast, or slow
```

### Per-Slide Override

```markdown
## Slide Title {transition="fade" transition-speed="fast"}
```

Separate in/out transitions:
```markdown
## Slide Title {transition="fade-in slide-out"}
```

---

## Auto-Animate

Smoothly animate elements between two adjacent slides. Add `auto-animate=true` to both slides.

### Basic Usage

```markdown
## {auto-animate=true}

::: {style="margin-top: 100px;"}
Animating content
:::

## {auto-animate=true}

::: {style="margin-top: 200px; font-size: 3em; color: red;"}
Animating content
:::
```

Works with most animatable CSS properties: `position`, `font-size`, `line-height`, `color`, `background-color`, `padding`, `margin`. Reveal uses CSS transforms internally for smooth motion.

### Code Animations

Animate code changes between slides:

````markdown
## {auto-animate=true}

```r
output$plot <- renderPlot({
  # Render a barplot
})
```

## {auto-animate=true}

```r
output$plot <- renderPlot({
  barplot(WorldPhones[,input$region]*1000,
          main=input$region,
          ylab="Number of Telephones",
          xlab="Year")
})
```
````

### Element Matching

Auto-animate matches elements by text content and node type. For elements without matching content, use `data-id`:

```markdown
## {auto-animate=true auto-animate-easing="ease-in-out"}

::: {.r-hstack}
::: {data-id="box1" auto-animate-delay="0" style="background: #2780e3; width: 200px; height: 150px; margin: 10px;"}
:::
::: {data-id="box2" auto-animate-delay="0.1" style="background: #3fb618; width: 200px; height: 150px; margin: 10px;"}
:::
:::

## {auto-animate=true auto-animate-easing="ease-in-out"}

::: {.r-stack}
::: {data-id="box1" style="background: #2780e3; width: 350px; height: 350px; border-radius: 200px;"}
:::
::: {data-id="box2" style="background: #3fb618; width: 250px; height: 250px; border-radius: 200px;"}
:::
:::
```

### Animation Settings

| Attribute | Default | Effect |
|---|---|---|
| `auto-animate-easing` | `ease` | CSS easing function |
| `auto-animate-duration` | `1.0` | Duration in seconds |
| `auto-animate-delay` | `0` | Delay in seconds (per-element only) |
| `auto-animate-unmatched` | `true` | Unmatched elements fade in. `false` = appear instantly |
| `auto-animate-id` | absent | Ties non-adjacent auto-animate slides together |
| `auto-animate-restart` | absent | Breaks apart two adjacent auto-animate slides |

Global defaults:
```yaml
format:
  revealjs:
    auto-animate-easing: ease-in-out
    auto-animate-unmatched: false
    auto-animate-duration: 0.8
```

---

## Fragments

Incrementally reveal elements within a single slide. Apply the `.fragment` class to any element.

```markdown
::: {.fragment}
Fade in (default)
:::

::: {.fragment .fade-out}
Fade out
:::

::: {.fragment .highlight-red}
Highlight red
:::
```

### Fragment Classes

| Class | Effect |
|---|---|
| *(default)* | Fade in |
| `.fade-out` | Start visible, fade out |
| `.fade-up` | Slide up while fading in |
| `.fade-down` | Slide down while fading in |
| `.fade-left` | Slide left while fading in |
| `.fade-right` | Slide right while fading in |
| `.fade-in-then-out` | Fade in, then out on next step |
| `.fade-in-then-semi-out` | Fade in, then 50% opacity on next step |
| `.grow` | Scale up |
| `.shrink` | Scale down |
| `.semi-fade-out` | Fade to 50% opacity |
| `.strike` | Strike through |
| `.highlight-red` | Turn text red |
| `.highlight-green` | Turn text green |
| `.highlight-blue` | Turn text blue |
| `.highlight-current-red` | Red on this step, then revert |
| `.highlight-current-green` | Green on this step, then revert |
| `.highlight-current-blue` | Blue on this step, then revert |

### Nested Fragments

Stack effects by nesting divs. This fades in, then turns red, then semi-fades out:

```markdown
::: {.fragment .fade-in}
::: {.fragment .highlight-red}
::: {.fragment .semi-fade-out}
Fade in > Turn red > Semi fade out
:::
:::
:::
```

### Fragment Order

Override display order with `fragment-index`. Multiple elements can share an index to appear simultaneously:

```markdown
::: {.fragment fragment-index=3}
Appears last
:::

::: {.fragment fragment-index=1}
Appears first
:::

::: {.fragment fragment-index=2}
Appears second
:::
```

### Custom Fragment CSS

Define custom effects with CSS. Add `.custom` to prevent default fade-in:

```markdown
::: {.fragment .custom .blur}
Content that starts blurred
:::
```

```css
.reveal .slides section .fragment.blur {
  filter: blur(5px);
}
.reveal .slides section .fragment.blur.visible {
  filter: none;
}
```
