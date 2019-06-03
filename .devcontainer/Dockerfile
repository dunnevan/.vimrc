FROM ubuntu:bionic

# Configure apt
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get -y install --no-install-recommends apt-utils 2>&1

# Install process tools, lsb-release (common in install instructions for CLIs)
# Install git, curl, wget
# Install pip
# Install zsh
RUN apt-get -y install procps gnupg2 lsb-release \
    git curl wget \
    python3-pip \
    zsh

# Set the default shell to zsh
RUN chsh -s $(which zsh)

# Install oh-my-zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Install nodejs and yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg \
     | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" \
     | tee /etc/apt/sources.list.d/yarn.list \
    && curl -sL https://deb.nodesource.com/setup_12.x \
     | bash - \
    && apt-get install -y nodejs yarn

# Install neovim (not using apt because it can be old)
RUN curl -LO https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.tar.gz \
    && tar -xzf ./nvim-linux64.tar.gz --strip-components=1 -C / \
    && ln -s /bin/nvim /bin/vi \
    && ln -s /bin/nvim /bin/vim \
    && yarn global add neovim \
    && pip3 install neovim

# Copy .vimrc, setup init.vim, and run PlugInstall
COPY .vimrc /root/
ADD init.vim.tar.gz /root/
RUN vi '+PlugInstall --sync' +qa > /dev/null

# Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
ENV DEBIAN_FRONTEND=dialog

# Set default zsh
ENV SHELL /usr/bin/zsh