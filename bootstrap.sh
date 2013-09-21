#!/bin/bash
# This builds a Haskell platform in PREFIX=/opt/hp-2013.2.0.0
# You should be able to tar this up and unpack to a travis worker
set -x
set -e
GHC_VER=7.6.3
HP_VER=2013.2.0.0
CABAL_VER=1.18.0.1
GHC_URL=http://www.haskell.org/ghc/dist/${GHC_VER}/ghc-${GHC_VER}-x86_64-unknown-linux.tar.bz2
HP_URL=https://github.com/haskell/haskell-platform.git
CABAL_URL=http://www.haskell.org/cabal/release/cabal-install-${CABAL_VER}/cabal-install-${CABAL_VER}.tar.gz
sudo apt-get -y install git gcc make autoconf libtool zlib1g-dev \
  libncurses-dev libgmp-dev
WORKDIR=${PWD}/tmp
export PREFIX=/opt/hp-${HP_VER}
mkdir -p "${WORKDIR}"
sudo mkdir -p "${PREFIX}"
sudo chown -R "${USER}" "${PREFIX}"
if [ ! -e "/usr/lib/libgmp.so.3" ]; then
  sudo ln -s /usr/lib/x86_64-linux-gnu/libgmp.so.10 /usr/lib/libgmp.so.3
fi
if [ ! -e "/usr/lib/libgmp.so" ]; then
  sudo ln -s /usr/lib/x86_64-linux-gnu/libgmp.so.10 /usr/lib/libgmp.so
fi
export PATH=${PREFIX}/bin:${PATH}
( cd "${WORKDIR}"
  if [ ! -e "${PREFIX}/bin/ghc" ]; then
    if [ ! -e "ghc-${GHC_VER}" ]; then
      curl "${GHC_URL}" | tar jxf -
    fi
    ( cd "ghc-${GHC_VER}"
      ./configure --prefix="${PREFIX}"
      make install )
  fi
  if [ ! -e "${PREFIX}/bin/cabal" ]; then
    if [ ! -e "cabal-install-${CABAL_VER}" ]; then
      curl "${CABAL_URL}" | tar zxf -
    fi
    ( cd "cabal-install-${CABAL_VER}"
      PREFIX="${PREFIX}" ./bootstrap.sh --global )
  fi
  if [ ! -e "haskell-platform" ]; then
    git clone "${HP_URL}"
  fi
  ( cd haskell-platform
    git fetch
    git reset --hard "${HP_VER}"
    mv haskell-platform.cabal haskell-platform.cabal.old
    grep -v '\(GLU\|OpenGL\)' haskell-platform.cabal.old > haskell-platform.cabal
    cabal update
    cabal install --global --only-dependencies --prefix="${PREFIX}" )
)
if [ -e "${PREFIX}/share" ]; then
  rm -rf "${PREFIX}/share"
fi
find "${PREFIX}" -exec strip -p --strip-unneeded --remove-section=.comment {} \;
find "${PREFIX}" -name html -exec rm -rf {} \;
find "${PREFIX}" -name latex -exec rm -rf {} \;
sudo chmod ugo+rX -R "${PREFIX}"
