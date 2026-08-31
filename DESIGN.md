---
name: Redmine
description: A self-hosted Redmine wearing a quiet paper-calm interface, where hairlines carry structure and one blue carries action.
colors:
  canvas: "#ffffff"
  canvas-soft: "#f7f7f5"
  surface: "#ffffff"
  surface-sunken: "#f1f0ee"
  ink: "#1f1e1c"
  ink-strong: "#0d0d0c"
  ink-secondary: "#37352f"
  ink-muted: "#615d59"
  ink-faint: "#6f6a64"
  hairline: "#e6e4e1"
  hairline-strong: "#d6d3ce"
  fill-subtle: "rgba(31, 30, 28, 0.03)"
  fill-hover: "rgba(31, 30, 28, 0.055)"
  fill-active: "rgba(31, 30, 28, 0.09)"
  primary: "#0075de"
  primary-hover: "#005bab"
  primary-soft: "#e8f2fd"
  primary-ring: "rgba(0, 117, 222, 0.28)"
  on-primary: "#ffffff"
  link: "#0075de"
  danger: "#c1341b"
  danger-soft: "#fbeae6"
  success: "#1a8a45"
  success-soft: "#e6f4ea"
  warning: "#9a5b06"
  warning-soft: "#fbf1e0"
  info: "#2a6fb0"
  info-soft: "#e9f1f9"
  purple: "#6940a5"
  purple-soft: "#f2ecfb"
typography:
  display:
    fontFamily: "Inter, Noto Sans, -apple-system, BlinkMacSystemFont, Segoe UI, sans-serif"
    fontSize: "1.625rem"
    fontWeight: 700
    lineHeight: 1.2
    letterSpacing: "-0.02em"
  headline:
    fontFamily: "Inter, Noto Sans, -apple-system, BlinkMacSystemFont, Segoe UI, sans-serif"
    fontSize: "1.25rem"
    fontWeight: 600
    lineHeight: 1.25
    letterSpacing: "-0.014em"
  title:
    fontFamily: "Inter, Noto Sans, -apple-system, BlinkMacSystemFont, Segoe UI, sans-serif"
    fontSize: "1.0625rem"
    fontWeight: 600
    lineHeight: 1.25
    letterSpacing: "-0.008em"
  body:
    fontFamily: "Inter, Noto Sans, -apple-system, BlinkMacSystemFont, Segoe UI, sans-serif"
    fontSize: "0.875rem"
    fontWeight: 400
    lineHeight: 1.5
    letterSpacing: "normal"
  dense:
    fontFamily: "Inter, Noto Sans, -apple-system, BlinkMacSystemFont, Segoe UI, sans-serif"
    fontSize: "0.8125rem"
    fontWeight: 400
    lineHeight: 1.4
    letterSpacing: "normal"
  label:
    fontFamily: "Inter, Noto Sans, -apple-system, BlinkMacSystemFont, Segoe UI, sans-serif"
    fontSize: "0.75rem"
    fontWeight: 500
    lineHeight: 1.4
    letterSpacing: "0.01em"
  mono:
    fontFamily: "SFMono-Regular, Consolas, Menlo, Liberation Mono, monospace"
    fontSize: "0.8125rem"
    fontWeight: 400
    lineHeight: 1.5
rounded:
  xs: "4px"
  sm: "5px"
  md: "8px"
  lg: "12px"
  full: "9999px"
spacing:
  xs: "4px"
  sm: "6px"
  md: "8px"
  lg: "12px"
  xl: "16px"
  2xl: "24px"
  gutter: "28px"
components:
  top-bar:
    backgroundColor: "{colors.canvas}"
    textColor: "{colors.ink-muted}"
    typography: "{typography.label}"
    height: "38px"
    padding: "4px 20px"
  page-title:
    textColor: "{colors.ink-strong}"
    typography: "{typography.display}"
    height: "2.75rem"
  tab:
    backgroundColor: "transparent"
    textColor: "{colors.ink-muted}"
    typography: "{typography.dense}"
    padding: "8px 10px"
    rounded: "0"
  tab-selected:
    backgroundColor: "transparent"
    textColor: "{colors.ink-strong}"
  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary}"
    rounded: "{rounded.full}"
    padding: "0 16px"
    height: "30px"
  button-primary-hover:
    backgroundColor: "{colors.primary-hover}"
  button-secondary:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.ink-secondary}"
    rounded: "{rounded.md}"
    padding: "0 14px"
    height: "30px"
  button-secondary-hover:
    backgroundColor: "{colors.fill-hover}"
  button-quiet:
    backgroundColor: "transparent"
    textColor: "{colors.ink-muted}"
    rounded: "{rounded.xs}"
    padding: "3px 6px"
    typography: "{typography.dense}"
  button-quiet-hover:
    backgroundColor: "{colors.fill-hover}"
    textColor: "{colors.ink-strong}"
  input-text:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.ink}"
    rounded: "{rounded.xs}"
    padding: "5px 8px"
    typography: "{typography.dense}"
  input-search:
    backgroundColor: "{colors.surface-sunken}"
    textColor: "{colors.ink}"
    rounded: "{rounded.sm}"
    height: "30px"
    width: "190px"
  input-disabled:
    backgroundColor: "{colors.surface-sunken}"
    textColor: "{colors.ink-faint}"
  panel:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.ink}"
    rounded: "{rounded.md}"
    padding: "16px 18px"
  panel-record:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.ink}"
    rounded: "{rounded.lg}"
    padding: "20px 22px"
  sidebar:
    backgroundColor: "{colors.canvas-soft}"
    textColor: "{colors.ink-secondary}"
    typography: "{typography.dense}"
    padding: "18px 12px 24px 20px"
  table-header-cell:
    backgroundColor: "transparent"
    textColor: "{colors.ink-muted}"
    typography: "{typography.label}"
    padding: "8px 6px"
  table-row:
    backgroundColor: "transparent"
    textColor: "{colors.ink}"
    typography: "{typography.dense}"
    padding: "7px 10px 7px 0"
  table-row-hover:
    backgroundColor: "{colors.fill-subtle}"
  table-row-selected:
    backgroundColor: "{colors.primary-soft}"
  badge-status-open:
    backgroundColor: "{colors.primary-soft}"
    textColor: "{colors.link}"
    rounded: "{rounded.full}"
    padding: "2px 8px"
  badge-status-closed:
    backgroundColor: "{colors.success-soft}"
    textColor: "{colors.success}"
    rounded: "{rounded.full}"
    padding: "2px 8px"
  badge-status-locked:
    backgroundColor: "{colors.fill-active}"
    textColor: "{colors.ink-muted}"
    rounded: "{rounded.full}"
    padding: "2px 8px"
  badge-private:
    backgroundColor: "{colors.danger-soft}"
    textColor: "{colors.danger}"
    rounded: "{rounded.full}"
    padding: "2px 8px"
  badge-count:
    backgroundColor: "{colors.fill-active}"
    textColor: "{colors.ink-secondary}"
    rounded: "{rounded.full}"
    padding: "2px 8px"
  callout-error:
    backgroundColor: "{colors.danger-soft}"
    textColor: "{colors.danger}"
    rounded: "{rounded.md}"
    padding: "12px 14px 12px 36px"
  callout-notice:
    backgroundColor: "{colors.success-soft}"
    textColor: "{colors.success}"
    rounded: "{rounded.md}"
    padding: "12px 14px 12px 36px"
  callout-warning:
    backgroundColor: "{colors.warning-soft}"
    textColor: "{colors.warning}"
    rounded: "{rounded.md}"
    padding: "12px 14px 12px 36px"
  callout-empty:
    backgroundColor: "{colors.fill-subtle}"
    textColor: "{colors.ink-faint}"
    rounded: "{rounded.md}"
    padding: "12px 14px"
  menu-surface:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.ink-secondary}"
    rounded: "{rounded.md}"
    padding: "4px 0"
  menu-item-hover:
    backgroundColor: "{colors.fill-hover}"
    textColor: "{colors.ink-strong}"
    rounded: "{rounded.xs}"
    padding: "5px 8px"
  tooltip:
    backgroundColor: "{colors.ink-strong}"
    textColor: "{colors.canvas}"
    rounded: "{rounded.sm}"
    typography: "{typography.label}"
  avatar:
    rounded: "{rounded.full}"
    typography: "{typography.label}"
    size: "24px"
---

# Design System: Redmine

## Overview

**Creative North Star: "The Quiet Working Document"**

This is Redmine reskinned as a document you work in, not an admin console you operate. The chrome recedes until it is barely furniture: a 38px top bar with no fill of its own, a project title set in ink over a small breadcrumb, tabs that mark themselves with a two-pixel underline instead of a coloured pill. What is left in front of the reader is the data. The visual world is pinned to Notion — the token record vendored at `.impeccable/references/DESIGN-notion.md` is the contract this build answers to — and it lands as white paper, warm-grey hairlines, a single warm off-white panel ground, Inter at tight tracking, and small radii that go full-round only where an action wants to be found.

The load-bearing idea is not a colour or a typeface, it is a **remap**. Every colour in the interface flows from one set of `--nx-*` semantic tokens. Beneath those tokens, the entire legacy open-color `--oc-*` scale is redefined as aliases onto them, so roughly two and a half thousand lines of untouched Redmine CSS — the context menu, the SCM views, wiki syntax highlighting, the dropdown, the icon compatibility shims — obey the new world without being edited. Light and dark come from that same token set: an OS-preference block and an explicit `[data-theme]` mirror, so a manual toggle wins in both directions and nothing needs a second palette.

The system is built for a developer scanning a dense issue list. Density outranks decoration. Rows are separated by hairlines and never by fills, because the fill is reserved for saying "your pointer is here." Colour is not used to decorate; it is used to say what state a thing is in, and the one blue in the palette is what tells you where the action is. This build was code-led: no comp exists, the world was pinned by brief rather than chosen by a direction roll, and every value below is read back out of the shipped stylesheets.

**Key Characteristics:**

- Chrome with no fill of its own; hairlines and ink carry all structure.
- One accent blue, spent on links, the single affirmative action, focus, and progress.
- Semantic `--nx-*` tokens with the legacy `--oc-*` scale remapped onto them.
- Light and dark from one token set, with an explicit toggle that beats the OS.
- Inter at negative tracking, tabular numerals in every list.
- Flat at rest; shadow only on things that actually leave the page.

## Colors

A warm near-neutral palette — paper white, warm-grey hairlines, brown-black ink — with exactly one saturated hue in the chrome and a small family of state accents that appear nowhere else.

### Primary

- **Signal Blue** (`{colors.primary}`): The only saturated colour in the chrome. It fills the round primary action (Rails' `name="commit"` submit, the `+` new-object pill, the login button), draws the focus ring, fills the closed portion of every progress bar, and tints the selected row. In dark it darkens rather than lightens, because it carries white text.
- **Signal Blue, pressed** (`{colors.primary-hover}`): Hover and active state of anything filled with Signal Blue.
- **Link Blue** (`{colors.link}`): Link text. Identical to Signal Blue on paper and deliberately *not* identical in the dark — see the Two-Blue Rule.
- **Blue Wash** (`{colors.primary-soft}`): The tint behind an open-status badge, a targeted journal header, a context-menu selection, and a user mention. Never a border.

### Secondary

The state accents. Each has a saturated ink value and a soft wash used as a ground; nothing else in the system is allowed a colour of its own.

- **Clay Red** (`{colors.danger}` / `{colors.danger-soft}`): Errors, overdue dates, private notes, deleted diff lines, late Gantt bars.
- **Field Green** (`{colors.success}` / `{colors.success-soft}`): Success flashes, closed-status badges, added diff lines, the check icon.
- **Amber Bark** (`{colors.warning}` / `{colors.warning-soft}`): Warnings, edit conflicts, Gantt labels for work running behind.
- **Iris** (`{colors.purple}` / `{colors.purple-soft}`): Reserved for the note-style callout, deliberately not blue so a note never reads as a link.
- **Slate Blue** (`{colors.info}` / `{colors.info-soft}`): Declared in all three theme blocks as the informational accent. No component consumes it yet; a future informational surface takes this token rather than inventing a blue.

### Neutral

- **Paper** (`{colors.canvas}`): The page ground and the ground of the top bar, header, tab strip and footer — none of which carry a fill of their own.
- **Panel** (`{colors.canvas-soft}`): The one quiet ground in the layout. The right sidebar, the mobile flyout, and the text-diff block sit on it; content never does.
- **Surface** (`{colors.surface}`): Cards, boxes, menus, modals, inputs. Identical to Paper in light; a distinct raised step in dark.
- **Sunken** (`{colors.surface-sunken}`): Inset controls — the quick-search field, the project-jump trigger, disabled inputs, the file-picker button.
- **Ink** (`{colors.ink}`): Body text.
- **Ink Strong** (`{colors.ink-strong}`): Headings, the selected tab, hovered chrome, the tooltip ground.
- **Ink Secondary** (`{colors.ink-secondary}`): Form labels, sidebar links, menu items.
- **Ink Muted** (`{colors.ink-muted}`): Top-bar links, table headers, unselected tabs, icon strokes, field labels on a record.
- **Ink Faint** (`{colors.ink-faint}`): Placeholders, timestamps, footers, empty-state text.
- **Hairline** (`{colors.hairline}`) and **Hairline Strong** (`{colors.hairline-strong}`): Every rule, divider, row separator, card edge and input border in the system. The strong step is for input borders, table header underlines and blockquote rails.
- **Fill Subtle / Hover / Active** (`{colors.fill-subtle}`, `{colors.fill-hover}`, `{colors.fill-active}`): Translucent ink washes, so they work over any ground. Subtle is the table-row hover; hover is the chrome hover; active is the selected sidebar item, the count badge, and the "todo" leg of a progress bar.

### Named Rules

**The One Blue Rule.** Blue is spent only on links, the single affirmative action of a form, the focus ring, and progress. If a new element wants blue for emphasis, it gets weight or hairline instead.

**The Two-Blue Rule.** `--nx-link` and `--nx-primary` are two tokens on purpose, not one token used twice. Link text sits on a panel and a filled button carries white text, so when the palette inverts they must move in opposite directions: in dark the link lightens and the fill darkens, and both stay above 4.5:1. Never collapse them.

**The Colour-Is-State Rule.** Colour carries state and nothing else. Gantt bars, progress bars, badges, callouts and diffs all draw from the same state tokens; no component keeps a private palette. A new component that needs to signal "late" uses the danger token the Gantt already uses.

**The Remap Rule.** The legacy `--oc-*` open-color names are aliases onto the `--nx-*` tokens, not colours. Never give an `--oc-*` name a literal value in a component rule, and never introduce a raw hex into a component rule — a new colour is a new `--nx-*` token or it is not a colour.

**The Tinted-Ground Rule.** State colour appears as a tinted ground with transparent border and matching ink, never as a coloured left rail or a saturated bar. A private note is marked by its own ground; a flash message is a wash, not a banner.

## Typography

**Display / Body Font:** Inter (self-hosted woff2, weights 400/500/600/700 plus a 400 italic and a Cyrillic subset), falling back to Noto Sans, then the platform UI stack.
**Label / Mono Font:** SFMono-Regular, Consolas, Menlo, Liberation Mono.

**Character:** One face does the whole interface. The shipped Inter 4.001 subsets expose `calt ccmp dnom frac kern locl mark mkmk numr pnum tnum` and nothing else, so no stylistic set is requested — an earlier `cv05`/`ss03` declaration asked for features the binaries do not contain and was removed rather than left as decoration. The one contextual alternate that does ship turns a digit-x-digit sequence into a multiplication sign, so `font-variant-ligatures: no-contextual` is applied narrowly to the places arbitrary identifiers appear — issue ids, file sizes, filenames, revisions — and prose keeps its alternates. Tracking tightens as size grows and loosens slightly for the smallest labels, which is what makes a 26px project title read as set rather than as scaled-up UI text.

### Hierarchy

- **Display** (700, `{typography.display}`, tight tracking): The project title in the header and the `h1` of any page. One per screen, sitting directly above a 12px breadcrumb.
- **Headline** (600, `{typography.headline}`): Section headings, the login card title, wiki `h2`.
- **Title** (600, `{typography.title}`): Sub-section headings, the subject line inside an issue panel.
- **Body** (400, `{typography.body}`, line-height 1.5): Prose, descriptions, wiki content, form values.
- **Dense** (400–500, `{typography.dense}`): The working size. Tables, tabs, sidebar, contextual actions, journal headers, breadcrumb paragraphs. Most of the interface lives here.
- **Label** (500–600, `{typography.label}`, positive tracking): Table headers, fieldset legends, sidebar section headings, badges, timestamps, the top bar. Sentence case — never uppercased. Positive tracking belongs to 11–12px labels only; at 13–14px it is zero.
- **The heading floor.** No heading renders smaller than the body it introduces. `h4` sits at body size with weight 600 and its hairline rule, rather than being demoted three ways at once — smaller, muted and ruled.
- **Mono** (`{typography.mono}`): Code, diffs, revision identifiers, backup codes.

There is a separate, slightly larger ramp inside `.wiki` content (28px / 22px / 18px / 16px), because a wiki page is a document and gets document proportions rather than UI proportions.

### Named Rules

**The One Face Rule.** Inter carries the entire interface; the mono stack appears only inside code, diffs and identifiers. Noto Sans exists solely as the fallback face for scripts Inter does not cover — it is never chosen deliberately.

**The Tight-Tracking Rule.** Letter-spacing tightens as type grows (−0.02em at display, −0.014em at headline, −0.008em at title) and opens to +0.01em only at label sizes. Body text stays at normal tracking.

**The Tabular-Numbers Rule.** Every list table and every date, time and number input sets `font-variant-numeric: tabular-nums`, so ids, hours and dates align down a column. Prose sets proportional numerals; a `.wiki` block re-enables tabular inside its own tables and code.

**The Sentence-Case Rule.** Nothing is uppercased by CSS. Small labels earn their rank through weight, colour and 0.01em of tracking, and copy comes from locale files, so a `text-transform` would break a translation as often as it helped it.

## Layout

The shell is a vertical stack: a 38px top bar, a header carrying the project title over a breadcrumb with the search field floated opposite, a tab strip pinned to the bottom edge of the header, then a flex row that puts content first and the sidebar second in source order but reverses it visually (`flex-direction: row-reverse`), so the sidebar reads on the trailing edge and the content still comes first for a screen reader. A footer closes the page with a hairline above it.

Content sits at a 28px gutter with 24px of space above and 48px below. Panels (`.box`, `.mypage-box`) take 16–18px of internal padding; a record panel (`div.issue`) takes 20–22px and a slightly larger radius. The sidebar takes 18px top, 20px leading, 12px trailing, 24px bottom, and steps its width by viewport: a 22% share below 1090px, then fixed steps of 240 / 280 / 320 / 360 / 380px as the viewport grows past 1090, 1280, 1600, 1920 and 2560px, so a wide monitor gives the sidebar more room without letting it swallow the table.

Two width primitives govern the content column. `--nx-frame` is the **outer** box of `#content` — `box-sizing: border-box` is stated explicitly, because the stylesheet has no universal reset and the 28px gutter would otherwise push a 1280px frame out to 1336px. It defaults to `none` and is raised to 1280px per action, never per controller: the admin index, settings, my page, a wiki page, the news index and the project index are framed; every issue list, repository view, gantt, timelog, version list, wiki history or diff, plugin settings page and admin sub-table is not, because capping a dense table produces empty outer margins and a sideways scroll inside them at the same time. `--nx-measure` is the reading measure, 31rem — about 76 characters of 14px Inter. It is expressed in `rem` rather than `ch` or `em` on purpose: both of those scale with the element's own font-size, which gave a 28px heading a cap almost twice the width of the prose beneath it.

The rhythm is a plain even scale — 4, 6, 8, 12, 16, 24px — with 28px reserved for the page gutter and 48px for the bottom of the content column. Vertical rhythm inside lists is tight on purpose: a table row is 7px of padding and one hairline.

Everything is written in logical properties (`padding-inline`, `inset-block-start`, `margin-inline-start`), and RTL is handled by flipping backgrounds and chevrons rather than by a mirrored stylesheet, so `dir="rtl"` is a first-class layout, not a patch.

**Responsive.** The desktop body holds a 900px minimum inline size. Below 900px that minimum is dropped and the layout becomes a mobile shell: the header becomes a fixed 64px bar, the project title is hidden (the project select in the flyout carries it), top menu and main menu move into a 250px flyout that slides the wrapper aside, and contextual actions become tappable bordered buttons with 9px padding. Tabular forms lose their 180px label column and stack. A second breakpoint at 599px tightens the remaining spacing. Table cells narrow to 4px of inline padding rather than collapsing into cards — the list stays a list, because scanning a table is the job.

### Named Rules

**The Hairline Rule.** Structure is carried by 1px hairlines: row separators, section rules, card edges, the underline beneath a table header, the line under the tab strip. A hairline is the default answer to "how do I separate these."

**The No-Fill-Rows Rule.** Rows are never separated by fills. The stock zebra striping is explicitly zeroed out in both directions, and the row fill is reserved for pointer feedback so a scanning eye tracks exactly one row at a time.

**The Panel Rule.** `{colors.canvas-soft}` is the panel ground — sidebar, mobile flyout, diff block. Content sits on `{colors.canvas}`. A panel is defined by its ground plus a hairline on the edge it meets content on, not by a shadow.

**The Logical-Property Rule.** New rules use logical properties and never physical `left`/`right`, so RTL keeps working. The two exceptions in the build are deliberate: numeric columns (hours, sizes, estimates) stay `text-align: right` in every direction, because a number column reads right-aligned regardless of script.

## Elevation & Depth

The system is flat by default. A surface at rest is a ground plus a 1px hairline — cards, panels, inputs, fieldsets, the record panel on an issue page all carry zero shadow. Depth is expressed tonally instead: `canvas` → `canvas-soft` → `surface-sunken` in light, and in dark the same three tokens separate into genuinely different values (`#191919` → `#202020` → `#262626`) so the layering survives the inversion.

Shadow is spent only on things that have actually left the page — a dropdown, a modal, a floating loading indicator, the login card, the sticky issue header. Each dark shadow carries a hairline ring in its own value list, because a pure black shadow disappears against a dark ground and the ring is what restores the edge.

### Shadow Vocabulary

- **Lift** (`box-shadow: 0 1px 2px rgba(15, 15, 15, 0.06)`): The sticky issue header only — a page element that has become fixed and needs to separate from what scrolls beneath it.
- **Float** (`box-shadow: 0 6px 18px rgba(15, 15, 15, 0.11), 0 0 0 1px rgba(15, 15, 15, 0.05)`): Menus, dropdowns, the login card, the ajax indicator. Anything summoned above the page.
- **Overlay** (`box-shadow: 0 14px 40px rgba(15, 15, 15, 0.16), 0 0 0 1px rgba(15, 15, 15, 0.05)`): Modals only.

### Named Rules

**The Flat-Until-Floating Rule.** A surface gets a shadow only when it has left the page. If it is still part of the document — a card, a panel, a row, a form — it gets a hairline and nothing else.

**The Ringed-Shadow Rule.** Every shadow above the smallest step carries a `0 0 0 1px` ring in its own value, and in dark that ring is a white wash. A shadow without its ring loses its edge the moment the theme inverts.

## Motion

Two durations and one curve: `{motion.dur-fast}` 90ms for feedback that fires many times a session, `{motion.dur}` 160ms for a state change, and an exponential ease-out for both. Nothing in the product runs past 300ms, because nothing here is a hero. Every transition in the stylesheet references those tokens — an audit is a grep, not a reading. Only colour, background, border, stroke, box-shadow and opacity animate; layout properties never do, and a table row's hover is background alone.

**Reduced motion is less movement, not less feedback.** A blanket `transition-duration` override also erases hover, focus and selection response, none of which move anything, and a blanket transform reset flattens static transforms like the expanded project-jump chevron. So `prefers-reduced-motion` addresses only the two things that actually displace or fade: the flash message swaps to a variant that fades without its 4px rise, and the my-page action reveal becomes instant. The loading spinner needs no exemption, because nothing suppresses it.

**Hidden-until-hover is a reachability bug, not a style.** An affordance revealed by `:hover` alone does not exist for a keyboard or a finger. The my-page contextual actions are revealed by `:focus-within` as well, are simply always visible where there is no hover to begin with, and only animate inside `(hover: hover) and (pointer: fine)`. The same reasoning makes every `.autoscroll` region focusable: a table that scrolls sideways under a pointer and not under a keyboard hides its last columns from anyone not using a mouse.

## Shapes

Corners are small and consistent: 4px for the things you click through quickly (inputs, sidebar links, contextual actions, menu items), 5px for the search field and the project-jump trigger, 8px for cards, menus, callouts, fieldsets and secondary buttons, 12px for the two surfaces that read as objects — the record panel on an issue page, the my-page block, the login card, the modal.

Full-round (`{rounded.full}`) is a deliberate signal, not a style: it belongs to the primary action, the badge, the progress bar, the avatar and the scrollbar thumb. Nothing else in the system is a pill.

Borders are always 1px, always a hairline token, never coloured — with the single documented exception of the closed status chip in an issue list, below. Where a state needs an outline, the build uses `border-color: transparent` plus a tinted ground so the box keeps its geometry without gaining a coloured edge. The one deliberate rail in the system is a 3–4px inline-start border: blockquotes take a hairline-strong rail, CommonMark alerts take a state-coloured one.

Selects and the project-jump control drop their native appearance and take a drawn chevron as a background image, positioned `right 6px` in LTR and mirrored in RTL, with an up-chevron swapped in on expansion.

### Named Rules

**The Round-Only-Action Rule.** `{rounded.full}` means "this is the action, this is the state, or this is a person." Primary buttons, badges, progress bars, avatars. Give a card a pill radius and the signal is gone.

**The Transparent-Border Rule.** A tinted state box declares `border: 1px solid transparent` rather than dropping the border. The geometry stays identical to its untinted sibling and the box never shifts when its state changes.

**The Closed-Chip Exception.** One selector is exempt from the Tinted-Ground and Transparent-Border rules: `tr.issue td.status .badge-status-closed` drops its ground and takes a `{colors.success}` hairline instead. It was granted deliberately, because open and closed were separated by hue alone — 1.04:1 between the two inks and 1.00:1 between the two grounds, so in greyscale they were the same chip and only the word distinguished them. The outline restores a luminance channel without introducing a hue. The exemption stops there: the open chip, the locked chip, the version and wiki badges, and any plugin-supplied badge all keep their tinted ground.

## Components

### Buttons

- **Shape:** Secondary controls take a gently rounded 8px corner; the primary action is full-round. Both stand 30px tall.
- **Primary:** Signal Blue fill, white text, transparent border, full-round, 16px of inline padding. Rails names the affirmative submit of a form `commit`, and that attribute selector is what makes it primary — so exactly one control per form carries the accent, automatically. The `+` new-object item in the main menu is the same treatment at 14px padding.
- **Secondary:** Surface ground, ink-secondary text, hairline-strong border, 8px radius, 14px padding. This is the default for every `input[type=submit]`, `button[type=submit]` and `.button`.
- **Quiet:** The contextual row above a list and inside a panel header. No border, no ground, ink-muted text at 13px with 3px/6px padding and a 4px radius; on hover it takes `fill-hover` and ink-strong. This is the most common action in the interface and it is deliberately almost invisible until pointed at.
- **Hover / Focus:** Fills move to the pressed value over 100ms linear; quiet controls take a fill over 120ms ease. Focus is a 2px Signal Blue outline at 1px offset on `:focus-visible` for every interactive element, plus a 3px `primary-ring` glow on text inputs.

### Cards / Containers

- **Corner Style:** 8px for a plain panel, 12px for a record panel, my-page block, login card or modal.
- **Background:** `{colors.surface}`. Panels never sit on the panel ground; that is the sidebar's job.
- **Shadow Strategy:** None at rest (see The Flat-Until-Floating Rule). The login card and the modal are the exceptions, because they float.
- **Border:** 1px hairline on all four sides.
- **Internal Padding:** 16px block / 18px inline for a panel; 20px / 22px for a record panel; 14px / 16px for a my-page block.

### Inputs / Fields

- **Style:** Surface ground, 1px hairline-strong border, 4px radius, 13px text, 5px/8px padding, inheriting the interface face. Selects strip their native appearance and take the drawn chevron. Date, time and number inputs stand 30px tall with tabular numerals. File inputs get a sunken, 8px-radius picker button inside the field.
- **Focus:** Border shifts to Signal Blue and a 3px `primary-ring` glow appears; the native outline is suppressed on text fields because the ring replaces it.
- **Disabled:** Sunken ground, faint ink, plain hairline border, `not-allowed` cursor.
- **Error:** The label turns danger and the control immediately after it takes a 1px danger border. Required markers are danger-coloured.
- **Search:** A sunken 190×30px field with a transparent border that turns white with a Signal Blue border and ring on focus. Autocomplete fields carry the drawn search glyph as an inline-start background image, mirrored in RTL.

### Navigation

- **Top bar:** 38px, no fill, hairline beneath, 12px ink-muted labels at weight 500 with a 5px-radius hover fill. Icons stroke in ink-muted and go ink-strong on hover alongside their label.
- **Header:** 26px project title over a 12px breadcrumb, both left, with the quick-search field and project-jump control aligned to the same 2.75rem minimum height on the opposite edge.
- **Tabs (main menu and content tabs):** 13px ink-muted labels, no fill, no border, no radius. Hover draws a 2px hairline-strong underline via inset box-shadow; the selected tab goes weight 600 in ink-strong with a 2px ink-strong underline. The underline is the entire state signal — there is no coloured tab, no pill, no filled background.
- **Sidebar:** Panel ground, hairline on its content-facing edge, 12px ink-faint section headings, 13px ink-secondary links with a 4px-radius hover fill pulled 6px into the gutter so the fill wraps the text rather than the column. A selected query takes `fill-active` and ink-strong.
- **Menus and dropdowns:** Surface ground, hairline, 8px radius, Float shadow, 4px of vertical padding. Items take a 4px-radius `fill-hover` on hover. A selected item in a selection dropdown is marked by the drawn check icon.
- **Mobile:** Below 900px the top and main menus move into a 250px flyout on the panel ground; the toggle button is a masked menu icon that swaps to a masked close icon when the flyout is open.

### Admin index

Fourteen peers in one column asks the reader to already know the menu. The directory groups them under four headings — People, Issues, Administration, Projects — laid out as a grid on the container, so a plugin's nested child menu stays a list rather than becoming a second grid. Grouping reorders across groups by construction; order inside a group is the order the menu resolved to. Anything a plugin pushed that the mapping does not name lands in a trailing "Other" group rather than being dropped. The shared admin sidebar on other screens is not grouped.

### Tables

The signature surface of the product, and the one most of the system is tuned for.

- 13px text with tabular numerals; a 12px ink-muted header row underlined with a hairline-strong rule; rows separated by a single hairline on the block-start edge and closed by a hairline under the last row.
- **No zebra.** Odd and even are explicitly set to transparent in both `.box` and bare contexts.
- **Hover** paints `fill-subtle` — the only fill a row ever receives except a context-menu selection, which takes `primary-soft`.
- Group headers are a hairline-strong rule with a 600-weight ink-strong name and muted totals, not a filled band.
- Nested issues are indented in 16px steps with a chevron background image, mirrored for RTL.
- Overdue dates turn danger; closed issues strike through in gray; locked and registered users go gray. Nothing else in a row is coloured.
- **Row rhythm** is 1.35 line-height on cells. The 1.5 that prose uses cost a row per viewport on a surface whose job is scanning.
- **Alignment carries meaning, scoped to issue rows.** The shared `table.list td` default stays centred, because every list in the product inherits it. Inside `tr.issue`, categorical columns and the issue id read from the start edge so the eye has a left edge to run down; magnitude columns (hours, totals, numeric and float custom fields) read from the right and keep the physical `right` the Logical-Property Rule reserves for numbers; headers follow their column. Numeric cells take weight 500, which is free — tabular figures drift 0.195% across the 400–700 range.
- **The status cell encodes twice over.** Open is a filled chip, closed is an outline chip, and both carry a 12px glyph before the label: a dot in a circle for open, a bare check for closed. The dot is deliberately neutral — it has to serve New, In Progress and Feedback equally, not illustrate one of them — and the check goes bare because the closed chip is already an outline, so a second container inside it would be one border too many. Both glyphs are `aria-hidden`; the status name carries the meaning. Priority spends colour and weight only above the default rung. Tracker stays plain muted text: it is filtered on, not triaged on. Three distinct indicators in a row is the ceiling.

### Badges

Small full-round chips at 12px / weight 500 with 2px/8px padding, sentence case, transparent border, drawing their ground and ink from the state tokens: open takes the blue wash and link ink, closed takes the green wash and success ink, locked and plain counts take `fill-active` and secondary ink, private takes the danger wash and danger ink.

### Error pages

`404.html` and `500.html` are standalone documents served without the application stylesheet, so they carry their own copy of the frame, the reading measure, the type and both palettes rather than inheriting anything. They are updated together, and a change to the frame that is not mirrored into them leaves the two most visible failure states looking like a different product.

### Callouts

Flash messages, error explanations, conflicts and warnings share one shape: a tinted ground, transparent border, 8px radius, 12px/14px padding with 36px of inline-start room for a stroked icon that takes the same state colour as the text. An empty result (`.nodata`) uses the same shape but with `fill-subtle` and faint ink — an empty list is a state, not a problem, and it must not read as an alarm.

### Progress bars

An 80px full-round track, 0.5rem tall, built from three cells: `closed` in Signal Blue, `done` in Signal Blue mixed 45% into transparency, `todo` in `fill-active`. The version overview widens the same bar to 40em and 1.2em tall. There is no second progress colour anywhere in the system.

### Avatars

A round element sized 13/16/22/24/40/50px. A user with no image gets initials on a ground built with `color-mix(in srgb, var(--nx-avatar-hue) 20%, var(--nx-canvas))`, with the hue itself as the text colour. Eight hues are assigned deterministically by user id, and each has a lighter dark-mode value; because the ground is mixed against the *current* canvas, one class works in both themes without a second palette.

### Icons

The interface uses a stroked SVG sprite (`svg.icon-svg`, 1.5 stroke, sizes 12/14/16/18/20) whose stroke is an ink token — muted at rest, strong on hover, and the state colour for ok / error / warning. The handful of icons that must live inside CSS — the chevron, the mobile menu, the flyout close, and the selection check — are inline-SVG data URIs applied through `mask` with `background-color: currentColor`, so they inherit ink in both themes. RTL-sensitive icons flip with `scaleX(-1)`.

### Theme toggle

A 28px square icon button in the top bar. A Stimulus controller flips `data-theme` on the root element between `light` and `dark`, seeding from the OS preference on the first press, and stores the choice in `localStorage` under `redmine-theme` inside a try/catch. A tiny inline script in the head applies the stored value before first paint so the page never flashes the wrong theme.

### Named Rules

**The One-Action Rule.** Exactly one control per form carries the accent fill, and the build gets that for free by keying the primary style off Rails' `name="commit"`. If a screen appears to need two primary buttons, one of them is secondary.

**The Drawn-Icon Rule.** Icons are drawn, never typed. Every icon is an SVG — sprite-stroked with an ink token, or an inline-SVG data URI applied through `mask` with `background-color: currentColor`. No icon fonts, no text glyphs, no emoji as UI chrome.

**The Mirror Rule.** Every dark-mode value is declared twice: once inside `@media (prefers-color-scheme: dark) > :root:not([data-theme="light"])` and once in a `:root[data-theme="dark"]` block. That duplication is deliberate — it is what lets an explicit toggle win in both directions. A new dark value that lands in only one of the two blocks is a bug.

## Do's and Don'ts

### Do:

- **Do** route every colour through a `--nx-*` token. If the colour you want has no token, add one to all three theme blocks (light `:root`, the `prefers-color-scheme` block, and the `[data-theme="dark"]` mirror) before you use it.
- **Do** separate rows and sections with a 1px hairline, and reserve every fill for pointer feedback or selection.
- **Do** keep the accent to links, one affirmative action, focus, and progress — the One Blue Rule.
- **Do** take state colour from the existing state tokens (danger / success / warning / purple / info). A new component signalling "late" uses the same danger token the Gantt chart uses.
- **Do** give a tinted state box `border: 1px solid transparent` so it keeps the geometry of its untinted sibling.
- **Do** write logical properties (`padding-inline`, `inset-block-start`) so RTL keeps working, and mirror any background-position you set.
- **Do** set `font-variant-numeric: tabular-nums` on anything that puts numbers in a column.
- **Do** reach for `color-mix(… , var(--nx-canvas))` when a tint must survive both themes from one class, the way avatar hues do.
- **Do** draw new icons as SVG and colour them with `currentColor` or an ink token.

### Don't:

- **Don't** reintroduce zebra striping, or any row fill that is not hover or selection. The stripes are explicitly zeroed out; putting them back undoes the central table decision.
- **Don't** give the top bar, header, tab strip or footer a coloured fill. They are the same ground as the page, and the refusal of coloured header bars is the loudest thing this world says.
- **Don't** collapse `--nx-link` into `--nx-primary`. They diverge in dark mode on purpose, and merging them drops one of the two below 4.5:1.
- **Don't** write a literal hex, `rgb()` or named colour into a component rule, and don't assign a literal value to an `--oc-*` name — the open-color scale is an alias layer, not a palette.
- **Don't** put a shadow on a resting surface. Cards, panels, rows and inputs get a hairline; shadow means the thing has left the page.
- **Don't** use `{rounded.full}` on anything that is not the primary action, a badge, a progress bar or an avatar.
- **Don't** render UI chrome icons as text glyphs, icon-font characters or emoji.
- **Don't** uppercase labels with `text-transform`, and don't hardcode UI strings — copy comes from locale files and case belongs to the translation.
- **Don't** treat an empty result as an error state; it takes the quiet `fill-subtle` treatment, not a coloured callout.
- **Don't** copy colour values out of the Rouge syntax-highlighting block at the foot of the stylesheet. It is untouched generated output with literal light-only hex, and it is the one part of the file that does not speak the token system.
