
const hre = require("hardhat");

async function main() {
  const SubscriptionPayments = await hre.ethers.getContractFactory("SubscriptionPayments");
  const subpayments = await SubscriptionPayments.deploy();

  await subpayments.deployed();

  console.log("SubscriptionPayments deployed to:", subpayments.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
