### Deploy MyNFT.sol

Go to https://remix.ethereum.org

Get the content of `MyNFT.sol`, compile it, deploy it and verify it.

You can then go the blockchain explorer https://mumbai.polygonscan.com and check the contract tab with the green check mark.

You can now invoke your contract from the write tab and mint to any address a NFT.

The NFT is defined by the metadata that is stored on IPFS.

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

To mint the NFT, you then put the two parameters, the recipient address of the NFT, and this tokenURI as: https://aquamarine-regular-kiwi-524.mypinata.cloud/ipfs/QmQhHEf6WwmhbETxb4LWEp3jkiTaeFnUS6MySddBqpxtzf

Follow the tutorial on this page to build the interface for a Minter: https://docs.alchemy.com/docs/nft-minter
