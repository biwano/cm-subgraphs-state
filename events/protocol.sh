# Sample events file
# One event per line, e.g.:
# $EVENT subgraphName datasourceName eventName eventArg1 eventArg2 ...

DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $DIR/constants.sh

# Get tokens
$EVENT protocol K2 Transfer $ZERO $WALLET 1$E18
$EVENT protocol KVcm Transfer $ZERO $WALLET 1$E18
$EVENT protocol KVcmUsdcLP Transfer $ZERO $WALLET 1$E18
$EVENT protocol KVcmK2LP Transfer $ZERO $WALLET 1$E18

# Create classes
$EVENT protocol CarbonLedger ClassVaultRegistered $CLASS1
$EVENT protocol CarbonLedger ClassVaultRegistered $CLASS2
$EVENT protocol CarbonLedger ClassVaultRegistered $CLASS3

# Register tokens
$EVENT protocol CarbonLedger CreditRegisteredForClass $CLASS1 $TOKEN1 [0]
$EVENT protocol CarbonLedger CreditRegisteredForClass $CLASS1 $TOKEN2 [0]
$EVENT protocol CarbonLedger CreditRegisteredForClass $CLASS1 $TOKEN3 [0]
$EVENT protocol CarbonLedger CreditRegisteredForClass $CLASS2 $TOKEN4 [0]
$EVENT protocol CarbonLedger CreditRegisteredForClass $CLASS2 $TOKEN5 [0]
$EVENT protocol CarbonLedger CreditRegisteredForClass $CLASS3 $TOKEN7 [0]
