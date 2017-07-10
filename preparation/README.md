# Required prior knowledge & preparing the tutorial environment

Building Debian packages requires either a Debian or an Ubuntu environment. We assume that you are familiar with Debian and Ubuntu and that you are comfortable with the command line.

Each version of Debian/Ubuntu behaves packages slightly differently. We require that you use **Debian 8**. Not Ubuntu, and not any earlier or later versions of Debian.

## Using our Docker environment

Don't have a Debian 8 system lying around? No problem: we have provided you with a Docker image, based on Debian 8 and containing all the tools you need to pass these tutorials. Here is how you can use this environment:

 1. Git clone DPMD.
 2. Enter the cloned DPMD directory.
 3. Install Docker and Docker-Compose.
 4. Enter the environment:

        ./enter-docker.sh

Inside the environment, the current working directory on the host is mounted onto /host in the container.

Tip: our environment is compatible with Docker for Mac.

## Setting up an existing Debian 8 system

Install:

    apt-get install -y devscripts gdebi-core build-essential python
