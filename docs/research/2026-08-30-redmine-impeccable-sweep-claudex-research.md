# Research: Redmine /impeccable sweep

Six questions were scouted and deep-read against primary sources — design-system specs and token files (Carbon, Primer, Pajamas, Atlassian, Polaris, USWDS, GOV.UK, Material), normative W3C text, shipped rollbacks and merged MRs, first-hand user threads, and direct fontTools/CSS measurement of this repo's own committed assets. Out of scope by construction: replacing or extending the committed token system, adding any runtime dependency (JS animation library, CSS framework, build step), user-preference machinery requiring migrations, and anything requiring a booted demo container to verify — several claims below are flagged as unverified for exactly that reason.

## Key Takeaways

- **The stated WCAG AA failure is stale — do not spend the sweep on it.** `application.css:152` already ships a split token `--nx-badge-open-ink: #005bab`, measured at 6.01:1 on `#e8f2fd`; closed is `#146633` on `#e6f4ea` = 6.21:1. Both pass AA.
- **The real encoding defect is measured and different: open and closed badges are separated by hue only.** Ink-to-ink 1.04:1, fill-to-fill 1.00:1 — in grayscale they are literally the same chip, which is [Carbon's explicit failing test](https://carbondesignsystem.com/patterns/status-indicator-pattern/). Only the label rescues 1.4.1, and text is the slow channel, so the encoding contributes nothing to scan speed today.
- **Fix it with two channels that cost nothing: make closed an outline chip (the `border: 1px solid transparent` slot at `application.css:3216-3230` is already declared and unspent), and put one `sprite_icon` glyph *before* the label in the `when :status` branch of `queries_helper.rb:291-296`.** Both channels must say the same thing as the text — redundant, never conjunctive; [conjunctive encoding was measured to collapse performance "even with minor heterogeneity"](https://arxiv.org/abs/2103.06084).
- **Colorize derived categories, never admin-authored names.** `IssueStatus#is_closed` and `IssuePriority#position_name` (`app/models/issue_priority.rb:76-93`) are already Jira's StatusCategory move; exposing a per-status color setting is exactly the vocabulary rot [Shopify shipped and had to revert](https://github.com/Shopify/polaris-react-archive/discussions/6579). Hold the row's total distinct-indicator count at three (open, closed, urgent) against [Carbon's five-or-six ceiling](https://carbondesignsystem.com/patterns/status-indicator-pattern/) — Redmine's defaults offer 14 candidates.
- **Keep `--nx-dur-fast: 90ms` and `--nx-dur: 160ms` exactly as committed; add one exit token (~110ms) and one exit curve, and hold a hard 300ms ceiling.** The committed values already sit inside every independently converged band ([Carbon 70/110/150](https://github.com/carbon-design-system/carbon/blob/main/packages/motion/src/dtcg/motion.json), [Primer 100/200/≤300 "NEVER exceed 500ms"](https://github.com/primer/primitives/blob/main/src/tokens/functional/motion/motion.json5), [Atlassian 50–150 / 150–400](https://atlassian.design/foundations/motion)). The gap is coverage and asymmetry, not the numbers.
- **Three typography values are measurably wrong against every published floor: `h4` at 13px renders smaller than the 14px body (`application.css:643`), `.badge` sits at 11px (`:3195`) below the floor [Atlassian raised from 11 to 12 on accessibility grounds](https://www.atlassian.com/blog/how-we-build/implementing-typography-at-scale-the-journey-behind-the-screens), and `table.list td` defaults to `text-align: center` (`:1374`), which [prevents quick scanning](https://www.pencilandpaper.io/articles/ux-pattern-analysis-enterprise-data-tables).** All three are one-line fixes.
- **`font-feature-settings: "cv05" 1, "ss03" 1` at `application.css:623` is dead CSS.** fontTools dump of all nine committed woff2 faces shows the available features are exactly `calt ccmp dnom frac kern locl mark mkmk numr pnum tnum` — no cv05, no ss03. Delete it, or re-subset with `--layout-features+=cv05` if the tailed `l` is actually wanted.
- **`max-inline-size: 72ch` on wiki prose (`application.css:656`) renders ~97 characters in Inter at 14px** — past [WCAG AAA's 80-glyph ceiling](https://www.w3.org/WAI/WCAG22/Understanding/visual-presentation.html) and well past [GOV.UK's 75](https://design-system.service.gov.uk/styles/layout/), because `1ch` (0.6309em) is 35% wider than a mean rendered character (0.4678em). Express measure in `em`: ~35em ≈ 75 characters.
- **Set page width per surface, not globally, using the `controller-*` / `action-*` body classes `body_css_classes` already emits (`app/helpers/application_helper.rb:924`).** Zero Ruby. A blanket max-width reproduces [GitHub's documented failure on code-dense pages](https://github.com/orgs/community/discussions/7096), which went unfixed for a year.
- **Never move a `call_hook` site, and never put load-bearing design work in `responsive.css`, `dropdown.css`, `gantt.css` or `jstoolbar.css`** — `application_helper.rb:1748-1762` substitutes any of those five filenames wholesale from an installed theme. Trunk fires 101 `call_hook` calls across 87 distinct names, 66 of them in `app/views`; [the published hook list is stale in both directions](https://www.redmine.org/projects/redmine/wiki/Hooks_List).

---

## 1. Encoding status, priority and type in dense tables

### What the evidence supports

Documented decision: in a dense scannable table the correct variant is the cheap **shape indicator** (shape + color + label), not the loud **icon indicator** (symbol + shape + color + label). [Carbon assigns them to different layouts by name](https://carbondesignsystem.com/patterns/status-indicator-pattern/) — the icon indicator is "Used when the layout offers ample space and the content requires maximum attention", the shape indicator is "Useful in smaller spaces or when users need to scan large amounts of data" and is "Most often used in lists, dashboards, data tables". Carbon pairs the shape indicator with a 16px icon at 12–14pt type.

The accessibility floor is two of {color, shape, symbol}, plus 3:1 non-text contrast both between status colors and against the page background, and the operative test is grayscale separability — [Carbon states it as "If the contrast is sufficient, even in grayscale, users should still be able to differentiate statuses without relying solely on color"](https://carbondesignsystem.com/patterns/status-indicator-pattern/). [GitLab Pajamas gives the same test as a pass/fail rule](https://design.gitlab.com/accessibility/visual/): "an icon that only changes color to indicate a status is insufficient. If the icon itself were to change, or it is paired with a meaningful text, then color alone isn't being relied on."

Glyph placement is normative, not taste: [Carbon requires the shape indicator *before* the label](https://carbondesignsystem.com/patterns/status-indicator-pattern/) — "Do not place shape indicators after the labels to avoid pushing them out of alignment" — and requires left alignment of icon and type in data tables.

For unbounded, admin-defined status sets the documented move is to colorize a derived **category**, never the status name. [Jira introduced StatusCategory and in 6.2 replaced per-status icons with category-colored lozenges](https://developer.atlassian.com/server/jira/platform/jira-issue-statuses-as-lozenges/), collapsing to four fixed categories with a documented fallback to icon-plus-text when category metadata is absent.

Badge weight belongs to system-derived metadata; [Pajamas routes user-defined or customizable metadata to a label instead](https://design.gitlab.com/components/badge/), and says "If it doesn't need to be highlighted consider using a static icon or plain text." [Atlassian draws the same line as a component split](https://atlassian.design/components/lozenge/usage): lozenge weight for workflow status, system state, priority and permissions; tag for metadata that "only classifies or categorizes."

Where a state set grows, the shipped pattern is a distinct **glyph**, not another color: Primer's [`StateLabel` octicon map](https://github.com/primer/react/blob/main/packages/react/src/StateLabel/StateLabel.tsx) gives `issueClosedNotPlanned` its own `SkipIcon`, and recoloring an existing glyph was [rejected in Primer's own icon repo as unusable for colorblind users](https://github.com/primer/octicons/issues/477). Notably the same file codes the *generic* `open`/`closed` statuses to render no icon at all — the glyph is spent only where the state set is product-specific.

Measured: redundant encoding of one meaning across two channels makes finding a row immune to display heterogeneity, while requiring the reader to *combine* two channels collapses performance ([Visual Informatics 2022 / arXiv 2103.06084](https://arxiv.org/abs/2103.06084)).

### Where sources disagree

- **Carbon contradicts itself on the accessibility floor within one page** — its visual section says three of four elements are needed "for WCAG compliance"; its accessibility section says two of three. Treat two as the requirement and three as house style; WCAG 1.4.1 says neither.
- **Carbon caps, GitHub adds.** Carbon limits the *number* of distinct indicators ("more than five or six... can overwhelm") and falls back to plain text where no action is required. Every documented GitHub move adds *channels per indicator*: [distinct icons per state in 2021](https://github.blog/changelog/2021-06-08-new-issue-and-pull-request-state-icons/), a distinct glyph rather than a recolor for a fifth state, [icons added to a search surface that had color only, as late as Feb 2025](https://github.com/orgs/community/discussions/39593). They reconcile only under that reading; a naive reading of either alone produces a bad table.
- **Semantic purity vs raw discriminability is unresolved inside Shopify's own thread.** The opening post argues to harden color roles; [the staff reply reports that shipping exactly that made adjacent order statuses share a color, drew "almost immediate" merchant complaints, and was reverted to an off-system yellow that "doesn't map to anything else in the system"](https://github.com/Shopify/polaris-react-archive/discussions/6579). Neither side is retracted.
- **Whether an icon may stand alone.** Carbon says icon-only "is acceptable" at 3:1 and then walks it back in the following sentence; [Primer is unambiguous the other way](https://primer.style/octicons/usage-guidelines/) — "use icons to supplement text, rather than replacing it." Weight of evidence is against icon-only in a status column.
- **Whether "closed" deserves a semantic color at all.** Carbon assigns green to completion states; [GitHub deliberately moved closed off red to purple](https://github.com/github/roadmap/issues/289) citing "the general scariness of seeing red across the issues index page when a bunch of closed issues is usually a good thing." They agree closed must not be red; they disagree on whether it is a success signal.

### What applies here

- **Correct the baseline first.** Measured at HEAD: `--nx-badge-open-ink: #005bab` on `#e8f2fd` = 6.01:1; `#146633` on `#e6f4ea` = 6.21:1. Both pass AA. Do not re-fix this.
- **The defect to fix is luminance.** Measured: open ink relative luminance 0.1042 vs closed 0.0989 → 1.04:1 between them; fills 1.00:1. Grayscale-identical.
- **Cheapest fix, pure CSS, no new token:** make closed an outline chip (transparent fill, hairline in `--nx-success`), leave open filled. The `border: 1px solid transparent` at `application.css:3216-3230` is an already-declared, unspent shape slot. This adds a luminance-bearing channel with no new hue and satisfies Carbon's outline rule.
- **Second channel at zero asset cost:** `app/assets/images/icons.svg` already ships `icon--issue`, `icon--issue-closed`, `icon--circle-dot-filled`, `icon--checked`, `icon--lock`, `icon--warning`, `icon--alert-circle`. One `sprite_icon(...)` call in the `when :status` branch at `queries_helper.rb:291-296`. Size 12–14px per Carbon's type pairing and Primer's fixed-size rule, and **verify separability at row size** — [GitHub's own users report shape differences that read in a spec sheet stop reading at render size](https://github.com/orgs/community/discussions/39593).
- **Alignment is already correct — keep it.** `application.css:1419-1422` sets `text-align: start` on `td.tracker`, `td.status`, `td.priority`, `td.category`. Any glyph goes before the label so it stays aligned across variable-length, localized status names.
- **Redmine already implements the StatusCategory move — defend it.** `IssueStatus#is_closed` collapses N statuses to 2 buckets; `IssuePriority#position_name` collapses N priorities to an ordinal scale from `position`, independent of admin naming. If a third status bucket is ever wanted, derive it; never expose per-status color settings.
- **Priority is already the good pattern — do not badge it.** `application.css:1426-1429` gives `priority-highest` `--nx-danger` + weight 600, `priority-high*` `--nx-warning` + 500, `priority-default` muted, `priority-low*` faint. That is redundant encoding spending color only above the default rung — the arXiv redundant condition plus Carbon's plain-text rule. A priority lozenge would put two lozenge weights in one row.
- **If a third channel is wanted on priority, spend it on the top rung only** (`icon--warning` before the label of `tr.issue.priority-highest`), keeping distinct indicators at three.
- **Tracker stays plain text** (`--nx-ink-muted`, `application.css:1423`). Developers filter on tracker; they do not triage on it.
- **`.badge-status-locked` (`application.css:3221`) is dead in lists** — `queries_helper.rb:291-296` only ever emits open or closed. Wire it or delete it; an unused color role is the seed of the Shopify drift.
- **Do not add `max-width` + ellipsis to `.badge`.** [Atlassian documents that a truncated lozenge is unrecoverable because lozenges are not focusable](https://atlassian.design/components/lozenge/usage). Today `.badge` has no max-width, so a long localized name widens the column — the safer failure.
- **Dark theme needs no new tokens.** Measured against `--nx-canvas #191919`: `#5aa5f0` 6.76:1, `--nx-success` 6.16:1, `--nx-danger` 6.62:1, `--nx-warning` 7.82:1, `--nx-ink-faint` 5.19:1. Every candidate glyph or hairline tint clears the 3:1 non-text floor in both themes with the palette exactly as committed.
- **Don't let a new blue in.** `--nx-primary-soft #e8f2fd` is simultaneously the open-badge fill, the context-menu selection background (`:1556`) and the journal highlight (`:3141`). Tint any open-badge glyph with `--nx-badge-open-ink`; leave the fill alone.

### What must be rejected here

- **Carbon's 9-token status color ramp.** A blue status chip would compete directly with links, breaking the one-blue rule, and immediately overshoots Carbon's own indicator ceiling.
- **GitHub's green-open / red-closed axis, and its red→purple hex.** The first re-imports the exact confusion [GitHub spent a roadmap issue walking back](https://github.com/github/roadmap/issues/289); the second requires a purple the token system does not have. The transferable lesson is the reasoning, not the color — and Redmine's closed badge already fails in the opposite direction (too quiet, not alarming).
- **Carbon's icon-indicator, badge-indicator and differential-indicator variants.** Reserved for ample-space / maximum-attention layouts, notification counts, and financial deltas respectively. Note the name collision: Redmine's `.badge` is a lozenge, not Carbon's badge indicator.
- **Primer's full per-state glyph set.** GitHub can do this with three-to-five fixed product-defined states; Redmine statuses are admin-defined and unbounded. Only the derived `is_closed` category can carry a glyph — and Primer itself renders no icon for its generic `open`/`closed`, which is the honest precedent.
- **Icon-only status encoding**, despite Carbon's one permissive sentence. Keep the label.
- **arXiv 2103.06084's 7-color / 5-shape numbers as a design budget.** They are ceilings measured on abstract glyph grids with no competing text; a row full of subject lines and dates is more heterogeneous, so the real limit is lower. Carbon's five-or-six is the operative constraint; cite the arXiv numbers only as order of magnitude.
- **Atlassian's lozenge dropdown trigger and trailingMetric badge.** The first needs an interactive JS component; Redmine already has a context menu for bulk status edits.
- **Zebra striping or status-tinted row backgrounds as the encoding channel** — forbidden by the committed world, and GitHub's own rationale about a semantic color repeated down an index page is the strongest argument against it even if it were allowed.
- **Shadows on badges.** No status-chip shadow appears in Carbon, Primer, Pajamas or Atlassian. A shadow is not an encoding channel; on a flat hairline table it reads as elevation.
- **Anything about how Linear encodes status or priority.** Linear publishes nothing normative on row encoding. If its four-bar priority glyph is imitated, flag it as product observation, not citation — and note that as an icon-only encoding it fails Pajamas' test unless paired with text.

---

## 2. The motion budget for a high-density work tool

### What the evidence supports

Documented decision: set the **frequency ceiling** before the duration ladder. [Atlassian splits its entire budget on that axis](https://atlassian.design/foundations/motion) — "If someone will trigger this motion dozens of times a day, keep it under 150ms", with interactions at 50–150ms and transitions at 150–400ms, and a named don't: "Motion that blocks the next step in a flow." [Carbon's token source ships per-token usage prose](https://github.com/carbon-design-system/carbon/blob/main/packages/motion/src/dtcg/motion.json): 70ms instant feedback, 110ms small fades, 150ms "Default transition speed", 240ms expansion/toast, 400ms/700ms for large or hero events. [Primer encodes a hard normative ceiling in the token file itself](https://github.com/primer/primitives/blob/main/src/tokens/functional/motion/motion.json5): "MUST keep UI interactions ≤300ms... NEVER exceed 500ms", with 500ms annotated "NEVER use for simple UI interactions." [Pajamas independently lands at 100ms list-item hover and 200ms interactive-element hover](https://design.gitlab.com/product-foundations/animation-fundamentals/).

Exit should be a separate, shorter token than enter — [Primer ships 300ms enter / 200ms exit with the stated reason "Shorter than enter to feel snappy"](https://github.com/primer/primitives/blob/main/src/tokens/functional/motion/motion.json5); [NN/g gives the same asymmetry](https://www.nngroup.com/articles/animation-duration/); [eBay's accordion expands at `medium.3` and collapses at `medium.1`](https://playbook.ebay.com/design-system/components/accordion?tab=motion).

Expert opinion: decide whether to animate by **counting triggers per day**. [Emil Kowalski's standards file publishes the table](https://github.com/emilkowalski/skills/blob/main/skills/review-animations/STANDARDS.md) — "100+ times/day... No animation. Ever."; "Tens of times/day (hover effects, list navigation) | Remove or drastically reduce"; occasional surfaces get standard animation. Also: "Never animate keyboard-initiated actions."

Documented decision: the fix for perceived sluggishness is often the **delay**, not the animation. [GitLab MR !212773, merged 2025-11-17, is a one-line diff](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/212773) removing a 100ms `transition-delay` while explicitly keeping the 200ms transition. Separately, [GitLab MR !119801 removed hover animation across all links and buttons and reported "the result makes the product feel quite a bit snappier than before"](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/119801) — precedent that *deleting* transitions is a legitimate move in an animate phase.

Never animate layout properties on a long list — [animating width/height/top/left/margin/padding forces a per-frame recompute of every subsequent element; "Never animate those. I mean never"](https://performance.dev/how-is-linear-so-fast-a-technical-breakdown). Prefer CSS transitions over `@keyframes` for retriggerable motion, because transitions retarget mid-flight while keyframes restart from zero.

Measured: the only genuinely measured constant underneath all of this is [the 0.1-second perceptual limit, sourced to Miller (1968) and Card et al. (1991)](https://www.nngroup.com/articles/response-times-3-important-limits/). Everything else is convergent industry convention.

Normative: [Media Queries Level 5 §12.1](https://www.w3.org/TR/mediaqueries-5/) says `reduce` means the user prefers an interface that "removes **or replaces** the types of motion-based animation that either trigger discomfort... or distraction" — scoped to *types*, with replacement explicitly permitted. [MDN's worked example is a swap, not a kill](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/At-rules/@media/prefers-reduced-motion): a scale-pulse becomes an opacity-dissolve, because "Animations such as scaling or panning large objects can be vestibular motion triggers." [WCAG SC 2.3.3 is Level AAA and carries an essential-motion carve-out](https://www.w3.org/WAI/WCAG21/Understanding/animation-from-interactions).

### Where sources disagree

- **What `prefers-reduced-motion: reduce` should DO is genuinely unsettled, and Redmine currently ships the losing side.** The spec, MDN, web.dev and Emil all argue reduce-and-replace; [Atlassian states flatly "when reduced motion is active, motion is off and instant"](https://atlassian.design/foundations/motion). `application.css:4036` implements Atlassian's position with a blanket `transition-duration: 0.01ms !important` plus an `!important` counter-exception to keep the spinner running (`:4045-4048`). Nobody is objectively wrong; the blanket nuke is safe and one line. Pick deliberately.
- **Whether list rows should carry a hover transition at all.** [Linear ships "There are no transitions on list items to keep things snappy"](https://performance.dev/how-is-linear-so-fast-a-technical-breakdown) and Emil's table puts list navigation in the "remove or drastically reduce" band. Against that, Primer's `transition.hover` token exists for exactly this, Carbon's 70ms covers it, and Atlassian's 50–150ms band names hover states. The disagreement is not about duration — it is whether a sub-100ms color fade counts as motion.
- **Enter/exit asymmetry flips depending on what is moving.** For elements entering and leaving the viewport, Primer, NN/g and eBay agree enter > exit. For hover highlights Linear inverts it entirely (`--speed-highlightFadeIn: 0s`, `--speed-highlightFadeOut: .15s`). Applying the element rule to a row-hover fill gives the slower half exactly where the pointer is.
- **Whether ease-in is ever acceptable for exits.** Primer's semantic exit token resolves to an ease-in curve that Primer's own base file annotates "Rarely used alone. Prefer ease-out for most exit animations." Emil: "Never ease-in on UI." Carbon splits the difference with a productive exit curve that accelerates away without starting slow.
- **Evidence quality is far weaker than the numeric consistency implies.** [NN/g's duration article](https://www.nngroup.com/articles/animation-duration/) — the most-cited source in the space — grounds its 100–400ms range in practitioner experience; its sole research citation establishes nothing about duration. [Its scroll-animation study publishes no participant count and no measured delay](https://www.nngroup.com/articles/scroll-animations/). That five systems converged independently is itself the strong evidence, not any one citation.
- **Motion sensitivity vs motion as tax.** [Val Head reports that not one motion-sensitive person she interviewed wanted interface animation eliminated](https://alistapart.com/article/designing-safer-web-animation-for-motion-sensitivity/), while [developers in this exact persona globally kill all transitions via `userContent.css` and report nothing important breaks](https://hn.algolia.com/api/v1/items/32081528). Both can be true — which is precisely why motion must never be load-bearing.

### What applies here

- **Keep `--nx-dur-fast: 90ms` and `--nx-dur: 160ms` (`application.css:184-186`).** 90ms sits between Carbon's 70 and 110 and inside Atlassian's interaction band; 160ms is one tick above Carbon's 150ms default and inside Atlassian's transition band. Resist a six-step ladder for a stylesheet with 12 `transition:` declarations.
- **Add exactly two tokens: `--nx-dur-exit` ~110ms and `--nx-ease-exit: cubic-bezier(0.2, 0, 1, 0.9)`** (Carbon's productive exit, ending at slope 1.0 so the element snaps away). Use for dismissal only — `.drdn-items`, `#main-menu .menu-children`, modal close, tooltip hide. Roughly six selectors.
- **Keep `--nx-ease` (0.16, 1, 0.3, 1) for hover and enter** — it is already a strong ease-out, which NN/g, Primer, Carbon, Atlassian and Emil all recommend as default. Stop using it for exits.
- **Consolidate the twelve hardcoded `0.12s ease` / `0.1s ease` / `100ms linear` transitions** (lines 700, 713, 734, 823, 887, 911, 1001, 1769, 2867) onto `var(--nx-dur-fast) var(--nx-ease)`, matching lines 1559 and 1682. Find-and-replace in one file; makes the motion budget auditable by grep.
- **Decide the reduced-motion block deliberately.** Two coherent options: (a) keep the blanket nuke at `:4036` — one line, safe, already shipped; (b) move to reduce-and-replace — keep opacity/color/background-color at committed durations, zero out only transform/translate/scale, and override `nx-flash-in` under `reduce` to fade without the `translateY(-4px)` (MDN's pulse→dissolve pattern applied to the one animation Redmine has). Either way, [prefer wrapping *new* motion in `@media (prefers-reduced-motion: no-preference)` per Primer](https://primer.style/accessibility/design-guidance/motion-and-animation/) — the opt-in form cannot be defeated by later specificity and needs no `!important` carve-outs. The existing spinner exemption is correct under 2.3.3's essential-motion carve-out.
- **Row hover on `table.list tbody tr` (`:1559`) is the highest-frequency motion in the product.** Either keep it as-is (90ms, background-color only) or drop it to 0 on the issue list following Linear and GitLab !119801. What is not defensible is *extending* it: no transform, no box-shadow, no border-width, no scale.
- **Never animate keyboard-initiated surfaces** — `context_menu.css`, the issue-list context menu, any accesskey-driven panel.
- **Restrict animated properties on the issue list to opacity, color, background-color and border-color.** Never animate height on `tr.group` toggles; instant collapse is the correct and cheapest answer.
- **If group disclosure gets motion, make collapse faster than expand** and animate the chevron on its own track.
- **Audit `transition-delay` before duration and keep it at zero.** Never add hover-intent delay to `#main-menu li:hover ul.menu-children` or the `.drdn` dropdowns.
- **Gate hover-only motion behind `@media (hover: hover) and (pointer: fine)`** — Redmine ships `responsive.css` and touch fires a false hover on tap.
- **Cap translation at the ~4px already used by `@keyframes nx-flash-in` (`:4031-4034`).** [Val Head's property-level rule is reviewable in a diff](https://alistapart.com/article/designing-safer-web-animation-for-motion-sensitivity/): "Animation that involves only non-moving properties, like opacity, color, and blurs, are unlikely to be problematic."
- **Hold 300ms as the hard ceiling on every daily surface; leave 400ms+ entirely unused.** Redmine has no hero, onboarding, or celebration surface.

### What must be rejected here

- **Material 3's medium/long/extra-long ladder (250–1000ms).** [Phone-first and archived read-only since October 2024](https://github.com/material-foundation/material-tokens/blob/json/json/motion.json); its only band agreeing with everyone else is 100ms. Cite as contrast case only.
- **Carbon's expressive easing mode and slow-01/slow-02 (400/700ms).** Documented for "large hero transitions" and "background dimming" — the committed world has nothing to dim.
- **Springs, momentum, drag physics, `useSpring`, Framer Motion transform-string advice.** All require a JS animation runtime on a stylesheet that currently declares 12 transitions.
- **Staggered list entrances (30–80ms per item).** On server-rendered 100-row tables this reproduces [the NN/g scroll-animation failure verbatim](https://www.nngroup.com/articles/scroll-animations/) — "I hate that it has to load every single section."
- **Shared-layout / FLIP tab transitions and page transitions generally.** Redmine's `#content .tabs` switches *are* page loads; the animation competes with the navigation it decorates.
- **`transform: scale(0.97)` press feedback and origin-aware popover scale.** Feasible in plain CSS, but the committed world is hairline structure with no elevation play, and button presses sit in the "reduce" frequency band.
- **NN/g's 300ms modal and 400ms "big movements" numbers.** Calibrated for phones and marketing pages; `#ajax-modal`, the context menu and `.drdn` dropdowns are opened many times per session and belong under the 150ms frequency ceiling.
- **eBay's +7px chevron bounce.** Take the expand/collapse asymmetry; leave the bounce.
- **Linear's exact hover values as a template.** A 150ms lingering fade-out on a 100-row table means several rows are visibly decaying as the pointer sweeps. The committed symmetric 90ms is the safer shape.
- **WCAG 2.3.3's in-page global animation preference.** It is the correct answer to [the GNOME problem, where users who only want speed flip the accessibility switch](https://gitlab.gnome.org/GNOME/gnome-shell/-/work_items/7513) — but it needs a persisted user setting, a migration, and a settings form, and 2.3.3 is AAA.
- **Atlassian's four-easing vocabulary.** Redmine has one committed easing plus (proposed) one exit curve. Four curves create four new ways to be inconsistent.
- **Pajamas' 500ms action-feedback and 600ms position-change tokens.** They exist for client-side board drags. A 600ms token in this stylesheet would only ever be misused.

---

## 3. Typography and hierarchy in dense interfaces

### What the evidence supports

Documented decision: the resolution for "the heading would be smaller than body" is to make the smallest heading the **same size and same line-height as body, differentiated by weight alone**. [Carbon's `$heading-compact-01` and `$body-compact-01` are byte-identical except regular vs semibold](https://raw.githubusercontent.com/carbon-design-system/carbon/main/packages/type/scss/_styles.scss). [Atlassian lands independently on the same shape](https://atlassian.design/foundations/typography) — Heading XS Bold 14/20 pairs with Body M Regular 14/20 — and [chose bolder over bigger explicitly for dense-screen scanability](https://www.atlassian.com/blog/how-we-build/implementing-typography-at-scale-the-journey-behind-the-screens): "Bolder headings offer greater contrast and improved visual hierarchy within our UI. This is key for the scanability of information-dense screens."

The 11px→12px floor raise was a documented accessibility reversal, not a preference, and [all-caps was deleted entirely in the same pass](https://www.atlassian.com/blog/how-we-build/implementing-typography-at-scale-the-journey-behind-the-screens): "The removal of all caps is a win for accessibility." [Shopify — itself a dense admin — sets 13px as the hard minimum for headings, body and interactive text, 12px only for captions](https://shopify.dev/docs/apps/design/visual-design).

[Primer forbids letter-spacing adjustment outright](https://raw.githubusercontent.com/primer/design/main/content/foundations/typography.mdx) — "this should be avoided altogether" — makes weight the primary hierarchy tool, explicitly demotes color ("Refrain from utilizing color as a primary method of emphasis"), and forbids renumbering heading tags for visual effect.

For tables: [Rutter specifies tabular lining figures, header alignment matched to data alignment, and grouping by whitespace rather than fills](https://alistapart.com/article/web-typography-tables/) — "Right-align numbers to help your reader make easier comparisons of magnitude when scanning down columns." [Digit columns split by kind: quantitative right-aligns, qualitative digit strings do not, and centering is actively harmful](https://www.pencilandpaper.io/articles/ux-pattern-analysis-enterprise-data-tables): "Center alignment prevents quick scanning and noticing irregularities."

[WCAG 2.2 SC 1.4.12 makes any tight-row decision testable](https://www.w3.org/WAI/WCAG22/Understanding/text-spacing.html): the layout must survive a user override of letter-spacing to 0.12em, word-spacing 0.16em, line-height 1.5, paragraph spacing 2em with no clipping or lost function.

[Inter's own designer publishes an exponential tracking curve whose sign flips at ~12.1px](https://d.rsms.me/inter-website/v3/dynmetrics/) — tracking is ~0 at 12px and goes negative above it: −0.0032em at 13px, −0.0062em at 14px, −0.011em at 16px.

Measured, in this repo (fontTools on the committed woff2 files):
- The nine committed faces expose exactly `calt ccmp dnom frac kern locl mark mkmk numr pnum tnum`. **No `cv05`, no `ss03`, no `ss02`, no `ss04`, no `cv08`.** `application.css:623` is dead CSS. (Separately, [in Inter's own data file `ss03` is "Round quotes & comma"](https://raw.githubusercontent.com/rsms/inter/master/docs/_data/feature_samples.yml) — it never had anything to do with `l`/`I`.)
- `tnum` genuinely works: default proportional digit advances span 833–1323 units of a 2048 upm (~5.3px to ~8.4px at 13px); all ten tabular digits collapse to a single 1328-unit advance. The existing `font-variant-numeric: tabular-nums` is real, not decorative.
- **Tabular digit advance is effectively weight-invariant**: 1328/1327/1325/1324 units at weights 400/500/600/700 — 0.195% max drift, ~0.025px across a ten-character column at 13px. Weight is a free encoding channel for numeric cells.
- The `l`/`I` ambiguity is real and unfixable from CSS: identical heights (1490 units), ink widths 180 vs 190 units at weight 400 — 1.14px vs 1.21px at 13px. Inter's x-height is 0.546em, which is the mitigating factor.
- Committed values outside every published floor: `h4` 13px muted (`:643-650`) below the 14px body (`:613-615`); `.badge` 11px (`:3195`); `table.list td { text-align: center }` (`:1374`).

[Web Almanac 2024 measured that `font-variant` properties are sufficient on their own](https://almanac.httparchive.org/en/2024/fonts): "there isn't any need to use `font-feature-settings`."

### Where sources disagree

- **Letter-spacing at small sizes is a genuine three-way split.** [Carbon ships +0.32px at 12px and +0.16px at 14px](https://raw.githubusercontent.com/carbon-design-system/carbon/main/packages/type/scss/_styles.scss); [Primer forbids it](https://raw.githubusercontent.com/primer/design/main/content/foundations/typography.mdx); [Inter's own curve is *negative* at 14px](https://d.rsms.me/inter-website/v3/dynmetrics/). Carbon and Inter agree only that tracking is spent inversely with size; they disagree on where zero sits and what happens past it. No source explains the split — the usual explanation (Primer rides OS fonts it does not control) is inference, not evidence.
- **Line-height in table cells spans 1.0–1.5 across four credible sources** — Rutter `line-height: 1`, Carbon compact 1.28572, Inter's own `1.4 × z`, WCAG 1.4.12's 1.5 override requirement. The only thing all four agree on is that the row must not have a fixed height.
- **The minimum size is contested between 10 and 13** — [Shopify 13](https://shopify.dev/docs/apps/design/visual-design), Carbon's hard 12px floor, Atlassian's 12 after a reversal, and [a practitioner in this exact problem space refusing a single number](https://stephaniewalter.design/blog/what-minimum-font-size-for-a-high-density-data-web-app-do-you-suggest/): "10px for headings in tables or a tag in a card could do the job."
- **cv05 / the tailed `l` has two primary sources pointing opposite ways.** [Designsystemet.no recommends it in writing on accessibility grounds with exact CSS](https://designsystemet.no/en/fundamentals/theme/typography); in [rsms/inter#182 the people who *reported* the ambiguity reject the alternate](https://github.com/rsms/inter/issues/182) as "a totally different vibe than the simplicity of the default set", and rsms closed it without changing the default. Note the asymmetry: cv05 touches one glyph, ss02 touches many.
- **Monospace vs tabular figures for numeric columns.** [Pencil & Paper: "It is highly recommended to use a monospace font for numerical values."](https://www.pencilandpaper.io/articles/ux-pattern-analysis-enterprise-data-tables) Rutter and Inter specify tabular figures instead. Measurement settles it here in favour of `tnum`.
- **Uppercase.** [NN/g measured a 26% lowercase penalty at p<0.01](https://www.nngroup.com/articles/glanceable-fonts/) — but the same article reports matched-x-height lowercase performing the same, and does not recommend all-caps for longer passages. The finding is about rendered x-height, not case.

### What applies here

- **Delete the dead feature line at `application.css:623`.** Either remove it outright, or — if the tailed `l` is genuinely wanted on the Designsystemet argument — re-subset the five Latin faces with `pyftsubset --layout-features+=cv05` and enable **only** cv05. Drop `ss03` either way; it was never relevant.
- **Raise `h4` to body size**: `0.875rem` / weight 600, and drop `--nx-ink-muted` on it. Muted color + smaller size + a rule is three emphasizers stacked in the demoting direction. Let the existing `border-block-end` hairline carry the separation.
- **Raise `.badge` from 11px to 12px.** 12px is also where Inter's curve crosses zero, so the existing `letter-spacing: 0.01em` on the badge becomes consistent with both Carbon and Inter at that size instead of neither.
- **Keep table cells at 13px and go no lower.** `table.list { font-size: 0.8125rem }` lands exactly on Shopify's stated minimum for interactive text — correct, because Redmine cells contain links. Inter's measured 0.546em x-height is the specific reason it holds.
- **Stop centring table cells.** Flip the `td` default to `text-align: start`; keep right-align on `estimated_hours` / `spent_hours` / `total_*` and add `done_ratio`; move `td.id` off centre to start (an issue number is a qualitative digit string, not a magnitude). Extend the header rule at ~`:1360` so right-aligned numeric columns get right-aligned headers.
- **Keep `font-variant-numeric: tabular-nums` at `:1333`, `:1752`, `:2952`; add no `font-feature-settings` fallback.**
- **Set numeric columns at weight 500 without fear of reflow** — measured 0.195% drift. Use it for `td.id` and any figure the reader compares; leave categorical cells at 400. This matters because Primer makes weight the primary emphasis tool and the committed world has exactly one blue.
- **Tighten dense-row line-height toward 1.35–1.4 on `table.list td`, not to 1.** Inter's own recommendation is 1.4 (18.2px at 13px); Carbon's compact body is 1.28572. Body is currently a uniform 1.5 — a reading measure applied to a scanning surface.
- **Band letter-spacing by size and stop the positive values at 12px.** Keep small positive tracking on 11–12px micro-labels only; set 0 at 13–14px (removing it from `h4`); keep the existing negative tracking on h1/h2/h3, which already follows Inter's curve direction.
- **Run the WCAG 1.4.12 stress test as an acceptance check** via bookmarklet. Named risks in the committed CSS: `white-space: nowrap` on `table.list th`, `td.buttons`, `td.reorder`; `body { min-inline-size: 900px }`; and any row that acquires a fixed block-size.
- **No all-caps anywhere, including table headers.** `text-transform: none` at `:3202` is already correct.

### What must be rejected here

- **Rutter's `line-height: 1` in cells** — the subject column wraps in a real issue list, and 1.0 leaves zero headroom for the 1.4.12 override the same table must survive.
- **Rutter's em-based cell padding** — it rescales with the 13px table font and desynchronises from the px-based `--nx` spacing scale.
- **Pencil & Paper's monospace-for-numbers rule** — measured unnecessary; a second woff2 breaks the one-face world for nothing.
- **Pencil & Paper's 40/48/56px density row heights** — Redmine rows are content-sized and wrap; pinning a height clips under the 1.4.12 override.
- **The NN/g uppercase result as licence for caps.** It is scoped to isolated 1–2 word strings out of sentence context, and its own control undercuts the caps reading. Use it only as an argument for adequate size.
- **Inter's `opsz` axis and the optical-sizing route.** Measured: the committed faces are static (no `fvar`), Version 4.001. Using `opsz` means shipping a variable font and rebuilding the asset pipeline. Type Network is useful here only as the *explanation* for why a tighter line-height is safe.
- **ss02 / ss04 / cv08** — absent from the subset, and the disambiguation set is exactly what the issue-182 requesters rejected. Slashed zeros and serifed capital I in product chrome read as terminal cosplay against a Notion-derived world.
- **The "slightly taller or thinner `l`" compromise everyone in issue #182 wanted.** It has no OpenType tag, was never built, and cannot be reached from CSS. Do not list it as an option.
- **Carbon's additive type scale as a replacement.** The committed scale (26/20/17/14/13/12/11) is part of the binding world. Carbon is useful for its letter-spacing values and its heading==body precedent, not as a scale to import.
- **Primer's letter-spacing ban applied literally** — the committed negative tracking on h1/h2/h3 follows Inter's published curve; removing it would be a regression against the type designer's own spec.
- **Atlassian's "Medium weight for alignment with iconography" rule** — a rule about Atlassian's own icon set's optical weight, with no measured equivalent here.
- **TypeTogether's 9-point threshold translated into a CSS pixel floor.** It is a print figure about when glyph *design* must change. Use Shopify/Carbon/Atlassian for the numeric floor.
- **Stéphanie Walter's 10px figure.** Her scanned-vs-read *framing* applies; the number does not, for an instance people stare at all day.
- **Rutter's `text-align: "." center` decimal alignment** — not implemented in any shipping browser, and the hours columns are fixed-precision where right-align + `tnum` suffices.
- **Any change that renumbers heading tags to hit a visual size.**

---

## 4. Composing sparse surfaces on a wide viewport

### What the evidence supports

Documented decision: cap the **page frame**, not the content. [Primer limits page layouts to 1280px "so the content region doesn't render paragraphs with too many words per line", and states the real visual ceiling is 1232px after 24px padding](https://primer.style/product/getting-started/foundations/layout/). It also defines column capacity by viewport range: narrow (<768px) 1 column, regular (≥768px) up to 2, wide (≥1400px) up to 3.

[GOV.UK's answer to the empty third is to keep prose in a two-thirds column anyway](https://design-system.service.gov.uk/styles/layout/), with a 1020px default max and a 75-character target. But [a government team building an internal admin/caseworking tool decoupled the two numbers](https://design-patterns.service.justice.gov.uk/probation/styles/pds-layout): at 1280px "a 'two-thirds' column will be too wide", so they added a separate constraint inside the wider frame.

[USWDS ships six measure steps with named use cases](https://designsystem.digital.gov/design-tokens/typesetting/measure/) rather than one global value — "Most lines of text should be 45–90 characters" with 66 as the target for longer texts.

[WCAG SC 1.4.8's 80-character line is Level AAA, and its own Note 1 says the requirement is that a *mechanism* be available, not that content hardcode a width](https://www.w3.org/WAI/WCAG22/Understanding/visual-presentation.html).

Documented decision: width is a **per-surface** decision. [GitLab kept a fixed default but flipped the diff/changes surface to full width, behind a feature flag, on named projects first](https://gitlab.com/gitlab-org/gitlab/-/issues/340761). The counter-example is loud: [GitHub applied one max-width uniformly and its own users called the result "barely usable by default on a 4k screen"](https://github.com/orgs/community/discussions/7096); the thread ran Nov 2021 to Oct 2022 and no fix shipped.

When a system needs a second width, [the documented move is to parameterize the existing width primitive rather than add a competing container](https://github.com/alphagov/govuk-frontend/pull/1626).

For long settings navs: [group with headings, never with per-item dividers, and label the nav landmark so group headings land in a correct h2→h3 outline](https://primer.style/product/components/nav-list/guidlines/). [GitHub shipped grouping across all four settings surfaces on a discoverability argument alone](https://github.blog/changelog/2022-02-02-redesign-of-githubs-settings-pages/) — no widths, no counts, no before/after IA. [Discourse shipped its admin regrouping default-on for new installs and opt-in for existing ones](https://meta.discourse.org/t/3-3-0-beta2-new-admin-sidebar-redesigned-bookmark-menu-chat-from-user-profile-and-more/307777), with the escape hatch to be removed only after every page is converted.

[A sidebar-plus-content composition can be built with zero media queries via `flex-basis` + `flex-grow: 999` + `min-inline-size: 50%` on the content](https://every-layout.dev/layouts/sidebar/) — container-aware, not viewport-aware.

[An empty region owes three things, none of them decoration](https://www.nngroup.com/articles/empty-state-interface-design/): system status, a learning cue naming what would fill it, and a direct pathway to the task that fills it.

Measured, in this repo:
- `.wiki > p …{ max-inline-size: 72ch }` (`application.css:656`) renders **~97 characters** at the committed 14px body. From the repo's own `Inter-400.woff2`: 1ch = 0.6309em, 1ex = 0.5459em, mean English advance = 0.4678em. 75 characters needs ~55.6ch (35.1em, 491px); 66 needs ~48.9ch (30.9em, 433px).
- **The admin page already multi-columns.** `#admin-index #admin-menu ul` (`:959-963`) is `grid-template-columns: repeat(auto-fill, minmax(240px, 1fr))` with a 24px gap — five columns at 1400px. `lib/redmine/preparation.rb:251-305` registers 14 flat `menu.push` items with zero nesting, while `render_menu_node_with_children` (`lib/redmine/menu_manager.rb:131`) already handles groups. All 14 carry an `:icon`, so Primer's leading-visual mixing anti-pattern is already avoided.
- **Per-surface width is a pure CSS change with zero Ruby.** `body_css_classes` (`app/helpers/application_helper.rb:924-939`) emits `controller-*` and `action-*` on every request. `#content` (`:1051`) currently has no `max-inline-size` and no `margin-inline: auto`. `#sidebar` widths are hardcoded across six media queries (`:977-982`); at 1440px the content region is ~1104px — Primer's *regular* range, not *wide*.
- **The empty-state contract is half-built.** `nodata_tag(action = nil)` (`application_helper.rb:1817-1821`) emits both `.nodata-message` and `.nodata-action`, styled at `:2575-2576`; but `application_helper.rb:541` still returns the bare message-only variant.

### Where sources disagree

- **Prose measure does not converge**: WCAG AAA 80, GOV.UK 75, USWDS 45–90 with 66 as target. Any single number is a convention, not a finding.
- **Page frame max-width spans 564px across five mature systems**: GOV.UK 1020, Primer 1280 (1232 visual), MoJ PDS 1280 (1170 content), [Atlassian fixed-wide 1296](https://atlassian.design/foundations/grid), [Carbon 1584](https://v10.carbondesignsystem.com/guidelines/2x-grid/implementation/). Carbon is 55% wider than GOV.UK. There is no consensus frame to inherit.
- **Units are routinely conflated.** USWDS emits measure in `ex`; this repo and most systems use `ch`; neither equals a rendered character. Measured for this repo's Inter: 0.6309 / 0.5459 / 0.4678em. The conversion is font-specific.
- **Constrain vs widen is unresolved between two mature vendors.** Primer and Atlassian argue a max width protects readability; GitHub's own users document that constraint failing on code review and GitHub shipped no fix; GitLab refused to pick a side and began flipping individual data-dense surfaces.
- **The annotated settings layout is prescribed and critiqued by the same vendor.** [Polaris specifies `columns={{ xs: "1fr", md: "2fr 5fr" }}`](https://github.com/Shopify/polaris/issues/7961), while [its own forum records the pattern degenerating into filler](https://github.com/Shopify/polaris-react/discussions/8217) — "maintaining the recommended 2-column layout feels extra redundant since there's not a lot of context needed for each section" — with the Polaris lead conceding "Patterns are defaults and strong recommendations... You and your team are always ultimately responsible."
- **The line-length literature itself is contested in a way design-system docs paper over** — the ~55–66cpl optimum is a comprehension/preference optimum, not a reading-throughput one. The primary source (Dyson & Haselgrove 2001) could not be opened, so no number is cited to it.
- **No source publishes an item count at which a flat nav must be grouped.** Primer is silent on counts; GitHub and Discourse both justified grouping without one.

### What applies here

- **Add one width primitive, following the `govuk-width-container` shape**: `--nx-frame` for the page frame, `--nx-measure` for prose. Apply as `#content { max-inline-size: var(--nx-frame); margin-inline: auto; }` with `--nx-frame: none` as the root default. Do not introduce a second competing container class.
- **Set the frame per surface via the existing body classes.** `body.controller-admin, body.controller-settings, body.controller-my { --nx-frame: 1280px; }`; leave it unset on `.controller-issues.action-index`, `.controller-repositories`, `.controller-gantts`, `.controller-timelog`, `.controller-versions`. This is GitLab's per-surface resolution and directly avoids GitHub #7096 on the surfaces that are Redmine's job.
- **Fix the measure, which is wrong by measurement.** Express in `em` so it tracks the element's own font-size: `--nx-measure: 35em` (~75 chars) or `31em` (~66). If 636px is wanted for the wiki, raise wiki prose to ~17px, which lands 636px at exactly 80 characters.
- **Group the 14 admin links in Ruby, not CSS.** Four sections is the natural cut (People: users/groups/roles; Issue configuration: trackers/issue_statuses/workflows/custom_fields/enumerations; System: settings/ldap_authentication/applications/plugins; Content: projects; plus info). Headings, never dividers.
- **Correct the premise before planning admin layout work**: the admin grid already exists at `:959`. Whatever narrowness was measured is a different surface or a stale reading. Spend the effort on grouping.
- **Replace the six hardcoded `#sidebar` media queries with Every Layout's Sidebar.** `#main` is already `display: flex; flex-direction: row-reverse`, so the diff is small, and it fixes the current behavior where the sidebar never yields.
- **Apply the Polaris 2fr/5fr split to `/settings` tab bodies ONLY where a real section description already exists in the i18n files.** Plain CSS grid on the existing `.tabular` markup. Where no description exists, keep the single column.
- **Finish the empty-state contract**: pass a permission-gated action at each remaining `nodata_tag` call site. Zero new markup, zero new CSS.
- **Frame `public/404.html` and other genuinely sparse pages** at `--nx-frame` with `margin-inline: auto` and give them the NN/g trio. It is 17 lines today and carries none of the three.

### What must be rejected here

- **Carbon's 1584px max grid.** The sparse-surface complaint is about composition, not box size. A bigger box makes an ungrouped 14-link admin page emptier.
- **GOV.UK's "always a two-thirds column" rule.** GOV.UK serves citizens reading prose once, at 19px. A blanket two-thirds column across `#content` reproduces GitHub #7096 on issue lists, diffs and the repository browser — the pages developers live in.
- **Polaris's annotated layout as a general prescription.** Redmine's settings labels are terse i18n strings with no descriptions; adopting it means inventing explanatory copy for ~100 fields (filler) or shipping a half-empty rail (the documented degradation).
- **USWDS's `ex`-based measure tokens.** Importing 60ex would give ~70 characters in Inter, correct only by accident. State the target in characters; implement in `em`.
- **GitLab's per-user Fixed/Fluid preference.** Needs a column, a migration, a preference control and a body-class hook to solve what per-surface CSS defaults solve for zero Ruby. Take the per-surface insight; leave the machinery.
- **Discourse's relocation of admin nav into a left sidebar.** Take the grouping; the move imports Discourse's own documented admin disorientation for no structural gain.
- **Primer's "wide ≥1400px = up to 3 columns."** Redmine does not have that width to spend — ~1104px of content region at 1440px. Designing three columns claims space that does not exist on the persona's monitor.
- **Citing SC 1.4.8 as a conformance target.** Setting `max-inline-size` earns no conformance claim. Use 80 glyphs as a ceiling heuristic.
- **Atlassian's "visual relationships break down at very large viewports" as evidence.** Keep the idea; refuse the citation weight — it is an unsupported vendor assertion with no measurement and no rollback behind it. Every documented failure in this set runs the other way.
- **Any runtime dependency for wide-viewport composition** — grid library, container-query polyfill. Every mechanism worth taking is plain CSS on the committed stack.

---

## 5. Delight in internal work tools — and what infuriates

### What the evidence supports

Documented decision: write restraint in as a **gate**, not a preamble. [Pajamas: "Animation should not be added without a good reason. Too much animation can distract a user and disrupt their task."](https://design.gitlab.com/product-foundations/animation-fundamentals/) [Atlassian's Clarity principle: "Motion is a clarifying layer, not decoration," and "It should never add friction to how quickly teams get work done."](https://atlassian.design/foundations/motion)

[Primer's three-category taxonomy — notification/feedback, editorial, design — is the tool that lets a sweep argue rather than assert](https://primer.style/accessibility/design-guidance/motion-and-animation/): "Motion in the design category is the most likely to cause harm without adding value." The same page sets hard thresholds: never exceed three flashes per second, stop animation after five seconds or provide controls, do not loop indefinitely without pause capability.

Motion must never be load-bearing: with reduced motion active the UI has to remain fully usable, so no state change may be communicated by movement alone.

Measured: **skeleton loaders are not polish.** [Viget, n=136 (39/39/58), identical load durations](https://www.viget.com/articles/a-bone-to-pick-with-skeleton-screens/): agreement it "loaded quickly" skeleton 59% / spinner 74% / blank 66%; mean perceived wait 2.82s / 2.41s / 2.29s; post-load task completion 10.54s / 9.49s / 9.50s. The authors self-describe it as "lean research."

Anecdote: the specific failure mode of delight in a daily driver is not bad taste. [In Asana's forum, four users over a year describe an animation that *blocks*](https://forum.asana.com/t/how-to-turn-off-childish-unicorns/578094): "causes my screen to freeze until the animals go across and I can't move to another screen to continue working", plus "infantilizing", plus multiple reports of celebrations still firing with both off-switches disabled. [The same feature is loved in another thread of the same forum](https://forum.asana.com/t/where-a-the-uniorns/963084) — so the design question is tiering and defaults, not whether personality exists.

Anecdote: budget for the thousandth viewing. [HN, this exact persona](https://hn.algolia.com/api/v1/items/32081528): "Animation is often cool: The first time I use it. After that, it becomes quite tiresome." And a nontrivial slice has already nuked all motion globally via `userContent.css` and reports "this doesn't break anything important."

Anecdote: [what gets hated in a server-rendered dev tool is polish that breaks browser primitives](https://lobste.rs/s/5qq2k2/why_is_github_ui_getting_so_much_slower) — in-page find ("i tried to ctrl-F some code, no hits... gh uses js to render only portions of the page"), scroll position, and the back button.

Expert opinion: [NN/g distinguishes surface delight ("local and contextual... largely isolated interface features") from deep delight, and warns "If your product or service lacks basic functionality and reliability, delightful features will likely fail to provide any sustainable benefit"](https://www.nngroup.com/articles/theory-user-delight/), with negativity bias meaning one irritating flourish outweighs several pleasant ones. Note its examples are Yelp and Unroll.me — no work-tool cases.

Documented decision: put personality in **copy**. [Mailchimp: "Don't go out of your way to make a joke—forced humor can be worse than none at all," and "it's always more important to be clear than entertaining."](https://styleguide.mailchimp.com/voice-and-tone/)

Documented decision: [Carbon ships per-row overflow menus **persistent by default**](https://carbondesignsystem.com/components/data-table/usage/) precisely so users know actions can be taken; hover/focus-only reveal is an opt-in to reduce clutter. *(Verified by search snippet — the page truncates through WebFetch.)*

### Where sources disagree

- **Skeleton screens**: Viget's controlled comparison found them worst on all three metrics; a widely-cited competing study claims the opposite "but not by much." Neither is large or replicated. The honest position is that no one has shown skeletons help — not that they are proven harmful.
- **Whether motion should exist at all in a daily driver.** Val Head reports no motion-sensitive interviewee wanted animation eliminated; HN developers in the target persona kill it all globally and report no loss. Both can be true.
- **The same delight feature is loved and hated by the same product's own users.** There is no defensible taste consensus to design toward, only defaults and controls.
- **Loading affordances**: Pajamas names skeleton loaders as its single legitimate exception to its restraint clause, and Primer classifies loading animation as legitimate feedback motion — while the only measurement suggests the skeleton form specifically does not deliver the benefit that justifies it.
- **Carbon offers both** persistent and hover-reveal row actions. This repo already picked the hover side in one place: `application.css:3108` sets `.mypage-box > .contextual { opacity: 0.001; transition: opacity 0.2s; }`. Defensible on a dashboard block; a discoverability regression if extended to issue rows.
- **Robinhood's confetti removal is the best-known rollback and the weakest citation in this set.** [The primary newsroom post confirms the replacement but states no rationale](https://robinhood.com/us/en/newsroom/a-new-way-to-celebrate-with-robinhood); the quoted "we just took out the distraction" line reached this research only through secondary coverage (CNBC returned HTTP 403). Context was a regulatory gamification complaint, not a usability study.

### What applies here

- **Sequencing correction, verified on HEAD:** two of the sweep's stated prerequisites already shipped in commit `069d9a860`. Status is encoded (`queries_helper.rb:295` + `application.css:1425`), priority is encoded (`:1426-1429`), and the named AA failure is fixed (`--nx-badge-open-ink` at `:152`). Do not use the NN/g "fix fundamentals first" argument to gate this sweep on work that is done.
- **Ship "delete transitions" as a first-class option in the animate phase**, citing GitLab !119801. The `table.issues` row hover at `:1559` is the candidate to test both ways.
- **Put the personality in ERB copy and locale strings, not motion.** Copy is free at runtime, needs no reduced-motion guard, is reversible in one commit, has zero latency cost, and Mailchimp supplies the restraint rule. It is the only delight channel that survives every constraint here.
- **Ship exactly one signature element and make it a moment of competence, not celebration.** The flash message already animating via `nx-flash-in` (`:4031-4034`) is the natural home — a flash is the system answering an action. Zero indefinite loops, nothing viewport-wide, nothing that delays the next click.
- **Write two hard prohibitions into the plan**, derived from the two strongest first-hand negatives: no animation may block, delay, or overlay the next action; and no JS enhancement may break Ctrl-F, scroll position, or the back button. The Propshaft/importmap/ERB stack honors both by default — the risk is only in what the sweep adds.
- **If any per-row action affordance is proposed for the issue list, ship it persistent**, citing Carbon. Keep the existing hover-reveal scoped to `.mypage-box`.

### What must be rejected here

- **Skeleton loaders anywhere.** Redmine is a fast server-rendered Rails app; full pages arrive at once and there is no streaming shell to skeleton. Pajamas' exception governs a heavily client-rendered SPA and does not transfer.
- **Celebration animations, confetti, or any completion flourish on closing an issue or logging time.** That is the highest-frequency success event in the product — the worst possible place for a moment that repeats thousands of times — and the Asana threads document this exact pattern being called infantilizing by the professional-tool persona.
- **A user-facing animation-intensity toggle on the Asana model.** Asana's tiering is right for a product that already shipped celebrations, but the same threads show its off-switch failing, and a Redmine preference column + settings row + migration is a far larger diff than not shipping the motion. `prefers-reduced-motion` is the free, already-committed control. If nothing ships that anyone would want to turn off, no toggle is needed.
- **Empty-state illustration or mascot craft.** There is no first-hand praise corpus to act on, and NN/g's branding-risk warning cuts directly against a mascot in a developer's issue tracker.
- **Shadow-driven hover lift on issue rows, justified as "using the unused shadow tokens."** The premise is false: `--nx-shadow-*` are applied at `application.css:932, 1085, 1114, 1237, 1867, 2636`, correctly scoped to overlays and popups. Animating elevation into a dense hairline table contradicts the committed no-card world and adds per-row paint cost on 100+ rows.
- **Parallax and scroll-linked motion of any kind.** Named as harmful by Primer's design category, by Val Head, and by [the WCAG issue that produced SC 2.3.3](https://github.com/w3c/wcag21/issues/18).
- **Anything that survives on the strength of SC 2.3.3's pause/stop mechanism.** It is AAA and landed there because there was insufficient research to set thresholds. Building a pause control for a flourish is strictly worse than not shipping the flourish; cite 2.3.3 as a reason to omit, never as a spec to build against.
- **Superhuman's speed-as-delight numbers.** Founder-interview marketing with no first-party engineering writeup. Rest the speed-is-the-delight argument on the GitLab MR and the Lobsters thread, which are real artifacts.
- **The Mailchimp "Freddie high-five removal backlash" story.** No primary source exists; treat as apocryphal.
- **Web Almanac's ~32% `prefers-reduced-motion` figure to size the affected audience.** That number is site-side authoring adoption of the media query, not the share of users who enable the setting.

---

## 6. Redmine's contract with plugins and themes

### What the evidence supports

Measured, in this fork: **any installed theme shipping `stylesheets/application.css` substitutes this fork's file by filename.** `app/helpers/application_helper.rb:1748-1762` overrides `stylesheet_link_tag` and maps every source through `current_theme.stylesheets.include?(source)`; `app/views/layouts/base.html.erb:11` passes `'jquery/jquery-ui-1.13.2', 'tribute-5.1.3', 'application', 'dropdown', 'responsive'` through that same call. [The theme wiki confirms the theme side is expected to `@import` the core path](https://www.redmine.org/projects/redmine/wiki/howto_create_a_custom_redmine_theme) — after which the theme's rules land on top at equal or higher specificity. The fork put 71 lines into `responsive.css`, 49 into `gantt.css`, 19 into `jstoolbar.css`.

Measured: **the published hook list is not the contract.** Trunk has 101 `call_hook` occurrences across app+lib, 87 distinct names, 66 call sites in `app/views`. [The wiki](https://www.redmine.org/projects/redmine/wiki/Hooks_List) lists `:view_issues_move_bottom` (0 occurrences in trunk), names `:view_journals_update_rjs_bottom` (renamed to `_js_bottom`), and omits roughly forty hooks trunk actually fires. It also publishes no stability or deprecation policy in either direction.

Measured: **the `#main.collapsiblesidebar` / `.nosidebar` class is driven by plugin output.** `application_helper.rb:1798-1804` defines `sidebar_content?` as `content_for?(:sidebar) || view_layouts_base_sidebar_hook_response.present?`; `base.html.erb:156-157` toggles the class and conditionally calls `collapsibleSidebar()`.

Measured: **the fork's widest-blast-radius change is Ruby-level.** `queries_helper.rb:285-297` injects a nested `<span class="badge badge-status-*">` into every status cell and an avatar `<img>` into every `assigned_to` cell inside `column_value` — six lines above the `helper_queries_column_content` hook at `:249`. Every query-driven list in every plugin now renders different markup inside `td.status` / `td.assigned_to`.

Measured: **the feared icon collision does not exist.** The redesign adds zero `.icon` / `.icon-*` selectors; its icons are `--nx-icon-*` data-URI masks plus rules on `svg.icon-svg`. `legacy-icons-compat.css` sits byte-identical upstream at 11454 bytes and is not referenced from any layout.

Measured: **the fork will not churn against upstream's logical-property migration** — 72 logical declarations added vs 1 physical, on top of 416 existing occurrences. [Redmine 7.0.0 replaced physical CSS properties with logical ones across core stylesheets](https://www.redmine.org/news/161). Plan for rule-body conflict inside `application.css`, not a syntax sweep.

Documented decision: when core deliberately breaks plugin-facing CSS, [the accepted resolution is an opt-in compatibility stylesheet plugins `@import` themselves](https://www.redmine.org/issues/43206) — neither reverting nor keeping the old rules in the main sheet.

Documented decision: [the SVG sprite is a Ruby-level contract with theme override and per-icon fallback to the core sprite](https://www.redmine.org/issues/43087), specifically so theme authors do not have to track core icon changes. Present in the fork at `lib/redmine/themes.rb:114`.

Expert opinion: [an unknown number of installed plugins reach past hooks by CSS/XPath selector at render time via Deface](https://jbbarth.com/posts/2015-05-24-redmine-plugins-hooking-anywhere-in-views.html), because "in most cases you will want to modify a Redmine view just a few lines before or after the existing hook" and a new hook is one "you will probably never get." That coupling is invisible to any grep of this repository.

Documented decision: [plugin `app/views` are prepended to the Rails view path and shadow core views wholesale with no merging](https://www.redmine.org/boards/2/topics/43977) — and two plugins overriding the same file is a known, unfixed silent failure.

Measured: **theme↔core selector coupling is dense and bidirectional.** [Opale styles plugin DOM combined with core structural selectors](https://raw.githubusercontent.com/gagnieray/opale/master/src/sass/components/_plugins.scss) — `#content > .contextual > span.heart-link-with-count`, `table.list th .desc::after`, `.controller-articles` with `#sidebar-wrapper`, `#global_banner .box`. Restyling `.contextual`, `table.list th`, `#content`, `#main` or `#sidebar-wrapper` breaks theme rules written for third-party plugins.

Anecdote: [a single core structural change to one form area killed PurpleMine2 outright](https://www.redmine.org/boards/2/topics/70680) — the maintainer archived it rather than migrate. Structural churn, not color churn, ends themes.

Anecdote: [the 6.0 Propshaft move produced widespread plugin image breakage from hardcoded asset paths](https://www.redmine.org/boards/2/topics/70794). The fork ships nine Inter woff2 files through the same resolution class.

Expert opinion: [for a fork whose divergence is one large commit, track upstream on a vanilla branch and rebase the local commit onto it](https://jkraemer.net/2016/03/deploy-and-maintain-redmine-the-right-way/), using `git rebase --onto` across majors.

Measured: **the current `!important` discipline is safe** — 9 added total, exactly one on a core structural selector (`#sidebar a.selected svg.icon-svg`).

### Where sources disagree

- **Can a theme override `responsive.css`?** [Defect #22861 is still open as "Needs feedback"](https://www.redmine.org/issues/22861), was not implemented, and its reasoning was that `responsive.css` loads after the theme stylesheet so it cannot be overridden. A direct read of this fork's trunk contradicts that: `application_helper.rb:1748-1762` substitutes any source name the theme carries, and `base.html.erb:11` passes `responsive` through the same call. **This is a code read against a stale issue and was not verified end-to-end.**
- **The wiki vs the tree.** Where they disagree, the tree wins — but note the wiki is what plugin authors read, so plugins may still be written against names the tree no longer fires.
- **How broadly did Redmine 6 replace tables with divs?** [Forum posters state it generally](https://www.redmine.org/boards/2/topics/70680); measured against trunk that is too broad — `table.list` and `tr.issue` still exist and the redesign adds 18 and 11 rules to them respectively. The change was confined to the query/filter form area (`#list-definition`, `#query_form_content`), exactly where the posted workaround selectors point.
- **Core's own position on breaking plugins is internally split and was resolved by neither side.** On #43206 Go MAEDA raised the breakage; Marius BĂLTEANU refused to carry the compatibility in core while offering an easier path. The outcome was an opt-in shim. Read as precedent, not a promise.
- **Whether a fork should edit core at all.** Barth and the theme-first guidance say customization belongs in a plugin or theme; jkraemer's workflow assumes you *will* carry local commits. This fork already committed to jkraemer's side (2243 changed lines in `application.css` plus ERB, helper and importmap changes), so theme-first is now advice about a road not taken.

### What applies here

- **Never delete or relocate a `call_hook` site.** Before touching any view, run `grep -n call_hook <file>`. Wrapping a hook call in a new container div is safe; moving it out of the element plugins expect it inside is not.
- **Preserve the sidebar contract exactly**: `sidebar_content?`, the class toggle at `base.html.erb:156`, and the conditional `collapsibleSidebar()` at `:157`. If the layout pass gives `#main` a max-inline-size or a grid, drive it off the existing class toggle.
- **Make the sweep additive at the class level.** Add `.nx-*` classes alongside core ones; do not rename or remove `#main`, `#sidebar`, `#content`, `#wrapper`, `table.list`, `tr.issue`, `.contextual`, `.box`, `.tabs`, `.attributes`, `.journal`, `.splitcontentleft/right`, `#query_form`, `#filters`, `#admin-menu`, `#list-definition`, `.nodata`, `#footer`.
- **Do not put load-bearing redesign work in `responsive.css`, `gantt.css`, `jstoolbar.css` or `dropdown.css`.** Consolidate anything the design depends on into `application.css`, which at least gets re-imported by well-behaved themes.
- **Audit `queries_helper.rb:285-297` during the colorize pass.** Scope new rules as `tr.issue td.status .badge` (already done at `:1425`) rather than styling `td.status` itself, so plugin rules keyed on the cell keep working.
- **Keep every new icon on the `sprite_icon` helper** (as the theme toggle already does) rather than inlining raw `<svg>` or new mask-image variables — going around it forfeits theme sprite override with per-icon fallback for no gain.
- **Hold the `!important` budget.** Fix specificity conflicts by adding a class, never by escalating on `#content` / `table.list` / `.contextual` — that forces every theme to escalate in turn, which is the PurpleMine2 failure mode.
- **Keep writing logical properties**, which removes an entire class of rebase conflict for free.
- **If a later pass restyles a plugin-depended selector beyond recognition, ship the escape hatch instead of reverting**: a small `nx-compat.css` plugins `@import`, mirroring `legacy-icons-compat.css`.
- **Style `.nodata` without assuming `.nodata-action` is present** — it is optional, and plugin-rendered empty lists will hit the same class with no action.
- **Adopt jkraemer's branch discipline now**, before the sweep adds more CSS, so the redesign replays on top of each upstream release rather than accumulating merge commits inside a 2243-line file.
- **Reference the nine Inter woff2 files only through Propshaft-resolved helpers**, never a hand-written `/assets/` or `/plugin_assets/` path.

### What must be rejected here

- **Building an icon compatibility shim or auditing against `legacy-icons-compat.css`.** Measured: zero `.icon` / `.icon-*` selectors added, and the file is not linked from the layout. There is no collision to fix.
- **Adding Deface as a dependency.** Barth recommends it to *plugin* authors as an alternative to whole-view overrides. This fork edits core views in place, so it has nothing to insert into.
- **Converting the redesign into a `themes/<name>/` directory to escape the substitution problem.** Themes can carry stylesheets, `javascripts/theme.js`, images and a favicon only. The redesign also changes `queries_helper.rb`, `application_helper.rb`, `base.html.erb`, `config/importmap.rb` and two locale files. Only half the work would fit, and splitting it creates two artifacts to keep in sync.
- **Shipping the fork's own `images/icons.svg`.** It buys no visual change and inherits exactly the burden the #43087 fallback was built to remove.
- **Adopting Opale's build toolchain (Grunt, SCSS, stylelint).** The obvious answer to a 2243-line CSS diff, and forbidden here — Propshaft plus plain CSS, no build step.
- **Implementing Barth's boot-time duplicate-view-override warning.** Good idea, still unimplemented after a decade, and aimed at plugin collisions this fork does not have (it edits nine files in place, +52/−10).
- **Restoring zebra striping, colored chrome or table borders "so plugin tables still look right."** `redmine_agile` ships 32 `table.list` and 28 `tr.issue` rules; Opale ships 162 more. The correct outcome is that plugin tables look different, not that the design retreats.
- **Migrating the CSS into `redmine_custom_css`.** That advice is for someone who has not yet forked. Moving half a design system into a database field makes none of it reviewable in git.
- **Treating the redmine.org Hooks List as the preservation checklist.** It would waste effort protecting a dead hook and leave real ones unguarded.
- **Citing Defect #41826 ("All themes except default broken") as proof core breaks themes.** It was closed as Invalid — an install/config problem. Its only honest use is as evidence that asset-pipeline moves generate a wave of false-alarm breakage reports.

---

## Open questions the research could not close

1. **Does the proposed fill/outline + glyph encoding actually beat hue-only badges on *this* product?** No instrumented time-to-locate test exists on a 30-row Redmine issue list. This is the single thing that would settle the christmas-tree line here, and it requires booting the demo container and measuring, not more reading.
2. **Whether a theme shipping `stylesheets/responsive.css` is genuinely substituted on 7.x.** The code read (`application_helper.rb:1748-1762` + `base.html.erb:11`) says yes; the still-open [Defect #22861](https://www.redmine.org/issues/22861) says no. Nobody booted a Redmine with such a theme installed. Verify before relying on either.
3. **Letter-spacing at 13–14px is a live three-way conflict with no explanation anywhere.** Carbon +0.0114em, Inter's own curve −0.0062em, Primer "never." The usual reconciliation (Primer rides OS fonts it does not control) is inference, not something any source states. A rendered A/B of the issue list at 12/13/14px with tracking at 0, +0.01em, and Inter's curve value — screenshotted at 1x and 2x on both themes, plus a 1.4.12 override pass — would close it.
4. **The dense-row line-height number.** Four credible sources span 1.0–1.5 for the same 13px cell. One measurement of rows-per-viewport at 1.35 vs 1.5 would settle it; none was taken.
5. **Whether row hover should be 90ms or 0.** Linear and Emil say remove; Primer, Carbon and Atlassian say keep it sub-100ms. No A/B with task-completion times on a dense list, with and without row-hover transitions, surfaced anywhere in this sweep.
6. **The real rendered content-region width and characters-per-line on `/admin`, `/settings` and a wiki page at 1440px and 2560px.** Every layout recommendation here is computed from CSS and font metrics, not observed in a browser.
7. **Whether the cv05 re-subset is worth doing.** Designsystemet.no recommends it in writing on accessibility grounds; the people who filed [rsms/inter#182](https://github.com/rsms/inter/issues/182) reject the same alternate for product UI. Both are primary, neither is taste-free, and the measured ambiguity (1.14px vs 1.21px of ink at 13px) does not adjudicate it.
8. **`ss04` could not be verified at all** — it does not appear in Inter's `feature_samples.yml`. Moot here (the subset has neither ss02 nor ss04), but any future claim about it is unsourced.
9. **No first-hand user thread about hover-reveal row actions in a dense work tool was found** — the most tempting density move in this sweep is supported only by vendor guidance (Carbon), and that line itself is verified by search snippet rather than a full page read.
10. **Skeleton screens remain formally unsettled** (Viget vs a competing study, neither large nor replicated). Moot, since they are rejected on stack grounds anyway, but do not cite Viget as settled.
11. **The line-length literature's scan-vs-read distinction is unresolved.** The primary source (Dyson & Haselgrove 2001) could not be opened; the widely-cited ~55–66cpl optimum is a comprehension/preference figure, not a throughput one. For a developer scanning an issue list rather than reading prose, that distinction matters and no number can honestly be attached to it.
12. **No grouping threshold exists in any published source.** Grouping Redmine's 14 admin links rests entirely on precedent (GitHub, Discourse), not on a cited count.
13. **Two motion citations could not be read at their source**: Apple HIG's Motion/Reduce Motion page is fully JS-rendered and the Wayback capture contains only the shell; Robinhood's stated rationale reached this research only through secondary coverage after CNBC returned HTTP 403. The "tighten, don't remove" position rests on the spec, MDN, web.dev and Emil instead.
14. **Plugin selector counts were measured against free GitHub mirrors**, not current commercial RedmineUP builds. The blast-radius estimate for `queries_helper.rb:285-297` is therefore a floor, not a ceiling.