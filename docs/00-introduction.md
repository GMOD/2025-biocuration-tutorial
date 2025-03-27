# Introduction

This tutorial will cover setting up and running Apollo on a Linux server. We use
Ubuntu in this example, and while the exact commands may differ on other types
of Linux systems, the ideas are the same.

## Running the Ubuntu Docker image

This tutorial assumes a fresh Ubuntu Noble Docker container environment. The
commands should be the same for any Ubuntu Noble server, although in a
real-hardware installation some of the tools we install in this tutorial may
already be installed.

If you are using [Visual Studio Code](https://code.visualstudio.com/) as your
editor and you have Docker installed, you can use the "Dev Containers" extension
to easily get the environment running. Simply clone this repository, open it in
Visual Studio Code, and run the "Dev Containers: Reopen in Container" command.

If you don't have Docker or Visual Studio Code, you can also access an
development environment through your web browser. Go to the
[README](../README.md) of this repository and click on the "Open in GitHub
Codespaces" link. GitHub allows 60 hours of free Codespaces use per month, which
is plenty for this tutorial.

The last option is create a Docker image manually. To do so, clone this
repository and in the `.devcontainer/` directory, run

```sh
docker build -t bctutorial .
docker run -it bctutorial /bin/bash
```

## Contents of this tutorial
