# Introduction

In this tutorial, you will set up [Apollo 3](https://apollo.jbrowse.org/) with
[JBrowse 2](https://jbrowse.org/) and learn about some of the functionality of
both of those tools.

This tutorial uses an Ubuntu Linux server to set up and host Apollo 3 and
JBrowse 2. While the exact commands may differ on other types of Linux systems
(e.g. Amazon Linux, Red Hat, etc.), the ideas are applicable to any unix-line
environment.

## About the tutorial environment

In order to make sure everyone has a consistent environment to set up these
tools, this guide has been written with the intent for the user to run the steps
in [GitHub Codespaces](https://github.com/features/codespaces). Codespaces is
free for individual use up to 60 hours a month, although you will need a GitHub
account.

Another option for running the tutorial is to use
[Visual Studio Code](https://code.visualstudio.com/) with the "Dev Containers"
extension. You will need to also have [Docker](https://www.docker.com/)
installed to use this option.

## Running the tutorial environment

### GitHub Codespaces

Open the repository at <https://github.com/GMOD/2025-biocuration-tutorial> and
make sure you are logged in to GitHub. Click the "Open in GitHub Codespaces"
button in the README section of the page. On the next page, the defaults should
all work, and you can click on "Create codespace." An in-browser editor will
open, and the commands here can be run in the terminal of that editor.

The last step is to open the "Ports" tab at the bottom of the editor and click
"Forward a Port." Enter "80" as the port to forward. It will then give you a
forwarded address, which you will need for the tutorial.

### Visual Studio Code

Clone the repository at <https://github.com/GMOD/2025-biocuration-tutorial> and
open it in Visual Studio Code. Then run the command "Dev Containers: Reopen in
Container." (The command can be accessed by clicking the "><" icon in the bottom
left of the editor, or by pressing <kbd>Ctrl</kbd> + <kbd>Shift</kbd> +
<kbd>P</kbd> and typing in the command.) When the window re-opens, you can use
the terminal in Visual Studio Code to run the commands in the tutorial.

Next: [Setting up the environment](01-setting-up-the-environment.md)
