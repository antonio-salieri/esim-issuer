import './App.css';

import { UseOptions, CW721, musselnetOptions as netOptions } from './cosmwasm';
import { contractAddress, walletMnemonic } from './config';
import { v4 as uuidv4 } from 'uuid';

const issueNFT = async (identifier) => {
  console.info('issuing eSIM to NFT', identifier)
  const client = await UseOptions(netOptions).fromMnemonic(walletMnemonic);
  const cw721 = CW721(client);
  console.info('client.sender', client.sender);
  
  const account = await client.client.getAccount(client.sender);
  console.info('account', account);
  console.info('chain id', await client.client.getChainId());
  
  console.info('uuid', uuidv4());

  const contract = cw721.use(contractAddress);

  await contract.mint(identifier, )

  console.info('nftInfo', await contract.nftInfo(identifier));
}

function App() {
  let identifiers = [];
  // if (!localStorage.getItem('nftIdentifiers')) {
  //   for(let i = 0; i < 10; i++) {
  //     identifiers.push(uuidv4());
  //   }
  //   localStorage.setItem('nftIdentifiers', JSON.stringify(identifiers));
  // }
  // identifiers = JSON.parse(localStorage.getItem('nftIdentifiers'));
  for(let i = 0; i < 10; i++) {
    identifiers.push(uuidv4());
  }

  const itemRows = identifiers.map((i) => <tr>
    <td>{i}</td>
    <td>
      <button onClick={() => issueNFT(i)}>
        issue eSIM to NFT
      </button>
    </td>
  </tr>);

  return (
    <div className="App">
      <header className="App-header">
        <h1>eSIM NFT Issuer</h1>
      </header>
      <div>
        <table>
          <thead>
            <tr>
              <th>NFT identifier</th>
              <th>Action</th>
            </tr>
          </thead>
          <tbody>
            {itemRows}
          </tbody>
        </table>
        {}
      </div>
    </div>
  );
}

export default App;
