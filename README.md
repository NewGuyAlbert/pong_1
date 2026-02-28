# Pong

A classic Pong game built with [Godot 4](https://godotengine.org/).
This project is for personal learning.

## TODOs

- Check for inconsistent solutions across project.
- Ball can be squeezed in the corner bug.
- Update ball hit logic. Different parts of the paddle should change the return angle of the ball.
- Update winning text. Write somewhere about how to restart, pressing r or esc.
- Add sounds for button hovers and clicks. Make menu interactible with arrow keys and Enter key.
- Make the game work for multiple screen sizes. Also some pixel values are hardcoded. Implement settings menu.
- Add AI opponent. (easy, medium, hard)
    medium - Calculates the current y axis of the ball and takes shot angle into consideration.
    hard - Calculates the current y axis of the ball, takes shot angle into consideration and potential wall hits.
    Misc: Add impossible difficulty that gets unlocked after beating hard. Make that actually not possible to beat. Add reaction delay to logic. Add error margin in the calculation that is random.
- Make it playable with controllers. (On most of the main platforms eg: Windows, Linux, Mac)

## Setup

How to export the game:
WIP

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
