# OpenStream and Aftermath in Docker

Help yourself with an hassle-free install of OpenStream and Aftermath.

## Use the Docker Image

- To use the docker, you will need to install it on your computer by following the [installing docker](#Installing-Docker) section.
- [Pull the image from the docker hub](#pull-from-the-docker-hub).
- [Run the image in a container](#running-a-container).

Limitation: Aftermath's user interface will not work inside the container, you will have to copy the trace outside the container to visualize them. You can do that by copying through the host mount point (see [running a container](#running-a-container)) or by using `docker cp`.

### Pull from the Docker Hub

```bash
docker pull syllo/openstream-aftermath
```

### Running a Container

If you don't know exactly how to use docker, this repository provides the script `runDockerImage.sh` to create and reuse a container named `OpenStreamInteractive` and runs an interactive shell (`zsh`). All you have to do is:

```bash
./runDockerImage.sh
```

Inside the container you will have access to your local home directory through the `yourUserHomeDir` binding.

### Installing Docker

#### On Debian / Ubuntu

```bash
sudo apt install docker
```

#### Fedora / CentOS / Red Hat

```bash
sudo dnf install docker
```

#### OpenSUSE

```bash
sudo zypper install docker
```

#### Arch Linux

```bash
sudo pacman -S docker
```

#### Apple

```bash
# This command may only work on some system
please install docker
```

## Build the Docker Image from Source

Run the following script to build an image named `openstream-aftermath` from scratch:

```bash
./buildDockerImage.sh
```