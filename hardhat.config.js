require("@nomicfoundation/hardhat-toolbox");

require('dotenv').config();
const { API_URL, PRIVATE_KEY, ETHERSCAN_API } = process.env;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.4",
  networks: {
    rinkeby: {
      url: API_URL,
      accounts: [`0x${PRIVATE_KEY}`],
    }
  },
  etherscan: {
    apiKey: {
      rinkeby: ETHERSCAN_API,
    }
  }
};
