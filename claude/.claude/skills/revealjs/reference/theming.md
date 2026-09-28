# Theming and Custom Styles

## Contents

- [Built-in Themes](#built-in-themes)
- [Customizing Themes](#customizing-themes)
- [Creating Themes from Scratch](#creating-themes-from-scratch)
- [Sass Variables Reference](#sass-variables-reference)

---

## Built-in Themes

Built-in themes. Set via the `theme` option:

```yaml
format:
  revealjs:
    theme: dark
```

| Theme | Character |
|---|---|
| `default` | Clean, light background, sans-serif. Good starting point. |
| `dark` | Dark background, light text. Classic dark mode. |
| `beige` | Warm, parchment-like background |
| `blood` | Dark with red accents |
| `dracula` | Popular dark color scheme |
| `league` | Dark grey with large white serif text |
| `moon` | Dark blue-grey background |
| `night` | Black background, thick white text |
| `serif` | Palatino, light background. Traditional/academic feel. |
| `simple` | White background, minimal styling |
| `sky` | Blue gradient background |
| `solarized` | Solarized color palette |

---

## Customizing Themes

Layer a custom Sass file on top of a built-in theme:

```yaml
format:
  revealjs:
    theme: [default, custom.scss]
```

Sass files have two sections:

```scss
/*-- scss:defaults --*/

$body-bg: #191919;
$body-color: #fff;
$link-color: #42affa;

/*-- scss:rules --*/

.reveal .slide blockquote {
  border-left: 3px solid $text-muted;
  padding-left: 0.5em;
}
```

- `scss:defaults` -- Override Sass variables (colors, fonts, sizes)
- `scss:rules` -- Add CSS rules. Target Reveal content with `.reveal .slides section` prefix to override theme defaults.

---

## Creating Themes from Scratch

When used as `theme: mytheme.scss` (standalone), the file implicitly inherits from `default`. Just redefine the variables you want to change:

```scss
/*-- scss:defaults --*/

$font-family-sans-serif: "Palatino Linotype", "Book Antiqua", Palatino, serif !default;
$body-bg: #f0f1eb !default;
$body-color: #000 !default;
$link-color: #51483d !default;
$selection-bg: #26351c !default;
$presentation-heading-font: "Palatino Linotype", "Book Antiqua", Palatino, serif !default;
$presentation-heading-color: #383d3d !default;

/*-- scss:rules --*/

.reveal a {
  line-height: 1.3em;
}
```

Use `!default` on variables so users of your theme can override them.

Apply with:
```yaml
format:
  revealjs:
    theme: mytheme.scss
```

Quarto uses the same Sass format for HTML documents and presentations, so a single theme file can serve both.

Built-in theme source code for reference: `https://github.com/quarto-dev/quarto-cli/tree/main/src/resources/formats/revealjs/themes`

---

## Sass Variables Reference

### Colors

| Variable | Default |
|---|---|
| `$body-bg` | `#fff` |
| `$body-color` | `#222` |
| `$text-muted` | `lighten($body-color, 50%)` |
| `$link-color` | `#2a76dd` |
| `$link-color-hover` | `lighten($link-color, 15%)` |
| `$selection-bg` | `lighten($link-color, 25%)` |
| `$selection-color` | `$body-bg` |
| `$light-bg-text-color` | `#222` |
| `$light-bg-link-color` | `#2a76dd` |
| `$light-bg-code-color` | `#4758ab` |
| `$dark-bg-text-color` | `#fff` |
| `$dark-bg-link-color` | `#42affa` |
| `$dark-bg-code-color` | `#ffa07a` |

### Fonts

| Variable | Default |
|---|---|
| `$font-family-sans-serif` | `"Source Sans Pro", Helvetica, sans-serif` |
| `$font-family-monospace` | `monospace` |
| `$presentation-font-size-root` | `40px` |
| `$presentation-font-smaller` | `0.7` |
| `$presentation-line-height` | `1.3` |

### Headings

| Variable | Default |
|---|---|
| `$presentation-h1-font-size` | `2.5em` |
| `$presentation-h2-font-size` | `1.6em` |
| `$presentation-h3-font-size` | `1.3em` |
| `$presentation-h4-font-size` | `1em` |
| `$presentation-heading-font` | `$font-family-sans-serif` |
| `$presentation-heading-color` | `$body-color` |
| `$presentation-heading-line-height` | `1.2` |
| `$presentation-heading-letter-spacing` | `normal` |
| `$presentation-heading-text-transform` | `none` |
| `$presentation-heading-font-weight` | `600` |

### Layout

| Variable | Default |
|---|---|
| `$border-color` | `lighten($body-color, 30%)` |
| `$border-width` | `1px` |
| `$border-radius` | `3px` |
| `$presentation-block-margin` | `12px` |
| `$presentation-slide-text-align` | `left` |
| `$presentation-title-slide-text-align` | `center` |

### Code Blocks

| Variable | Default |
|---|---|
| `$code-block-bg` | `$body-bg` |
| `$code-block-border-color` | `lighten($body-color, 60%)` |
| `$code-block-font-size` | `0.55em` |

### Inline Code

| Variable | Default |
|---|---|
| `$code-color` | `var(--quarto-hl-fu-color)` |
| `$code-bg` | `transparent` |

### Tabsets

| Variable | Default |
|---|---|
| `$tabset-border-color` | `$code-block-border-color` |

### Callouts

| Variable | Default |
|---|---|
| `$callout-border-width` | `0.3rem` |
| `$callout-border-scale` | `0%` |
| `$callout-icon-scale` | `10%` |
| `$callout-margin-top` | `1rem` |
| `$callout-margin-bottom` | `1rem` |
| `$callout-color-note` | `#0d6efd` |
| `$callout-color-tip` | `#198754` |
| `$callout-color-caution` | `#fd7e14` |
| `$callout-color-warning` | `#ffc107` |
| `$callout-color-important` | `#dc3545` |

Variables prefixed with `presentation-` are specific to presentations. Others are shared with standard Quarto HTML themes.
