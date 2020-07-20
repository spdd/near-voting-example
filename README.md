Near voting DApp example in Rust Fix-04
=================================

## Description

This contract implements simple voting dapp backed by storage on blockchain.
Contract in `contract/src/lib.rs` provides methods to vote / get votes for candidate

## To Run

```
git clone https://github.com/spdd/near-voting-example
```


## Setup 
Install dependencies:

```
yarn
```

Make sure you have `near-shell` by running:

```
near --version
```

If you need to install `near-shell`:

```
npm install near-shell -g
```

## Set your NODE_ENV

```
export NODE_ENV=development
```

## Login
If you do not have a NEAR account, please create one with [NEAR Wallet](https://wallet.nearprotocol.com).

In the project root, login with `near-shell` by following the instructions after this command:

```
near login
```

Modify the top of `src/config.js`, changing the `CONTRACT_NAME` to be the NEAR account that was just used to log in.

```javascript
…
const CONTRACT_NAME = 'YOUR_ACCOUNT_NAME_HERE'; /* TODO: fill this in! */
…
```

Start the example!

```
yarn start
```

## To Test

```
cd contract
cargo test -- --nocapture
```

## To Explore

- `contract/src/lib.rs` for the contract code
- `src/index.html` for the front-end HTML
- `src/main.js` for the JavaScript front-end code and how to integrate contracts
- `src/test.js` for the JS tests for the contract
