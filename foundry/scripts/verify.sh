#!/bin/bash

set -e

cast abi-encode "constructor(address,address,address,address,address,address,bytes32)" "${FBEETS_CRYPT}" "${BEETS_VAULT}" "${BEETS_BAR}" "${BEETS}" "${WFTM}" "${FBEETS_BPT}" "${FBEETS_POOL_ID}"

echo "${encodedArgs}"

#export RUST_BACKTRACE=full
forge verify-contract \
  --chain-id=250 \
  --constructor-args "${encodedArgs}" \
  --compiler-version "0.8.6+commit.11564f7e" \
  --num-of-optimizations 200 \
  "${ADDRESS}" \
  "src/BeetsToReaper.sol:BeetsToReaper" \
  "${ETHERSCAN_API_KEY}"


