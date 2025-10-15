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

# Stake tokens
$EVENT protocol KlimaStaking LpStaked 1 $WALLET $KVcmUsdcLP 5$E18 1
$EVENT protocol KlimaStaking LpStaked 2 $WALLET $KVcmK2LP 6$E18 1
$EVENT protocol KlimaStaking LpStaked 4 $WALLET $KVcm 8$E18 1
$EVENT protocol KlimaStaking LpStaked 5 $WALLET $KVcmUsdcLP 4$E18 1
$EVENT protocol KlimaStaking LpUnstaked 5 $WALLET $KVcmUsdcLP 4$E18

$EVENT protocol KlimaXStaking KlimaXBonded $WALLET 18$E18 1
$EVENT protocol KlimaXStaking KlimaXUnbondRequested $WALLET 3$E18 1

# Add maturities
START_TS=$(date +%s)
for i in $(seq 1 40); do
  START_TS_OFFSET=$(( (i - 1) * 7776000 ))
  TS=$(( START_TS + START_TS_OFFSET ))
  $EVENT protocol MaturityManager MaturityAdded $TS $i
done
