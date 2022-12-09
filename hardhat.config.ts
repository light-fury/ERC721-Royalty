import * as dotenv from "dotenv"
import "@nomicfoundation/hardhat-toolbox";
import "@nomiclabs/hardhat-solhint";

dotenv.config();

const {
  ALCHEMY_KEY,
  ETHERSCAN_API_KEY,
  PRIVATE_KEY,
  GAS_PRICE
} = process.env;

const accounts = [PRIVATE_KEY];

const gasPrice = GAS_PRICE ? Number(GAS_PRICE) : "auto"

const config = {
  solidity: {
    compilers: [
      {
        version: "0.8.17",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          }
        }
      }
    ]
   },

  networks: {
    goerli: {
      url: `https://eth-goerli.alchemyapi.io/v2/${ALCHEMY_KEY}`,
      accounts: accounts,
      gasPrice: gasPrice
    },
  },
  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://etherscan.io/
    apiKey: ETHERSCAN_API_KEY
  },
  mocha: {
    timeout: 50000
  }
};

export default config;
