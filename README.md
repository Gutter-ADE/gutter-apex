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
- **The jar.** Gutter downloads it for you. Installing this extension from Browse shows a confirmation naming the download, and installing runs it. For a development folder, use **Install server** on the Apex row in Settings > Extensions. Until it's installed, opening an Apex file says the server isn't installed. The download comes from Salesforce's own repository, pinned to one commit (`5a804a9`, October 2026) and checked against its SHA-256, and goes to Gutter's data folder, not into this folder. **Reinstall server** on the same row downloads it again.
- **Your own jar.** Set **apex-jorje-lsp.jar** in Settings > Extensions > Apex to a jar's path (**Browse…** picks one) to use it instead, such as a newer one from the Salesforce Extension Pack. Gutter then starts that jar whether or not the server is installed. Clear the setting to go back to the downloaded one.
- **Memory.** **Server memory limit** is the Java heap, `1g` by default.

**The jar's license.** `apex-jorje-lsp.jar` is Salesforce's. It sits in `packages/salesforcedx-vscode-apex/jars/` of [forcedotcom/salesforcedx-vscode](https://github.com/forcedotcom/salesforcedx-vscode), whose `LICENSE.txt` is the BSD 3-Clause license (Copyright (c) Salesforce.com, inc.). It also bundles third-party libraries (among them Guava, Guice, LSP4J, Xtend, Logback, ANTLR, SnakeYAML), whose license files are inside the jar under `META-INF/`. This extension doesn't redistribute the jar: the package holds no copy, and Gutter downloads it from Salesforce's repository. This extension isn't made or endorsed by Salesforce.

**Updating the pinned jar.** Find the newest commit that changed the jar (`gh api "repos/forcedotcom/salesforcedx-vscode/commits?path=packages/salesforcedx-vscode-apex/jars/apex-jorje-lsp.jar&sha=develop&per_page=1"`), put that commit in the `url` in `gutter-extension.json`, download the file from that URL, and set `sha256` to its hash (`certutil -hashfile apex-jorje-lsp.jar SHA256` on Windows, `shasum -a 256 apex-jorje-lsp.jar` elsewhere). Changing the step makes Gutter offer **Reinstall server** to everyone who has it installed.

What Gutter doesn't send, because it only uses hover and definitions: no completion, diagnostics, or semantic errors (`enableSemanticErrors` stays off), and no embedded SOQL completion. The server may still write its own working files into the project (Salesforce's tools use `.sfdx/`); add that folder to the project's `.gitignore` so it never shows in Changes.

## Known gaps

Notes on anything colored wrong in real files go here. Known from the design:

- A query is recognized only when `[` is followed by `SELECT` or `FIND`, so a query that starts on the next line after `[` is colored as Apex.
- SOQL field names, objects, and functions are colored as plain names; only keywords, bind variables, dates, strings, and numbers are marked.
- Nested brackets inside a query, such as a bind expression like `:list[0]`, end the query early.

## Publishing

`package.json` uses the placeholder scope `@your-scope`. To publish, swap in your own scope, add a `repository` field pointing at this repository's remote, run `npm run check-extension` on it from Gutter, and run `npm publish --access public` from this folder; keep `version` the same in `package.json` and `gutter-extension.json`. The `gutter-extension` keyword is what lists it in Gutter's Browse tab. Then add your scope under Browse > Trusted publishers.
