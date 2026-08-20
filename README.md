<img alt="Banner showing some features of this template" src="https://raw.githubusercontent.com/dhbw-typst/oderso-template-dev/c81d3f24e453e59ed817c8bfc42fd6fffc448581/banner.jpeg" width="100%" />

# ODERSO Typst Template (Dev)

Hello and welcome to the **development repository** of the Typst template. It is **awesome** to see you want to improve the template!

>[!WARNING]
> If you just want to start writing your thesis, this is not the correct repository. Use the [user repository](https://github.com/dhbw-typst/oderso-template) instead.


## 💡 Feedback

**Anything Missing?** Please [create an issue](https://github.com/dhbw-typst/oderso-template-dev/issues/new) or open a Pull Request right away.

## 🤝 Contribute

We welcome new contributors! Please take a look at [good first issues](https://github.com/dhbw-typst/oderso-template-dev/contribute) or our [contribution guide](CONTRIBUTING.md) for more information on how to help!

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

## Customization Architecture

### Document Components

```
- coversheet
- frontmatter (postion < 0)
    - frontbackmatter-header
    - frontbackmatter-footer
- body
    - body-header
    - body-footer
- backmatter (postion >= 0)
- appendix
    - appendix-toc
    - appendix-header
    - appendix-footer

frontbackmatter:
    - toc (base)
    - acknowledgements (base)
    - abstracts (base)
    - figure-listings (base)
```

1. Base
    Defaults for base frontbackmatter component positions, despite that no defaults (using typst defaults, no headers, footers, coversheet)
2. Theme
    Sets defaults (and producers) for relevant general, component and frontbackmatter components. Expects following layers to configer semantic information (e.g. provide a title if required by a theme). Provides producers for institution components if they differ between themes.
3. Institution
    Configures metadata and adjusts configurations to be institution compliant. Provides producers for institution components if they are the same for all themes.
4. Customization
    Allows the user to override values of previous layers

```typ
#show: project.with(
    // Specify theme
    theme.oderso(),
    // Specify institution
    institution.dhbw-ka(
        authors: (
            (
                name: "Marvin Fuchs",
            ),
            ...
        )
    ),
    // Specify general front/backmatter
    frontbackmatter.acknowledgements(
        text: [
            Thanks to my mom!
        ],
    ),
    // Institution specific front/backmatter
    frontbackmatter.dhbw-ka.ai-declaration(
        ...
    )
    // component specific configuration
    component.frontmatter.header(
        ...
    )
    // configuration regarding the complete document (e.g. special features like book-mode or watermark, layout, typography)
    general.book-mode(
        ...
    )
)
```