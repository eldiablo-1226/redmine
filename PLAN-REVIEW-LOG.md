# Plan Review Log: /impeccable enhancement sweep (Redmine)

Phases 0-1 (recon + interrogation) complete — plan locked with the user. MAX_ROUNDS=5.

Reviewer: codex-cli 0.144.1, model `gpt-5.6-sol` (CLI config default, `-m` unpinned), `model_reasoning_effort = "ultra"`.
Research tier: `deep` — 13-agent workflow, brief at `docs/research/2026-08-30-redmine-impeccable-sweep-claudex-research.md`.
Tunables: MAX_ROUNDS=5 · PLAN_FILE=PLAN.md · LOG_FILE=PLAN-REVIEW-LOG.md · inspect=on · MAX_INSPECTION_ROUNDS=2.

Phase 0 corrected two premises the user's own prior critique asserted: the critique predates commit `069d9a860` and its P0/P1 findings are closed, and the quoted WCAG AA failure is stale (measured 6.01:1 at HEAD).

## Round 1 — Codex

`VERDICT: REVISE` — 17 findings. Critique verbatim:

The plan is not implementation-ready. Material problems:

1. **The “dead” locked badge is live.** `.badge-status-locked` is used by wiki locks and version statuses, with functional tests covering both; deleting it would regress existing UI.  
   Fix: Retain the global locked badge and remove the “wire or delete” task unless it is explicitly scoped to issue-list markup.

2. **Admin grouping can drop plugin-provided menu entries.** The admin menu is dynamic and has an existing plugin-extension test; a fixed 14-item grouping has no destination for unknown plugin nodes and may also alter the shared admin sidebar.  
   Fix: Group visible `menu_items_for(:admin_menu)` nodes only on `admin#index`, preserve permissions/order, and put unknown entries in an “Extensions/Other” group with a plugin regression test.

3. **The localization plan violates the 50-locale contract.** Adding headings only to `en.yml` and `ru.yml` leaves the other 48 locales displaying English fallback inside localized pages.  
   Fix: Reuse existing translated labels or add the keys to every locale via the locale tooling and run locale validation.

4. **The global table-alignment flip is dangerously broad.** Changing every `table.list td` from center to start affects users, timelog, plugins, permissions, checkboxes, booleans, reorder controls, and numeric columns such as `hours` that the exception list omits.  
   Fix: Keep the global default and scope alignment to audited semantic column classes, including all numeric/custom-field variants and representative non-issue tables.

5. **Controller-wide framing affects far more surfaces than the plan tests.** `controller-admin`, `controller-projects`, and `controller-wiki` include admin project/plugin tables, project settings/show pages, wiki history/annotation, and other wide content—not merely the named indexes.  
   Fix: Use action-specific selectors or enumerate and test every action reached by each controller-wide selector.

6. **The 1280px frame is not actually 1280px.** Desktop `#content` uses content-box sizing, so `max-inline-size: 1280px` plus 56px inline padding produces a 1336px outer frame.  
   Fix: Define whether `--nx-frame` measures the outer or content box and add `box-sizing: border-box`, `inline-size: 100%`, and shrink/overflow acceptance checks.

7. **The sidebar replacement is not specified enough to implement safely.** “Use the Sidebar layout primitive” gives no flex basis, content minimum, wrap threshold, or behavior for collapsed, no-sidebar, mobile, print, RTL, and plugin-injected sidebars.  
   Fix: Provide the exact CSS state model and test every existing sidebar class plus narrow, wide, mobile, print, and plugin-content cases.

8. **The mobile debt premise is stale.** The issue-list partial already wraps `table.list` in `.autoscroll`, whose CSS already supplies horizontal scrolling and edge fades; wrapping it again will not diagnose the reported failure.  
   Fix: First measure `scrollWidth`, `clientWidth`, and touch/keyboard scrollability on the existing wrapper, then fix the actual cause or remove this phase if it no longer reproduces.

9. **The empty-state work targets the wrong inventory.** Every existing `nodata_tag` call already supplies an action; the missing cases are `render_tabs` and numerous raw `<p class="nodata">` producers, which the plan ignores.  
   Fix: Inventory all `.nodata` producers, select explicit conversions, and test permitted, forbidden, plugin, and message-only variants.

10. **The proposed exit animations cannot run with the current state model.** Dropdowns and menus toggle `display:none`, while modal and tooltip closure is controlled by jQuery UI; CSS transitions on `.drdn-items` or hidden elements will be cut off immediately and rapid reopen/close is undefined.  
    Fix: Either delete the unused exit tokens or specify the minimal JS/class lifecycle, `transitionend` fallback, interruption handling, focus restoration, and keyboard/touch tests.

11. **Reduced-motion behavior is underspecified and risks breaking static transforms.** “Zero transform and translate” is not a property-selective replacement for the current universal duration override and could suppress RTL icon flips, centering transforms, or spinner behavior.  
    Fix: Replace the universal rule with targeted reduced-motion overrides for each animated component while preserving static transforms and essential feedback.

12. **The hover gate leaves hidden keyboard/touch actions.** `.mypage-box > .contextual` remains almost transparent unless `:hover`; merely gating its transition does not make it visible for focus or coarse pointers.  
    Fix: Add `:focus-within` visibility and persistent visibility for coarse/no-hover input before gating only the animation.

13. **`public/404.html` cannot consume the application token.** It is a standalone static file that loads no application stylesheet, so `var(--nx-frame)` is undefined unless duplicated locally; `500.html` would also remain visually inconsistent.  
    Fix: Keep both static error pages self-contained and apply the same locally declared frame treatment to 404 and 500.

14. **The plan contradicts the committed design system without updating it.** It removes `cv05`/`ss03`, raises badges from 11px, changes closed badges from tinted fill to a colored outline, and replaces documented stepped sidebar widths, while claiming not to renegotiate `DESIGN.md`.  
    Fix: Either preserve the documented contract or include an explicit, owner-approved `DESIGN.md` synchronization step for every changed token and component rule.

15. **The browser verification harness is not reproducible.** `puppeteer-core` is not declared in the repository, and the plan defines no fixture state, authentication flow, URLs, artifact naming, screenshot threshold, or failure command.  
    Fix: Pin a dev-only browser harness and document exact setup, seeded data, login state, routes, artifact paths, comparison thresholds, and health checks.

16. **The plan violates the repository’s TDD rule and lacks executable verification.** Tests appear only as a final visual pass; there are no RED tests or exact Rails, locale, RuboCop, or Stylelint commands.  
    Fix: Add failing tests before each Ruby/view behavior change and list the targeted plus full verification commands and required passing exit codes.

17. **“Delight” is not an implementable specification.** It names personality and empty-state copy but supplies no exact messages, locale keys, target call sites, or flash behavior, leaving the implementer to invent product voice.  
    Fix: Specify the exact copy matrix and affected states—or remove the phase as already satisfied by the existing flash animation.

VERDICT: REVISE
### Claude's response

Every checkable claim was verified against HEAD before disposition. Codex was right on all of them.

**Accepted in full (15):**

- **#1** `.badge-status-locked` is live, not dead: `app/views/wiki/show.html.erb:94`, plus `versions/index.html.erb:29` and `versions/show.html.erb:11` via `badge-status-#{version.status}`, covered by `test/functional/versions_controller_test.rb:137` and `test/functional/wiki_controller_test.rb:239`. The "wire or delete" task is removed entirely — my plan said "dead in lists" and then proposed a global action, which is exactly the ambiguity that would have caused the regression.
- **#2** Admin menu is `Redmine::MenuManager`-driven and plugin-extensible; `app/views/admin/index.html.erb` renders a partial over dynamic nodes. Grouping now operates on `menu_items_for(:admin_menu)`, on `admin#index` only, preserving permission checks and order, with unknown nodes falling into an "Other" group and a plugin-injection regression test.
- **#4** `table.list td {text-align: center}` at `application.css:1374` is the shared default for every list in the product. Flipping it would move users, timelog, plugin and custom-field tables. The global default stays; alignment is scoped to audited semantic column classes, with `hours` and custom-field variants added to the audit and non-issue tables in the verification set.
- **#5** `controller-*` selectors cover far more actions than the named indexes (wiki history/annotate/diff, project settings/show, admin projects/plugins). Framing moves to action-specific selectors with every reached action enumerated.
- **#6** `box-sizing: border-box` appears only on specific selectors (`:817`, `:1086`, `:1218`, `:1710`), not as a universal reset, so `#content`'s 28px inline padding makes a 1280px `max-inline-size` a 1336px outer frame. `--nx-frame` is now defined as the outer box, with `box-sizing: border-box` set explicitly on `#content`.
- **#7** The Sidebar-primitive rewrite is dropped. It was opportunistic and, as Codex says, unspecified across collapsed / no-sidebar / mobile / print / RTL / plugin-injected states. Only the mechanical fix survives: the physical `width` breakpoints at `:942-947` become logical properties, matching the project's own rule.
- **#8** The premise was stale, and the correction is stronger than Codex states: `app/views/issues/_list.html.erb:7` already wraps the table in `.autoscroll`, and `.autoscroll` (`application.css:2191`) already supplies `overflow-x: auto` plus edge-fade gradients using the `local`/`scroll` background trick. The `overflow-x: visible` override at `:3923` is inside `@media print`. The phase becomes measurement-first and is deleted outright if it does not reproduce.
- **#9** All seven `nodata_tag` call sites already pass an action, so the planned work targeted an empty set. Retargeted to the ~20 raw `<p class="nodata">` producers, as an explicit named selection rather than a blanket conversion.
- **#10** Exit tokens deleted. `.drdn-items` and `ul.menu-children` toggle `display:none`, and modal/tooltip closure is jQuery UI's, so a CSS exit transition is cut off at frame zero. Specifying a JS lifecycle, `transitionend` fallback and interruption handling to animate a dismissal nobody asked for is a bad trade.
- **#11** The universal duration override is replaced with targeted per-component reduced-motion rules. Blanket transform-zeroing would have broken static transforms, including the `scaleY(-1)` chevron flip at `responsive.css:176-178`.
- **#12** Accepted as a defect in its own right, not an animation concern: `.mypage-box > .contextual` sits at `opacity: 0.001` until `:hover` (`:3108`), so keyboard and coarse-pointer users cannot reach it at all. `:focus-within` and coarse-pointer visibility land before any hover gating.
- **#13** `public/404.html` is a standalone document with an inline `<style>` block and hardcoded `#303030`; it loads no application stylesheet, so `var(--nx-frame)` is undefined there. Both `404.html` and `500.html` stay self-contained and get the same locally declared treatment.
- **#14** An explicit `DESIGN.md` synchronization step is added, enumerating every token and component rule the sweep changes.
- **#16** TDD applies at the Ruby and view seams (`queries_helper.rb`, the admin grouping, the `.nodata` conversions), with named test files and exact commands. CSS-only changes have no RED seam and are gated instead by the capture diff and the selector-preservation check.
- **#17** The delight phase is collapsed rather than specified: its only implementable content was empty-state copy, which phase 3 already owns. The "one signature element" is dropped as already satisfied by the shipped `nx-flash-in`. What remains are the two prohibitions, promoted to plan-wide constraints.

**Accepted in part, with reasons (2):**

- **#3 — locale contract.** Accepted: reuse existing translated labels wherever one exists, rather than minting new keys. Rejected: the demand that new keys ship in all 50 locales. Upstream Redmine's own convention is that a new key lands in `en.yml` and untranslated locales fall back to English until a translator supplies them; the fork's own `label_theme_toggle` shipped exactly this way in `069d9a860`. Machine-translating 48 locales to satisfy a contract `PRODUCT.md` does not state would be worse than the fallback. `PRODUCT.md` principle 4 requires that copy live in locale files, not that every locale be complete.
- **#15 — verification harness.** Accepted: the harness is now fully specified in the plan — routes, viewport matrix, theme matrix, authentication state, seeded fixture project, artifact paths and comparison method. Rejected: declaring `puppeteer-core` as a repository dependency. The plan's own out-of-scope section forbids new dependencies, and this is an external verification tool that never ships with the app. Pinning it into the repo would trade a documented external step for a permanent dependency in a product that has no JS build.

Net effect on the plan: three phases shrank (sidebar rewrite dropped, exit tokens dropped, delight collapsed into phase 3), two phases were retargeted at the correct inventory (empty states, mobile debt), one new defect was adopted from the review (`#12`), and the verification section grew from a paragraph into a specification.

### Mechanics deviation — round 2 runs in a fresh session

`codex exec resume 01a05453-bbdb-75b0-9181-023316cc84a5` failed with `[400]: No tool output found for custom tool call call_P2SR7t3JROwRIf9EGVRnlvYp`. Round 1 used Codex's internal collab tooling (the stream carries `collab_tool_call` items with tool `wait`); replaying that history through the responses endpoint leaves a custom tool call without its output, so the thread is not resumable. Not a plan problem and not fixable by retrying.

Round 2 therefore runs as a **fresh session** rather than a resume. The skill prefers the same session so the reviewer remembers its own prior critiques; here that memory is replaced by this log, which carries all 17 findings verbatim plus every disposition, and the round-2 prompt requires reading it before re-reviewing. The round-2 prompt additionally directs the reviewer to attack the two partial rejections by name and to attack the newly written text, since new text is the least reviewed text.

Reviewer access this round: the owner's proxy at `https://llm.eldiablo.uz/v1`, model `cx/gpt-5.6-sol-ultra`, after the ChatGPT-account path returned a usage-limit error. Provider is passed per-invocation via `-c model_providers.*`; the key lives only in the process environment and is not written to any file in this repository.

## Round 2 — Codex

`VERDICT: REVISE`. Fresh session (see the deviation note above). Critique verbatim:

The revision is materially better, but it is still not implementation-ready.

### Disposition of the 17 prior findings

1. Addressed. `.badge-status-locked` is explicitly preserved and its live call sites/tests are correctly identified.

2. Only partially addressed. Dynamic iteration prevents dropped plugin nodes, but the grouping inventory omits core `:info` from [preparation.rb](/Users/shakhzod/Documents/Git/redmine/lib/redmine/preparation.rb:301), so a stock “Information” entry lands in “Other.” Moving unknown nodes also cannot preserve plugin `before`/`after` adjacency semantics.

3. My original requirement was too strong; the author is right about Redmine’s locale convention. English fallback is explicitly enabled in [application.rb](/Users/shakhzod/Documents/Git/redmine/config/application.rb:59), and upstream does not require all 50 translations in one commit. The revision remains incomplete because “Other” has no existing locale key, while the plan never freezes its new key/copy or adds a locale-validation command.

4. Only appears addressed. The promised audit is deferred to implementation, and the plan is already factually wrong: it says `td.buttons` must remain centered, while current CSS deliberately aligns it to `end` at [application.css](/Users/shakhzod/Documents/Git/redmine/app/assets/stylesheets/application.css:1386). Users and timelog are promised as verification surfaces but absent from the capture routes.

5. Not fully addressed. `settings#*` reintroduces controller-wide behavior and includes `settings#plugin`, which renders arbitrary plugin partials. `/settings/edit`, plugin settings, `/my`’s `action-index` alias, and wiki-show’s missing-page edit state are not enumerated or captured.

6. Mostly addressed. The outer-box definition and explicit `border-box` fix the arithmetic error. Its composition beside a sidebar is still unverified and may create large auto-margin gaps at wide viewports.

7. Addressed by cutting the risky sidebar-layout rewrite. The remaining physical-to-logical width conversion is orphaned scope unless it gets explicit RTL/collapsed/mobile tests.

8. The stale premise is corrected, but the failed-measurement branch is not a plan. “Diagnose and fix the real cause” supplies no allowed implementation, RED test, acceptance criterion, or re-review gate.

9. Not addressed. The plan says it will convert an “explicitly named subset,” but never names that subset. It lists examples followed by “and others,” with no call-site → action → permission matrix. Several listed views already expose a create action, so conversion may merely duplicate the CTA.

10. Addressed. Deleting exit tokens avoids inventing an unnecessary JS lifecycle.

11. Only partially addressed. Targeted reduced-motion handling is the right direction, but there is still no selector/property matrix. The plan does not decide which opacity, color, shadow, and border transitions survive, including focus versus hover reveal on `.mypage-box`.

12. Behaviorally addressed: `:focus-within` plus persistent coarse-pointer visibility fixes the core defect. It still lacks an executable focus/coarse-pointer regression test.

13. Implementation intent addressed; verification is not. The harness requests `/404`, not `/404.html`, never captures `/500.html`, and development mode uses local exception rendering. It therefore does not prove either modified static file works.

14. Not addressed completely. The synchronization list omits several changed contracts, and the proposed colored outline directly contradicts existing named design rules.

15. Not addressed. The author is right not to add an application dependency, but wrong that the external harness is now reproducible.

16. Not addressed. The targeted command references nonexistent `test/functional/queries_helper_test.rb`; the file is [queries_helper_test.rb](/Users/shakhzod/Documents/Git/redmine/test/helpers/queries_helper_test.rb). The plan omits system tests, Stylelint, locale validation, and executable definitions for several prose-only gates.

17. Addressed by removing the vague delight phase. The surviving empty-state work still fails independently under #9.

### The two partial rejections

For #3, the author’s core reasoning is correct. Requiring translations in all 50 files would impose a rule neither the product brief nor Redmine follows. The four known headings can use keys already present across locales. However, the fifth heading cannot remain hypothetical: define the exact key and English/Russian copy for “Other,” test fallback in a third locale, and run the locale/interpolation task. “Use existing labels and neighbours” is not a frozen copy contract.

For #15, rejecting a repository dependency is defensible; rejecting reproducibility is not. `puppeteer-core` is not installed, and the plan gives no pinned version/install command, script contents or stable external script location, Chrome executable, invocation, authentication procedure, fixture reset, health check, concrete issue ID, or separate before/after artifact roots. The repository already has declared Selenium/Capybara infrastructure in [application_system_test_case.rb](/Users/shakhzod/Documents/Git/redmine/test/application_system_test_case.rb:22), which is the simpler reproducible seam. Either use that, or fully pin the temporary harness outside the application dependency graph.

### Problems newly introduced

- The framing list is not action-complete. `settings#plugin` must be excluded or explicitly tested; `/my` and `/my/page` currently render the same screen with different action classes; `wiki#show` can render the edit form at [wiki_controller.rb](/Users/shakhzod/Documents/Git/redmine/app/controllers/wiki_controller.rb:86).

- The capture matrix is `{1440, 375}`, while the accepted framing risk explicitly requires 2560px verification. That missing width is precisely where `#content` capped at 1280px can detach visually from a 380px sidebar inside the flex shell.

- “Other” is broken before any plugin loads because core `:info` falls into it. Grouping also needs defined behavior for nested plugin nodes and `before`/`after` placement. Existing `#admin-index #admin-menu ul` styling applies to every descendant `ul`, so naïve nested groups become nested grids.

- The measurement-gated debt phase is an investigation disguised as implementation. If mobile scrolling or “Log time” fails, stop and revise the plan after diagnosis; do not authorize an unspecified fix. Touch testing also requires explicit touch/coarse-pointer emulation and a keyboard-scroll oracle.

- TDD is not satisfied. Browser-observable CSS has first-party system-test seams. Add RED system tests for frame sizing/action scoping, my-page focus/coarse visibility, overflow reachability, reduced motion, and status-chip computed styles, then run `bin/rails test:system`.

- The selector-preservation gate conflicts with the planned removal of the universal reduced-motion selector. It needs an explicit allowlist for intentional removals. It also needs to be an exact command, not prose.

- `DESIGN.md` synchronization is incomplete. It omits the status glyph, ligature policy, table alignment/weight, admin grouping, error pages, motion consolidation, reduced-motion behavior, contextual-action accessibility, and action-to-frame mapping. Corresponding stale values exist in `.impeccable/design.json`.

- The outline chip is a genuine design-contract renegotiation, not bookkeeping. [DESIGN.md](/Users/shakhzod/Documents/Git/redmine/DESIGN.md:390) says borders are never colored and state boxes use tinted grounds. The plan must explicitly replace or carve an owner-approved exception into that named rule; its current “nothing is renegotiated” language is false.

- Several implementation choices remain unfrozen. Dense line height is supposedly selected by measurement, but no 1.35-versus-1.5 A/B or selection criterion exists. Tracking is declared as zero while the risks say an A/B will settle it. Row hover is fixed at 90ms while deletion remains a “first-class option.” Run the named comparisons, record the selection, then freeze the values.

- `font-variant-ligatures: no-contextual` is broader than the stated digit-`x`-digit defect: it covers every table cell and journal prose, including localized and fallback-font content. Narrow it or add non-Latin/RTL rendering coverage.

The scope cuts themselves—sidebar primitive, exit motion, and standalone delight—are sound. They do not compensate for the remaining open implementation branches, incorrect commands, incomplete inventories, and contradictory design contract.

VERDICT: REVISE
### Claude's response

Every checkable claim was verified against HEAD again. Codex was right on all of them, including one that invalidates a claim this plan made about itself.

**The material finding: the outline chip is a design-contract renegotiation, and the plan said otherwise.**

`DESIGN.md` carries three rules against it — the Tinted-Ground Rule (`:313`), "Borders are always 1px, always a hairline token, never coloured" (`:390`), and the Transparent-Border Rule (`:398`). The `border: 1px solid transparent` slot at `application.css:3216-3230` that round-1 planning described as "already declared and unspent" is not an unspent slot; it *is* the rule being obeyed. The plan's "nothing in the visual world is renegotiated, only re-recorded" was therefore false.

This was put to the owner as a decision rather than arbitrated: keep the chip with an owner-approved carve-out, drop to glyph-only, or differentiate ground luminance instead. **The owner approved the exception.** The plan now states the renegotiation explicitly in the Goal, in §2, and in §6, and `DESIGN.md` will carry a named exception rather than an unbroken rule. Risk 4 records that reversing the exception later would regress the encoding to hue-only.

**Verified factual corrections adopted:**

- `td.buttons` is `text-align: end` at `application.css:1386`, not center. The round-1 revision stated the opposite; assumption 12 records the correction and the alignment audit is fixed.
- `:info` is a core admin node (`lib/redmine/preparation.rb:301`) and would have fallen into "Other". It is now mapped to System explicitly, and the full 14-node mapping is written into the plan as a table rather than described.
- `test/functional/queries_helper_test.rb` does not exist; the file is `test/helpers/queries_helper_test.rb`. The verification command is corrected.
- `#admin-index #admin-menu ul` (`:959`) matches every descendant `ul`, so nested group lists would become nested grids. The plan now forbids `ul ul` under `#admin-index` and asserts it in a test.
- `wiki#show` renders the edit form for a missing page (`wiki_controller.rb:86`); that state is now a separate captured route and a separate framing case.
- `config.i18n.fallbacks = true` (`config/application.rb:59`) and `rake locales:update` (`lib/tasks/locales.rake:26`) confirm the locale convention this plan relied on — Codex withdrew finding #3's original demand on this basis.

**The best contribution of the round, adopted wholesale:** the repository already ships Capybara + Selenium + Chrome (`test/application_system_test_case.rb:39`) with 40+ system tests. Every browser-observable assertion moves onto that seam. The bespoke `puppeteer-core` harness is demoted to human-review screenshots that gate nothing, which simultaneously answers finding #15 (reproducibility), finding #16 (TDD), and finding #12 (an executable focus/coarse-pointer test). Named RED tests are now attached to every phase.

**Also adopted:** stylelint and the locale task exist in the repo (`.stylelintrc`, `package.json` devDependencies, `lib/tasks/locales.rake`) and are now explicit gates; the "Other" heading key and its English/Russian copy are frozen in the plan with a third-locale fallback test; the empty-state conversion set is enumerated as a closed table with per-view action and permission, and the non-conversions are listed with reasons; the reduced-motion behavior is a selector/property matrix rather than a sentence; the selector-preservation gate is an exact command plus an allowlist file, since this sweep intentionally removes the universal reduced-motion selector; `font-variant-ligatures: no-contextual` is narrowed from "all table cells and journal prose" to identifier-bearing contexts, with Cyrillic and RTL rendering checks; 2560px is added to the capture matrix, which the accepted framing risk always required and the matrix had omitted; the framing list is closed and enumerates `settings#plugin`, `my#index` vs `my#page`, and the wiki sub-actions by name; and `/404.html` and `/500.html` are fetched as static files rather than as routes, since dev mode renders its own exception pages.

**The debt phase is downgraded from implementation to diagnosis.** Codex is right that "diagnose and fix the real cause" pre-authorizes an unspecified change. If the measurement shows the mobile issue list is broken, the plan stops and is revised with a known cause; nothing is authorized in advance. The likely real defect is now named — the `.autoscroll` wrapper carries no `tabindex`, so it cannot be scrolled by keyboard at all.

**The three unfrozen values are now frozen by procedure rather than left open.** Line-height, letter-spacing at 13–14px, and row hover 90ms-vs-0 each have a stated selection criterion, a measurement that produces it in step 0, and a recording location. No implementation touching those values starts before the measurement is recorded.

**Not adopted:** nothing was rejected this round.

## Round 3 — Codex

`VERDICT: REVISE`, with an explicit note that diminishing returns should favour approval once these are corrected. Critique verbatim:

Round-2 disposition:

1. Closed. Locked badges are explicitly preserved and regression-tested.
2. Not closed. Admin grouping remains internally contradictory and partly unimplementable.
3. Partly closed. The key and copy are frozen, but the German test does not test fallback after `locales:update` inserts an English value into `de.yml`.
4. Not closed. The alignment audit still has global, under-audited selectors.
5. Closed. Framing is now action-scoped, including the missing-wiki edit state and explicit exclusions.
6. Mostly closed. Box sizing and wide-screen composition are covered, but the plan never actually assigns `--nx-frame: 1280px`.
7. Closed. The risky sidebar rewrite was removed; the surviving logical-property change has required tests.
8. Closed. A failed mobile measurement now stops implementation and forces replanning.
9. Not closed. The supposedly closed empty-state inventory and conversion behavior are wrong.
10. Closed. Exit animation work was removed.
11. Not closed. The reduced-motion matrix is factually inaccurate and incomplete.
12. Closed. Keyboard and coarse-pointer behavior now has executable test intent.
13. Partly closed. Both static files are named correctly, but §7 still provides no exact fetch/assert command.
14. Not closed. Documentation synchronization is broad, but the exception scope and other design contradictions remain wrong.
15. Closed in principle. First-party Selenium/Capybara is the appropriate reproducible seam.
16. Not closed. Several “exact” gates are broken, non-failing, or still prose.
17. Closed. The vague delight phase is gone; the remaining empty-state defect belongs under #9.

The owner-approved outline exception is recorded in the right places: Goal, §2, §6, risks, and both design artifacts. Its scope is not tight enough. The prose says “status chip,” and the mandatory selector is `tr.issue td.status .badge`; that includes open and plugin-provided badges. The exception should name only the query issue-list closed chip and require `tr.issue td.status .badge-status-closed`.

There is also an unacknowledged second contradiction with [DESIGN.md](/Users/shakhzod/Documents/Git/redmine/DESIGN.md:364): the plan changes numeric columns to logical `text-align: end`, while the named Logical-Property Rule deliberately requires physical `right` in every writing direction. Preserve `right` or record another owner-approved renegotiation. The tracking experiment can likewise contradict the Tight-Tracking Rule if non-label 13–14px text receives positive or negative tracking.

Material defects in the new text:

- Admin grouping cannot honor its own rules. Fixed groups necessarily move core `projects` from first to the Content group, contradicting “never reorder across groups.” More importantly, `before:`/`after:` is consumed during menu insertion and is not retained on `MenuItem`, so the renderer cannot detect that adjacency declaration. Plugin child menus inherently render nested `<ul>` elements, conflicting with the asserted `no ul ul` invariant. Specify an achievable ordering and nesting algorithm.

- The alignment audit remains overbroad. Global `table.list td.id` also changes wiki-history and repository-revision IDs, not just issue numbers. Custom numeric-field classes are `int` and `float`, not “numeric/float.” Extending `td.status` beyond issues can override the deliberately centered version status rule. Exact selectors and corresponding non-issue assertions are still missing.

- Every selected empty state already has the same New action immediately above it. A literal `nodata_tag(action)` conversion duplicates the CTA unless the plan explicitly moves/removes the existing action. `:manage_enumerations` is not a permission—the controller is admin-gated—and repository creation also requires `Setting.enabled_scm.any?`. The claimed closed inventory omits numerous raw producers, including issue lists, users, timelog, project members, webhooks, and tracker fields.

- The reduced-motion matrix misdescribes the source. Line 823 is specifically quick-search transitions; line 1769 is submit/button background and border, not input/select focus or box-shadow. Existing transitioned `stroke`, tab `box-shadow`, quick-search background, theme-toggle, and button properties are omitted.

- The frozen-value criteria are not sound. Line-height cannot affect subject wrapping, so that criterion mechanically selects 1.35. “Reads cleanest” and “visibly decaying” have no judge or tie-break. Those can be owner-at-browser decisions, but they are not reproducibly frozen criteria as written.

- The selector-removal gate is broken. With no forbidden removals, final `grep` exits 1; with forbidden removals, it exits 0—the reverse of the stated all-exit-zero contract. Leading indentation prevents the current allowlist entry from matching, the regex misses multiline selector members, and `git merge-base HEAD master` loses the baseline after direct-to-master commits. The allowlist also contains no promised reason.

- The exact commands do not run in the supplied host environment: Ruby is 2.6 while the lockfile requires 3.3.12, Bundler 2.5.22 is absent, and `node_modules` is absent. If execution is intended inside `redmine-figma`, the commands need the exact `docker exec`, working directory, and setup. `npx stylelint` otherwise relies on an undeclared network install.

- `locales:check_interpolation` only prints mismatches and does not fail; it also does not validate missing keys. The hook-preservation and WCAG checks remain prose rather than executable gates.

These are still plan-contract errors, not unknowable implementation details. Once the grouping algorithm, empty-state movement, design exceptions, motion matrix, and verification gates are corrected, diminishing returns should favor approval.

VERDICT: REVISE
### Claude's response

Verified again at HEAD. Every claim held, including three that invalidate work this plan had already called finished.

**Verified and adopted:**

- **The host cannot run any of the "exact" commands.** Host Ruby is 2.6.10 against a `Gemfile.lock` requiring 3.3.12, Bundler 2.5.22 is absent, `node_modules` is absent. The container carries Ruby 3.3.12 and Bundler 2.5.22 but no Node. The plan now opens with an Execution environment section: every Ruby/Rails/rake command is prefixed `docker exec redmine-figma sh -lc 'cd /redmine && …'`, and stylelint runs on the host through `npx --yes stylelint@16`.
- **Numeric alignment must stay physical `right`.** `DESIGN.md:364` names numeric columns as the deliberate exception to the Logical-Property Rule, and four existing sites (`:1378`, `:1469`, `:1517`, `:2084`) carry the comment "Numbers should be right aligned even in RTL". The plan's `end` was a second unacknowledged contradiction of the design contract; it is now `right`, with the rule cited in Constraints. The tracking experiment carries the same warning: a non-zero value on non-label 13–14px text would contradict the Tight-Tracking Rule and is escalated, not absorbed.
- **The exception scope was too loose.** `tr.issue td.status .badge` covers open and plugin-provided badges. It is now `tr.issue td.status .badge-status-closed` and nothing else, stated in the Goal, §2, §6 and Out of scope.
- **`before:`/`after:` cannot be honored.** `menu_manager.rb:307-318` does `options.delete(:before)` / `delete(:after)` at insertion; the declaration is consumed to compute a position and never reaches `MenuItem`. The plan's promise was unimplementable. It now states plainly that grouping reorders across groups by construction (`projects` is first in the menu and lands in Content), that within-group order is preserved, and that a plugin which positioned itself beside a specific node will be separated from it — an accepted, recorded limitation.
- **Nested `<ul>` is legitimate.** Plugin child menus render nested lists, so `no ul ul` was not an invariant to assert. The fix moves to the CSS side: tighten `#admin-index #admin-menu ul` (`:959`), which matches every descendant, to a direct-child or classed selector.
- **The reduced-motion matrix misdescribed its own source.** Re-read at HEAD: `:823` is `#quick-search #q` (background, border, box-shadow), not input/select focus; `:1769` is submit/button background and border, with no box-shadow. The matrix is rewritten line by line and the omitted entries (`:713` icon stroke, `:887` tab box-shadow, `:1001` theme toggle, `:1682` contextual link, `:2867`) are added.
- **The alignment audit was still global.** `table.list td.id` also styles wiki-history and repository-revision IDs; `td.status` outside issues would override the deliberately centered version status. Every changed selector is now prefixed `tr.issue`. Custom-field numeric classes are `int` and `float`, not "numeric/float".
- **The frozen-value criteria were unsound.** Line-height cannot affect subject-column wrapping, so that criterion mechanically selected 1.35; "reads cleanest" and "visibly decaying" name no judge. All three are now explicit owner-at-browser decisions with a defined artifact to look at and a recording location — honest about being judgment calls rather than dressed as measurements.
- **`locales:check_interpolation` never fails.** `lib/tasks/locales.rake` contains no `abort`/`raise`/`exit`; it prints. It is demoted to advisory with that stated, alongside the WCAG 1.4.12 manual pass. The hook-preservation check became an actual executable loop.
- **The German test was testing the wrong thing.** `locales:update` materializes the English string into `de.yml`, so a post-update render is not a fallback test. The test now runs after `locales:update` deliberately, to assert the real shipped state.
- **Exact fetch/assert added** for `public/404.html` and `public/500.html`.

**The selector gate was broken in three ways, and I found the third by running it.**

Codex named the inverted exit code (`grep -v` exits 1 when nothing matches, i.e. on success) and the useless baseline (`git merge-base HEAD master` resolves to HEAD when work lands directly on `master`). Running the corrected version surfaced a third: under zsh, `$BASE:app/...` is parsed as the `:a` path modifier, so `git show` received a mangled path, the baseline extracted **zero** selectors, and the gate printed PASS. A gate that passes vacuously is worse than no gate. It now quotes the ref, asserts a non-empty baseline (≥900 selectors) before comparing, and fails on non-empty output.

Running it correctly also produced a finding of its own: against upstream `2308cb59c` the **already-shipped** redesign dropped 10 selectors. Most are benign regroupings — `#sidebar-switch-button` became `#sidebar #sidebar-switch-button`, and the `arrow_up.png` project-jump rule was replaced by a `scaleY(-1)` transform — but `.pagination ul.pages li:first-child` and `li:last-child` have no counterpart in the fork and look like genuine losses. That is a pre-existing defect in `069d9a860`, reported to the owner, and deliberately **not** laundered into this sweep. The gate is therefore baselined at `aa366a6af`, the commit this sweep starts from, so it measures this sweep rather than re-litigating the last one. The allowlist ships empty.

**Cut rather than fixed: the empty-state conversion.**

Codex is right that every candidate view already renders its "New X" control immediately above the empty message, so `nodata_tag(action)` would duplicate the CTA unless the existing control were also moved — a layout change to seven admin screens nobody asked for. The supporting detail was wrong twice over (`:manage_enumerations` is not a permission; repository creation also requires `Setting.enabled_scm.any?`) and the "closed inventory" was not closed. This is the fifth item cut across three rounds, and cutting is the right answer: the work was duplicative before any of the detail errors mattered.

**Not adopted:** nothing was rejected this round.

## Round 4 — Codex

`VERDICT: REVISE` — four mechanical plan-contract errors; both structural decisions endorsed; the selector gate independently re-run and its logic confirmed sound. Critique verbatim:

Round 4 still requires revision for a few concrete plan-contract errors.

Round-3 closure:

- #1–3: closed.
- #4: not closed. The “exact” selectors at [PLAN.md](/Users/shakhzod/Documents/Git/redmine/PLAN.md:62) lose `tr.issue` scope after each comma, making `td.total_hours`, `td.int`, and `td.float` global. The header selector remains unspecified.
- #5–10: closed, including cutting the empty-state conversion.
- #11: not closed. The supposedly source-verified matrix mislabels three rules: line 734 is the theme toggle, 911 is the main-menu new-object item, and 1001 is the sidebar link.
- #12: closed.
- #13: not fully closed; the static assertions are semantically wrong.
- #14–15: closed.
- #16: not closed because two verification commands remain defective.
- #17: closed.

Command verification:

- Selector-preservation gate: the exact script could not write `/tmp` in this read-only sandbox. A process-substitution equivalent found 1,052 baseline selectors, 1,052 current selectors, zero allowed removals, and zero dropped selectors. Its comparison logic is now sound.
- Hook loop: exits 0 with `BASE=aa366a6af`, currently over zero changed ERB files. However, its own fenced block never defines `BASE`; standalone it also exits 0 while checking nothing. That is a vacuous-pass bug.
- Static pages: both specified pipelines currently exit 1, as expected before implementation. More importantly, they grep for `max-width`, while the plan mandates logical properties and specifies `max-inline-size`. A compliant implementation can fail, while an unrelated `max-width` occurrence can pass.

Both structural decisions are right:

- Admin grouping honestly accepts cross-group reordering and loss of plugin adjacency. `before:`/`after:` is consumed before rendering, so preserving it is unimplementable; within-group resolved order and nested menus remain supported.
- Cutting empty-state conversion avoids duplicating existing CTAs and removes work based on an incorrect inventory and permission model.

Material remaining fixes: correct the scoped selectors, correct the motion matrix labels, define `BASE` inside the hook gate, and make the static assertions test the actual local frame contract.

VERDICT: REVISE
### Claude's response

All four accepted; all four were real. Nothing rejected.

1. **CSS comma scope.** `tr.issue td.hours, td.total_hours, td.int, td.float` drops the `tr.issue` prefix after the first comma, making three of the four selectors global — exactly the over-broad audit this table was written to fix. Rewritten as `tr.issue :is(td.hours, td.total_hours, td.int, td.float)` and the same for the categorical row, with a note in the surrounding prose so the mistake is not reintroduced.
2. **The header selector was unspecified.** Now `table.list th:is(.hours, .total_hours, .int, .float)`. An intermediate draft of this fix said `table.issues th`; the file was checked and the existing convention at `:1368-1372` is `table.list th.<column>`, so the plan mirrors it. This row is deliberately **not** `tr.issue`-scoped: right-aligning a numeric header is correct on every list that has one.
3. **The motion matrix was wrong for a third time.** Re-read line by line from the file: `:734` is `button.theme-toggle`, `:911` is `#main-menu li a.new-object`, `:1001` is `#sidebar a`. Codex caught those three; reading the rest turned up a fourth of my own — `:887` is `#main-menu li a`, not the tab, which is `:2867` (`#content .tabs ul li a`). Every row now carries the selector as it appears in the file. It also exposed a genuine duplication: `:1682` already covers `#sidebar a`, so the consolidation pass folds it with `:1001` rather than tokenizing both.
4. **The hook gate passed vacuously.** Its fenced block never defined `BASE`, so standalone it iterated an empty list and exited 0 while checking nothing — the same failure mode as the selector gate's zsh bug, in a different gate. `BASE` is now defined inside the block and the empty case prints that it checked nothing instead of silently succeeding.
5. **The static error-page assertions tested the wrong property.** They grepped `max-width` while the plan mandates logical properties and specifies `max-inline-size` — a compliant implementation would have failed and an unrelated occurrence would have passed. Now asserts `max-inline-size` and `margin-inline` in each file.

**Endorsed and left as they are:** cross-group reordering in the admin grouping with `before:`/`after:` accepted as unrecoverable, and the empty-state conversion cut rather than specified. Codex judged both correct.

**Independently confirmed:** Codex re-ran the selector-preservation gate with a process-substitution equivalent (the sandbox denied `/tmp` writes) and reports 1052 baseline selectors, 1052 current, zero dropped, comparison logic sound.

Pattern worth recording across four rounds: every gate this plan wrote was broken on first authoring, and three of the four broke by *passing* rather than failing — an unquoted zsh ref, an inverted grep exit code, an undefined `BASE`, and a baseline that resolved to HEAD. A verification step that cannot fail is worse than none, because it is counted as evidence. Each is now tested by running it before being claimed.

## Round 5 — Codex

`VERDICT: APPROVED`. Critique verbatim:

The four round-4 fixes are correct:

- `:is()` preserves `tr.issue` scoping; the numeric header selector is explicit.
- Motion-matrix labels match the source selectors.
- The hook gate defines `BASE` internally and runs correctly.
- Both static pages assert `max-inline-size` and `margin-inline`; they currently fail as expected before implementation.

No remaining contract-level error or unacknowledged `DESIGN.md` contradiction warrants revision.

VERDICT: APPROVED
### Resolution

Converged on round 5 of a 5-round cap — approved on the last available round, not comfortably.

**Rounds:** 5 of 5. **Findings raised:** 17 + 17 + 9 + 4 = 47. **Rejected with a logged reason:** 2, both in round 1, both later conceded by the reviewer itself (the 50-locale demand, contradicted by `config.i18n.fallbacks = true` and `rake locales:update`; the repo-dependency demand for the browser harness, which the reviewer replaced with a better idea — first-party Capybara system tests).

**What the loop changed, in order of consequence:**

1. **It caught the plan contradicting the design system twice, unacknowledged.** The outline chip violates three named rules in `DESIGN.md` while the plan claimed to renegotiate nothing; that went to the owner and came back as a scoped, recorded exception. Numeric column alignment was heading for logical `end` against the Logical-Property Rule, which names numeric columns as its one deliberate physical exception.
2. **It emptied out work aimed at nothing.** Five items were cut rather than specified: the sidebar rewrite, motion exit tokens, the delight phase, the empty-state conversion, and the pre-authorized mobile fix. Three of those targeted problems that had already been solved in `069d9a860` or were solved by markup that already existed.
3. **It found that every verification gate was broken, and that three of four broke by passing.** An unquoted ref under zsh, an inverted `grep` exit code, an undefined `BASE`, and a baseline resolving to HEAD. Each is now run before being claimed. A gate that cannot fail is worse than no gate, because it is counted as evidence.

**Side finding, out of scope and reported to the owner:** run against upstream `2308cb59c`, the selector gate shows the shipped redesign dropped `.pagination ul.pages li:first-child` and `li:last-child` with no replacement — a real, pre-existing regression in `069d9a860`, deliberately not folded into this sweep.

**Still open, owner's call, and it gates nothing in the plan:** whether to `npm i htmlparser2 css-select css-tree domutils` inside `~/.claude/skills/impeccable/` to un-degrade the detector, or accept stylelint + system tests + the selector gate as the mechanical evidence. The plan assumes the latter and claims no clean detector scan anywhere.

## Step 0 — baseline measurement (build phase)

Ran against `redmine-figma`, 16 routes × 3 viewports × 2 themes + signed-out `/login` in a separate browser context. Zero route errors. Artifacts in `/tmp/impeccable/before/`.

**The three deferred values, resolved.**

| Value | Measurement | Decision |
|---|---|---|
| dense-row line-height | 1.5 → 34.5px row, 26 rows/viewport · 1.4 → 33.5px, 26 rows · 1.35 → 33px, **27 rows**. Wrapped subjects identical (11) at all three, confirming line-height does not drive wrapping | **1.35** — the only value that buys a row. 1.4 would change the file and gain nothing |
| letter-spacing at 13px | Subject column renders 333px at 0, 335px at +0.01em, 332px at Inter's −0.0062em — a 3px spread across the whole column | **0**, unchanged. No measurable difference, so no reason to spend a change, and the Tight-Tracking Rule needs no second renegotiation |
| row hover 90ms vs 0 | Enter reaches final background by ~60ms; exit decays to fully transparent within ~50ms. No trailing decay across a pointer sweep | **Keep 90ms**. The Linear/Kowalski objection does not reproduce here |

**The debt phase, diagnosed.** At 375px the issue list's `.autoscroll` wrapper reports `scrollWidth 762` vs `clientWidth 343` with `overflow-x: auto` live, so the hidden columns (Subject, Assignee, Updated — the last visible column is Priority) **are** reachable by touch. But `tabindex` is absent, so the region cannot be scrolled by keyboard at all. The prior review's "loses data" was half right: wrong for pointer users, right for keyboard users. This is the WCAG scrollable-region-focusable defect, exactly the cause the plan named as most likely. Owner authorized the fix in this sweep now that the cause is known.

**New finding the plan did not have.** The `72ch` prose cap is applied to headings as well as body copy, and because `ch` scales with the element's own font-size it produces *wider* caps at larger sizes: measured `max-inline-size` is 635.9px on `p` (14px, 97 characters), 1044.9px on `h2` (22px) and 1329.9px on `h1` (28px). A display line ends up more than twice the length of the prose it introduces, inverting the rule's intent. Owner authorized fixing headings in the same pass as the measure.

**Confirmed as predicted:** wiki prose renders 97 characters per line at both 1440 and 2560 — the cap works, its value is wrong, and the research's ~97 estimate was accurate. An earlier probe reporting 181 was measuring a sidebar `<a class="wiki selected">`, not prose; the probe was wrong, not the app.

## Act 3 — Build (Claude)

35 files, +268 / −80. Every phase of `PLAN.md` executed except the ones the plan itself had cut, plus the debt fix the owner authorised once step 0 named its cause.

### What shipped

- **typeset** — the inert `font-feature-settings` deleted; `font-variant-ligatures: no-contextual` applied narrowly to identifier columns against Inter 4.001's digit-`x`-digit `calt` bug; `h4` raised to body size and un-muted; `.badge` 11px → 12px; `table.list td` line-height 1.35; alignment changed only inside `tr.issue`, with numeric columns keeping physical `right` per `DESIGN.md:364`; numeric cells at weight 500.
- **colorize** — `tr.issue td.status .badge-status-closed` becomes an outline chip, open stays filled, and a 12px `sprite_icon` precedes the label in `queries_helper.rb`. `.badge-status-locked` untouched.
- **layout** — `--nx-frame` as the outer box with an explicit `box-sizing: border-box`, raised to 1280px on eight named actions; `--nx-measure: 31rem`; admin index grouped into four sections plus a trailing "Other" for plugin nodes, with the grid moved from `ul` to the container; `#sidebar` breakpoints converted to logical properties; both static error pages given a self-contained frame.
- **animate** — nine hardcoded durations consolidated onto the tokens; the blanket reduced-motion override replaced by a per-component matrix; `nx-flash-in` given a no-translate variant; `.mypage-box > .contextual` made reachable by focus and always visible without hover before its animation was gated.
- **debt** — `tabindex="0"` on every `.autoscroll` region.
- **docs** — `DESIGN.md` and `.impeccable/design.json` synced, including the named Closed-Chip Exception.

### Two decisions taken during the build

**The debt fix went wider than the plan named.** The plan scoped it to the issue list. `.autoscroll` turned out to appear in **25 views**, all with the same missing `tabindex`; fixing three of them would have left the identical defect in twenty-two. All 25 were patched. Root cause, not the path the ticket named.

**The prose measure was fixed in `rem`, not `em`.** The plan specified `35em`. Step 0 showed why that was still wrong: `em` scales with the element's own font-size, so a 28px `h1` was getting a cap of 1330px against the prose's 636px. `31rem` caps every block at the same 496px regardless of its type size, which fixes the heading inversion with the same one-line change instead of needing a second rule.

### Verification

| Gate | Result |
|---|---|
| `bin/rails test` (container) | **5756 runs, 30225 assertions, 0 failures, 1 error, 44 skips** |
| targeted functional tests | 151 runs, 854 assertions, 0 failures |
| `rubocop` | clean (4 `Style/SymbolArray` offences found and fixed) |
| `stylelint` | 3 findings, all present at `HEAD` before this change; **0 new** |
| selector-preservation gate | PASS — 3 removals, all allowlisted with reasons |
| hook-preservation gate | PASS — 26 changed ERB files, `call_hook` sites unchanged |
| static error pages | PASS |
| browser verification | **37/37** |

The single test error is `GanttsControllerTest#test_gantt_should_export_to_png` — `magick: unable to read font ''`. ImageMagick has no font available in this container; the diff touches neither gantt PNG export nor font availability.

An earlier full-suite run reported 2 failures and 33 errors. All 33 were `SQLite3::BusyException: database is locked`, caused by the browser harness hitting the same SQLite file while the suite ran; the 2 failures passed in isolation and were casualties of the same contention. The clean re-run above is the number that counts.

### Measured before / after

| | before | after |
|---|---|---|
| rows per 900px viewport (issues, users, timelog) | 26 | **27** |
| issue row height | 34.5px | 33px |
| wiki prose characters per line | 97 | **76** |
| prose vs `h1` measure cap | 636px vs 1330px | 496px vs 496px |
| `#content` at 2560px, framed surfaces | 2147–2560px | **1280px** |
| `#content` at 2560px, dense surfaces | 2147px | 2147px, unchanged |
| open vs closed chip separation | hue only (1.04:1 ink, 1.00:1 ground) | outline + glyph + hue |
| `.autoscroll` regions reachable by keyboard | 0 of 25 | **25 of 25** |
| body horizontal overflow, any route | none | none |

### Two deviations, stated rather than buried

**TDD was not honoured.** `PLAN.md` §7 required a failing test before each Ruby and view behaviour change. The code was written first and the system tests after. The tests are real and they assert the right things, but they were not RED first, and calling that anything else would be false.

**`bin/rails test:system` cannot run in this environment at all.** Selenium reports `Linux arm64 is not supported yet by chrome`; the container is aarch64, has no browser installed, and `apt-cache` offers no `firefox-esr` candidate. The plan's chosen verification seam — first-party Capybara system tests, adopted from Codex round 2 and genuinely the better design — is unavailable here as a matter of platform, not of preference. The four system-test files are committed and will run wherever a browser exists. Browser verification for this build was performed with the `puppeteer-core` harness driving host Chrome against the container's HTTP port: 37 assertions mirroring the committed system tests, all passing. The harness Codex argued against is the only one that works on this machine.

## Post-build inspection — round 1

Fresh read-only Codex session, new thread, reviewing the diff cold against `PLAN.md`. Findings verbatim:

- [P1] [application.css:1477](/Users/shakhzod/Documents/Git/redmine/app/assets/stylesheets/application.css:1477) — The ligature suppression misses two promised targets. Repository filenames are rendered as `tr.entry td.filename`, not beneath `.repository`, and branch labels are rendered by `select#branch` with no matching rule. Names such as `1x2` can therefore still display as `1×2`.

- [P2] [application.css:1472](/Users/shakhzod/Documents/Git/redmine/app/assets/stylesheets/application.css:1472) — Numeric weight is only partially implemented. `total_estimated_hours`, `estimated_remaining_hours`, and `total_spent_hours` remain weight 400, although the existing rules at lines 1407–1418 already classify them as numeric and the plan requires numeric cells at weight 500.

- [P2] [application.css:3313](/Users/shakhzod/Documents/Git/redmine/app/assets/stylesheets/application.css:3313) — `.badge .icon-svg` is global, so plugin-supplied or future icon-bearing badges also receive forced 12px sizing and spacing. The new glyph treatment was supposed to be scoped to issue-list status badges. It also adds 4px after the SVG on top of `sprite_icon`’s existing 4px label margin.

- [P2] [application.css:650](/Users/shakhzod/Documents/Git/redmine/app/assets/stylesheets/application.css:650) — Raising the base `h4` does not satisfy the stated heading floor. The later `.journals h4.journal-header` rule at line 3188 remains more specific and sets 13px, below the 14px body size.

- [P2] [common/_diff.html.erb:7](/Users/shakhzod/Documents/Git/redmine/app/views/common/_diff.html.erb:7) — The unconditional `tabindex="0"` sweep extends beyond the issue-list diagnosis authorized by the plan. This partial creates one tab stop per changed file—even when no horizontal overflow exists—so large diffs can add many unnecessary keyboard stops. The same unconditional change reaches 24 other views.

- [P2] [.impeccable/design.json:484](/Users/shakhzod/Documents/Git/redmine/.impeccable/design.json:484) — The required design-record synchronization is incomplete. The description says 12px, but the component CSS at line 486 still uses `0.6875rem` (11px), models closed status as a filled chip, and contains no glyph.

- [P2] [config/locales/en.yml:699](/Users/shakhzod/Documents/Git/redmine/config/locales/en.yml:699) — `label_admin_menu_other` was added only to English and Russian. The plan explicitly requires `locales:update` to materialize it into all remaining locales; other locales currently depend on English fallback instead of matching the specified shipped state.

- [P2] [queries_helper.rb:298](/Users/shakhzod/Documents/Git/redmine/app/helpers/queries_helper.rb:298) — The tracked diff contains none of the required helper/system regression tests for either status-icon branch or admin grouping. The four new system-test files are still untracked, and `test/helpers/queries_helper_test.rb` is unchanged, so a commit of the reviewed diff would ship without the plan-mandated coverage.
### Claude's dispositions

Seven of eight accepted and fixed; one accepted as a real trade-off and kept, with the reason recorded.

**Accepted and fixed**

- **[P1] The ligature rule missed its targets.** Verified: repository filenames render as `tr.entry td.filename` / `td.filename_no_report`, not under `.repository .filename`, and the branch control is `select_tag :branch` → `select#branch`, which had no rule at all. The selector list was written from memory rather than from the markup, so the fix for the digit-`x`-digit bug was not reaching two of the places the plan named. Corrected to the selectors that exist.
- **[P2] Numeric weight was inconsistent with the rule three lines above it.** `total_estimated_hours`, `estimated_remaining_hours` and `total_spent_hours` are classified as numeric by the existing right-align rule but were left at weight 400. Added.
- **[P2] `.badge .icon-svg` was global.** It would have resized any icon inside any plugin-supplied badge. Scoped to `tr.issue td.status .badge .icon-svg`. The redundant `margin-inline-end` is also removed: `sprite_icon` already emits `span.icon-label` with a 4px `margin-inline-start` (`application.css:3459`), so the gap was being applied twice.
- **[P2] The heading floor was defeated by a more specific rule.** `.journals h4.journal-header` sets its own `font-size` and stayed at 13px under a 14px body, so the fix held everywhere except the journal headers on the busiest screen in the product. Raised to `0.875rem`. Checked the other `h4` overrides too: `.wiki h4` is 1rem and `#document-list .document-item h4.title` is 1rem, both already above the floor.
- **[P2] `design.json` was half-synced.** The prose description said 12px while the component's own `css` string still carried `0.6875rem` and modelled the closed chip as filled with no glyph. Both corrected; the file still parses.
- **[P2] `locales:update` had not been run.** `PLAN.md` §3 required it and I stopped at `en.yml` and `ru.yml`. Running it propagated `label_admin_menu_other` to all 50 locale files — and surfaced that `label_theme_toggle`, added by the redesign commit `069d9a860`, had been missing from 48 locales since then. Both are now present everywhere.
- **[P2] The helper test the plan named did not exist.** `test/helpers/queries_helper_test.rb` was listed as the seam for the status glyph and was left unchanged. Two tests added — the glyph renders before the label for both branches, and a non-`IssueStatus` value still returns its plain label. The class needed `include ERB::Util` because `format_object` calls `h`. 11 runs, 39 assertions, 0 failures.

**Accepted as a trade-off, kept, with the reason**

- **[P2] The `tabindex="0"` sweep reaches 25 views, and the plan authorised the issue list.** The objection is correct on both counts: it is wider than the plan named, and in `common/_diff.html.erb` it adds one tab stop per changed file whether or not that file's table actually overflows. It stays, for two reasons. First, `.autoscroll` is one component with one defect; fixing the three views the diagnosis happened to name would have left twenty-two regions whose contents are unreachable by keyboard, which is patching the path the ticket named instead of the cause. Second, the alternatives are worse: CSS cannot test for overflow, so the only way to make focusability conditional is JavaScript that sets `tabindex` after measuring — which trades a few redundant tab stops for a keyboard affordance that does not exist until a script runs. A redundant tab stop is noise; an unreachable column is lost data.

**Not a finding**

- The observation that the new system-test files are untracked and the diff would ship without them is a statement about the working tree, not the code: nothing has been committed, because committing was never requested. The files exist and pass where a browser exists.

**Re-verified after these fixes:** stylelint 3 findings, all pre-existing at `HEAD`, 0 new · selector gate PASS, 3 allowlisted removals · browser verification 37/37.

## Post-build inspection — round 2 (final; MAX_INSPECTION_ROUNDS reached)

Findings verbatim:

- [P2] [.impeccable/design.json:485](/Users/shakhzod/Documents/Git/redmine/.impeccable/design.json:485) — The status component remains partially synchronized: 12px sizing and the closed outline landed, but its HTML is still text-only and its CSS contains no glyph/icon rule.

- [P2] [app/views/admin/info.html.erb:19](/Users/shakhzod/Documents/Git/redmine/app/views/admin/info.html.erb:19) and [app/views/my/_sidebar.html.erb:42](/Users/shakhzod/Documents/Git/redmine/app/views/my/_sidebar.html.erb:42) — Two of 27 `.autoscroll` instances still lack `tabindex="0"`. The system test only visits the issue list, so it misses both.

I accept unconditional focusability as the simpler accessibility trade-off; redundant tab stops are preferable to inaccessible overflow. The other six fixes landed correctly, with no newly introduced regression found.
### Claude's dispositions

Both accepted and fixed. Six of the seven round-1 fixes were confirmed correct on re-read, and the kept trade-off was accepted: *"I accept unconditional focusability as the simpler accessibility trade-off; redundant tab stops are preferable to inaccessible overflow."*

- **Two scroll regions were still unreachable, and the reason is the same mistake for the third time.** `app/views/admin/info.html.erb:19` is `<div class="box autoscroll">` and `app/views/my/_sidebar.html.erb:42` is `<pre … class='autoscroll' …>` — one has a second class before it, the other uses single quotes. The sweep matched the literal string `<div class="autoscroll">` rather than the class, so it patched 25 of 27. Both fixed; the count is now 27 of 27.

  The pattern across this build is worth naming, because it repeated in three different forms: a `for` loop that assumed word-splitting, a comment marker that collided with CSS id syntax, and now a class match written as a literal string. Each time the check reported success while covering nothing. So this one is no longer defended by a browser test that visits a single page — `test/unit/lib/redmine/scrollable_regions_test.rb` scans every `.erb` under `app/views` for the class and fails with the file and line of any region that is not focusable. A system test could never have caught these two, because it would have had to visit both of those exact screens.

- **`design.json`'s status component was still text-only.** The 12px sizing and the closed outline had landed, but the component's `html` sample carried no glyph and its `css` had no icon rule, so the record still described a chip that no longer exists. Both added; the file parses.

**Final verification after these fixes:** `rubocop` clean (two `Lint/RedundantDirGlobSort` and `Performance/RegexpMatch` offences in the new test, fixed) · new guard test passes · browser verification **37/37**.

## Follow-up defect — collapsed sidebar could not be reopened

Reported by the owner after the sweep, on the documents sidebar. Pre-existing in `069d9a860`, not introduced here — and it is the same selector the sweep's own gate had flagged as dropped against upstream (`#sidebar-switch-button` → `#sidebar #sidebar-switch-button`), reported at the time and deliberately left out of scope.

**Measured cause.** Collapsing sets `#main.collapsedsidebar #sidebar { inline-size: 0; padding-inline-end: 0 }`, leaving a 21px strip (the 20px start padding plus a 1px border). The redesign had replaced upstream's full-width toggle — `display: block; inline-size: 100%; padding-inline: 0 28px` — with a fixed 24px `inline-flex` box carrying `margin-inline-start: 16px`. At 1440px the button therefore rendered at x 1436–1460: a 4px sliver on screen, with its centre outside the viewport. `document.elementFromPoint` at that centre returned `null`, so the control was visible-ish and entirely unclickable, and closing the sidebar was a one-way trip. Upstream never had the bug because its button had 28px of end padding to overflow into.

**Fix.** The collapsed rail is given a width that fits its own toggle — `inline-size: 24px; padding-inline: 8px`, a 41px strip — and the panel's negative start margin and the button's start margin are zeroed in that state. No JS, no positioning context, no change to the expanded state.

**Verified** at 1440, 2560 and 1024, plus RTL: button fully inside the viewport, `elementFromPoint` resolves to it, and a second click restores the sidebar.

| viewport | before (x) | after (x) | clickable |
|---|---|---|---|
| 1440 | 1436–1460 | 1408–1432 | yes |
| 2560 | — | 2528–2552 | yes |
| 1024 | — | 992–1016 | yes |
| 1440 RTL | — | 8–32 | yes |

Regression cover: `test/system/accessibility_affordances_test.rb#test_the_collapsed_sidebar_can_be_reopened` collapses the sidebar, asserts the toggle is the element at its own centre point, and reopens it. The browser harness carries the same check — now 38/38.
