---
target: редизайн Redmine (слишком простой)
total_score: 21
max_score: 40
na_heuristics: 
p0_count: 2
p1_count: 2
timestamp: 2026-08-30T12-35-39Z
slug: app-assets-stylesheets-application-css
---
Method: dual-agent (A: design review · B: detector + browser measurement)

## Design Health Score

| # | Heuristic | Score | Key issue |
|---|---|---|---|
| 1 | Visibility of system status | 2 | `Loading…` renders over the clicked row at 13px on `--nx-fill-subtle`; no skeletons, no dirty-form state |
| 2 | Match system / real world | 3 | Domain vocabulary sound; `label_no_data` = "No data to display" on every empty surface |
| 3 | User control and freedom | 2 | Native `window.confirm()` on delete; no undo; Cancel is a bare link beside the pill submit |
| 4 | Consistency and standards | 2 | Sidebar present on issues/wiki/roadmap, absent on overview/edit/admin → content column jumps 280px. Two byte-identical 26px/700 h1 per page |
| 5 | Error prevention | 2 | "Delete issue" flush under "Copy" in a 15-item context menu, no separator |
| 6 | Recognition rather than recall | 2 | Status/priority/tracker are undifferentiated text — every cell must be read |
| 7 | Flexibility and efficiency | 3 | Context menu, saved queries, bulk ops, focus-visible all work; no keyboard affordance surfaced |
| 8 | Aesthetic and minimalist | 2 | Minimal yes, resolved no: no measure, no composition on 7 of 10 surfaces, no signature element |
| 9 | Error recovery | 2 | 404 is a 1100px danger banner for one sentence, then a lone Back and 600px of void |
| 10 | Help and documentation | 1 | Help → redmine.org. Zero inline hints, zero empty-state guidance, zero first run |
| **Total** | | **21/40** | Below par for a daily-driver work tool |

## Design Specificity Verdict

Category-interchangeable. Strip the word "Redmine" and this is any 2023 self-hosted admin tool: white page, grey hairlines, one blue, Inter. No signature moment on any screen.

Measured portrait of the plainness (issues list, 1440x900, light / dark):
- distinct painted backgrounds: 3 / 3
- elements with box-shadow != none: 1 / 1 (and it is a 2px inset tab underline, not elevation)
- distinct border-radius values: 2 / 2
- distinct font weights rendered: 4 / 4 (400 x91, 500 x25, 600 x5, 700 x1)
- saturated colours in the chrome: 1 (`#0075de`)
- `--nx-shadow-sm/md/lg` declared, applied to zero elements on both pages
- header 99.6px, content gutter 24/28/48, table row 34.5px

Deterministic scan: CLI returned `[]` exit 0, but the run was a near no-op — `.erb` is absent from SCANNABLE_EXTENSIONS (detector/node/file-system.mjs:26), so 1 of 81 target files was read; re-running with all 76 .erb passed explicitly gave the same `[]`. The static-HTML engine is unavailable (htmlparser2, css-select, domutils unresolvable; no node_modules in the skill dir) and degrades to regex, which does not evaluate custom properties, selector matching or computed contrast. Fix: `npm i htmlparser2 css-select css-tree domutils` in ~/.claude/skills/impeccable/.

Browser injection ran on 5 pages (live-server 8400, started and stopped, repo byte-identical). Real findings: `skipped-heading` (h1 "Redmine" → h3 "Custom queries", missing h2, every page with a sidebar); `clipped-overflow-container` on `#wrapper`, all 5 pages; `low-contrast` on `.badge-status-open` — `#0075de` on `#e8f2fd` = 4.03:1 vs 4.5 required (the only WCAG AA failure in the whole measurement; passes at 5.63:1 in dark).
False positives: `gpt-thin-border-wide-shadow` on `#ajax-indicator` / `.drdn-content` / `ul.menu-children` (display:none, never rendered); `ai-color-palette` / `undersized-ui-text` on `span.avatar-color-*` (hash-derived avatar hues, not authored); `overused-font` on body (factually Inter 100%, but a taste rule).
No overlays are live — the server was stopped before reporting. The demo session was left signed out by the measurement pass.

## Overall Impression

The restraint is applied uniformly to everything, including what carries meaning: status, priority, people, progress. The system stripped ornament and never spent the freed budget anywhere. Biggest opportunity: put encoding back into the issue table — it fixes both the flat look and the stated PRODUCT.md principle that scan speed outranks ornament. "Too plain" is not permission for gradients or coloured chrome: no zebra, no coloured header bars, one blue, hairlines, sentence case all stay.

## What's Working

1. The list table is genuinely well made — `table.list td` (application.css:1266): 7px block padding, one `--nx-hairline` top border, zebra explicitly zeroed both directions, tabular-nums, `--nx-hairline-strong` header underline at 12px/500/+0.01em, row fill reserved for hover.
2. The token remap is real leverage — every `--oc-*` is an alias onto `--nx-*` (:196+), so ~2500 lines of untouched legacy obey the new world for free and dark mode is a complete second palette, not a filter. No leaks between desktop-issues.png and dark-issues.png.
3. The tab underline is the one authored piece of chrome — `inset 0 -2px 0 var(--nx-ink-strong)` + weight 600 (:861-872). No pill, no fill, no colour, reads instantly.

## Priority Issues

### [P0] The issue list encodes nothing
grep for `td.status|td.priority|priority-` in application.css returns zero hits. Immediate/Urgent/High/Normal and In Progress/Resolved all render as identical 0.8125rem `--nx-ink`, centered by `tr.issue { text-align: center }` (:1299). `.badge-status-open/-closed/-locked` are defined (:3023-3037) and unused in lists.
Why: the primary persona lives here all day; every triage decision requires reading instead of recognising. Eleven rows of undifferentiated grey IS the plainness.
Fix: text-align start for `td.tracker, td.status, td.priority, td.category, td.fixed_version` (numerics stay right); apply the existing badge shape to `tr.issue td.status`; `td.priority` weight 600 + `--nx-danger` for Immediate/Urgent, 500 + `--nx-warning` for High, `--nx-ink-muted` below. No new tokens. Lift `--nx-primary-soft` so the badge clears 4.5:1.
Command: /impeccable colorize

### [P0] No page-level composition on sparse surfaces
`#content` (:1007) has no max-inline-size, no grid, no second column. Home, /admin, My page, Projects and 404 render as a left strip with 60-85% of the viewport empty. /admin is 14 links at x=28-190 of a 1440px page. `.wiki` runs full width: ~150 characters per line.
Fix: `.wiki, #content > p, .nodata { max-inline-size: 72ch }`; `#admin-menu ul` to a grid with 3 titled sections; `#content .splitcontentleft/right { flex-basis: 0; min-inline-size: 320px }`. Differentiate `#header h1` from `#content h1` — currently byte-identical 26px/700/-0.02em.
Command: /impeccable layout

### [P1] Zero depth and zero motion, measured
1 shadowed element per page (an inset tab underline); `--nx-shadow-*` applied nowhere. 11 transitions in 3618 lines, 1 @keyframes (the spinner). Table rows have no transition on hover fill; disclosures snap.
Fix: `--nx-ease: cubic-bezier(.2,0,0,1)`, `--nx-dur-fast: 90ms`, `--nx-dur: 160ms`, spent in exactly four places (table row background, `.contextual a` fill, `#sidebar a` fill, Filters/Options disclosure), wrapped in prefers-reduced-motion. Apply `--nx-shadow-md` where it was designed to go: dropdowns, menus, modal, login card.
Command: /impeccable animate, then /impeccable bolder

### [P1] The destructive path has no design
app/views/issues/_action_menu.html.erb:13 and app/views/context_menus/issues.html.erb:178 use `:data => {:confirm => …}` → native window.confirm(). DESIGN.md specifies a modal at `--nx-r-lg` / `--nx-shadow-lg` that this never reaches.
Fix: route data-confirm through a Stimulus controller on native `<dialog>`, destructive action as secondary shape in `--nx-danger`, Cancel default. Add a hairline separator and 6px gap above "Delete issue".
Command: /impeccable harden

### [P2] Empty and first-run states are one string
Every empty surface renders `<p class="nodata"><%= l(:label_no_data) %></p>`. /login still shows Search: and "Jump to a project…" while signed out. Every page ends on "Powered by Redmine © 2006-2026 Jean-Philippe Lang".
Fix: keep the quiet treatment, give `.nodata` a two-line shape with the surface's own primary action inline; new locale keys in en.yml and ru.yml, no hardcoded strings; hide search and project-jump when unauthenticated.
Command: /impeccable onboard

## Persona Red Flags

Developer living in the issue list: cannot triage by shape; all categorical cells centered so there is no left edge to run the eye down; the `...` row menu costs a round trip then shows 15 flat options; Subject ~300px while Updated holds a full `08/30/2026 10:48 AM`; no avatars in the Assignee column though the avatar component exists.
First-day teammate: /login shows controls that cannot work while signed out; the card has no title, mark or copy; home page is two sentences of admin text including "You can modify this message in the 'Welcome text' setting"; My page is two "No data to display" slabs; nothing identifies whose instance this is.
Admin: /admin is 14 ungrouped links in the left 11% of the page; Trackers, Issue statuses, Workflow, Custom fields and Enumerations are one cluster shown as five peers of "Information"; no admin page has a sidebar.
Mobile user: mobile-issues.png clips mid-Subject with `#content {overflow-x: auto}` (:1013) as the only silent mechanism — no scroll shadow, no gradient; Apply/Clear/Save become three full-width buttons of identical weight, the affirmative action loses its accent.

## Minor Observations

- `h4` (:621) is 0.8125rem — smaller than body (0.875rem).
- `#sidebar` breakpoints (:942-947) use physical `width`, contradicting the Logical-Property Rule.
- `p.subtitle { font-style: italic }` (:1700) puts italic in UI chrome.
- Native `<input type=date>` calendar glyph sits 40px from hand-drawn `--nx-chevron` selects — two icon vocabularies.
- `--nx-info` / `--nx-info-soft` declared in all three theme blocks, consumed by zero components.
- The login submit is a ~310px blue pill; at that width `--nx-r-full` reads as a stadium button on the most-seen unauthenticated screen.
- `div.issue .attributes .attribute` (:1715-1716): padding-inline-start 180px with a 170px floated label leaves ~120px of dead gap between "Status:" and its value.

## Questions to Consider

1. Delete every `--nx-primary` fill — could anyone identify the product? If not, the blue is doing identity work it was never designed for.
2. DESIGN.md says the load-bearing idea is the remap, which is by definition invisible to the user. What is the load-bearing idea the user can see?
3. The build follows Notion's tokens exactly and its proportions not at all. Was the reference read as a palette when it was a spatial argument?
4. Roadmap is the only screen with a peak, and its peak is a progress bar — a component about magnitude. What else in this product has a magnitude worth drawing?
5. The most destructive action renders in the OS font through window.confirm(). In what sense is the design system a system?
