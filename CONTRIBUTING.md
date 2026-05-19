# Contributing to Forge Kit

Hi there! We're thrilled that you'd like to contribute to Forge Kit. Contributions to this project are released to the public under the MIT open source license.

## Prerequisites for running and testing code

1. Install [Python 3.11+](https://www.python.org/downloads/)
1. Install [uv](https://docs.astral.sh/uv/)
1. Install [Git](https://git-scm.com/downloads)

## Submitting a pull request

1. Fork and clone the repository
1. Configure and install the dependencies: `uv sync --extra test`
1. Make sure the CLI works on your machine: `uv run forge --help`
1. Create a new branch: `git checkout -b my-branch-name`
1. Make your change, add tests, and make sure everything still works
1. Test the CLI functionality with a sample project if relevant
1. Push to your fork and submit a pull request
1. Wait for your pull request to be reviewed and merged.

## Resources

- [FORGE Methodology](./forge-methodology.md)
- [How to Contribute to Open Source](https://opensource.guide/how-to-contribute/)
- [GitHub Help](https://help.github.com)
