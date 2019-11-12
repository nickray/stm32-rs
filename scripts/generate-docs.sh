#!/bin/sh

set -eux

curl https://sh.rustup.rs -sSf | sh -s -- -y
. $HOME/.cargo/env

cargo install svd2rust form
rustup component add rustfmt
pip install pyyaml

(cd svd; ./extract.sh)

CRATES="stm32f1 stm32f4 stm32l0 stm32l1 stm32l4"

make patch CRATES="${CRATES}"
make svd2rust CRATES="${CRATES}"
make form CRATES="${CRATES}"

(cd stm32docs; cargo doc -j1 --all-features --verbose)

remote_repo="https://nickray::${INPUT_GITHUB_TOKEN}@github.com/nickray/stm32-docs.git"
git clone ${remote_repo}
cp -R stm32docs/target/doc/* stm32-docs

cd stm32-docs
git config --local user.email "action@github.com"
git config --local user.name "GitHub Action"
git commit -m "Add changes" -a
git push

