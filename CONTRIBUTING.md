# Welcome to the ODERSO contribution guide

Thank you for your interest in helping improve this Template!

## Contribute by Creating an Issue

If you found a bug or have an idea for a feature, don't hesitate and [create an issue](https://github.com/dhbw-typst/oderso-template-dev/issues/new)!

Even if you don't have the time or capability to contribute code directly, opening an issue helps draw attention of maintainers to the problem or idea.

## Contribute by Making Code Changes

Helping us close an issue helps us even more!
Filter for [good first issue](https://github.com/dhbw-typst/oderso-template-dev/issues?q=is%3Aissue%20state%3Aopen%20label%3A%22good%20first%20issue%22) if you want to solve an easy or small problem, but contributions for other issues are welcome as well.
Or you can create a new issue if you already have in mind what you want to work on.

Please comment on an issue you want to work on, before starting. This prevents a maintainer from picking up an issue you are already working on.

The [setup guide](https://github.com/dhbw-typst/oderso-template-dev#️-setup) should contain everything you need to get started. See [Code Formatting](#code-formatting) and [Pull Requests](#pull-requests) for more information about how we format our code and what to keep in mind when creating a pull request.

## Contribute a new Adapter

Currently, the template contains university adapters for the DHBW Karlsruhe and Mannheim and the IHK. If you are from a different university, creating an adapter for your university could be a great way to contribute, as it makes the template available to more students.

Feel free to open an issue, and we are happy to assist you with the implementation.

## Code Formatting

We are using [Typestyle](https://github.com/typstyle-rs/typstyle) to ensure consistent formatting of Typst source code. Please make sure to format your code with `typstyle -i .` to make the pipeline pass.

## Pull Requests

Pull requests should contain a concise title and the description should detail the changes made. Additionally, the title needs to be prefixed with either `chore:`, `fix:`, `feat:` or `feat!:`.
These prefixes are used by our release pipeline to determine the next version bump. As this project is following [Semantic Versioning](https://semver.org/), the prefixes should be used as follows:

- `chore`: (_No version bump_) Should be used for changes to `README`, documentation and typo fixes.
- `fix`: (_Patch bump_) Should be used when fixing an issue that has no effect on the API. Must be forward and backwards compatible.
- `feat`: (_Minor bump_) Should be used when adding a new parameter or function, or when changing the look or behavior of the template. Must be backwards compatible.
- `feat!`: (_Major bump_) Should be used for major changes to the look of the template or when making changes that are not backwards compatible.

Add the correct prefix to your PR title (e.g., `fix: <PR title>`). If you are unsure, let us know in your PR description.