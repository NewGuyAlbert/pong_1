# Pong

A classic Pong game built with [Godot 4](https://godotengine.org/).
This project is for personal learning.

## Setup

How to export the game:

1. Open the project in Godot 4.
2. Go to **Project → Export...**.
3. The **Windows Desktop** preset is already configured.
4. Click **Export Project...**, choose a location, and save.
   - Check **Export as ZIP** for a compressed archive, or uncheck it for a standalone `.exe` + `.pck`.
5. To run, extract the ZIP (if applicable) and launch the `.exe`.

> **Note:** You need the [Godot export templates](https://docs.godotengine.org/en/stable/tutorials/export/exporting_projects.html#export-templates) installed. Godot will prompt you to download them if missing (**Editor → Manage Export Templates → Download and Install**).

## Publishing to itch.io

Builds are uploaded using [butler](https://itch.io/docs/butler/), itch.io's command-line tool.
<https://newguyalbert.itch.io/pong-1>

### First-time setup

1. Download butler from <https://itch.io/docs/butler/>
2. Log in once:

   ```sh
   butler login
   ```

### Pushing a build

```sh
butler push <path-to-export-zip> <itchio-user>/<game-slug>:<channel>
```

For example:

```sh
butler push exports/pong_windows.zip myuser/pong-1:windows
```

Subsequent pushes to the same channel only upload the diff, so updates are fast.

### Useful commands

```sh
butler status <itchio-user>/<game-slug>            # List all channels and versions
butler unpush <itchio-user>/<game-slug>:<channel>   # Remove a channel entirely
```

### VS Code (optional)

1. Install the [Godot Tools](https://marketplace.visualstudio.com/items?itemName=geequlim.godot-tools) extension.
2. Go to **Settings** → search for **Godot Tools › Editor Path** and set it to the path of your Godot 4 executable.

### Formatting (optional)

Install [gdtoolkit](https://github.com/Scony/godot-gdscript-toolkit) for GDScript formatting and linting:

```sh
pip install gdtoolkit
```

Format all files from the project root:

```sh
gdformat .
```

To format automatically in VS Code, install the [GDScript Formatter & Linter](https://marketplace.visualstudio.com/items?itemName=eddiedover.gdscript-formatter-linter) extension.

## License

See [LICENSE](LICENSE) for details.
