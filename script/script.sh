#!/usr/bin/env bash

# Stop on error
set -e

echo "🚀 Starting fresh Anvil setup..."

# RPC
export RPC="http://127.0.0.1:8545"

# Default Anvil private keys
export DEPLOYER_PK="0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
export ATTACKER_PK="0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d"

echo "📦 Deploying EvilToken..."

TOKEN=$(forge create --broadcast src/EvilToken.sol:EvilToken \
  --rpc-url $RPC \
  --private-key $DEPLOYER_PK \
  | grep "Deployed to:" | awk '{print $3}')

echo "TOKEN deployed at: $TOKEN"

echo "📦 Deploying Lockup..."

ATTACKER_ADDR=$(cast wallet address --private-key $ATTACKER_PK)
UNLOCK_TIME=$(($(date +%s) - 10))

LOCKUP=$(forge create --broadcast src/Lockup.sol:Lockup \
  --rpc-url $RPC \
  --private-key $DEPLOYER_PK \
  --constructor-args $TOKEN $TOKEN $UNLOCK_TIME \
  | grep "Deployed to:" | awk '{print $3}')

echo "LOCKUP deployed at: $LOCKUP"

echo "🔗 Setting target..."

cast send $TOKEN "setTarget(address)" $LOCKUP \
  --private-key $DEPLOYER_PK \
  --rpc-url $RPC

echo "💰 Funding Lockup..."

cast send $TOKEN "setAttack(bool)" false \
  --private-key $DEPLOYER_PK \
  --rpc-url $RPC

cast send $TOKEN "transfer(address,uint256)" $LOCKUP 100000000000000000000 \
  --private-key $DEPLOYER_PK \
  --rpc-url $RPC
ATTACKER_ADDR=$(cast wallet address --private-key $ATTACKER_PK)

cast send $TOKEN \
 "transfer(address,uint256)" \
$ATTACKER_ADDR 100000000000000000000 \
--private-key $DEPLOYER_PK \
--rpc-url $RPC

cast send $TOKEN "approve(address,uint256)"  $LOCKUP 100000000000000000000 \
  --private-key $ATTACKER_PK \
  --rpc-url $RPC

cast send $LOCKUP "deposit(uint256)" \
  100000000000000000000 \
  --private-key $ATTACKER_PK \
  --rpc-url $RPC

echo "⚔️ Enabling attack..."

cast send $TOKEN "setAttack(bool)" true \
  --private-key $ATTACKER_PK \
  --rpc-url $RPC

echo "🔥 Setup complete!"
echo "TOKEN=$TOKEN"
echo "LOCKUP=$LOCKUP"
