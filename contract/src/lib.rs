use borsh::{BorshDeserialize, BorshSerialize};
use near_sdk::{env, near_bindgen};

use std::collections::HashMap;

#[global_allocator]
static ALLOC: wee_alloc::WeeAlloc = wee_alloc::WeeAlloc::INIT;

#[near_bindgen]
#[derive(Default, BorshDeserialize, BorshSerialize)]
pub struct Voting {
    votes_received: HashMap<String, i32>,
}

#[near_bindgen]
impl Voting {
    #[init]
    pub fn new() -> Self {
        Self {
            votes_received: HashMap::new(),
        }
    }

    pub fn add_candidate(&mut self, candidate: String) {
        self.votes_received.insert(candidate, 0);
    }

    pub fn get_total_votes_for(self, name: String) -> Option::<i32> {
        if !self.valid_candidate(&name) {
            ()
        }
        self.votes_received.get(&name).cloned()
    }

    pub fn vote_for_candidate(&mut self, name: String) {
        let counter = self.votes_received.entry(name).or_insert(0);
        *counter += 1;
    }

    pub fn valid_candidate(&self, name: &String) -> bool {
        for (candidate, votes) in self.votes_received.iter() {
            if self.votes_received.contains_key(name) {
                return true
            }
        }
        false
    }
    
    pub fn get_candidates(&self) -> HashMap<String, i32> {
        self.votes_received.clone()
    }
}

#[cfg(not(target_arch = "wasm32"))]
#[cfg(test)]
mod tests {
    use super::*;
    use near_bindgen::MockedBlockchain;
    use near_bindgen::{testing_env, VMContext};

    fn get_context(input: Vec<u8>, is_view: bool) -> VMContext {
        VMContext {
            current_account_id: "alice_near".to_string(),
            signer_account_id: "bob_near".to_string(),
            signer_account_pk: vec![0, 1, 2],
            predecessor_account_id: "carol_near".to_string(),
            input,
            block_index: 0,
            block_timestamp: 0,
            account_balance: 0,
            account_locked_balance: 0,
            storage_usage: 0,
            attached_deposit: 0,
            prepaid_gas: 10u64.pow(18),
            random_seed: vec![0, 1, 2],
            is_view,
            output_data_receivers: vec![],
        }
    }

    #[test]
    fn test_add_candidate() {
        let context = get_context(vec![], false);
        testing_env!(context);
        let mut contract = Voting::new();
        contract.add_candidate("Jeff".to_string());
        assert_eq!(0, contract.get_total_votes_for("Jeff".to_string()).unwrap());
    }

    #[test]
    fn test_get_total_votes_for() {
        let context = get_context(vec![], true);
        testing_env!(context);
        let contract = Voting::new();
        assert_eq!(None, contract.get_total_votes_for("Anna".to_string()));
    }
}