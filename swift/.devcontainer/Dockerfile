#Start build image
#FROM ubuntu:bionic AS build
FROM ubuntu:xenial AS build

ARG BUNDLE_PREFIX="swift-tensorflow" 
#YEAR=$(date +"%Y") MONTH=$(date +"%m") DAY=$(date +"%d") TOOLCHAIN_VERSION="swift-tensorflow-LOCAL-${YEAR}-${MONTH}-${DAY}-a" ARCHIVE="${TOOLCHAIN_VERSION}-${HOST}.tar.gz" SWIFT_INSTALL_DIR="${SRC_DIR}/swift-nightly-install"

# Configure apt
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get -y install --no-install-recommends apt-utils 2>&1 \
    && apt-get -y install git curl \
    # Install Swift Tensorflow dependencies
    cmake ninja-build clang uuid-dev libicu-dev icu-devtools libbsd-dev libedit-dev \
    libxml2-dev libsqlite3-dev swig libpython-dev libncurses5-dev pkg-config \
    libblocksruntime-dev libcurl4-openssl-dev systemtap-sdt-dev tzdata rsync \
    # Install bazel dependencies
    zip g++ zlib1g-dev unzip

# Install bazel
RUN curl -LO https://github.com/bazelbuild/bazel/releases/download/0.25.2/bazel-0.25.2-installer-linux-x86_64.sh \
    && chmod +x ./bazel-0.25.2-installer-linux-x86_64.sh \
    && ./bazel-0.25.2-installer-linux-x86_64.sh

# Clone Tensorflow for Swift
RUN mkdir swift-source \
    && cd swift-source \
    && git clone https://github.com/apple/swift.git -b tensorflow \
    && ./swift/utils/update-checkout --clone --scheme tensorflow

# Build Tensorflow for Swift 
#RUN utils/build-script --enable-tensorflow --release
#--release 
#--release-debuginfo
#--debuginfo

# Build Tensorflow for Swift Toolchain
RUN cd /swift-source/swift/ \
    && utils/build-toolchain-tensorflow $BUNDLE_PREFIX

#Start base image
FROM ubuntu:bionic

# Configure apt
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get -y install --no-install-recommends apt-utils 2>&1 \
    # Install process tools, lsb-release (common in install instructions for CLIs)
    # Install git, curl, wget
    # Install pip
    # Install zsh
    && apt-get -y install procps gnupg2 lsb-release \
        git curl wget \
        python3-pip libpython2.7-dev \
        zsh \
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* \
    # Set the default shell to zsh and install oh-my-shell
    && chsh -s $(which zsh) \
    && sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Install nodejs and yarn, and neovim
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg \
     | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" \
     | tee /etc/apt/sources.list.d/yarn.list \
    && curl -sL https://deb.nodesource.com/setup_12.x \
     | bash - \
    && apt-get install -y nodejs yarn \
    #Install neovim (not using apt because we want newest stable)
    && curl -fsSL https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.tar.gz \
     | tar -xz --strip-components=1 -C / \
    && ln -s /bin/nvim /bin/vi \
    && ln -s /bin/nvim /bin/vim \
    && yarn global add neovim \
    && pip3 install neovim

# Copy .vimrc, setup init.vim, and run PlugInstall
COPY .config /root/.config/
COPY .vimrc /root/
RUN vi '+PlugInstall --sync' +qa > /dev/null

# Install swift from build image
COPY --from=build /swift-source/swift/swift-nightly-install/ /

# Install sourcekit-lsp for swift
COPY --from=build /swift-source/build/buildbot_linux/sourcekitlsp-linux-x86_64/release/sourcekit-lsp /usr/bin/

# Set interactive mode, default zsh, set sourcekit toolchain path, and library path
ENV DEBIAN_FRONTEND=dialog SHELL=/usr/bin/zsh SOURCEKIT_TOOLCHAIN_PATH=/ LD_LIBRARY_PATH=/usr/lib/swift/linux/

# Set default command to zsh
CMD zsh