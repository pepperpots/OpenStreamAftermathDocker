FROM debian:buster
LABEL maintainer.name="Maxime Schmitt"
LABEL maintainer.email="maxime.schmitt@manchester.ac.uk"
LABEL version="1.0"

# Development packages
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y git cmake zsh zsh-autosuggestions zsh-syntax-highlighting make autoconf automake gdb wget texinfo dpkg-dev libc-dev sudo
# Setup user pepperpots
RUN useradd -d /home/pepperpots -m pepperpots && \
    su - pepperpots -c 'wget -O /home/pepperpots/.zshrc https://git.grml.org/f/grml-etc-core/etc/zsh/zshrc' && \
    su - pepperpots -c 'wget -O /home/pepperpots/.zshrc.local  https://git.grml.org/f/grml-etc-core/etc/skel/.zshrc' && \
    wget -O /root/zsh-completions.tar.gz https://github.com/zsh-users/zsh-completions/archive/0.31.0.tar.gz && \
    mkdir -p /usr/share/zsh-completions && tar -xzf /root/zsh-completions.tar.gz --directory /usr/share/zsh-completions --strip-components 1 && \
    echo "source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh" >> /home/pepperpots/.zshrc.local && \
    echo "source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> /home/pepperpots/.zshrc.local && \
    echo "fpath=(/usr/share/zsh-completions/src \$fpath)" >> /home/pepperpots/.zshrc.local && \
    echo "alias please=sudo" >> /home/pepperpots/.zshrc.local && chsh --shell=/bin/zsh pepperpots && \
    echo "pepperpots ALL=(ALL) ALL" >> /etc/sudoers && passwd --delete pepperpots

# OpenStream
# Replace gcc/g++ version 8 which cannot build OpenStream by gcc-7/g++-7
RUN apt-get install -y gfortran-7 gcc-7 g++-7 && apt-get remove -y gcc g++ && apt-get autoremove -y && \
    ln -s /usr/bin/gfortran-7 /usr/bin/gfortran && ln -s /usr/bin/gcc-7 /usr/bin/gcc && ln -s /usr/bin/g++-7 /usr/bin/g++
RUN su - pepperpots -c 'git clone --depth 1 https://github.com/pepperpots/OpenStream.git OpenStream'
ADD --chown=pepperpots:pepperpots numactl.patch /home/pepperpots/OpenStream/
RUN su - pepperpots -c 'cd OpenStream && git apply numactl.patch && make -j $(nproc)'

# Aftermath
RUN apt-get install -y libcairo2 libcairo2-dev libglib2.0-dev libtool pkg-config qt5-default qtbase5-dev qtbase5-dev-tools libqt5core5a libqt5gui5 libqt5widgets5 python-jinja2 python-pip python-cffi
RUN su - pepperpots -c 'git clone git://git.aftermath-tracing.com/aftermath-prerelease.git aftermath'
RUN su - pepperpots -c 'cd aftermath && ./build-all.sh --local-install --enable-python --env=env.sh -j $(nproc)'

# Setup environment variables
RUN su - pepperpots -c 'echo "export PATH=/home/pepperpots/OpenStream/install/bin:\$PATH" >> /home/pepperpots/.zshrc.local && \
                        echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/home/pepperpots/OpenStream/install/lib" >> /home/pepperpots/.zshrc.local && \
                        echo "source /home/pepperpots/aftermath/env.sh" >> /home/pepperpots/.zshrc.local'

# Install what you need
RUN apt-get install -y  man manpages less ack vim 

USER pepperpots:pepperpots
WORKDIR /home/pepperpots
CMD [ "/bin/zsh" ]