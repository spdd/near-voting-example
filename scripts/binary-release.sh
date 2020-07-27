#!/bin/bash
set -euo pipefail

function branch_to_net {
    if [ "$1" == "master" ]; then 
        echo "guildnet"
    elif [ "$1" == "beta" ]; then
        echo "betanet"
    elif [ "$1" == "stable" ]; then
        echo "testnet"
    fi
}

branch=${BUILDKITE_BRANCH:-${GITHUB_REF##*/}}
net=$(branch_to_net $branch)
commit=${BUILDKITE_COMMIT:-${GITHUB_SHA}}
if [[ ${commit} == "HEAD" ]]; then
    commit=$(git rev-parse HEAD)
fi
os=$(uname)

make release

# Save network state and config to S3
mkdir -p outside/metadata
mkdir -p ~/.ssh
echo "$SSH_PRIV_KEY" | tr -d '\r' > ~/.ssh/id_rsa
echo "$SSH_PUB_KEY" > ~/.ssh/id_rsa.pub
chmod 700 ~/.ssh/id_rsa
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa 
ssh-keyscan -H $SSH_HOST >> ~/.ssh/known_hosts

scp -o StrictHostKeyChecking=no $SSH_USER@$SSH_HOST:~/.near/${net}/config.json outside/

msg=$(git log --no-merges -1 --oneline)
if [[ $msg == *"hard-fork"* ]]; then
    #accessing state-viewer more directly
    #scp -o StrictHostKeyChecking=no target/release/state-viewer $SSH_USER@$SSH_HOST:~/
    #ssh $SSH_USER@$SSH_HOST "~/.nearup/nearup stop && ./state-viewer --home ~/.near/${net}/ dump_state && ~/.nearup/nearup ${net} --nodocker"
    ssh $SSH_USER@$SSH_HOST "source ~/.cargo/env && cd ~/nearcore && ~/.nearup/nearup stop && cargo run -p state-viewer -- --home ~/.near/${net} dump_state" 
    scp -o StrictHostKeyChecking=no $SSH_USER@$SSH_HOST:~/.near/${net}/output.json outside/genesis.json
else
    scp -o StrictHostKeyChecking=no $SSH_USER@$SSH_HOST:~/.near/${net}/genesis.json outside/
fi

date '+%Y%m%d_%H%M%S' > outside/metadata/latest_deploy_at
cat outside/genesis.json | jq -r '.genesis_time' > outside/metadata/genesis_time
cat outside/genesis.json | jq -r '.protocol_version' > outside/metadata/protocol_version
md5sum outside/genesis.json | awk '{ print $1 }' > outside/metadata/genesis_md5sum
echo $commit > outside/metadata/latest_deploy

cp outside/genesis.json outside/metadata/
cp outside/config.json outside/metadata/

function upload_binary {
    aws s3 cp --acl public-read target/release/$1 s3://build.openshards.io/nearcore/${os}/${branch}/$1
    aws s3 cp --acl public-read target/release/$1 s3://build.openshards.io/nearcore/${os}/${branch}/${commit}/$1
}

function upload_metadata {
    aws s3 cp --acl public-read outside/metadata/$1 s3://build.openshards.io/nearcore-deploy/${net}/$1
}

upload_binary near
upload_binary keypair-generator
upload_binary genesis-csv-to-json
upload_binary near-vm-runner-standalone
upload_binary state-viewer
upload_binary store-validator


upload_metadata latest_deploy_at
upload_metadata genesis_time
upload_metadata protocol_version
upload_metadata genesis_md5sum
upload_metadata latest_deploy
upload_metadata genesis.json
upload_metadata config.json
