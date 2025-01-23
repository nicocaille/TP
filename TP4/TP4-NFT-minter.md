# Create an NFT smart contract

Go to REMIX IDE and create the following smart contract:

```javascript
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CYTechNFT is ERC721, ERC721URIStorage, ERC721Burnable, Ownable {
    uint256 private _nextTokenId;

    constructor() ERC721("CYTech NFT", "CNFT") Ownable(msg.sender) {}

    function safeMint(address to, string memory uri) public onlyOwner {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    // The following functions are overrides required by Solidity.

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
```

Once compiled, deploy the contract and then verify the contract thanks to the `CONTRACT VERIFICATION` plugin and your BscScan API key within REMIX IDE.

## NFT Minter

You can now invoke your smart contract from the write tab and mint to any address a NFT.

The NFT is defined by the metadata that is stored on IPFS (via pinata).

As an example:

```json
{
  "attributes": [
    {
      "trait_type": "cryptocurrency",
      "value": "Bitcoin"
    },
    {
      "trait_type": "total supply",
      "value": "21,000,000"
    }
  ],
  "description": "The world's first Cryptocurrency",
  "image": "https://aquamarine-regular-kiwi-524.mypinata.cloud/ipfs/QmTiBdh9RmT9w94FMnqZGN1Mdtx85v13A4KGC3F3xve6S5",
  "name": "Bitcoin"
}
```

To mint the NFT, you then put the two parameters, the recipient address of the NFT, and this `tokenURI` as: https://aquamarine-regular-kiwi-524.mypinata.cloud/ipfs/QmQhHEf6WwmhbETxb4LWEp3jkiTaeFnUS6MySddBqpxtzf

## Exercice

Create a generic Minter UI that will connect to your Metamask, and take the `tokenURI` as an input.

This interface will then ask you to confirm via MetaMask the minting of the NFT to your address.
