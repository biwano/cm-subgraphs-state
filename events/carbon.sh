# Sample events file
# One event per line, e.g.:
# Create event:
# $EVENT subgraphName datasourceName eventName eventArg1 eventArg2 ...

# Deploy template contract and recover address
# ADDRESS=$($DEPLOY_TEMPLATE  subgraphName templateName alias)

set -e

DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $DIR/constants.sh

# Issue CMARK-1-2025
CMARK_1_2025_ADDRESS=$($DEPLOY_TEMPLATE carbon CreditToken CMARK_1_2025)
$EVENT carbon CmarkFactory Issued CMARK-1-2025 1000$E18 $WHALEWALLET $CMARK_1_2025_ADDRESS CMARK-1-2025-PROV
$EVENT carbon CMARK_1_2025 Transfer $ZERO $WHALEWALLET 1000$E18 
$EVENT carbon CMARK_1_2025 Transfer $WHALEWALLET $WALLET 200$E18 

# Cannot issue toucan credits because of calls to the contract

# Credit manager (lets fake some Toucan credits)
TCO2_1_2024_ADDRESS=$($DEPLOY_TEMPLATE carbon CreditToken TCO2_1_2024)
$EVENT carbon CreditManager CreditAdded $TCO2_1_2024_ADDRESS 0 false TCO2-1 2024 "Toucan Carbon Offsets 1-2024" ["meth1"] "earth" "China" "Asia"
$EVENT carbon TCO2_1_2024 Transfer $ZERO $WHALEWALLET 1000$E18 
$EVENT carbon TCO2_1_2024 Transfer $WHALEWALLET $WALLET 200$E18 

# Retirements
$EVENT carbon CMARK_1_2025 Retired 50$E18 $WALLET "Me" "message" CMARK-1-2025 $OTHERWALLET "cn"

# Canont test aggregator retirements because calls should be in the same transaction
#$EVENT carbon RetirementAggregator AggregatorRetired 0 $WALLET "Me" $OTHERWALLET "HIM" "message" $CMARK_1_2025_ADDRESS 0 0 0 50$E18 





