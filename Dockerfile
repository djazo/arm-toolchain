FROM alpine:3.20.2 AS bob-llvm

RUN apk add \
  clang \
  cmake \
  git \
  meson \
  ninja 
RUN mkdir /src ; cd /src ; git clone https://github.com/ARM-software/LLVM-embedded-toolchain-for-Arm.git --depth=1 --branch release-18.1.3
RUN git config --global user.email "builder@embeddedreality.com" ; git config --global user.name "Bob The Builder"
RUN mkdir /build ; cd /build ; CC=clang CXX=clang++ cmake -G Ninja /src/LLVM-embedded-toolchain-for-Arm/
RUN cd /build ; ninja llvm-toolchain ; ninja package-llvm-toolchain
RUN mkdir -p /opt/toolchain ; tar -xvf /build/LLVM-ET*.tar.xz -C /opt/toolchain --strip-components=1

FROM alpine:3.20.2

COPY --from=bob-llvm /opt/toolchain /opt/toolchain
RUN apk add \
  cmake \
  make \
  meson

ENV PATH="/opt/toolchain/bin:${PATH}"
