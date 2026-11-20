# Apex for Gutter

Colors Apex (`.cls`, `.trigger`, `.apex`) in Gutter's editor, and runs Salesforce's Apex language server for hover docs and go to definition.

What it colors:

- Case-insensitive keywords, including `with sharing`, `without sharing`, `inherited sharing`, `trigger … on`, and the DML keywords (`insert`, `update`, `upsert`, `delete`, `undelete`, `merge`)
- Strings, `//` and `/* */` comments, numbers, annotations, and `System`-style built-in types
- SOQL and SOSL inside `[ … ]`, with their keywords and bind variables (`:name`)

## Add it

1. Open Settings > Extensions.
2. Choose **Add development folder…** and pick this repository's folder.
3. After editing `grammars/apex.json`, choose **Reload extensions** to see the change.

Once it's published, install it from Settings > Extensions > Browse instead.

## Check it

The grammar is CodeMirror's simple mode written as JSON. From a checkout of Gutter, run:

```sh
npm run check-extension -- path/to/gutter-apex
```

It validates `gutter-extension.json`, compiles the grammar and fails if any rule is skipped, colors every file in `samples/`, runs the expectations in `tests/apex.json` (each case lists `[token, text]` pairs the parse must have or lack, with token names as the parser reports them, such as `typeName` for a `type` rule), and checks what `npm pack` would publish. Add a case to `tests/apex.json` when you fix something, so it stays fixed.

## The language server

Hover docs (ApexDoc) and Ctrl+click / Cmd+click to a definition come from Salesforce's `apex-jorje-lsp.jar`. Gutter starts it with the same arguments Salesforce's VS Code extension uses (`languageServer.ts` in `forcedotcom/salesforcedx-vscode`): `java -cp <jar> -Xmx<limit> -Ddebug.internal.errors=true -Ddebug.semantic.errors=false -Ddebug.completion.statistics=false -Dlwc.typegeneration.disabled=true apex.jorje.lsp.ApexLanguageServerLauncher`, in the nearest folder holding `sfdx-project.json`.

**Needs:**

- **Java.** Gutter doesn't install it. Use a JDK Salesforce supports for its Apex extension (Java 11, 17, or 21 at the time of writing; check the Salesforce Extension Pack's requirements). Put `java` on `PATH`, or set **Java** in Settings > Extensions > Apex to the full path of `java`.
- **The jar.** It isn't in this folder, and Gutter can't download it. Get `apex-jorje-lsp.jar` from the Salesforce Extension Pack: install the "Salesforce Apex" extension (`salesforce.salesforcedx-vscode-apex`) in VS Code, or download its `.vsix` from the Marketplace, rename it to `.zip`, and take `extension/dist/apex-jorje-lsp.jar`. Check the license allows your use before you copy it.
- **Where it goes.** Put the jar in `server/` in this folder (`server/apex-jorje-lsp.jar`, which is the default and is ignored by git), or put it anywhere and set **apex-jorje-lsp.jar** in Settings > Extensions > Apex to its path. Until one of them exists, opening an Apex file says "Set apex-jorje-lsp.jar in Settings > Extensions > Apex".
- **Memory.** **Server memory limit** is the Java heap, `1g` by default.

What Gutter doesn't send, because it only uses hover and definitions: no completion, diagnostics, or semantic errors (`enableSemanticErrors` stays off), and no embedded SOQL completion. The server may still write its own working files into the project (Salesforce's tools use `.sfdx/`); add that folder to the project's `.gitignore` so it never shows in Changes.

## Known gaps

Notes on anything colored wrong in real files go here. Known from the design:

- A query is recognized only when `[` is followed by `SELECT` or `FIND`, so a query that starts on the next line after `[` is colored as Apex.
- SOQL field names, objects, and functions are colored as plain names; only keywords, bind variables, dates, strings, and numbers are marked.
- Nested brackets inside a query, such as a bind expression like `:list[0]`, end the query early.

## Publishing

The jar ships in the package only after you've checked its license allows redistribution: put it in `server/` and publish (`package.json`'s `files` lists `server`). Until then the package has no jar and each user places one.

`package.json` uses the placeholder scope `@your-scope`. To publish, swap in your own scope, add a `repository` field pointing at this repository's remote, run `npm run check-extension` on it from Gutter, and run `npm publish --access public` from this folder; keep `version` the same in `package.json` and `gutter-extension.json`. The `gutter-extension` keyword is what lists it in Gutter's Browse tab. Then add your scope under Browse > Trusted publishers.
