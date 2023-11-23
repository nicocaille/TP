# Create an NFT smart contract with HardHat

## Introduction

In this tutorial we will learn how to use HardHat which is a popular framework used for smart contract development. It is a JavaScript based framework like Truffle but has certain advantages over Truffle which we will go over in the tutorial. The goal of this tutorial is to build an awesome NFT project where we can convert anything into an NFT. We will also learn how to write, test and deploy smart contracts using the Hardhat framework.

## Creating Polygonscan API key

When we deploy our contract to the blockchain (either mainnet or testnet), it is a good practice to verify the code of our smart contract after deploying it. If our smart contract is verified, then the smart contract code will be visible on the block explorer and users will be able to interact with the smart contract directly from the block explorer (such as Polygonscan). Verifying the source code is highly encouraged as it makes our project more transparent, and users are more likely to interact with it.

Using a HardHat plugin, smart contracts can be verified automatically during the deployment process. To do this, we will need a Polygonscan API key. Follow these steps to get your own API key:

1. Open [Polygonscan](https://polygonscan.com/).
2. Click on SignIn in the upper right corner of the page.
3. If you already have an account, enter your username and password to login, or else create your new account by visiting https://polygonscan.com/register.
4. Once you are logged in, go to the API-KEYs section on the left sidebar.
5. Click on the "Add" button, give it a name and click on continue.

You now have an API key which will allow you to access the Polygonscan API features such as contract verification. This key will be same for both mainnet and testnet.

## Creating a HardHat project

To install HardHat, run the command:

```bash
npm install -g hardhat
```

This will install HardHat globally so that later we can make use of the `npx` command to create HardHat projects.

Now to create our project, we will use the following code:

```bash
mkdir art_gallery # I am naming my project folder as art_gallery but any other name works
cd art_gallery    # move into the directory
npx hardhat
```

We can start with a basic sample project so that it is easier to understand the project layout, so let's just press Enter. After this we will be asked to set our project root - Press Enter to keep the default value. Next it will ask if we want a .gitignore file. Press Enter again to keep the default value of "yes" or type n for "no". It will then ask if we want to install the dependencies for our sample project. Press Enter to accept the default of yes. Now HardHat will create a sample project for us and install the dependencies.

## Understanding the code

Now let's open our project and take a look at what it contains.

What we get is a very simple project scaffold. The directory names are quite self explanatory. All our smart contracts, script files and test scripts are going to be kept in their respective directories (folders).

`hardhat.config.js` is the file which contains all the configuration details specific to HardHat.

Before we start writing our smart contract, let's look at the `hardhat.config.js` file which is the heart of our HardHat project. The contents of this file by default are:

```solidity
require("@nomiclabs/hardhat-waffle");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.4",
};
```

We start by importing the `@nomiclabs/hardhat-waffle` package which will give us access to the `hre` class. HRE is short for Hardhat Runtime Environment which is an object that contains all the functionality that HardHat exposes. You can think of it as "HardHat is hre".

Next is where we define various tasks which can be run by typing `npx hardhat <TASK_NAME>`

While developing our project we are also doing to write our own custom tasks.

At the end of the file is `module.export`, this is where we are going to list various parameters like compiler version, networks to use, API keys, etc. Please note, here we have defined the solidity version as `0.8.4`.

## Install the OpenZeppelin library

While writing any program, we always prefer using various libraries so that we don't have to write everything from scratch. Since we are going to build an NFT based project, we will follow the standards defined in [EIP-721](https://eips.ethereum.org/EIPS/eip-721). The best way to do this is to import the ERC721 contract present in the OpenZeppelin contracts library and only making the necessary changes for our project. To install this package, open a terminal and run the command:

```bash
npm install @openzeppelin/contracts
```

## Starting our smart contract

Let's create a new file named `Artwork.sol` inside the `contracts` directory. This is going to be our first smart contract which will help us in creating NFTs.

```solidity
//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.4;

contract Artwork {}
```

We start by defining the License of our smart contract. For this tutorial we are keeping it unlicensed. If we don't define the license, it will cause a warning during compile time. The `pragma` keyword is used to define the Solidity version used to compile the code. Make sure you are using the same Solidity version as defined in the `hardhat.config.js` file.

Next we are going to import the ERC721 smart contract from the OpenZeppelin library which we just installed. After the line defining the Solidity version and before defining the contract, import the ERC721 contract:

```solidity
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
```

### Inheriting ERC721 and constructor initialisation

Make the following modifications to the code:

```solidity
//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Artwork is ERC721 {

    constructor(
        string memory name,
        string memory symbol
    ) ERC721(name, symbol) {}

}
```

Here we are doing the following things:

- Inheriting the OpenZeppelin ERC721 smart contract into our `Artwork.sol` smart contract using the `is` keyword.
- The constructor is always the first function that is called while deploying a smart contract. Since we are inheriting another smart contract, we have to pass in the values for the constructor of that smart contract while defining our constructor. Here we take a name and symbol as constructor arguments and are passing them to the constructor of ERC721.
- `name` and `symbol` are going to be the name and symbol of our NFT respectively.

### Defining tokenCounter

NFTs are called Non-Fungible Tokens because each one is unique. What makes them unique is the token id assigned to them. We are going to define a global variable called tokenCounter and use it for calculating the token id. It will start with zero and increment by 1 for every new NFT that is created (or "minted"). The value of tokenCounter is set to 0 in the constructor.

```solidity
//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Artwork is ERC721 {

    uint256 public tokenCounter;

    constructor(
        string memory name,
        string memory symbol
    ) ERC721(name, symbol) {
        tokenCounter = 0;
    }

}
```

### Creating the mint function

Now we are going to define a mint function which can be called by any user in order to mint new NFTs. Each NFT will have certain data associated with it. In our case, we are using images or other collectibles as the basis of the NFT and hence the image should be somehow stored in the smart contract. Since storing data directly on a blockchain has an associated cost, it won't be financially feasible if the entire image and other associated data (metadata) is stored. So, we will need to host the image separately along with a JSON file containing all the details about the NFT. The image and JSON file can be hosted separately either decentralised (using IPFS) or centrally using traditional methods. The JSON file contains the link to the image as well. Once the JSON file is hosted, the link pointing to that JSON file is stored in the blockchain in the as tokenURI. URI stands for "Universal Resource Identifier".

With that in mind, the mint function is how we create each NFT associated with the smart contract:

```solidity
function mint(string memory _tokenURI) public {
    _safeMint(msg.sender, tokenCounter);
    _setTokenURI(tokenCounter, _tokenURI);

    tokenCounter++;
}
```

`_safeMint` is another function present in the OpenZeppelin ERC721 contract which is used to mint new NFTs. It takes two parameters:

- `to`: The first parameter is the address of an account which will own the NFT after it is minted.
- `tokenId`: The second parameter is the `tokenId` of the newly minted NFT.

`msg.sender` is a special keyword which returns the address of the account calling the smart contract. In this case it would return the account currently calling the mint function. Hence the account calling the mint function will be passed as first argument and therefore the minted NFT will be owned by this account.

The `_setTokenURI()` function is not yet defined so just ignore it for the moment. This function will be used for setting the tokenURI for the minted NFT. This function was present in the ERC721 library but has been discontinued after Solidity version `0.8.0` and so we will need to implement it ourselves.

Once the token is minted and its tokenURI is set, we increment the tokenCounter by 1 so that the next minted token has a new token id.

### Creating the `_setTokenURI()` function

Our NFT smart contract must store all the valid token id's with their respective tokenURI. For this we can use the `mapping` data type in Solidity. Mappings work similarly to hashmaps in other programming languages like Java. We can define a mapping from a `uint256` number to a `string` which will signify that each token id is mapped to its respective `tokenURI`. Just after the declaration of the tokenCounter variable, define the mapping:

```solidity
mapping (uint256 => string) private _tokenURIs;
```

Now let's write the `_setTokenURI` function:

```solidity
function _setTokenURI(uint256 _tokenId, string memory _tokenURI) internal virtual {
    require(
        _exists(_tokenId),
        "ERC721Metadata: URI set of nonexistent token"
    );  // Checks if the tokenId exists
    _tokenURIs[_tokenId] = _tokenURI;
}
```

There are many new terms defined here so let's deal with them one-by-one:

- `internal`: The function is defined with internal keyword. It means this function can be called only by other functions in this smart contract or other smart contracts inheriting this smart contract. This function cannot be called by an external user.
- `virtual`: This keyword means that the function can be overriden by any contract that is inheriting this smart contract.
- `require`: The first thing inside the function body is the require keyword. It takes in a conditional statement. If this statement returns true then the rest of the function body is executed. If the conditional statement returns false, then it will generate an error. The second parameter is the generated error message and it is optional.
- `_exists()`: This function returns `true` if there is a token minted with the passed `tokenId`, otherwise it returns `false`.

In summary: This function first makes sure that the `tokenId` for which we are trying to set the `tokenURI` is already minted. If it is, it will add the `tokenURI` to the mapping, along with the respective `tokenId`.

### Creating the tokenURI() function

The last function which we have to create is the `tokenURI()` function. It will be a publicly callable function which takes a tokenId as a parameter and returns its respective `tokenURI`. This is a standard function which is called by various NFT based platforms like [OpenSea](https://opensea.io/). Platforms like this use the `tokenURI` returned from this function to display various information about the NFT like its properties and the display image.

Let's write the `tokenURI` function:

```solidity
function tokenURI(uint256 _tokenId) public view virtual override returns(string memory) {
    require(
        _exists(_tokenId),
        "ERC721Metadata: URI set of nonexistent token"
    );
    return _tokenURIs[_tokenId];
}
```

- `public`: This function is public which means any outside user can call it.
- `view`: Since this function doesn't change the state of the blockchain, i.e. it doesn't change any value in the smart contract, executing this function will not require any Gas. Since no state change will take place, this function is defined as view.
- `override`: We already have a `tokenURI()` function in the ERC721 contract we have inherited which uses the concept of "baseURI + tokenId" to return the tokenURI. Since we need a different logic, we need to override the inherited function by using this keyword.
- `returns(string memory)`: Since this function will return a string value we have to define it when declaring the function. The memory keyword defines where the information is stored.

This function first checks whether the tokenId passed was actually minted. If the token was minted, it returns the tokenURI from the mapping.

### Putting it all together

```solidity
//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Artwork is ERC721 {

    uint256 public tokenCounter;
    mapping (uint256 => string) private _tokenURIs;

    constructor(
        string memory name,
        string memory symbol
    ) ERC721(name, symbol) {
        tokenCounter = 0;
    }

    function mint(string memory _tokenURI) public {
        _safeMint(msg.sender, tokenCounter);
        _setTokenURI(tokenCounter, _tokenURI);

        tokenCounter++;
    }

    function _setTokenURI(uint256 _tokenId, string memory _tokenURI) internal virtual {
        require(
            _exists(_tokenId),
            "ERC721Metadata: URI set of nonexistent token"
        );  // Checks if the tokenId exists
        _tokenURIs[_tokenId] = _tokenURI;
    }

    function tokenURI(uint256 _tokenId) public view virtual override returns(string memory) {
        require(
            _exists(_tokenId),
            "ERC721Metadata: URI set of nonexistent token"
        );
        return _tokenURIs[_tokenId];
    }

}
```

## Compiling the Smart Contract

Now that our smart contract is ready, we must compile it. In order to compile a smart contract with HardHat, run the command:

```bash
npx hardhat compile
```

If everything went as expected, you will be getting the message "Compilation finished successfully". If the contract doesn't compile successfully or there are errors, try to read the tutorial again to find out where it went wrong. Some of the possible mistakes are:

- The `SPDX-License-Identifier` is not provided
- There is a mismatch between the Solidity compiler version defined with the `pragma` keyword and the version defined in `hardhat.config.js`.
- There is a version mismatch between the imported smart contract's Solidity version and the version used to write our smart contract. To solve this, double check the version of the OpenZeppelin contracts you are installing with npm. In my case, the npm package is version `4.3.2` and the smart contracts are written with solidity version `0.8.0`.
