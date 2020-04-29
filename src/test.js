describe('Token', function () {
  let near;
  let contract;
  let accountId;

  jasmine.DEFAULT_TIMEOUT_INTERVAL = 10000;

  beforeAll(async function () {
    console.log('nearConfig', nearConfig);
    near = await nearlib.connect(nearConfig);
    accountId = nearConfig.contractName;
    contract = await near.loadContract(nearConfig.contractName, {
      viewMethods: ['get_total_votes_for', 'get_candidates', 'valid_candidate'],
      changeMethods: ['vote_for_candidate', 'add_candidate'],
      sender: accountId
    });
  });

  describe('voting', function () {
    // TODO:
  });
});
