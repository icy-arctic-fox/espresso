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
  libevent-dev \
  xorg-dev \
  x11-xserver-utils \
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
  cmake -DCMAKE_BUILD_TYPE=Release -DGLFW_BUILD_EXAMPLES=OFF -DGLFW_BUILD_TESTS=OFF .. && \
  cmake --build . --target install && \
  cd ../.. && \
  rm -rf glfw

RUN groupadd -r build && \
  useradd --no-log-init -m -r -g build build

COPY entrypoint.sh /entrypoint.sh

USER build
WORKDIR /home/build
ENTRYPOINT ["/entrypoint.sh"]
CMD ["fluxbox"]
