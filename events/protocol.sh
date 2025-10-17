# Sample events file
# One event per line, e.g.:
# $EVENT subgraphName datasourceName eventName eventArg1 eventArg2 ...

DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $DIR/constants.sh

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
$EVENT protocol CarbonLedger CreditRegisteredForClass $CLASS1 $TOKEN1 [0]
$EVENT protocol CarbonLedger CreditRegisteredForClass $CLASS1 $TOKEN2 [0]
$EVENT protocol CarbonLedger CreditRegisteredForClass $CLASS1 $TOKEN3 [0]
$EVENT protocol CarbonLedger CreditRegisteredForClass $CLASS2 $TOKEN4 [0]
$EVENT protocol CarbonLedger CreditRegisteredForClass $CLASS2 $TOKEN5 [0]
$EVENT protocol CarbonLedger CreditRegisteredForClass $CLASS3 $TOKEN7 [0]
$EVENT protocol CarbonLedger CreditRegisteredForClass $CLASS3 $TOKEN8 [0]
$EVENT protocol CarbonLedger CreditUnregisteredForClass $CLASS3 $TOKEN8 [0]

# Stake tokens bondId user token amount maturityId
$EVENT protocol KlimaStaking LpStaked 1 $WALLET $KVcmUsdcLP 5$E18 7
$EVENT protocol KlimaStaking LpStaked 2 $WALLET $KVcmK2LP 6$E18 25
$EVENT protocol KlimaStaking LpStaked 3 $WALLET $KVcmUsdcLP 4$E18 12
$EVENT protocol KlimaStaking LpUnstaked 4 $WALLET $KVcmUsdcLP 4$E18

$EVENT protocol KlimaStaking KlimaBonded $WALLET 5 9$E18 $NOW 5
$EVENT protocol KlimaStaking KlimaBonded $WALLET 6 8$E18 $NOW 12
$EVENT protocol KlimaStaking KlimaBonded $WALLET 7 7$E18 $NOW 28
$EVENT protocol KlimaStaking KlimaBonded $WALLET 8 18$E18 $NOW 30
$EVENT protocol KlimaStaking KlimaUnbonded $WALLET 8 18$E18 0 0

$EVENT protocol KlimaXStaking KlimaXBonded $WALLET 18$E18 1
$EVENT protocol KlimaXStaking KlimaXUnbondRequested $WALLET 3$E18 1

# Allocate bonds: bondId carbonClass amount
$EVENT protocol KlimaStaking KlimaBondAllocated 5 $CLASS1 4$E18
$EVENT protocol KlimaStaking KlimaBondAllocated 5 $CLASS2 5$E18
$EVENT protocol KlimaStaking KlimaBondAllocated 6 $CLASS2 5$E18
$EVENT protocol KlimaStaking KlimaBondAllocated 7 $CLASS2 5$E18
$EVENT protocol KlimaStaking KlimaBondDeallocated 7 $CLASS2 4$E18
$EVENT protocol KlimaStaking KlimaBondReallocated 6 $CLASS2 $CLASS1 2$E18

$EVENT protocol KlimaXStaking KlimaXAllocated $WALLET 15$E18 $CLASS1
$EVENT protocol KlimaXStaking KlimaXDeallocated $WALLET 5$E18 $CLASS1
$EVENT protocol KlimaXStaking KlimaXReallocated $WALLET 4$E18 $CLASS1 $CLASS2

# Swaps sender to amount0In amount1In amount0Out amount1Out
$EVENT protocol KVcmUsdcLP Swap $WALLET $OTHERWALLET 10$E18 0 0 100$E18
$EVENT protocol KVcmK2LP Swap $WALLET $OTHERWALLET 0 40$E18 23$E18 0

# CarbonSwaps carbonClass quoter tokenId tonnageAmount klimaAmount recipient
$EVENT protocol Operations CarbonSwap $CLASS1 $OTHERWALLET 0 200$E18 195$E18 $WALLET


# Add maturities
START_TS=$NOW
for i in $(seq 1 40); do
  START_TS_OFFSET=$(( (i - 1) * 7776000 ))
  TS=$(( START_TS + START_TS_OFFSET ))
  $EVENT protocol MaturityManager MaturityAdded $TS $i
done
