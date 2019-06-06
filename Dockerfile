FROM ubuntu:18.04

ARG GLFW_VERSION=3.3

# Install dependencies.
RUN apt-get update -y && \
  apt-get install -y \
  cmake \
  git \
  curl \
  libssl-dev \
  libxml2-dev \
  libyaml-dev \
  libgmp-dev \
  libreadline-dev \
  libz-dev \
  xorg-dev \
  xvfb \
  fluxbox

# Install Crystal.
RUN curl -sL "https://keybase.io/crystal/pgp_keys.asc" | apt-key add - && \
  echo "deb https://dist.crystal-lang.org/apt crystal main" | tee /etc/apt/sources.list.d/crystal.list && \
  apt-get update -y && \
  apt-get install -y crystal

# Build and install GLFW.
RUN git clone -b $GLFW_VERSION https://github.com/glfw/glfw.git && \
  cd glfw && \
  mkdir build && \
  cd build && \
  cmake -DCMAKE_BUILD_TYPE=Release .. && \
  cmake --build . --target install && \
  cd ../.. && \
  rm -rf glfw

RUN groupadd -r build && \
  useradd --no-log-init -m -r -g build build

USER build
WORKDIR /home/build
ENTRYPOINT ["/bin/sh", "-c", "/usr/bin/xvfb-run -a -s '-screen 0 1280x720x24' $@", ""]
CMD ["fluxbox"]
