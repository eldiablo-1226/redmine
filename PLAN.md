# Plan: /impeccable enhancement sweep (typeset · colorize · layout · animate)

_Locked via claudex-loop — by Claude + shakhzod, 2026-08-31. Revised after Codex review rounds 1–3._

## Goal

The Notion-derived redesign already shipped to `master` (`069d9a860`, merged as `aa366a6af`). This sweep does not redesign it and does not add ornament to it. It closes a set of **measured** defects in the shipped system — a status encoding that is grayscale-identical, three typographic values below published floors, a prose measure wrong by 22 characters, a motion vocabulary that drifted into twelve hardcoded durations, and a row-action affordance keyboard users cannot reach at all.

Every change lands inside the committed visual world with **one owner-approved exception**, recorded in §2 and scoped to a single selector: `tr.issue td.status .badge-status-closed` is granted a carve-out from the Tinted-Ground Rule. Open chips, plugin-provided badges, and the locked badge are outside the exception. Everything else — one blue, hairline structure, no zebra, no colored chrome, sentence case, `--nx-*` tokens, self-hosted Inter — is unchanged.

Research: [docs/research/2026-08-30-redmine-impeccable-sweep-claudex-research.md](docs/research/2026-08-30-redmine-impeccable-sweep-claudex-research.md). Review history: [PLAN-REVIEW-LOG.md](PLAN-REVIEW-LOG.md).

## Execution environment

**Every Ruby, Rails and rake command runs inside the container**, not on the host. The host carries system Ruby 2.6.10 while `Gemfile.lock` requires 3.3.12, and Bundler 2.5.22 is not installed there; the container `redmine-figma` carries Ruby 3.3.12 and Bundler 2.5.22. The canonical prefix is:

```
docker exec redmine-figma sh -lc 'cd /redmine && <command>'
```

Node is not installed in the container, so stylelint runs on the host. `node_modules` is absent there too, so it runs through `npx --yes stylelint@16`, which needs network on first use. If that is unacceptable, `yarn install` once on the host and drop the `--yes`.

## Approach

Typography moves the metrics layout is measured against, so it goes first.

**Every browser-observable change is gated by a first-party system test.** The repository ships Capybara + Selenium + Chrome (`test/application_system_test_case.rb:39`) with 40+ tests under `test/system/`. That is the reproducible seam; a hand-rolled screenshot harness is strictly worse and is demoted to review material that gates nothing.

### 0. Baseline measurement (no edits)

Four research questions (#1, #3, #4, #6) are open only because nobody booted a browser. This step closes them and settles three values the plan deliberately leaves open.

- Run against `redmine-figma` (`http://localhost:3001`, live-mounted, dev mode, seeded project `notion-demo`, login `admin`).
- Screenshots via headless Chrome, written to `/tmp/impeccable/before/<route>__<w>x<h>__<theme>.png`. Review material only.
- Viewport matrix: **375×812, 1440×900, 2560×1440** × {light, dark}. 2560 is mandatory — it is where a 1280px `#content` can visually detach from the sidebar inside the flex shell, which is the accepted risk from decision 2.
- Routes: `/issues`, `/issues/:id`, `/admin`, `/settings`, `/settings?tab=display`, `/my/page`, `/my`, `/projects`, `/projects/notion-demo/wiki`, `/projects/notion-demo/wiki/NoSuchPage` (the edit-on-missing state, `wiki_controller.rb:86`), `/projects/notion-demo/wiki/index`, `/news`, `/projects/notion-demo/settings`, `/admin/projects`, `/admin/plugins`, `/users`, `/projects/notion-demo/time_entries`, `/login` (signed out), plus `/404.html` and `/500.html` fetched as static files.

**Three values are decided by the owner at the browser, not by a formula.** Earlier drafts dressed these up as objective criteria; two of those criteria did not survive review — line-height cannot affect subject-column wrapping, and "reads cleanest" names no judge. They are owner calls, and the plan records them as such:

| Value | What is shown | Outcome recorded in |
|---|---|---|
| `table.list td` line-height | The same 30-row list at 1.35, 1.40 and 1.50, screenshotted at 1440×900, with the rows-per-viewport count printed on each | PLAN-REVIEW-LOG.md |
| letter-spacing at 13–14px | The same list at 0, +0.01em and −0.0062em, 1× and 2×, both themes | PLAN-REVIEW-LOG.md |
| row hover 90ms vs 0 | A screen recording of a pointer sweep down 30 rows at each setting | PLAN-REVIEW-LOG.md |

No implementation touching these values starts before the owner's choice is recorded.

### 1. typeset

- Delete `font-feature-settings: "cv05" 1, "ss03" 1` (`application.css:623`). A fontTools dump of all nine committed woff2 faces (Inter v4.001) reports exactly `calt ccmp dnom frac kern locl mark mkmk numr pnum tnum`. Neither feature exists in the binaries.
- **Narrowly** suppress the `calt` digit-`x`-digit bug (`1x2` → `1×2`) with `font-variant-ligatures: no-contextual` on identifier-bearing contexts only: `tr.issue td.id`, `tr.entry td.size`, revision and branch labels, `.repository .filename`. Issue subjects and journal prose are left alone, because the property also alters localized and fallback-font rendering. A system test renders a Cyrillic and an RTL locale to confirm nothing regressed.
- Raise `h4` (`:643`) to `0.875rem` / weight 600 and drop `--nx-ink-muted`. It currently renders smaller than the 14px body while also muted and rule-separated — three emphasizers stacked in the demoting direction.
- Raise `.badge` (`:3195`) from 11px to 12px.
- Keep `table.list` cells at 13px; they contain links.
- Line-height and letter-spacing per the step-0 table. Negative tracking on `h1`/`h2`/`h3` untouched — it follows Inter's published curve, and `DESIGN.md`'s Tight-Tracking Rule. **If the owner's tracking choice puts non-label 13–14px text at a non-zero value, that is a second design-rule renegotiation and is escalated, not absorbed.**
- **Alignment — scoped to issue lists, using exact selectors.** `table.list td { text-align: center }` (`:1374`) is the shared default for every list in the product and **stays**. All changes are scoped with `:is()` inside a single `tr.issue` prefix — writing `tr.issue td.hours, td.total_hours` would silently drop the prefix after the first comma and make the rest global, which an earlier draft did:

  | Exact selector | Now | After | Why |
  |---|---|---|---|
  | `tr.issue td.id` | center (`:1376`, global `table.list td.id`) | start | An issue number is a qualitative digit string, not a magnitude. Scoped to `tr.issue` so wiki-history and revision IDs keep their current alignment |
  | `tr.issue :is(td.tracker, td.status, td.priority, td.category, td.fixed_version)` | already `start` (`:1419`) | unchanged | Already correct; **not** extended to non-issue lists, because `td.status` outside issues would override the deliberately centered version status |
  | `tr.issue :is(td.hours, td.total_hours, td.int, td.float)` | center | `text-align: right` | Magnitudes compare on the right. **Physical `right`, not logical `end`** — `DESIGN.md:364` names numeric columns as the deliberate exception to the Logical-Property Rule, and the four existing sites (`:1378`, `:1469`, `:1517`, `:2084`) all carry the comment "Numbers should be right aligned even in RTL". Custom-field numeric classes are `int` and `float`, which is what Redmine emits |
  | `table.list th:is(.hours, .total_hours, .int, .float)` | mixed | `text-align: right` | Header follows its column. Mirrors the existing rule at `:1370`, which is already global `table.list th.<column>` — right-aligning a numeric header is correct on every list that has one, so this row is deliberately not `tr.issue`-scoped |

  Explicitly not touched: `td.checkbox`, `td.reorder` (`:1390`), `td.icon`, boolean columns, and `td.buttons` — already `text-align: end` at `:1386`.
- Numeric columns at weight 500. Measured advance-width drift across weights 400–700 in the shipped tnum faces is 0.195% (1328/1327/1325/1324 at upem 2048) — ~0.15px across a six-digit cell.
- Keep `font-variant-numeric: tabular-nums` at `:1333`, `:1752`, `:2952`.
- No all-caps. `text-transform: none` at `:3202` stays.

**RED test:** `test/system/issue_list_typography_test.rb` — computed `text-align` on `tr.issue td.id` and a numeric column; **and** that a wiki-history `td.id` and a version status cell are unchanged; computed `font-size` on `.badge`; `h4` no smaller than `body`.

### 2. colorize

The defect is **not** contrast. `--nx-badge-open-ink: #005bab` on `#e8f2fd` = 6.01:1; `#146633` on `#e6f4ea` = 6.21:1 — both clear AA; the 4.03:1 figure in the older critique is stale. The defect is that open and closed are separated by hue alone: ink-to-ink 1.04:1, fill-to-fill 1.00:1. In grayscale they are the same chip.

**Design-contract exception — owner-approved 2026-08-31, scoped to one selector.** The outline chip contradicts the Tinted-Ground Rule (`DESIGN.md:313`), the never-coloured-borders sentence (`:390`) and the Transparent-Border Rule (`:398`). The `border: 1px solid transparent` slot at `application.css:3216-3230` is not an unspent slot; it *is* the rule. The exception applies to **`tr.issue td.status .badge-status-closed` and nothing else** — not open chips, not `.badge-status-locked`, not plugin-provided badges, not the same class outside an issue list.

- **Shape:** `tr.issue td.status .badge-status-closed` takes a transparent fill and a 1px hairline in `--nx-success`.
- **Symbol:** one `sprite_icon` before the label in the `when :status` branch of `app/helpers/queries_helper.rb:291-296`, at 12–14px, from the shipped `app/assets/images/icons.svg`.
- Both channels say what the text says — redundant, never conjunctive.
- **`.badge-status-locked` untouched.** Live and tested: `wiki/show.html.erb:94`, `versions/index.html.erb:29`, `versions/show.html.erb:11`, covered by `test/functional/wiki_controller_test.rb:239` and `test/functional/versions_controller_test.rb:137`.
- Priority untouched — `:1426-1429` already spends color only above the default rung.
- Three distinct indicators maximum per row. Derived categories only (`IssueStatus#is_closed`, `IssuePriority#position_name`); never admin-authored names; never a per-status color setting.
- No `max-width` + ellipsis on `.badge` — a truncated lozenge is unrecoverable because it is not focusable.
- No new blue. `--nx-primary-soft` is also the context-menu selection (`:1556`) and journal highlight (`:3141`).

**RED tests:** `test/helpers/queries_helper_test.rb` (glyph present, before the label, for open and closed) and `test/system/issue_list_status_test.rb` (computed border-color differs between open and closed in the issue list; the wiki and version badges keep their filled rendering).

### 3. layout

- `--nx-frame` (page frame, **outer box**) and `--nx-measure` (prose). Root default `--nx-frame: none`; **framed actions set `--nx-frame: 1280px`** — an earlier draft defined the primitive and never assigned the value. Applied as `#content { box-sizing: border-box; max-inline-size: var(--nx-frame); margin-inline: auto; }`. `box-sizing` is explicit because the stylesheet has no universal reset (it is declared only at `:817`, `:1086`, `:1218`, `:1710`), so without it 28px inline padding turns 1280px into 1336px.
- **Framed per action; the list is closed:** `admin#index`, `my#page`, `my#index`, `wiki#show`, `news#index`, `projects#index`, `settings#index`, `settings#edit`. **Excluded by name:** `settings#plugin` (renders arbitrary plugin partials), every issue list, repositories, gantt, timelog, versions, `wiki#history`/`#annotate`/`#diff`/`#date_index`, `admin#projects`, `admin#plugins`, project settings. `wiki#show` renders the edit form for a missing page (`wiki_controller.rb:86`) and is captured and tested in that state separately.
- **Measure:** `72ch` on wiki prose (`:656`) renders ~97 characters in Inter at 14px — `1ch` (0.6309em) is 35% wider than a mean rendered character (0.4678em). Replace with `--nx-measure: 35em` ≈ 75 characters.
- **Admin grouping — what is actually achievable.** The menu is `Redmine::MenuManager`-driven (`lib/redmine/preparation.rb:251-310`) and plugin-extensible.

  | Group | Nodes |
  |---|---|
  | People | `users`, `groups`, `roles` |
  | Issue configuration | `trackers`, `issue_statuses`, `workflows`, `custom_fields`, `enumerations` |
  | System | `settings`, `ldap_authentication`, `applications`, `plugins`, `info` |
  | Content | `projects` |
  | Other | every node not named above, including any plugin-injected node |

  Three corrections forced by review, stated rather than papered over:

  1. **Grouping reorders across groups by construction.** `projects` is the first node in the menu and lands in Content, which is last. That is the point of grouping. The plan preserves order *within* each group and makes no promise about cross-group order.
  2. **`before:`/`after:` adjacency cannot be honored.** `menu_manager.rb:307-318` does `options.delete(:before)` / `options.delete(:after)` at insertion time; the declaration is consumed to compute a position and is not retained on `MenuItem`. A renderer therefore cannot detect it. Grouping is applied to the resolved order, and a plugin that positioned itself next to a specific node will be separated from it if the two fall in different groups. This is a known, accepted limitation, and it is why unknown nodes get their own group instead of being scattered.
  3. **Nested `<ul>` is legitimate and is not forbidden.** Plugin child menus render nested lists. Instead of asserting `no ul ul`, the grid selector is tightened from `#admin-index #admin-menu ul` (`:959`, which matches every descendant) to a direct-child or explicitly classed selector, so a nested child list does not become a nested grid.

  The "Other" heading is frozen: key `label_admin_menu_other`, English `Other`, Russian `Прочее`, added to `en.yml` and `ru.yml`. `rake locales:update` (`lib/tasks/locales.rake:26`) propagates the key to the remaining locales with the English string — upstream's own mechanism, backed by `config.i18n.fallbacks = true` (`config/application.rb:59`). The other four headings reuse existing translated keys (`label_user_plural`, `label_issue_plural`, `label_administration`, `label_project_plural`). A system test renders `/admin` under `de` **after** running `locales:update`, so it tests the real shipped state rather than a fallback that has already been materialized.
- **`#sidebar` rework is dropped** (round 1). The only survivor is converting the physical `width` breakpoints at `:942-947` to logical properties, and it ships **with** an RTL and a collapsed-sidebar system test or it does not ship.
- **The empty-state conversion is cut entirely** (round 3). Every candidate view already renders its "New X" action immediately above the empty message, so `nodata_tag(action)` would duplicate the CTA unless the existing control were also moved — which is a layout change to seven admin screens that nobody asked for. The supporting detail was also wrong in two ways: `:manage_enumerations` is not a permission (the controller is admin-gated), and repository creation additionally requires `Setting.enabled_scm.any?`. The claimed "closed inventory" was not closed either. Cutting is the correct outcome; `nodata_tag` and `.nodata` styling are left exactly as they shipped.
- **`public/404.html` and `public/500.html` stay self-contained.** Both are standalone documents with inline `<style>` that load no application stylesheet, so `var(--nx-frame)` is undefined there. Each gets an equivalent frame declared locally, both updated together.

**RED tests:** `test/system/admin_index_grouping_test.rb` (a synthetic plugin node lands in Other; `info` lands in System; permission-filtered nodes stay filtered; a nested child list does not become a grid; `/admin` renders under `de`) and `test/system/content_frame_test.rb` (framed actions have a bounded `#content` of 1280px outer, excluded actions do not, checked at 1440 and 2560).

### 4. animate

Consolidation, not addition.

- Keep `--nx-dur-fast: 90ms` and `--nx-dur: 160ms` (`:184-186`), subject to the step-0 row-hover decision.
- Consolidate the hardcoded transitions at lines 700, 713, 734, 823, 887, 911, 1001, 1769, 2867, 3108 onto `var(--nx-dur-fast) var(--nx-ease)`. `:1769` is additionally `linear`, which no source defends for UI.
- **No exit tokens** (round 1). `.drdn-items` and `ul.menu-children` toggle `display:none` and modal/tooltip closure is jQuery UI's, so a CSS exit transition is cut off at frame zero.
- Issue-list transitions restricted to opacity, color, background-color, border-color. Never animate height on `tr.group` toggles.
- Rewrite `@keyframes nx-flash-in` (`:4031-4034`) opacity-first, keeping ~4px as the translation cap for the file.
- **Reduced motion — matrix, corrected against the actual source.** An earlier draft misdescribed two of these lines; the descriptions below were re-read at HEAD.

  | Line | Selector, read at HEAD | Under `reduce` |
  |---|---|---|
  | `:700` | `.top-menu__links a, #account .dropdown-trigger` — background + color | kept |
  | `:713` | `.top-menu__links svg.icon-svg, #account .dropdown-trigger .icon-svg` — `stroke` | kept |
  | `:734` | `button.theme-toggle` — background | kept |
  | `:823` | `#quick-search #q` — background, border, box-shadow | kept; focus feedback is meaning |
  | `:887` | `#main-menu li a` — color + box-shadow | kept |
  | `:911` | `#main-menu li a.new-object` — background | kept |
  | `:1001` | `#sidebar a` — background + color | kept |
  | `:1559` | `table.list tbody tr` — row hover background | kept |
  | `:1682` | `.contextual > a, .contextual > .drdn > a, #sidebar a, .contextual .drdn-items > a` — already tokenized | kept |
  | `:1769` | `input[type=submit], button[type=submit], input[type=button], .button, .nx-confirm-actions button` — background + border, currently `linear` | kept, easing corrected |
  | `:2867` | `#content .tabs ul li a` — color + box-shadow (the tab underline) | kept |
  | `:3108` | `.mypage-box > .contextual` — opacity | **removed**; visibility becomes instant |
  | `@keyframes nx-flash-in` (`:4031`) | opacity + 4px translate | overridden to fade with **no** translation |
  | `svg.svg-loader` | spinner | keeps turning — essential-motion carve-out, SC 2.3.3 |

  Two earlier drafts mislabelled rows in this table; every row above was re-read from the file. Note that `:1682` already covers `#sidebar a`, duplicating `:1001` — the consolidation pass folds them rather than tokenizing both.

  A blanket transform reset is **rejected**: it would suppress static transforms including the `scaleY(-1)` chevron flip at `responsive.css:176-178`. New motion is wrapped in `@media (prefers-reduced-motion: no-preference)`.
- **Fix `.mypage-box > .contextual` reachability first.** It sits at `opacity: 0.001` until `:hover` (`:3108`), unreachable for keyboard and coarse-pointer users. Add `:focus-within` visibility and persistent visibility under `@media (hover: none), (pointer: coarse)`; only then gate the hover animation behind `@media (hover: hover) and (pointer: fine)`.
- `transition-delay` stays zero. Never animate keyboard-initiated surfaces. Hard ceiling 300ms.

**RED tests:** `test/system/my_page_contextual_test.rb` and `test/system/reduced_motion_test.rb`.

### 5. Carried-over debt — diagnosis only, no pre-authorized fix

The prior review's fix #4 claimed the mobile issue list loses data. **The premise is stale:** `app/views/issues/_list.html.erb:7` already wraps the table in `.autoscroll`, which (`application.css:2191`) supplies `overflow-x: auto` plus edge-fade gradients. The `overflow-x: visible` at `:3923` is inside `@media print`.

Step 0 measures at 375px with touch emulation: `scrollWidth` vs `clientWidth`, touch-drag scrollability, and keyboard reachability — the wrapper carries no `tabindex`, so it is likely not keyboard-scrollable at all, and that is the probable real defect.

- Columns reachable → **phase deleted**, recorded as fixed by `069d9a860`.
- Not reachable → **stop, report the diagnosis, revise this plan.** No fix is pre-authorized. Same for fix #5 ("Log time" wrapping).

### 6. DESIGN.md and design.json synchronization

Both files updated in the same series; the owner reviews that diff alongside the code. Contracts touched: the **Tinted-Ground Rule** (`:313`), never-coloured-borders (`:390`) and **Transparent-Border Rule** (`:398`) gain a named exception scoped to `tr.issue td.status .badge-status-closed`; the status glyph as a new documented behavior; `.badge` 11px → 12px; `h4` size and color; removal of the `cv05`/`ss03` line and the narrowed ligature policy; the issue-list alignment rules and numeric-column weight, explicitly noting that numeric columns keep physical `right` per the **Logical-Property Rule** (`:364`); dense line-height and tracking (owner's step-0 values); `--nx-frame`/`--nx-measure` and the action-to-frame mapping; motion consolidation and the reduced-motion matrix; the contextual-action accessibility rule; admin index grouping; the error-page treatment.

### 7. Verification

**Gates. Each must exit 0.**

```
docker exec redmine-figma sh -lc 'cd /redmine && bin/rails test \
  test/helpers/queries_helper_test.rb test/functional/issues_controller_test.rb \
  test/functional/admin_controller_test.rb test/functional/wiki_controller_test.rb \
  test/functional/versions_controller_test.rb'
docker exec redmine-figma sh -lc 'cd /redmine && bin/rails test'
docker exec redmine-figma sh -lc 'cd /redmine && bin/rails test:system'
docker exec redmine-figma sh -lc 'cd /redmine && bundle exec rubocop'
npx --yes stylelint@16 "app/assets/stylesheets/**/*.css"
```

`test/helpers/queries_helper_test.rb` is the correct path; an earlier draft named a nonexistent `test/functional/` file.

**Selector-preservation gate.** Baseline is `aa366a6af`, the commit this sweep starts from. Two earlier forms were wrong and both were caught by actually running it: `git merge-base HEAD master` resolves to HEAD when work lands directly on `master`, and an unquoted `$BASE:app/...` is parsed by zsh as the `:a` path modifier, so the baseline extracted zero selectors and the gate reported PASS vacuously. It now asserts a non-empty baseline before comparing, and the exit-code polarity is fixed — the earlier form exited 1 on success.

```
BASE=aa366a6af
extract() { grep -oE '^[^{@/][^{]*\{' "$1" | sed 's/[{ ]*$//; s/^[[:space:]]*//; s/[[:space:]]*$//' | sort -u; }
git show "${BASE}:app/assets/stylesheets/application.css" > /tmp/base.css || { echo "FAIL: baseline unreadable"; exit 1; }
extract /tmp/base.css > /tmp/sel-before
extract app/assets/stylesheets/application.css > /tmp/sel-after
[ "$(wc -l < /tmp/sel-before)" -ge 900 ] || { echo "FAIL: baseline extraction looks empty"; exit 1; }
grep -v '^#' .impeccable/selector-removals.allow | grep -v '^$' > /tmp/allow
comm -23 /tmp/sel-before /tmp/sel-after | grep -vxF -f /tmp/allow > /tmp/sel-dropped || true
[ -s /tmp/sel-dropped ] && { echo "FAIL: selectors dropped"; cat /tmp/sel-dropped; exit 1; }
echo "selector gate: PASS"
```

Baselining at `aa366a6af` rather than at upstream is deliberate: the gate's job is that *this sweep* drops nothing. Run against upstream `2308cb59c` it reports 10 selectors already dropped by the shipped redesign, most of them benign regroupings (`#sidebar-switch-button` became `#sidebar #sidebar-switch-button`; the `arrow_up.png` project-jump rule was replaced by a `scaleY(-1)` transform), but `.pagination ul.pages li:first-child` and `li:last-child` appear to be genuine losses. That is a pre-existing defect in `069d9a860`, reported to the owner and **out of scope here**; it is not laundered into this sweep's gate.

Known limitation, stated rather than hidden: the extraction is line-based and does not resolve selector lists split across lines. It is a regression tripwire, not a parser. `.impeccable/selector-removals.allow` is empty at plan time — nothing is authorized for removal yet.

**Hook-preservation gate**, executable:

```
BASE=aa366a6af
CHANGED=$(git diff --name-only "$BASE" -- 'app/views/**/*.erb')
[ -z "$CHANGED" ] && echo "hook gate: no ERB changed, nothing to check"
for f in $CHANGED; do
  diff <(git show $BASE:$f | grep -n call_hook) <(grep -n call_hook $f) || \
    { echo "FAIL: call_hook changed in $f"; exit 1; }
done
```

**Advisory, not gates** — labeled honestly because they cannot fail a build:

- `docker exec redmine-figma sh -lc 'cd /redmine && bundle exec rake locales:check_interpolation'` prints mismatches and never aborts (`lib/tasks/locales.rake` contains no `abort`/`raise`/`exit`), and it does not check for missing keys. Read its output; do not treat exit 0 as a pass.
- The WCAG 1.4.12 text-spacing override pass is a manual bookmarklet check. Named risks: `white-space: nowrap` on `table.list th`, `td.buttons`, `td.reorder`; `body { min-inline-size: 900px }`.
- Static error pages: `grep -q 'max-inline-size' public/404.html && grep -q 'margin-inline' public/404.html`, and the same for `500.html`. An earlier draft grepped for `max-width`, which would have failed a compliant implementation and passed an unrelated occurrence — the plan mandates logical properties, so the assertion must name the property the plan actually requires.

**Owner review from rendered evidence:** glyph separability at row size (if it fails, drop the glyph and keep the outline chip — do not enlarge until it wins); framed surfaces checked for the GitHub #7096 shape at 1440 and 2560, `projects#index` and `wiki#show` being the named risks; contrast pairs in both themes.

## Constraints

- **No animation may block, delay or overlay the next action.**
- **No JS enhancement may break Ctrl-F, scroll position or the back button.**
- Never delete or relocate a `call_hook` site.
- Additive at the class level. Do not rename or remove `#main`, `#sidebar`, `#content`, `#wrapper`, `table.list`, `tr.issue`, `.contextual`, `.box`, `.tabs`, `.attributes`, `.journal`, `.splitcontentleft/right`, `#query_form`, `#filters`, `#admin-menu`, `#list-definition`, `.nodata`, `#footer`.
- No load-bearing design work in `responsive.css`, `gantt.css`, `jstoolbar.css`, `dropdown.css` — `application_helper.rb:1748-1762` substitutes any of those five filenames wholesale from an installed theme.
- Every new icon through `sprite_icon`.
- Hold the `!important` budget: add a class, never escalate on `#content` / `table.list` / `.contextual`.
- Logical properties throughout, **except** numeric column alignment, which stays physical `right` per `DESIGN.md:364`.
- Inter woff2 files only through Propshaft-resolved helpers.

## Key decisions & tradeoffs

1. **Scope: four build phases, a diagnosis-only debt phase, a docs-sync phase.** `delight` was collapsed in round 1; the empty-state conversion was cut in round 3.
2. **Framing is wider than recommended, action-scoped and closed.** Residual risk: `projects#index` and `wiki#show` carry tables inside a capped column — the GitHub #7096 shape — and carry a named gate at 1440 and 2560.
3. **cv05: delete, do not re-subset.**
4. **Status encoding ships shape and symbol at once and renegotiates one named design rule to do it,** scoped to a single selector, owner-approved on the record.
5. **No branch discipline.** Single-maintainer repo; work lands on `master`.
6. **Five items were cut rather than specified** — the `#sidebar` primitive rewrite, motion exit tokens, the standalone delight phase, the empty-state conversion, and the pre-authorized mobile fix. Each cut is recorded with its reason in `PLAN-REVIEW-LOG.md`.
7. **Verification runs on first-party system tests inside the container.** The host cannot run this project's Ruby at all.

## Toolchain

- **Impeccable playbooks** on both benches; the build follows `reference/typeset.md`, `colorize.md`, `layout.md`, `animate.md`, and loads `reference/craft-floor.md` immediately before the first UI edit.
- **Rejected: the `gsap-*` pack.** This phase removes hardcoded durations; a JS animation runtime would be a dependency bought for negative work.
- **Degraded: the impeccable detector.** `node_modules` is absent in the skill directory and `.erb` is not in `SCANNABLE_EXTENSIONS` (`scripts/detector/node/file-system.mjs:26`), so `detect.mjs --scope type|layout` returns near-empty. **Owner's call, still open:** install the four packages there, or accept that mechanical evidence comes from stylelint, the system tests and the selector gate. The plan assumes the latter and claims no clean detector scan anywhere.
- **Repository tooling used as-is:** RuboCop, stylelint 16, `rake locales:*`, Capybara/Selenium system tests.

## Assumptions

1. The redesign is live on `master` — `aa366a6af` merges `069d9a860`.
2. **Corrected (Phase 0):** the 2026-08-30 critique describes the pre-merge state; both P0s and both P1s are closed.
3. **Corrected (Phase 0):** the quoted WCAG AA failure is stale — 6.01:1 and 6.21:1 measured at HEAD.
4. Six of the eight fixes from the 2026-08-30 review are closed.
5. `PRODUCT.md` is binding.
6. Plugin and theme compatibility remains an owner-open constraint; not promoted to a requirement, not broken.
7. The demo container is up and live-mounts the repo, and is the only place this project's Ruby runs.
8. Redmine's JS arrives by two paths; `javascript_heads` emits rails-ujs from gem asset paths, invisible to a repo grep.
9. **Corrected (round 1):** `.badge-status-locked` is live and test-covered.
10. **Corrected (round 1):** every `nodata_tag` call site already passes an action.
11. **Corrected (round 1):** the issue list is already wrapped in `.autoscroll`.
12. **Corrected (round 2):** `td.buttons` is `text-align: end` (`:1386`), not center.
13. **Corrected (round 2):** `:info` is a core admin node (`preparation.rb:301`).
14. **Corrected (round 2):** `config.i18n.fallbacks = true` and `rake locales:update` mechanize the locale convention.
15. **Corrected (round 3):** numeric columns keep physical `right`; `DESIGN.md:364` names them as the deliberate exception to the Logical-Property Rule.
16. **Corrected (round 3):** `before:`/`after:` is consumed at insertion (`menu_manager.rb:307-318`) and cannot be honored by a renderer.
17. **Corrected (round 3):** the host Ruby is 2.6.10 against a 3.3.12 lockfile; all Ruby commands run in the container.

## Risks / open questions

1. **The wider framing set** — `projects#index` and `wiki#show` carry tables inside a capped column.
2. **Plugin blast radius on `queries_helper.rb` is a floor**, counted against free mirrors rather than commercial RedmineUP builds. If a later pass breaks a plugin-depended selector, ship `nx-compat.css` rather than reverting the design.
3. **Glyph separability at 13px is unverified** until step 0.
4. **The design-rule exception is permanent** in `DESIGN.md`. Reversing it later regresses the encoding to hue-only unless a replacement channel is chosen at the same time.
5. **The admin "Other" group is untested against a real plugin** — the test injects a synthetic node.
6. **Plugins that positioned themselves with `before:`/`after:` will be separated from their anchor** when the two fall in different groups. Accepted; the declaration is not recoverable at render time.
7. **The detector question is unanswered.**
8. **Whether a theme shipping `stylesheets/responsive.css` is substituted on 7.x** is contradicted between the code and open Redmine Defect #22861.
9. **System tests at 2560px depend on Selenium resizing reliably**; if Chrome clamps to the display, that check falls back to owner review at the real resolution.
10. **The selector gate is line-based** and will not catch a dropped member of a multi-line selector list.

## Out of scope

- Replacing the committed visual world. The single approved exception is `tr.issue td.status .badge-status-closed`.
- Any runtime or repository dependency: JS animation library, CSS framework, build step, grid library, container-query polyfill, second typeface, `puppeteer-core` in the repo.
- Schema changes, migrations, preference columns, settings forms.
- Skeleton loaders; celebrations, confetti, completion flourishes; mascots and empty-state illustration; parallax and scroll-linked motion; shadow-driven hover lift on issue rows.
- Zebra striping, status-tinted row backgrounds, colored chrome, all-caps, a second blue.
- Per-status color settings; colorizing admin-authored names.
- The `#sidebar` layout-primitive rewrite, CSS exit animations, a standalone delight phase, the empty-state conversion.
- Converting the redesign into a theme directory, migrating CSS into `redmine_custom_css`, or adopting SCSS/Grunt.
- Upstream rebase discipline and branch strategy.
- Hand-translating new locale keys into the other 48 locales.
- Any fix for the mobile table or the "Log time" wrap before step 0 diagnoses a cause.
