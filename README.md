<img src="template/banner.jpeg" width="100%" />

# ODERSO Typst Template (Dev)

Hello and welcome to the **development repository** of the Typst template. It is **awesome** to see you want to improve the template!

>[!WARNING]
> If you just want to start writing your thesis, this is not the correct repository. Use the [user repository](https://github.com/dhbw-typst/oderso-template) instead.


## 💡 Feedback

**Anything Missing?** Please [create an issue](https://github.com/dhbw-typst/oderso-template-dev/issues/new) or open a Pull Request right away.

## 🤝 Contribute

1. Pick an issue you want to work or create an issue you want to work on yourself.
2. Follow [setup guide](#️-setup) for your local development environment.
3. Make sure to format your changes with `typstyle . -i` before committing.

This project is using [get-next-version](https://github.com/thenativeweb/get-next-version) for automatic releases.
New releases are automatically created for commits on main. The version is determined by the commits prefix:

- `chore`: No release
- `fix`: Patch version bump
- `feat`: Minor version bump
- `feat!`: Major version bump

Add the correct prefix to your PR title and make sure it is included when merging.

## 🛠️ Setup

>[!TIP]
>This guide assumes **basic familiarity with Git, GitHub, and Typst**.

1. Create a fork of the `oderso-template-dev` repository
2. Clone the created repository to your local machine
3. Navigate to the cloned repository
4. Setup your dev environment
   1. [manually](#manual-setup): choose, when you don't know what the other two options are
   2. [dev containers](#devcontainer)
   3. [nix](#nix-shell)

#### Manual

1. Install [Typst](https://github.com/typst/typst)
    ```shell
    brew install typst
    ```
2. Install [Typstyle](https://typstyle-rs.github.io/typstyle/)
    ```shell
    brew install typstyle
    ```

#### Dev container

[Dev containers](https://code.visualstudio.com/docs/devcontainers/containers) allow you to work in an isolated development environment with all dependencies installed using Docker and pair well with VSCode.

Ensure that you have a running Docker installation. This setup was tested with [Colima](https://github.com/abiosoft/colima), a compliant Docker runtime. [Docker desktop (_license required_)](https://www.docker.com/products/docker-desktop/) or [Podman](https://podman.io/) should also work.

For an ergonomic VSCode-based setup, install the [Dev Container Extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers), open the command palette (<kbd>CMD</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd>) and run the command `Dev Containers: Reopen in Container`.

To change the LTeX+ spell checker language from default English to German navigate to `.devcontainer/devcontainer.json` and change `"ltex.language": "de-DE",`

#### Nix shell

[Nix shells](https://nixos.wiki/wiki/Development_environment_with_nix-shell) allow you to create a temporary shell with all dependencies installed.

Run `nix develop --command $SHELL` or `direnv allow` depending on your setup. From inside the resulting shell run `code .` to start VSCode with the installed dependencies.
