#!/usr/bin/env bash

# Configuration.
readonly glfw_version=3.3.6
readonly glfw_git_url=https://github.com/glfw/glfw.git
readonly glfw_src_dir=glfw
readonly cmake_args="-DCMAKE_BUILD_TYPE=Release -DGLFW_BUILD_EXAMPLES=OFF -DGLFW_BUILD_TESTS=OFF"

# Create a temporary directory to work in.
readonly temp_dir=$(mktemp -d 2>/dev/null || mktemp -d -t 'glfw')
pushd "${temp_dir}"

# Clone GLFW.
git clone -b ${glfw_version} "${glfw_git_url}" "${glfw_src_dir}"
cmake ${cmake_args} ${glfw_src_dir}
cmake --build . --target install

# Cleanup.
popd
rm -rf "${temp_dir}"
