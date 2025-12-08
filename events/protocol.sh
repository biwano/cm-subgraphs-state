# Sample events file
# One event per line, e.g.:
# $EVENT subgraphName datasourceName eventName eventArg1 eventArg2 ...

set -e
DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $DIR/constants.sh

# Get Carbon contract addresses
TCO2_1_2024_ADDRESS=$($GET_CONTRACT_ADDRESS carbon TCO2_1_2024)
CMARK_1_2025_ADDRESS=$($GET_CONTRACT_ADDRESS carbon CMARK_1_2025)

# Get tokens
$EVENT protocol K2 Transfer $ZERO $WALLET 10$E18
$EVENT protocol KVcm Transfer $ZERO $WALLET 10$E18
$EVENT protocol KVcmUsdcLP Transfer $ZERO $WALLET 10$E18
$EVENT protocol KVcmK2LP Transfer $ZERO $WALLET 10$E18

# Create classes
$EVENT protocol CarbonLedger ClassVaultRegistered $CLASS1
$EVENT protocol CarbonLedger ClassVaultRegistered $CLASS2
$EVENT protocol CarbonLedger ClassVaultRegistered $CLASS3
$EVENT protocol CarbonLedger ClassVaultRegistered $CLASS4
$EVENT protocol CarbonLedger ClassVaultUnregistered $CLASS4

# Register tokens
$EVENT protocol CarbonLedger CreditRegisteredForClass $CLASS1 $TCO2_1_2024_ADDRESS [0]
$EVENT protocol CarbonLedger CreditRegisteredForClass $CLASS1 $CMARK_1_2025_ADDRESS [0]
$EVENT protocol CarbonLedger CreditRegisteredForClass $CLASS1 $TOKEN3 [0]
$EVENT protocol CarbonLedger CreditRegisteredForClass $CLASS2 $TCO2_1_2024_ADDRESS [0]
$EVENT protocol CarbonLedger CreditRegisteredForClass $CLASS2 $TOKEN5 [0]
$EVENT protocol CarbonLedger CreditRegisteredForClass $CLASS3 $CMARK_1_2025_ADDRESS [0]
$EVENT protocol CarbonLedger CreditRegisteredForClass $CLASS3 $TOKEN8 [0]
$EVENT protocol CarbonLedger CreditUnregisteredForClass $CLASS3 $TOKEN8 [0]

# Stake tokens bondId user token amount maturityId
$EVENT protocol KlimaStaking LpStaked $WALLET 1 $KVcmUsdcLP 5$E18
$EVENT protocol KlimaStaking LpStaked $WALLET 1 $KVcmK2LP 6$E18
$EVENT protocol KlimaStaking LpStaked $WALLET 9 $KVcmK2LP 6$E18
$EVENT protocol KlimaStaking LpStakeUpdated $WALLET 25 $KVcmK2LP 6$E18
$EVENT protocol KlimaStaking LpStaked $WALLET 12 $KVcmUsdcLP 4$E18
$EVENT protocol KlimaStaking LpStaked $WALLET 12 $KVcmUsdcLP 4$E18
$EVENT protocol KlimaStaking LpUnstaked $WALLET 12 $KVcmUsdcLP 4$E18

$EVENT protocol KlimaStaking KVCMLocked $WALLET 1 9$E18
$EVENT protocol KlimaStaking KVCMLocked $WALLET 12 8$E18
$EVENT protocol KlimaStaking KVCMLocked $WALLET 28 7$E18
$EVENT protocol KlimaStaking KVCMLocked $WALLET 30 18$E18
$EVENT protocol KlimaStaking KVCMUnlocked $WALLET 30 18$E18

$EVENT protocol KlimaXStaking K2Staked $WALLET 18$E18
$EVENT protocol KlimaXStaking K2UnstakeRequested $WALLET 3$E18

# Allocate bonds: bondId carbonClass amount
$EVENT protocol KlimaStaking KVCMLockAllocated $WALLET 1 $CLASS1 4$E18
$EVENT protocol KlimaStaking KVCMLockAllocated $WALLET 12 $CLASS2 5$E18
$EVENT protocol KlimaStaking KVCMLockAllocated $WALLET 28 $CLASS2 5$E18
$EVENT protocol KlimaStaking KVCMLockDeallocated $WALLET 28 $CLASS2 4$E18
$EVENT protocol KlimaStaking KVCMLockReallocated $WALLET 28 $CLASS2 $CLASS1 2$E18

$EVENT protocol KlimaXStaking K2LockAllocated $WALLET $CLASS1 15$E18
$EVENT protocol KlimaXStaking K2LockDeallocated $WALLET $CLASS1 5$E18
$EVENT protocol KlimaXStaking K2LockReallocated $WALLET $CLASS1 $CLASS2 4$E18

# Swaps sender to amount0In amount1In amount0Out amount1Out
$EVENT protocol KVcmUsdcLP Swap $WALLET $OTHERWALLET 22$E18 0 0 10$E6
$EVENT protocol KVcmK2LP Swap $WALLET $OTHERWALLET 0 12$E18 23$E18 0

# CarbonSwaps carbonClass quoter tokenId tonnageAmount klimaAmount recipient
$EVENT protocol Operations CarbonSwap $CLASS1 $OTHERWALLET 0 200$E18 195$E18 $WALLET
$EVENT protocol Operations CarbonSwap $CLASS2 $OTHERWALLET 0 200$E18 155$E18 $WALLET
$EVENT protocol Operations CarbonSwap $CLASS3 $OTHERWALLET 0 200$E18 312$E18 $WALLET
$EVENT protocol Operations CarbonSwap $CLASS4 $OTHERWALLET 0 200$E18 40155$E18 $WALLET

# Pause staking

$EVENT protocol StakingManagerPause SystemPauseStatusChanged false
$EVENT protocol StakingManagerPause KvcmStakingPauseStatusChanged false
$EVENT protocol StakingManagerPause K2StakingPauseStatusChanged true
$EVENT protocol StakingManagerPause LpStakingPauseStatusChanged false

# Add maturities
START_TS=$NOW
for i in $(seq 1 40); do
  START_TS_OFFSET=$(( (i - 1) * 7776000 ))
  TS=$(( START_TS + START_TS_OFFSET ))
  $EVENT protocol MaturityManager MaturityAdded $TS $i

  # Update yield data
  MUL=1$E9
  UNSCALED_BOND_ISSUE=$(( (300 + i) * MUL ))
  DISCOUNT_FACTOR=$(( (((100 - i) * MUL) / 100) * MUL ))
  ZERO_COUPON_YIELD_CURVE=$(( (((30 + i) * MUL) / 1000) * MUL  ))
  $EVENT protocol RollUpdate SyntheticYieldCurveUpdated $i $DISCOUNT_FACTOR $ZERO_COUPON_YIELD_CURVE $UNSCALED_BOND_ISSUE
  $EVENT protocol RollUpdate RiskyYieldCurveUpdated $i $DISCOUNT_FACTOR $ZERO_COUPON_YIELD_CURVE $UNSCALED_BOND_ISSUE
done

$EVENT protocol MaturityManager MaxMaturityIdUpdated 1 40

# Midnight roll maturity 1 - midnight 1
$EVENT protocol RollUpdate KVCMMaturityRollSettled 1 1 1$E18 2000000000$E9 100$E18
$EVENT protocol RollUpdate K2YieldDistributedForLPs 1 $KVcmK2LP 1 1000000000$E9 10$E18
$EVENT protocol RollUpdate K2YieldDistributedForK2 1 1000000000$E9 15$E18
$EVENT protocol RollUpdate K2YieldDistributedForKVCM 1 1 1000000000$E9 12$E18

$EVENT protocol RollUpdate RiskyYieldDistributedForLPs 1 $KVcmK2LP 1 1000000000$E9 10$E18
$EVENT protocol RollUpdate RiskyYieldDistributedForLPs 1 $KVcmUsdcLP 1 1000000000$E9 11$E18
$EVENT protocol RollUpdate RiskyYieldDistributedForK2 1 1000000000$E9 15$E18

# Midnight roll maturity 1 - midnight 2
$EVENT protocol RollUpdate KVCMMaturityRollSettled 1 2 1$E18 2000100000$E9 100$E18
$EVENT protocol RollUpdate K2YieldDistributedForLPs 1 $KVcmK2LP 2 1000110000$E9 10$E18
$EVENT protocol RollUpdate K2YieldDistributedForK2 2 1000120000$E9 15$E18
$EVENT protocol RollUpdate K2YieldDistributedForKVCM 1 2 1000130000$E9 12$E18

$EVENT protocol RollUpdate RiskyYieldDistributedForLPs 1 $KVcmK2LP 2 1000100000$E9 10$E18
$EVENT protocol RollUpdate RiskyYieldDistributedForLPs 1 $KVcmUsdcLP 2 1000200000$E9 11$E18
$EVENT protocol RollUpdate RiskyYieldDistributedForK2 2 1000300000$E9 15$E18


# Shares minting maturity 1
$EVENT protocol RewardManager RiskyYieldLPSharesMinted $WALLET 1 $KVcmK2LP 1 10 3$E18
$EVENT protocol RewardManager K2YieldLPSharesMinted $WALLET 1 $KVcmK2LP 1 10 3$E18

$EVENT protocol RewardManager RiskyYieldLPSharesMinted $WALLET 1 $KVcmUsdcLP 1 10 3$E18

$EVENT protocol RewardManager RiskyYieldK2SharesMinted $WALLET 1 12 4$E18
$EVENT protocol RewardManager K2YieldK2SharesMinted $WALLET 1 12 4$E18

$EVENT protocol RewardManager SyntheticYieldForKVCMMinted $WALLET 1 1 6$E18 
$EVENT protocol RewardManager K2YieldForKVCMMinted $WALLET 1 1 15 5$E18

# Shares minting maturity 2
$EVENT protocol KlimaStaking LpStaked $WALLET 1 $KVcmK2LP 600$E18
$EVENT protocol RewardManager RiskyYieldLPSharesMinted $WALLET 2 $KVcmK2LP 1 10 13$E18
$EVENT protocol RewardManager K2YieldLPSharesMinted $WALLET 2 $KVcmK2LP 1 10 13$E18

$EVENT protocol KlimaStaking LpStaked $WALLET 1 $KVcmUsdcLP 500$E18
$EVENT protocol RewardManager RiskyYieldLPSharesMinted $WALLET 2 $KVcmUsdcLP 1 10 15$E18

$EVENT protocol KlimaStaking KVCMLocked $WALLET 2 900$E18
$EVENT protocol RewardManager SyntheticYieldForKVCMMinted $WALLET 2 1 15$E18
$EVENT protocol RewardManager K2YieldForKVCMMinted $WALLET 2 1 15 14$E18

# Shares claiming (maturity)
$EVENT protocol RewardManager RiskyYieldForLPClaimed $WALLET 2 $KVcmK2LP 1$E18
$EVENT protocol RewardManager K2YieldForLPClaimed $WALLET 2 $KVcmK2LP 10$E18

$EVENT protocol RewardManager RiskyYieldForLPClaimed $WALLET 2 $KVcmUsdcLP 1$E18

$EVENT protocol RewardManager RiskyYieldForK2Claimed $WALLET 2$E18
$EVENT protocol RewardManager K2YieldForK2Claimed $WALLET 3$E18

$EVENT protocol RewardManager SyntheticYieldForKVCMClaimed $WALLET 2 1$E18
$EVENT protocol RewardManager K2YieldForKVCMClaimed $WALLET 2 4$E18


######### TokenSnapshots #########
$INCREASE_TIME 86400

# Change prices
$EVENT protocol KVcmUsdcLP Swap $WALLET $OTHERWALLET 15$E18 0 0 10$E6
$EVENT protocol KVcmK2LP Swap $WALLET $OTHERWALLET 0 35$E18 23$E18 0

# Change supply
$EVENT protocol K2 Transfer $ZERO $WALLET 3$E18
$EVENT protocol KVcm Transfer $ZERO $WALLET 4$E18

# change TVL
$EVENT protocol KlimaStaking KVCMLocked $WALLET 9 2$E18
$EVENT protocol KlimaXStaking K2Staked $WALLET 4$E18

# CarbonSwaps carbonClass quoter tokenId tonnageAmount klimaAmount recipient
$EVENT protocol Operations CarbonSwap $CLASS1 $OTHERWALLET 0 200$E18 200$E18 $WALLET
$EVENT protocol Operations CarbonSwap $CLASS2 $OTHERWALLET 0 200$E18 180$E18 $WALLET
$EVENT protocol Operations CarbonSwap $CLASS3 $OTHERWALLET 0 200$E18 300$E18 $WALLET
$EVENT protocol Operations CarbonSwap $CLASS4 $OTHERWALLET 0 200$E18 30155$E18 $WALLET
