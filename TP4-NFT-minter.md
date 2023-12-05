# NFT Minter

To deploy the NFT contrat that will be used each time you want to mint a NFT, first go to https://remix.ethereum.org

Get the content of `MyNFT.sol`, compile it, deploy it and verify it.

You can then go the blockchain explorer https://mumbai.polygonscan.com and check the contract tab with the green check mark.

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

We are going to create a generic Minter UI by following the tutorial on this page: https://docs.alchemy.com/docs/nft-minter
