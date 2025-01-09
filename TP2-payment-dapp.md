# Creation d'un token de payment ERC20

## Requirements

Install ASDF

https://asdf-vm.com/

```bash
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.15.0
hash
rehash
asdf plugin-add nodejs
asdf list-all nodejs
asdf install nodejs 22.12.0
asdf global nodejs 22.12.0
hash
rehash
npm install -g npm@11.0.0
npm install -g yarn
```

## Project setup

Go to a project folder where you will store your different projects.

```bash
mkdir payment-dapp
cd payment-dapp
yarn init -2
yarn config set nodeLinker node-modules
yarn add hardhat --dev
yarn add --dev @nomiclabs/hardhat-waffle ethereum-waffle chai @nomiclabs/hardhat-ethers ethers
yarn add @openzeppelin/contracts
```

## Project initialization & Hardhat configuration

From the `payment-dapp` folder:

```bash
yarn hardhat init
```

You will then need to edit the `hardhat.config.ts` with the following content:

```javascript
require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-ethers");
const { mnemonic } = require("./secrets.json");

module.exports = {
  defaultNetwork: "testnet",
  networks: {
    testnet: {
      url: "https://bsc-testnet-rpc.publicnode.com",
      chainId: 97,
      gasPrice: 20000000000,
      accounts: { mnemonic: mnemonic },
    },
  },
  solidity: {
    version: "0.8.20",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts",
  },
};
```

At the root of the `payment-dapp` folder, you will need to create a file `secrets.json` that will contain your seed phrase:

```json
{
  "mnemonic": "list_of_the_12_or_24_words_from_your_seed_phrase"
}
```

and of course, add this `secrets.json` to your `.gitignore` file.

## Creating a smart contract

Create a new file called `PaymentToken.sol` in the `contracts` folder and add the following code:

```solidity
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.22 <0.9.0;
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
Since `PaymentToken` is an ERC20 token and we are using OpenZeppelin's ERC20 contract, we have a few ready-made functions like `transfer`, `approve`, `allowance`, etc.

## Deployment of the smart contract

To compile and deploy the smart contract run the following command:

```bash
yarn hardhat compile
```

Then we need to create the deployment script `scripts/deploy.js` with the following content:

```javascript
async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with account:", deployer.address);

  const Contract = await ethers.getContractFactory("PaymentToken");
  const contract = await Contract.deploy();
  await contract.deployed();

  console.log("Contract deployed to:", contract.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
```

Based on the successful completion of the last command, you will have the smart contract address in the terminal.

You can now head off to the chain explorer to check the deployment transaction and the balance for your wallet address as we minted some at inception.

You will all use this contract address in MetaMask in order to see your balance directly from it.
