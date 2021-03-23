# Set env
. ./wasm.env

# see how many codes we have now
wasmd query wasm list-code $NODE

JSON=$(jq -n --arg addr $(wasmd keys show -a fred) '{"denom":"ucosm","address":$addr}') && curl -X POST --header "Content-Type: application/json" --data "$JSON" https://faucet.cosmwasm.hub.hackatom.org

# store cosmons contract #

# gas is huge due to wasm size... but auto-zipping reduced this from 1.8M to around 600k
# you can see the code in the result
export COSMONS_RES=$(wasmd tx wasm store artifacts/cosmons.wasm --from fred $TXFLAG -y)

# you can also get the code this way
export COSMONS_CODE_ID=$(echo $COSMONS_RES | jq -r '.logs[0].events[0].attributes[-1].value')

# no contracts yet, this should return `null`
wasmd query wasm list-contract-by-code $COSMONS_CODE_ID $NODE

# instantiate cosmons #

export COSMONS_INIT=$(jq -n --arg fred $(wasmd keys show -a fred) '{ "name": "prbl-esim-nft", "symbol": "PSIM", "minter": $fred }')
wasmd tx wasm instantiate $COSMONS_CODE_ID "$COSMONS_INIT" --from fred --amount=50000umayo  --label "prbl esim nft" $TXFLAG -y

wasmd query wasm list-contract-by-code $COSMONS_CODE_ID $NODE
export COSMONS_CONTRACT=$(wasmd query wasm list-contract-by-code $COSMONS_CODE_ID -o json $NODE | jq -r '.contract_infos[0].address')


# we should see this contract with 50000umayo
wasmd query wasm contract $COSMONS_CONTRACT $NODE
wasmd query account $COSMONS_CONTRACT $NODE

# you can dump entire contract state
wasmd query wasm contract-state all $COSMONS_CONTRACT $NODE

# Note that keys are hex encoded, and val is base64 encoded.
# To view the returned data (assuming it is ascii), try something like:
# (Note that in many cases the binary data returned is non in ascii format, thus the encoding)
wasmd query wasm contract-state all $COSMONS_CONTRACT $NODE --output "json" | jq -r '.models[0].key' | xxd -r -ps
wasmd query wasm contract-state all $COSMONS_CONTRACT $NODE --output "json" | jq -r '.models[0].value' | base64 -d


# or try a "smart query", executing against the contract
wasmd query wasm contract-state smart $COSMONS_CONTRACT '{}' $NODE
# (since we didn't implement any valid QueryMsg, we just get a parse error back)

#

NFT_ID=38111222333
# Mint nft to bob
wasmd tx wasm execute $COSMONS_CONTRACT '{"mint": {"token_id": $NFT_ID, "esim_profile": "esim38111222333", "owner": "wasm1eymjpuh68vf9tu569avvumhhvwspc7azfdvk9y"}}' --from fred $TXFLAG -y --trace $NODE

# Query nft
wasmd query wasm contract-state smart $COSMONS_CONTRACT '{"nft_info": {"token_id": "'$NFT_ID'"}}' $NODE

# Query all
wasmd query wasm contract-state smart $COSMONS_CONTRACT '{"all_nft_info": {}}' $NODE



# store marketplace contract #

# gas is huge due to wasm size... but auto-zipping reduced this from 1.8M to around 600k
# you can see the code in the result
export MARKETPLACE_RES=$(wasmd tx wasm store artifacts/marketplace.wasm --from fred $TXFLAG -y)

# you can also get the code this way
export MARKETPLACE_CODE_ID=$(echo $MARKETPLACE_RES | jq -r '.logs[0].events[0].attributes[-1].value')

# no contracts yet, this should return `null`
wasmd query wasm list-contract-by-code $MARKETPLACE_CODE_ID $NODE

# Instatntiate marketplace #

export MARKETPLACE_INIT='{ "name": "prbl-nft-marketplace" }'
wasmd tx wasm instantiate $MARKETPLACE_CODE_ID "$MARKETPLACE_INIT" --from fred --amount=50000umayo  --label "prbl market" $TXFLAG -y

wasmd query wasm list-contract-by-code $MARKETPLACE_CODE_ID $NODE
export MARKETPLACE_CONTRACT=$(wasmd query wasm list-contract-by-code $MARKETPLACE_CODE_ID -o json $NODE | jq -r '.contract_infos[0].address')


# we should see this contract with 50000umayo
wasmd query wasm contract $MARKETPLACE_CONTRACT $NODE
wasmd query account $MARKETPLACE_CONTRACT $NODE

# you can dump entire contract state
wasmd query wasm contract-state all $MARKETPLACE_CONTRACT $NODE

# Note that keys are hex encoded, and val is base64 encoded.
# To view the returned data (assuming it is ascii), try something like:
# (Note that in many cases the binary data returned is non in ascii format, thus the encoding)
wasmd query wasm contract-state all $MARKETPLACE_CONTRACT $NODE --output "json" | jq -r '.models[0].key' | xxd -r -ps
wasmd query wasm contract-state all $MARKETPLACE_CONTRACT $NODE --output "json" | jq -r '.models[0].value' | base64 -d


# or try a "smart query", executing against the contract
wasmd query wasm contract-state smart $MARKETPLACE_CONTRACT '{}' $NODE
# (since we didn't implement any valid QueryMsg, we just get a parse error back)
