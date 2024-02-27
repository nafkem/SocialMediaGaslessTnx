import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  const SMToken = await ethers.getContractFactory("SMToken");
  const smToken = await SMToken.deploy("Name", "Symbol");

  console.log("SMToken deployed to:", smToken.target);

  const SocialMedia = await ethers.getContractFactory("SocialMedia");
  const socialMedia = await SocialMedia.deploy(smToken.target);

  console.log("SocialMedia deployed to:", socialMedia.target);

  const SocialMediaFactory = await ethers.getContractFactory("SocialMediaFactory");
  const socialMediaFactory = await SocialMediaFactory.deploy();

  console.log("SocialMediaFactory deployed to:", socialMediaFactory.target);

  
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
