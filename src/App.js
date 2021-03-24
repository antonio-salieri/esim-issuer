import './App.css';

import { UseOptions, CW721, musselnetOptions as netOptions } from './cosmwasm';
import { contractAddress, walletMnemonic, nftOwner } from './config';
import { v4 as uuidv4 } from 'uuid';
import { Component, useState } from 'react';
import esimProfile from './esim/dummyEsim';
class App extends Component {
  constructor(props) {
    super(props);

    this.cw721 = null;
    this.client = null;
    this.contract = null;

    this.state = {
      issuedTokens: [],
      identifiers: [],
    }

    for(let i = 0; i < 10; i++) {
      this.state.identifiers.push({
        identifier: uuidv4(),
        esimProfile: esimProfile(),
      });
    }

    this.fetchTokens();
  }

  issueNFT(client, contract, nftData) {
    console.info('issuing eSIM to NFT', nftData.identifier)
    console.info('client.sender', client.sender);
    
    client.client.getAccount(client.sender).then((account) => {
      console.info('account', account);
      client.client.getChainId().then(cid => console.info('chain id', cid));
    
      contract.mint(nftData.identifier, nftOwner, nftData.esimProfile).then((r) => {
        console.info('issued nft!')
        console.info('mint response', r);
        this.fetchTokens()
        contract.nftInfo(nftData.identifier).then(nfti => console.info('nftInfo', nfti));
      })
    });
  }
  
  fetchTokens() {
    UseOptions(netOptions).fromMnemonic(walletMnemonic).then(cli => {
      this.client = cli;
      this.cw721 = CW721(this.client);
      this.contract = this.cw721.use(contractAddress);
  
      this.contract.allTokens('0', 10000).then(tokens => {
        this.setState({...this.state, issuedTokens: tokens.tokens});
        console.info('exisiting tokens', tokens);
      });
    });
  }

  issuedTokensRows() {
    return this.state.issuedTokens.map((t, i) => <tr key={t}>
      <td>{i}</td>
      <td>
        <button onClick={() => this.getNft(t)}>{t}</button></td>
    </tr>);
  }

  getNft(t) {
    this.contract.nftInfo(t).then(nft => {
      alert(JSON.stringify(nft));
    });
  }

  itemRows() {
    return this.state.identifiers.map((i) => <tr key={i.identifier}>
      <td>{i.identifier}</td>
      <td><textarea defaultValue={i.esimProfile}></textarea></td>
      <td>
        <button onClick={() => this.issueNFT(this.client, this.contract, i)}>
          issue eSIM to NFT
        </button>
      </td>
    </tr>);
  }

  render() {
    return (
      <div className="App">
        <header className="App-header">
          <h1>eSIM NFT issuer</h1>
        </header>
        <div>
          <h2>Issue new eSIM NFT</h2>
          <table>
            <thead>
              <tr>
                <th>Identifier</th>
                <th>eSIM profile</th>
                <th>Action</th>
              </tr>
            </thead>
            <tbody>
              {this.itemRows()}
            </tbody>
          </table>
  
          <h2>Already issued eSIM NFTs</h2>
          <table>
            <thead>
              <tr>
                <th>#</th>
                <th>NFT</th>
              </tr>
            </thead>
            <tbody>
              {this.issuedTokensRows()}
            </tbody>
          </table>
          {}
        </div>
      </div>
    );
  }
}

export default App;
