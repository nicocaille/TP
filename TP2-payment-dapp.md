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
yarn add --dev hardhat
yarn add --dev @nomiclabs/hardhat-waffle ethereum-waffle chai @nomiclabs/hardhat-ethers ethers
yarn add @openzeppelin/contracts
```

## Project initialization & Hardhat configuration

From the `payment-dapp` folder:

```bash
yarn hardhat init
```

Please select the following options while running this command:

```bash
888    888                      888 888               888
888    888                      888 888               888
888    888                      888 888               888
8888888888  8888b.  888d888 .d88888 88888b.   8888b.  888888
888    888     "88b 888P"  d88" 888 888 "88b     "88b 888
888    888 .d888888 888    888  888 888  888 .d888888 888
888    888 888  888 888    Y88b 888 888  888 888  888 Y88b.
888    888 "Y888888 888     "Y88888 888  888 "Y888888  "Y888

👷 Welcome to Hardhat v2.22.17 👷‍

✔ What do you want to do? · Create a TypeScript project
✔ Hardhat project root: · /Users/ngc/payment-dapp
✔ Do you want to add a .gitignore? (Y/n) · y

You need to install these dependencies to run the sample project:
  yarn add --dev "hardhat@^2.14.0" "@nomicfoundation/hardhat-network-helpers@^1.0.0" "@nomicfoundation/hardhat-verify@^2.0.0" "chai@^4.2.0" "hardhat-gas-reporter@^1.0.8" "solidity-coverage@^0.8.0" "@nomicfoundation/hardhat-ignition@^0.15.0" "@types/chai@^4.2.0" "@types/mocha@>=9.1.0" "@types/node@>=18.0.0" "ts-node@>=8.0.0" "typescript@>=4.5.0" "@nomicfoundation/hardhat-toolbox@^5.0.0" "@nomicfoundation/hardhat-chai-matchers@^2.0.0" "@nomicfoundation/hardhat-ethers@^3.0.0" "ethers@^6.4.0" "@typechain/hardhat@^9.0.0" "typechain@^8.3.0" "@typechain/ethers-v6@^0.5.0" "@nomicfoundation/hardhat-ignition-ethers@^0.15.0"

✨ Project created ✨

See the README.md file for some example tasks you can run

Give Hardhat a star on Github if you're enjoying it! ⭐️✨

     https://github.com/NomicFoundation/hardhat
```

and install the dependencies as per the instructions above.

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
yarn add --dev hardhat@latest @nomiclabs/hardhat-ethers@^2.0.0 ethers@^5.0.0
yarn hardhat compile
```

You should end up with the following completion message:

```bash
Downloading compiler 0.8.20
Compiled 6 Solidity files successfully (evm target: paris).
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

and run the following command:

```bash
yarn hardhat run scripts/deploy.js --network testnet
```

Based on the successful completion of the last command, you will have the smart contract address in the terminal.

```bash
Deploying contracts with account: 0xf29B39E720cA9E8B803a793041C6712A63639159
Contract deployed to: 0xdFEc08Dd11f43dB87e61B7A510402Bb0937f052E
```

You can now head off to the chain explorer to check the deployment transaction and the balance for your wallet address as we minted some at inception.

You will all use this contract address in MetaMask in order to see your balance directly from it.
