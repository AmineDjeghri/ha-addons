# AIOStreams: configs, templates, variants, sharing

For authoring or publishing an AIOStreams template — "make a template", "let others use my config",
"parent config", "share my setup". This is upstream AIOStreams' own config-sharing feature, not this
add-on's packaging.

## Start from these facts

- The add-on's `bootstrap.js` maps options onto `BASE_URL`, `SECRET_KEY`, `AIOSTREAMS_AUTH`,
  `AIOSTREAMS_AUTH_REQUIRED`, `LOG_LEVEL` only — no template-hosting env var, so instance-level
  templates (served from the add-on itself) need a new add-on option first; publishing a template as
  a standalone file (the common case) needs none of that.
- **Base a template on what the UI itself built** (the v2.34+ create-template/share flow) whenever a
  user hands one over — that output is current-schema and already strips `services[].credentials` to
  `{}`. When handed a plain **config export** instead, check `services[].credentials` first: `{}`
  everywhere means it was exported with *Exclude Credentials*; anything non-empty means it wasn't.
- Authoring ground truth is upstream's own docs (`docs.aiostreams.viren070.me/reference/templates`,
  `guides/config-profiles`, the version changelogs) — third-party install guides only describe
  *importing* someone else's published template, never the authoring format itself.
- Don't rebuild a template from an old pre-2.32 export: those carry a singular
  `formatter.definition`, not the current `formatter.definitions` map — porting the old shape into a
  new template silently ships stale formatter config.

## The mechanism, in one block

- **Config export** = the whole state of one configuration, importable as a unit (backup / transfer
  to another install). **Template** = `metadata` + a *partial* `config`, applied at setup ("Use a
  Template" → import from file or URL). Same JSON body — a template is an export wrapped in
  `metadata`, with the personal bits parameterized. Field/input/expression tables:
  `references/aiostreams-template-format.md`.
- **Variant** (v2.33+) = a CEL script inside one config, selected per install URL (`/v/<id>/`).
  **Parent/child config** = a second config inheriting a parent UUID, with its own password and
  credentials. Pick by use case: distribution → template; a one-line per-device/per-person
  difference → variant; someone needs a genuinely editable config of their own → parent/child.
- Credentials never ship in a template: declare `metadata.services` (+ `serviceRequired`) so the
  import flow prompts for them, and reference `{{services.<id>.<key>}}` where a preset needs a key.

## Procedure: config → shareable template

1. **Scope the whole setup, not just the service wiring.** The formatter, filters, and sort order
   are usually the thing worth sharing — what changes for a template is the service wiring and
   personal strings, not the tuning.
2. **Convert by hand with a throwaway pass, not a maintained script** — the schema moves across
   versions, and an automated "looks clean" check whose credential-detection misses a key hiding
   inside an addon URL is worse than no check at all (it certifies a leaking file). Move the config
   body under `config:`, add a `metadata` block (`name`, `description`, `author`, `category`
   required; `id` namespaced `author.my-template`; `source: external`; `version`; inline
   `changelog`; `sourceUrl`), drop the per-user `trusted` flag. Print the written file's URL list,
   config-key count, and any non-empty credential field, and review that summary rather than the
   raw JSON.
3. **Make it service-agnostic** — this is the actual point of a template, and an export does not do
   it for you:
   - top-level `services`: one `{"__if": "services.<id>", "id": "<id>", "enabled": true,
     "credentials": {}}` entry per selectable debrid service; a service the user never picked simply
     drops out;
   - `metadata.services` lists those ids, with `serviceRequired: false` so the wizard offers a
     **Skip** button for P2P-only users;
   - every preset that hardcoded a specific service-id list becomes `"services": "{{services}}"`.
4. **De-personalize what's left**: `addonDescription` (an export copied from someone's live instance
   carries their blurb/URL — replace with generic text), every addon `manifestUrl` not on a generic
   keep-list, TMDB/indexer keys → `inputs.*`, `<template_placeholder>`, `__if`, `__switch`, or
   `__remove`. Report the pruned catalog entries and placeholdered URLs before publishing rather than
   deciding unilaterally what to keep.
5. **Test on a throwaway configuration**: import the file and confirm every field the template left
   blank is flagged as an unfilled placeholder. Static checks can't exercise `{{...}}` or `__if` —
   an import is the only real proof.
6. **Publish, cheapest route first**: (a) raw JSON in a repo, plus the deep link
   `?template=<raw-url>` and `metadata.sourceUrl` for auto-update — point `sourceUrl` at the
   **main**-branch raw URL, not a feature-branch URL used only for testing; (b) an instance-level
   `templates/` dir or `TEMPLATE_URLS` (needs the add-on option from step 1); (c) v2.34+'s in-UI
   Community share (own-instance only, with admin moderation and federation via a public instance's
   `/community/export.json`).

## Pitfalls

- `{{services}}` as a whole string value resolves to the array of selected service ids (arrays
  spread into a parent array). Per-service refs exist for credentials only
  (`{{services.<id>.<key>}}`) — there's no `{{services.<id>}}` boolean form for an `enabled` flag.
- Importing a template creates a NEW configuration and leaves an existing one untouched — safe to
  test immediately after publishing.
- **Placeholder credentials, API keys, and addon passwords only** — leave addon URLs, regex
  patterns, variant scripts, and every other free-text field as written, but read every one for
  anything personal before publishing. A key can hide **percent-encoded inside a custom addon's
  URL** (some addons embed their whole config in the URL) — an `"apiKey"`-style grep finds nothing
  there; decode every `manifestUrl` and judge it. When a key is found this way, the fix is rotating
  it at the provider — scrubbing the file alone isn't enough. An account-bound URL with no key at
  all (a per-user list URL, a personal UUID) is still personal data — placeholder it too.
- **Placeholdering an addon leaves its `catalogModifications` entries behind, and those must go
  too.** Their ids can embed the source config's addon instance ids or a list owner's username —
  prune the entries whose `addonName` was placeholdered; generic-id entries keep working for
  whoever adds their own URL.
- `metadata.version` + a changelog (`changelog`, or a remote `changelogUrl`) drives the importer's
  "update available" notice — omit both for a one-shot template (version defaults to `1.0.0`).
- Conditions under `__if`/`__switch` understand `inputs.<id>` and `services[.<id>]` with `!`, `==`,
  `!=`, `includes`, numeric compares, and `and`/`xor`/`or` — not a general expression language.
- Bare `services` is the debrid-vs-P2P switch (truthy once any service is selected); `services: []`
  skips the service screen entirely.
- Variants are per-config (limits apply: e.g. several per config, a combined-per-request cap, a
  character cap, an access-level setting) and are **not** inherited from a parent config — they name
  that config's own addon instance ids and saved formatters.
- A deep-linked template shows the importer a trust warning — always say plainly which source is
  being imported from.

## Linked Files

- `references/aiostreams-template-format.md` — the metadata/input/condition tables, the JSON
  skeleton, and the sharing routes in full.
