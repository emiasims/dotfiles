# Presenting, Publishing, and Plugins

## Contents

- [Keyboard Shortcuts](#keyboard-shortcuts)
- [Speaker View](#speaker-view)
- [Slide Numbers](#slide-numbers)
- [Navigation Menu](#navigation-menu)
- [Overview and Scroll View](#overview-and-scroll-view)
- [Print to PDF](#print-to-pdf)
- [Self-Contained Output](#self-contained-output)
- [Chalkboard](#chalkboard)
- [Multiplex](#multiplex)
- [Navigation Options](#navigation-options)
- [Slide Visibility](#slide-visibility)
- [Auto-Slide](#auto-slide)
- [Plugins](#plugins)

---

## Keyboard Shortcuts

| Action | Keys |
|---|---|
| Next slide | Right arrow, Space, N |
| Previous slide | Left arrow, P |
| Navigate without fragments | Alt + arrow |
| Jump to first/last slide | Shift + arrow |
| Fullscreen | F |
| Speaker view | S |
| Overview mode | O |
| Navigation menu | M |
| Jump to slide | G G, then type number/id, Enter |
| Toggle scroll view | R |
| Print view | E |
| Zoom (click element) | Alt + click |
| Chalkboard toggle | B |
| Notes canvas toggle | C |
| Pause auto-slide | A |

---

## Speaker View

Shows current slide, upcoming slide, timer, and speaker notes. Press S to open.

Add notes to any slide:
```markdown
## Slide Title

Slide content

::: {.notes}
Speaker notes go here. These are visible only in speaker view.
:::
```

Speaker notes cannot load external dependencies (e.g., Mermaid JS). If you need a diagram visible in notes, embed it as a static image.

---

## Slide Numbers

```yaml
format:
  revealjs:
    slide-number: true
    show-slide-number: all
```

**Number formats:**

| Value | Display |
|---|---|
| `c/t` | Slide number / total (default when `true`) |
| `c` | Slide number only |
| `h/v` | Horizontal / vertical |
| `h.v` | Horizontal . vertical |

**Visibility contexts** (`show-slide-number`): `all` (default), `print`, `speaker`.

---

## Navigation Menu

Built-in plugin. Access via the button at bottom-left or press M.

```yaml
format:
  revealjs:
    menu:
      side: left       # left or right
      width: normal    # normal, wide, third, half, full
      numbers: true    # add slide numbers to menu items
```

Hide menu button: `menu: false` (M key still opens the menu).

---

## Overview and Scroll View

**Overview mode** (O key): thumbnail grid of all slides.

**Scroll view** (R key): vertically scrollable alternative to slide-by-slide navigation. Activates automatically on mobile.

Shorthand to activate scroll view as default: `scroll-view: true`. Full options:

```yaml
format:
  revealjs:
    scroll-view:
      activate: true        # default view mode (scroll-view: true is shorthand)
      layout: full           # full (default) or compact
      snap: mandatory         # mandatory (default), proximity, or false
      progress: auto          # auto (default), true, or false
      activation-width: 435   # auto-activate below this width (0 to disable)
```

---

## Print to PDF

1. Press E to enter print view (or use navigation menu)
2. Open browser print dialog (Ctrl+P)
3. Set Destination to "Save as PDF"
4. Set Layout to Landscape
5. Set Margins to None
6. Enable Background Graphics
7. Save

Works in Chrome, Chromium, and Firefox.

**Print options:**

| Option | Effect |
|---|---|
| `show-notes: true` | Include speaker notes on slides |
| `show-notes: separate-page` | Speaker notes on their own pages |
| `slide-number: true` | Include slide numbers |
| `pdf-max-pages-per-slide` | Limit pages for tall slides |
| `pdf-separate-fragments` | One page per fragment step |

---

## Self-Contained Output

```yaml
format:
  revealjs:
    embed-resources: true
```

Creates a single HTML file with all assets inlined. Useful for email distribution or offline viewing.

**Caveats:**
- Slows rendering by a few seconds. Enable only when publishing.
- Incompatible with the chalkboard plugin.
- Resources at absolute URLs are downloaded; relative URLs resolved from working directory.
- Dynamically loaded JS resources (e.g., some advanced plugins) may not work offline.

---

## Chalkboard

Draw on slides or open a blank chalkboard during presentation.

```yaml
format:
  revealjs:
    chalkboard: true
```

**Shortcuts:**

| Action | Key |
|---|---|
| Toggle notes canvas | C |
| Toggle chalkboard | B |
| Reset all drawings | Backspace |
| Clear current slide | Delete |
| Cycle colors forward/back | X / Y |
| Download drawings | D |

**Options:**

```yaml
chalkboard:
  theme: whiteboard    # chalkboard (default) or whiteboard
  boardmarker-width: 5 # drawing width for markers (default 3)
  chalk-width: 7       # drawing width for chalk (default 7)
  chalk-effect: 1.0    # chalk texture intensity 0.0-1.0
  src: drawings.json   # restore saved drawings
  read-only: false     # prevent changes to saved drawings
  buttons: true        # show chalkboard buttons on slides
```

Disable buttons globally, re-enable per slide:
```markdown
## Slide Title {chalkboard-buttons="true"}
```

Add the `transition` option (milliseconds) to delay drawing until after slide transitions complete.

---

## Multiplex

Audience follows your slides on their own devices in real time.

```yaml
format:
  revealjs:
    multiplex: true
```

Rendering produces two files:
- `presentation.html` -- publish this for the audience
- `presentation-speaker.html` -- present from this (keep on your machine)

Uses a sync server at `https://multiplex.up.railway.app/` by default.

**Custom server:**
```yaml
multiplex:
  url: 'https://myserver.example.com/'
```

**Manual id/secret** (provision at the server URL):
```yaml
multiplex:
  id: '1ea875674b17ca76'
  secret: '13652805320794272084'
```

The `secret` is only included in the speaker file.

---

## Navigation Options

| Option | Default | Effect |
|---|---|---|
| `controls` | `auto` | Arrow controls. `auto` shows when vertical slides present or in iframe |
| `progress` | `true` | Progress bar at bottom |
| `history` | `true` | Push slides to browser history (back/forward buttons work) |
| `hash-type` | `title` | URL hash format: `title` or `number` |
| `touch` | `true` | Swipe navigation on touch devices |
| `controls-layout` | `edges` | `edges` or `bottom-right` (incompatible with `logo`) |
| `controls-tutorial` | `false` | Visual hint that controls exist |
| `preview-links` | `false` | Open links in overlay iframe. `auto` = only in fullscreen |
| `jump-to-slide` | `true` | Enable G G shortcut to jump to slide by number/id |

---

## Slide Visibility

Hide slides or exclude them from numbering.

**Hidden slide** (completely removed from navigation):
```markdown
## Slide Title {visibility="hidden"}
```

**Uncounted slide** (accessible but excluded from progress bar and slide numbers). Useful for backup/optional slides at the end:
```markdown
## Slide Title {visibility="uncounted"}
```

---

## Auto-Slide

Advance slides automatically on a timer:

```yaml
format:
  revealjs:
    auto-slide: 5000   # milliseconds between slides
    loop: true          # restart after last slide
```

A play/pause control appears. Interaction pauses auto-slide. Press A to toggle.

Disable the pause control: `auto-slide-stoppable: false`.

Per-slide override:
```markdown
## Slide Title {autoslide=2000}
```

---

## Plugins

Third-party Revealjs plugins extend presentation capabilities. Quarto includes several built-in:

| Plugin | Activation |
|---|---|
| RevealMenu | Enabled by default (`menu: false` to disable) |
| RevealChalkboard | `chalkboard: true` |
| PdfExport | Always enabled |
| Multiplex | `multiplex: true` or `multiplex: { ... }` |
| slide-tone | `slide-tone: true` (auditory cue on slide change) |

### Installing External Plugins

1. Create a folder for the plugin (e.g., `fullscreen/`)
2. Download the plugin JS file into the folder
3. Add a `plugin.yml` file:
   ```yaml
   name: RevealFullscreen
   script: [fullscreen.js]
   ```
   The `name` field must match the JS plugin's registered name (check the plugin source).
4. Reference in YAML:
   ```yaml
   format:
     revealjs:
       revealjs-plugins:
         - fullscreen
   ```

### Plugin Configuration

Plugins expose config keys at the same level as other revealjs options. Check the plugin's documentation for available options.

**Slide tone** plays a pitch that increases with slide progress (accessibility feature):
```yaml
format:
  revealjs:
    slide-tone: true
```
