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
NINETY_DAYS=$(( 90 * 24 * 60 * 60))

# 0
MATURITY_0_TS=$(( $NOW - 92 * 24 * 60 * 60))

# 1-40
for i in $(seq 1 40); do
  TS=$(( MATURITY_0_TS + NINETY_DAYS * i ))
  $EVENT protocol MaturityManager MaturityAdded $TS $i

  # Update yield data
  MUL=1$E9
  UNSCALED_BOND_ISSUE=$(( (300 + i) * MUL ))
  DISCOUNT_FACTOR=$(( (((100 - i) * MUL) / 100) * MUL ))
  ZERO_COUPON_YIELD_CURVE=$(( (((30 + i) * MUL) / 1000) * MUL  ))
  $EVENT protocol RollUpdate SyntheticYieldCurveUpdated $i $DISCOUNT_FACTOR $ZERO_COUPON_YIELD_CURVE $UNSCALED_BOND_ISSUE
  $EVENT protocol RollUpdate RiskyYieldCurveUpdated $i $DISCOUNT_FACTOR $ZERO_COUPON_YIELD_CURVE $UNSCALED_BOND_ISSUE
done

$EVENT protocol MaturityManager MaxMaturityIdUpdated 2 41

# Midnight roll maturity 1 - midnight 89
MIDNIGHT=89
$EVENT protocol RollUpdate KVCMMaturityRollSettled 1 $MIDNIGHT 1$E18 2000000000$E9 100$E18
$EVENT protocol RollUpdate K2YieldDistributedForLPs 1 $KVcmK2LP $MIDNIGHT 1000000000$E9 10$E18
$EVENT protocol RollUpdate K2YieldDistributedForK2 $MIDNIGHT 1000000000$E9 15$E18
$EVENT protocol RollUpdate K2YieldDistributedForKVCM 1 $MIDNIGHT 1000000000$E9 12$E18

$EVENT protocol RollUpdate RiskyYieldDistributedForLPs 1 $KVcmK2LP $MIDNIGHT 1000000000$E9 10$E18
$EVENT protocol RollUpdate RiskyYieldDistributedForLPs 1 $KVcmUsdcLP $MIDNIGHT 1000000000$E9 11$E18
$EVENT protocol RollUpdate RiskyYieldDistributedForK2 $MIDNIGHT 1000000000$E9 15$E18

# Midnight roll maturity 1 - midnight 90 = maturity 1 ends
MIDNIGHT=90
$EVENT protocol RollUpdate KVCMMaturityRollSettled 1 $MIDNIGHT 1$E18 2000100000$E9 100$E18
$EVENT protocol RollUpdate K2YieldDistributedForLPs 1 $KVcmK2LP $MIDNIGHT 1000110000$E9 10$E18
$EVENT protocol RollUpdate K2YieldDistributedForK2 $MIDNIGHT 1000120000$E9 15$E18
$EVENT protocol RollUpdate K2YieldDistributedForKVCM 1 $MIDNIGHT 1000130000$E9 12$E18

$EVENT protocol RollUpdate RiskyYieldDistributedForLPs 1 $KVcmK2LP $MIDNIGHT 1000100000$E9 10$E18
$EVENT protocol RollUpdate RiskyYieldDistributedForLPs 1 $KVcmUsdcLP $MIDNIGHT 1000200000$E9 11$E18
$EVENT protocol RollUpdate RiskyYieldDistributedForK2 $MIDNIGHT 1000300000$E9 15$E18

# Midnight roll maturity 1 - midnight 91 = Another one so midnight 0 is not latest
MIDNIGHT=91
$EVENT protocol RollUpdate KVCMMaturityRollSettled 1 $MIDNIGHT 1$E18 2000200000$E9 100$E18
$EVENT protocol RollUpdate K2YieldDistributedForLPs 1 $KVcmK2LP $MIDNIGHT 1000220000$E9 10$E18
$EVENT protocol RollUpdate K2YieldDistributedForK2 $MIDNIGHT 1000230000$E9 15$E18
$EVENT protocol RollUpdate K2YieldDistributedForKVCM 1 $MIDNIGHT 1000230000$E9 12$E18

$EVENT protocol RollUpdate RiskyYieldDistributedForLPs 1 $KVcmK2LP $MIDNIGHT 1000200000$E9 10$E18
$EVENT protocol RollUpdate RiskyYieldDistributedForLPs 1 $KVcmUsdcLP $MIDNIGHT 1000400000$E9 11$E18
$EVENT protocol RollUpdate RiskyYieldDistributedForK2 $MIDNIGHT 1000600000$E9 15$E18

# Shares minting maturity 1
MIDNIGHT=89
MATURITY=1
$EVENT protocol RewardManager RiskyYieldLPSharesMinted $WALLET $MATURITY $KVcmK2LP $MIDNIGHT 10$E18 3$E18
$EVENT protocol RewardManager K2YieldLPSharesMinted $WALLET $MATURITY $KVcmK2LP $MIDNIGHT 10$E18 3$E18

$EVENT protocol RewardManager RiskyYieldLPSharesMinted $WALLET $MATURITY $KVcmUsdcLP $MIDNIGHT 10$E18 3$E18

$EVENT protocol RewardManager RiskyYieldK2SharesMinted $WALLET $MIDNIGHT 12$E18 21$E18
$EVENT protocol RewardManager K2YieldK2SharesMinted $WALLET $MIDNIGHT 10$E18 18$E18

$EVENT protocol RewardManager SyntheticYieldForKVCMMinted $WALLET $MATURITY $MIDNIGHT 6$E18 
$EVENT protocol RewardManager K2YieldForKVCMMinted $WALLET $MATURITY $MIDNIGHT 15$E18 5$E18

# Shares minting maturity 2
MATURITY=2
$EVENT protocol KlimaStaking LpStaked $WALLET $MATURITY $KVcmK2LP 600$E18
$EVENT protocol RewardManager RiskyYieldLPSharesMinted $WALLET $MATURITY $KVcmK2LP $MIDNIGHT 10$E18 13$E18
$EVENT protocol RewardManager K2YieldLPSharesMinted $WALLET $MATURITY $KVcmK2LP $MIDNIGHT 10$E18 13$E18

$EVENT protocol KlimaStaking LpStaked $WALLET $MATURITY $KVcmUsdcLP 500$E18
$EVENT protocol RewardManager RiskyYieldLPSharesMinted $WALLET $MATURITY $KVcmUsdcLP $MIDNIGHT 10$E18 15$E18

$EVENT protocol KlimaStaking KVCMLocked $WALLET 2 900$E18
$EVENT protocol RewardManager SyntheticYieldForKVCMMinted $WALLET $MATURITY $MIDNIGHT 15$E18
$EVENT protocol RewardManager K2YieldForKVCMMinted $WALLET $MATURITY $MIDNIGHT 15$E18 14$E18

# Yield settling for K2
MIDNIGHT=90
$EVENT protocol RewardManager K2YieldForK2Settled $WALLET $MIDNIGHT 11$E18 20$E18
$EVENT protocol RewardManager RiskyYieldForK2Settled $WALLET $MIDNIGHT 9$E18 17$E18

# Shares claiming (maturity)
$EVENT protocol RewardManager RiskyYieldForLPClaimed $WALLET $MATURITY $KVcmK2LP 1$E18
$EVENT protocol RewardManager K2YieldForLPClaimed $WALLET $MATURITY $KVcmK2LP 10$E18

$EVENT protocol RewardManager RiskyYieldForLPClaimed $WALLET $MATURITY $KVcmUsdcLP 1$E18

$EVENT protocol RewardManager RiskyYieldForK2Claimed $WALLET 2$E18
$EVENT protocol RewardManager K2YieldForK2Claimed $WALLET 3$E18

$EVENT protocol RewardManager SyntheticYieldForKVCMClaimed $WALLET $MATURITY 1$E18
$EVENT protocol RewardManager K2YieldForKVCMClaimed $WALLET $MATURITY 4$E18


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
