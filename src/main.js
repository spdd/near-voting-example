import "regenerator-runtime/runtime";
import * as nearAPI from "near-api-js";
import getConfig from "./config";

let nearConfig = getConfig(process.env.NODE_ENV || "development");
window.nearConfig = nearConfig;

// Connects to NEAR and provides `near`, `walletAccount` and `contract` objects in `window` scope
async function connect() {
  // Initializing connection to the NEAR node.
  window.near = await nearAPI.connect(Object.assign(nearConfig, { deps: { keyStore: new nearAPI.keyStores.BrowserLocalStorageKeyStore() }}));

  // Needed to access wallet login
  window.walletAccount = new nearAPI.WalletAccount(window.near);

  // Initializing our contract APIs by contract name and configuration.
  window.contract = await near.loadContract(nearConfig.contractName, {
    viewMethods: ['get_total_votes_for', 'get_candidates', 'valid_candidate'],
    changeMethods: ['add_candidate', 'vote_for_candidate'],
    sender: window.walletAccount.getAccountId()
  });
}

let candidates = {"Anna": "candidate1", "Jeff": "candidate2", "Jose": "candidate3"}


window.voteForCandidate = function(candidate) {
  let candidateName = document.querySelector('input[name="vote"]').value;
  document.querySelector('#msg').innerText = "Vote has been submitted. Please wait...";
  document.querySelector('input[name="vote"]').innerText = '';
  contract.vote_for_candidate({ name: candidateName }).then(updateUI);
}

function updateUI() {
  if (!window.walletAccount.getAccountId()) {
    Array.from(document.querySelectorAll('.sign-in')).map(it => it.style = 'display: block;');
  } else {
    Array.from(document.querySelectorAll('.after-sign-in')).map(it => it.style = 'display: block;');

    let candidateNames = Object.keys(candidates);
    for (var i = 0; i < candidateNames.length; i++) {
      let name = candidateNames[i];
      contract.get_total_votes_for({ name: name }).then(count => {
        document.querySelector('#' + candidates[name]).innerText = count == undefined ? 'calculating...' : count;
        document.querySelector('#msg').innerText = "Please enter candidate name:";
      });
    }
  }
}

// Log in user using NEAR Wallet on "Sign In" button click
document.querySelector('.sign-in .btn').addEventListener('click', () => {
  walletAccount.requestSignIn(nearConfig.contractName, 'NEAR Voting Example');
});

document.querySelector('.sign-out .btn').addEventListener('click', () => {
  walletAccount.signOut();
  // TODO: Move redirect to .signOut() ^^^
  window.location.replace(window.location.origin + window.location.pathname);
});

window.nearInitPromise = connect()
.then(updateUI)
.catch(console.error);


