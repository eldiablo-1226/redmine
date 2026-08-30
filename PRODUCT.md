# Product

<!-- impeccable:product-schema 1 -->

## Platform

web

## Users

Primary: developers on the owner's team, using the instance as a daily driver — issue lists, filters, saved queries, time logging, repository and activity views. They live in dense list and detail screens all day, so scanning speed and information density matter more than decoration.

Other audiences (managers, non-technical staff, external clients) are not confirmed for this instance and must not be assumed.

## Product Purpose

A self-hosted fork of Redmine (7.0.1-devel trunk, remote `eldiablo-1226/redmine`) run as the team's own project-management instance. Success is the team tracking work in it without friction, with a UI the owner considers worth looking at — UI quality is an explicit goal of this fork, not an afterthought.

## Positioning

Redmine's own mechanism is preserved: self-hosted, plugin-extensible, no per-seat vendor, full data ownership, one instance covering issues, wiki, repositories, time tracking and forums. The fork's differentiator is that this stock functionality gets a modern, deliberately designed interface instead of the default Redmine chrome.

## Operating Context

- Rails 8.1 app, Ruby >= 3.3; asset pipeline is Propshaft + importmap-rails + stimulus-rails.
- Styles live in `app/assets/stylesheets/` (`application.css`, `responsive.css`, `context_menu.css`, `dropdown.css`, `gantt.css`, `scm.css`, `open-color.css`, `legacy-icons-compat.css`); layouts in `app/views/layouts/` (`base.html.erb`, `admin.html.erb`, `_file.html.erb`, mailer layouts).
- Current incumbent visual system: open-color CSS custom properties, Noto Sans self-hosted woff2, `body { min-inline-size: 900px }` with a separate `responsive.css`, SVG icon sprite served by `svg_icons_controller`.
- Roughly 50 surfaces backed by controllers: issues, projects, gantt, calendar, activity, wiki, boards, news, documents, files, repositories, time logging, search, my page, and a large admin section.
- Working copy tracks upstream trunk; no local commits yet, no `config/database.yml`, so the app is not runnable in this checkout as-is.

## Capabilities and Constraints

- Full stock Redmine feature set is in scope and must keep working; no functionality is being dropped as part of UI work.
- i18n: 50 locale files ship with the app. Text comes from locale files, so new UI must not hardcode strings.
- Third-party plugins and themes hook into Redmine DOM ids, class names and view hooks.
- **Undecided (user stated no preference):** whether upstream mergeability, plugin/theme compatibility, and i18n/RTL layout robustness are hard constraints on UI work. Treat them as open until the owner rules; do not silently promote them to requirements or silently break them.
- Deployment target, hosting, and instance URL: not established.

## Brand Commitments

The owner pinned a binding visual reference for the planned UI overhaul: **Notion's design language**, captured as a token document at `.impeccable/references/DESIGN-notion.md` (copied from `~/Downloads/DESIGN-notion.md`). It defines colors, type scale, radii, spacing and component chrome. Future visual work honors this reference; it is the user's brief, not a suggestion.

No other brand assets, logo, name change, or voice guidelines exist. The product keeps the Redmine name and GPL v2 licensing.

## Evidence on Hand

- Real codebase and real screens: the running Redmine UI is the incumbent evidence and the anti-reference for the redesign.
- `.impeccable/references/DESIGN-notion.md` — the pinned aesthetic reference.
- No customers, testimonials, benchmarks, pricing, or case studies exist for this instance. Do not invent any.

## Product Principles

1. Developers scanning dense lists are the design target; density and scan speed outrank ornament.
2. Every stock Redmine capability survives the redesign — this is a re-skin of a working tool, not a feature edit.
3. The pinned Notion reference governs the visual world; deviations need the owner's word.
4. Copy comes from locale files; nothing new gets hardcoded into views.
5. Constraints the owner has not ruled on (upstream merge, plugin compat, RTL) stay explicit open questions rather than assumed answers.
