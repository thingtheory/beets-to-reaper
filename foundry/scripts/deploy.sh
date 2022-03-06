#!/bin/bash

forge create \
  --optimize \
  --optimize-runs 200 \
  --rpc-url "${RPC_URL}" \
  --constructor-args \
    "${FBEETS_CRYPT}" \
    "${BEETS_VAULT}" \
    "${BEETS_BAR}" \
    "${BEETS}" \
    "${WFTM}" \
    "${FBEETS_BPT}" \
    "${FBEETS_POOL_ID}" \
  --private-key $(cat "${PRIVATE_KEY_PATH}") \
  --legacy \
  src/BeetsToReaper.sol:BeetsToReaper
