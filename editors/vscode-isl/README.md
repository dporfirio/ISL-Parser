# ISL Syntax Highlighting

This is a lightweight VS Code extension for `.isl` files used by ISL Parser.

## Load It Locally

From this repository root:

```sh
code --extensionDevelopmentPath=editors/vscode-isl .
```

Then open any `.isl` file.

## Install It Locally

Copy or symlink this folder into your VS Code extensions directory:

```sh
mkdir -p ~/.vscode/extensions
ln -s "$(pwd)/editors/vscode-isl" ~/.vscode/extensions/isl-syntax
```

Restart VS Code and open a `.isl` file.

## What It Highlights

- ISL sections: `import`, `labels`, `module`, `options`, and matching end markers
- Declarations: `action`, `predicate`, `params`, `st`, `guard`
- Constants: `init`, `SUCCESS`, `FAILURE`, `DEFAULT`, `conditional_effects`
- Comments beginning with `#`
- Transitions, guards, numbers, labels, identifiers, and punctuation
