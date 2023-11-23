# Requirements

Install ASDF

https://asdf-vm.com/

```bash
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.13.1
hash
rehash
asdf plugin-add nodejs
asdf list-all nodejs
asdf install nodejs 21.2.0
asdf global nodejs 21.2.0
hash
rehash
npm install -g truffle yarn
```

# Project setup

```bash
npx create-next-app --typescript payment-dapp
cd payment-dapp
truffle init
yarn add @openzeppelin/contracts @truffle/hdwallet-provider web3 dotenv tailwindcss
```

The command `npx create-next-app` will create a basic Next.js project with typescript support, and `truffle init` will scaffold a Truffle project.
The code libraries `@openzeppelin/contracts`, `@truffle/hdwallet-provider`, and `web3` will be used to create, deploy and integrate our smart contract. `dotenv` is for dealing with environment variables, and `tailwindcss` is used for UI styling.

# Creating a smart contract

Create a new file called `PaymentToken.sol` in the `contracts` directory and add the following code:

```solidity
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.6;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract PaymentToken is ERC20 {
    address public owner;

    constructor() ERC20("CYTech EUR Payment Token", "CEUR") {
        owner = msg.sender;
        _mint(msg.sender, 1000000 * 10**18);
    }

    function mint(address to, uint256 amount) external {
        require(msg.sender == owner, "Only owner can mint");
        _mint(to, amount);
    }
}
```

We create a new ERC20 token using the OpenZeppelin ERC20 contract called **CYTech EUR Payment Token**. This is the token we will use to make payments in our peer-to-peer payment dApp.
In the constructor of our contract, we are minting and sending **1,000,000 CEUR** tokens to the contract's owner, the account deploying the contract.
Since `PaymentToken` is an ERC20 token and we are using OpenZeppelin's ERC20 contract, we have a few ready-made functions like `transfer`, `approve`, `allowance`, etc. We will be looking into the `transfer` function in our dApp, and come back to this when we start our frontend.

`truffle-config.js`

```solidity
const HDWalletProvider = require("@truffle/hdwallet-provider");
const fs = require("fs");
const mnemonic = fs.readFileSync(".secret").toString().trim();
require("dotenv").config();

module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 7545,
      network_id: "*",
    },
    matic: {
      provider: () =>
        new HDWalletProvider(
          mnemonic,
          `https://polygon-mumbai.g.alchemy.com/v2/${process.env.ALCHEMY_POLYGON_API}/`
        ),
      network_id: 80001,
      confirmations: 2,
      timeoutBlocks: 200,
      skipDryRun: true,
      chainId: 80001,
    },
  },
  contracts_directory: "./contracts",
  contracts_build_directory: "./abis",
  compilers: {
    solc: {
      version: "^0.8.6",
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },

  db: {
    enabled: false,
  },
};
```

Head over to https://github.com/nicocaille/payment-dapp to clone the repository and retrieve the missing files

Create a `.env` file at the root of the project which will contain the API key from Alchemy we created during the previous module:

```bash
ALCHEMY_POLYGON_API="YOUR_API_KEY"
```

Create a `.secret` file at the root of the project which will contain the 24 mnemonic words we created during the previous module

To compile and deploy the smart contract run the following command:

```bash
truffle compile
truffle deploy --network matic
```

Based on the successful completion of the last command, you will have the smart contract address in the terminal to put in the frontend part of this dapp and also to be added to MetaMask to see your tokens balance.
