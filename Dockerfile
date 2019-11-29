FROM debian:buster
LABEL maintainer.name="Maxime Schmitt"
LABEL maintainer.email="maxime.schmitt@manchester.ac.uk"
LABEL version="1.1"

# OpenStream Variables
ENV OPENSTREAM_REMOTE "https://github.com/pepperpots/OpenStream.git"
ENV OPENSTREAN_CHECKOUT "master"
## The OPENSTREAM_CHECKOUT variable may take a branch, a tag or a hash, e.g., "master", "v1.0" or "7191fe0595f8458c2e12c72de03c6c87e1ab2058"

# Aftermath Variables
ENV AFTERMATH_REMOTE "https://github.com/pepperpots/aftermath.git"
ENV AFTERMATH_CHECKOUT "master"
## The AFTERMATH_CHECKOUT variable may take a branch, a tag or a hash, e.g., "master", "v1.0" or "7191fe0595f8458c2e12c72de03c6c87e1ab2058"

# Update the System
RUN apt-get update
RUN apt-get upgrade -y
# Install development packages
RUN apt-get install -y git subversion zsh zsh-autosuggestions zsh-syntax-highlighting build-essential cmake autoconf automake pkg-config wget curl texinfo gdb man manpages less ack vim gcc g++ gfortran flex bison
ADD https://github.com/zsh-users/zsh-completions/archive/0.31.0.tar.gz /root/zsh-completions.tar.gz
RUN mkdir -p /usr/share/zsh-completions && tar -xzf /root/zsh-completions.tar.gz --directory /usr/share/zsh-completions --strip-components 1 && rm /root/zsh-completions.tar.gz

# Setup pepperpots user account
RUN groupadd pepperpots
RUN useradd --create-home --home-dir /home/pepperpots -g pepperpots pepperpots
RUN passwd --delete pepperpots
RUN apt-get install -y sudo
RUN echo "pepperpots ALL=(ALL) ALL" >> /etc/sudoers
# User Shell Configuration
USER pepperpots
WORKDIR /home/pepperpots
ADD --chown=pepperpots:pepperpots https://git.grml.org/f/grml-etc-core/etc/zsh/zshrc .zshrc
ADD --chown=pepperpots:pepperpots https://git.grml.org/f/grml-etc-core/etc/skel/.zshrc .zshrc.local
RUN echo "source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh" >> .zshrc.local
RUN echo "source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> .zshrc.local
RUN echo "fpath=(/usr/share/zsh-completions/src \$fpath)" >> .zshrc.local
USER root
RUN chsh --shell=/bin/zsh pepperpots
USER pepperpots
RUN curl -sLf https://spacevim.org/install.sh | bash
RUN mkdir -p .SpaceVim.d && cp .SpaceVim/mode/dark_powered.toml .SpaceVim.d/init.toml

# OpenStream
# OpenStream needs to be built with gcc-7/g++-7
USER root
RUN apt-get install -y gcc-7 g++-7
USER pepperpots
RUN git clone $OPENSTREAM_REMOTE OpenStream
RUN cd OpenStream && git checkout $OPENSTREAM_CHECKOUT
ADD --chown=pepperpots:pepperpots numactl.patch OpenStream/
RUN cd OpenStream && git apply numactl.patch && CC=gcc-7 CXX=g++-7 make -j $(nproc)

# Aftermath
USER root
RUN apt-get install -y libcairo2 libcairo2-dev libglib2.0-dev libtool qt5-default qtbase5-dev qtbase5-dev-tools libqt5core5a libqt5gui5 libqt5widgets5 python-jinja2 python-pip python-cffi
USER pepperpots
RUN git clone $AFTERMATH_REMOTE aftermath
RUN cd aftermath && git checkout $AFTERMATH_CHECKOUT
RUN cd aftermath && ./build-all.sh --local-install --enable-python --env=env.sh -j $(nproc)

# Environment variables for OpenStream and aftermath
RUN echo "export CC=gcc-7" >> .zshenv
RUN echo "export CXX=g++-7" >> .zshenv
RUN echo "export PATH=/home/pepperpots/OpenStream/install/bin:/home/pepperpots/.local/bin:\$PATH" >> .zshenv
RUN echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/home/pepperpots/OpenStream/install/lib" >> .zshenv
RUN echo "source aftermath/env.sh" >> .zshenv
USER pepperpots
CMD [ "/bin/zsh" ]