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
$EVENT protocol KVcmUsdcLP Transfer $ZERO $WALLET 10$E12
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
$EVENT protocol KvcmLPStaking LpStaked $KVcmUsdcLP 1 $WALLET 5$E12 1
$EVENT protocol KvcmLPStaking LpStaked $KVcmK2LP 1 $WALLET 6$E18 2
$EVENT protocol KvcmLPStaking LpStaked $KVcmK2LP 9 $WALLET 6$E18 3
$EVENT protocol KvcmLPStaking LpStakeUpdated $KVcmK2LP 25 $WALLET 6$E18 4
$EVENT protocol KvcmLPStaking LpStaked $KVcmUsdcLP 12 $WALLET 4$E12 5
$EVENT protocol KvcmLPStaking LpStaked $KVcmUsdcLP 12 $WALLET 4$E12 6 
$EVENT protocol KvcmLPStaking LpStakeUnstaked $KVcmUsdcLP 12 $WALLET 4$E12 7

$EVENT protocol KvcmStaking KvcmLocked $WALLET 1 9$E18 91 1
$EVENT protocol KvcmStaking KvcmLocked $WALLET 1 4$E18 91 1
$EVENT protocol KvcmStaking KvcmLocked $WALLET 2 8$E18 91 12
$EVENT protocol KvcmStaking KvcmLocked $WALLET 3 7$E18 91 28 
$EVENT protocol KvcmStaking KvcmLocked $WALLET 4 18$E18 91 30
$EVENT protocol KvcmStaking KvcmUnlocked $WALLET 4 30 18$E18 0 0

$EVENT protocol K2Staking K2Locked $WALLET 18$E18 1 1
$EVENT protocol K2Staking K2UnlockRequested $WALLET 3$E18 $NOW

# Allocate bonds: bondId carbonClass amount
$EVENT protocol KvcmStaking KvcmLockAllocated $WALLET 1 $CLASS1 4$E18
$EVENT protocol KvcmStaking KvcmLockAllocated $WALLET 12 $CLASS2 5$E18
$EVENT protocol KvcmStaking KvcmLockAllocated $WALLET 28 $CLASS2 5$E18
$EVENT protocol KvcmStaking KvcmLockDeallocated $WALLET 28 $CLASS2 4$E18
$EVENT protocol KvcmStaking KvcmLockReallocated $WALLET 28 $CLASS2 $CLASS1 2$E18

$EVENT protocol K2Staking K2Allocated $WALLET 15$E18 $CLASS1
$EVENT protocol K2Staking K2Deallocated $WALLET 5$E18 $CLASS1 
$EVENT protocol K2Staking K2Reallocated $WALLET 4$E18 $CLASS1 $CLASS2

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

# Function to generate accumulator update events for a midnight and maturity
generate_accumulator_updates() {
  local MIDNIGHT=$1
  local MATURITY=$2
  local ACCUMULATOR_VALUE=$3
  local PPS=$4
  
  # RollUpdate event
  $EVENT protocol RollUpdate MaturityRollSettled $MIDNIGHT $MATURITY 18$E18 $PPS 17$E18 
  
  # K2Yield accumulator updates
  $EVENT protocol K2Yield LPK2YieldAccumulatorUpdated $KVcmK2LP $MIDNIGHT $MATURITY $ACCUMULATOR_VALUE
  $EVENT protocol K2Yield K2StakersK2YieldAccumulatorUpdated $MIDNIGHT $ACCUMULATOR_VALUE$E3
  $EVENT protocol K2Yield KVCMK2YieldAccumulatorUpdated $MIDNIGHT $MATURITY $ACCUMULATOR_VALUE
  
  # RiskyYield accumulator updates
  $EVENT protocol RiskyYield LPRiskyYieldAccumulatorUpdated $KVcmK2LP $MIDNIGHT $MATURITY $ACCUMULATOR_VALUE
  $EVENT protocol RiskyYield LPRiskyYieldAccumulatorUpdated $KVcmUsdcLP $MIDNIGHT $MATURITY $ACCUMULATOR_VALUE
  $EVENT protocol RiskyYield K2StakersRYAccumulatorUpdated $MIDNIGHT $ACCUMULATOR_VALUE
}

# 1-40
for i in $(seq 1 40); do
  TS=$(( MATURITY_0_TS + NINETY_DAYS * i ))
  $EVENT protocol MaturityManager MaturityAdded $TS $i

  # Generate accumulator updates for midnights 89, 90, 91
  # Base accumulator increases by 0.1% per maturity
  BASE_ACCUMULATOR_VALUE=1000000000
  BASE_ACCUMULATOR=$(awk "BEGIN {printf \"%.0f\", $BASE_ACCUMULATOR_VALUE * (1.001^($i-1))}")
  
  # Accumulator increases by 0.1% at each midnight index
  ACCUMULATOR_89=$(awk "BEGIN {printf \"%.0f\", $BASE_ACCUMULATOR}")
  ACCUMULATOR_90=$(awk "BEGIN {printf \"%.0f\", $BASE_ACCUMULATOR * 1.001}")
  ACCUMULATOR_91=$(awk "BEGIN {printf \"%.0f\", $BASE_ACCUMULATOR * 1.001 * 1.001}")
  
  # Base PPS increases by 0.1% per maturity
  BASE_PPS_VALUE=1$E18
  BASE_PPS=$(awk "BEGIN {printf \"%.0f\", $BASE_PPS_VALUE * (1.001^($i-1))}")
  
  # PPS difference between midnights increases per maturity: maturity 1 = 0.11%, maturity 2 = 0.12%, etc.
  PPS_MIDNIGHT_INCREASE=$(awk "BEGIN {printf \"%.6f\", 1.0011 + ($i-1) * 0.0001}")
  PPS_89=$(awk "BEGIN {printf \"%.0f\", $BASE_PPS}")
  PPS_90=$(awk "BEGIN {printf \"%.0f\", $BASE_PPS * $PPS_MIDNIGHT_INCREASE}")
  PPS_91=$(awk "BEGIN {printf \"%.0f\", $BASE_PPS * $PPS_MIDNIGHT_INCREASE * $PPS_MIDNIGHT_INCREASE}")
  
  # Midnight 89
  generate_accumulator_updates 89 $i ${ACCUMULATOR_89}$E9 ${PPS_89}
  
  # Midnight 90
  generate_accumulator_updates 90 $i ${ACCUMULATOR_90}$E9 ${PPS_90}
  
  # Midnight 91
  generate_accumulator_updates 91 $i ${ACCUMULATOR_91}$E9 ${PPS_91}
  
done

$EVENT protocol MaturityManager MaxMaturityIdUpdated 2 41

# Shares minting maturity 1
MIDNIGHT=89
MATURITY=1
$EVENT protocol RewardManager RiskyYieldLPSharesMinted $WALLET $MATURITY $KVcmK2LP $MIDNIGHT 10$E18 3$E18
$EVENT protocol RewardManager K2YieldLPSharesMinted $WALLET $MATURITY $KVcmK2LP $MIDNIGHT 10$E18 3$E18

$EVENT protocol RewardManager RiskyYieldLPSharesMinted $WALLET $MATURITY $KVcmUsdcLP $MIDNIGHT 10$E18 3$E18

$EVENT protocol RewardManager RiskyYieldK2SharesMinted $WALLET $MIDNIGHT 12$E18 21$E18
$EVENT protocol RewardManager K2YieldK2SharesMinted $WALLET $MIDNIGHT 10$E18 18$E18

$EVENT protocol KvcmIncentiveCurve LockUpdated $WALLET 1 $MATURITY 6$E18 0 $MIDNIGHT 
$EVENT protocol RewardManager K2YieldForKVCMMinted $WALLET $MATURITY $MIDNIGHT 15$E18 5$E18

# Shares minting maturity 2
MATURITY=2
$EVENT protocol KvcmLPStaking LpStaked $KVcmK2LP $MATURITY $WALLET 600$E18 10
$EVENT protocol RewardManager RiskyYieldLPSharesMinted $WALLET $MATURITY $KVcmK2LP $MIDNIGHT 10$E18 13$E18
$EVENT protocol RewardManager K2YieldLPSharesMinted $WALLET $MATURITY $KVcmK2LP $MIDNIGHT 10$E18 13$E18

$EVENT protocol KvcmLPStaking LpStaked $KVcmUsdcLP $MATURITY $WALLET 500$E12 20
$EVENT protocol RewardManager RiskyYieldLPSharesMinted $WALLET $MATURITY $KVcmUsdcLP $MIDNIGHT 10$E18 15$E18

$EVENT protocol KvcmStaking KvcmLocked $WALLET 1 900$E18 91 $MATURITY
$EVENT protocol KvcmIncentiveCurve LockUpdated $WALLET 1 $MATURITY 15$E18 0 $MIDNIGHT 
$EVENT protocol RewardManager K2YieldForKVCMMinted $WALLET $MATURITY $MIDNIGHT 15$E18 14$E18

# Yield settling for K2
MIDNIGHT=90
$EVENT protocol RewardManager K2YieldK2SharesMinted $WALLET $MIDNIGHT 11$E18 20$E18
$EVENT protocol RewardManager RiskyYieldK2SharesMinted $WALLET $MIDNIGHT 9$E18 17$E18

# Shares claiming (maturity)
$EVENT protocol RMLPRewards LPRYieldTransferred $KVcmK2LP $MATURITY $WALLET 1$E18
$EVENT protocol RMLPRewards LPK2YieldTransferred $KVcmK2LP $MATURITY $WALLET 10$E18
$EVENT protocol RMLPRewards LPRYieldTransferred $KVcmUsdcLP $MATURITY $WALLET 1$E18

$EVENT protocol RewardManager RiskyYieldForK2Claimed $WALLET 2$E18
$EVENT protocol RewardManager K2YieldForK2Claimed $WALLET 3$E18

$EVENT protocol KvcmIncentiveCurve LockUpdated $WALLET 1 $MATURITY 1$E18 0 $MIDNIGHT 
$EVENT protocol RMKVCMStakersRewards KVCMK2YieldTransferred $MATURITY $WALLET 4$E18


######### TokenSnapshots #########
$INCREASE_TIME 86400

# Change prices
$EVENT protocol KVcmUsdcLP Swap $WALLET $OTHERWALLET 15$E18 0 0 10$E6
$EVENT protocol KVcmK2LP Swap $WALLET $OTHERWALLET 0 35$E18 23$E18 0

# Change supply
$EVENT protocol K2 Transfer $ZERO $WALLET 3$E18
$EVENT protocol KVcm Transfer $ZERO $WALLET 4$E18

# change TVL
$EVENT protocol KvcmStaking KvcmLocked $WALLET 1 2$E18 91 0
$EVENT protocol K2Staking K2Locked $WALLET 4$E18 1 1

# CarbonSwaps carbonClass quoter tokenId tonnageAmount klimaAmount recipient
$EVENT protocol Operations CarbonSwap $CLASS1 $OTHERWALLET 0 200$E18 200$E18 $WALLET
$EVENT protocol Operations CarbonSwap $CLASS2 $OTHERWALLET 0 200$E18 180$E18 $WALLET
$EVENT protocol Operations CarbonSwap $CLASS3 $OTHERWALLET 0 200$E18 300$E18 $WALLET
$EVENT protocol Operations CarbonSwap $CLASS4 $OTHERWALLET 0 200$E18 30155$E18 $WALLET
