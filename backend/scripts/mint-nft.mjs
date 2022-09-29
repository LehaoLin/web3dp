const CONTRACT_ADDRESS = "0x14C77219F67E84Ab098aa08f93f984B31038ceB7"
const META_DATA_URL = "ipfs://bafyreigoljafmarsic6qj25g3d4to3piiebmfvvj7d5s2unporb7o2bmyu/metadata.json"

async function mintNFT(contractAddress, metaDataURL) {
   const ExampleNFT = await ethers.getContractFactory("Web3DP")
   const [owner] = await ethers.getSigners()
   await ExampleNFT.attach(contractAddress).mintNFT(owner.address, metaDataURL)
   console.log("NFT minted to: ", owner.address)
}

mintNFT(CONTRACT_ADDRESS, META_DATA_URL)
   .then(() => process.exit(0))
   .catch((error) => {
       console.error(error);
       process.exit(1);
   });