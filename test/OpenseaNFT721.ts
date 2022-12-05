import { Signer, Contract } from "ethers";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { LogLevel } from "@ethersproject/logger";
import hre, { ethers } from "hardhat";
import { expect } from "chai";

describe("OpenseaNFT721", () => {
  let owner: SignerWithAddress, addr1: Signer, addr2: Signer, addrs: Signer[];
  let openseaNFT721: Contract;

  before(async () => {
    ethers.utils.Logger.setLogLevel(LogLevel.ERROR);
  });

  beforeEach(async () => {
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

    const OpenseaNFT721 = await ethers.getContractFactory("OpenseaNFT721");
    openseaNFT721 = await OpenseaNFT721.deploy(300, "");
    await openseaNFT721.deployed();
  });

  it("should return default royalty", async () => {
    const ownerAddress = await owner.getAddress();
    const res = await openseaNFT721.royaltyInfo(0, ethers.utils.parseEther('10000'));
    expect(res[0]).to.equal(ethers.constants.AddressZero);
    expect(res[1]).to.equal(ethers.utils.parseEther('300'));
  });

  it("should return minter royalty", async () => {
    const addr1Address = await addr1.getAddress();
    await openseaNFT721.connect(owner).safeMint(addr1Address, 300);
    const res = await openseaNFT721.royaltyInfo(1, ethers.utils.parseEther('10000'));
    expect(res[0]).to.equal(addr1Address);
    expect(res[1]).to.equal(ethers.utils.parseEther('300'));
  });

  it("should change minter royalty", async () => {
    const addr1Address = await addr1.getAddress();
    await openseaNFT721.connect(owner).safeMint(addr1Address, 100);
    const res = await openseaNFT721.royaltyInfo(1, ethers.utils.parseEther('10000'));
    expect(res[0]).to.equal(addr1Address);
    expect(res[1]).to.equal(ethers.utils.parseEther('100'));
  });

  it("should not allow change admins from other accounts", async () => {
    const addr1Address = await addr1.getAddress();
    await expect(openseaNFT721.connect(addr1).addAdmin(addr1Address)).to.be.rejectedWith('Ownable: caller is not the owner');
    await expect(openseaNFT721.connect(addr1).removeAdmin(addr1Address)).to.be.rejectedWith('Ownable: caller is not the owner');
  });

  it("should allow change admins from owner account", async () => {
    const addr1Address = await addr1.getAddress();
    expect(await openseaNFT721.hasRole(ethers.utils.keccak256(ethers.utils.toUtf8Bytes("ADMIN_ROLE")), addr1Address)).to.equal(false);
    await openseaNFT721.connect(owner).addAdmin(addr1Address);
    expect(await openseaNFT721.hasRole(ethers.utils.keccak256(ethers.utils.toUtf8Bytes("ADMIN_ROLE")), addr1Address)).to.equal(true);
    await openseaNFT721.connect(owner).removeAdmin(addr1Address);
    expect(await openseaNFT721.hasRole(ethers.utils.keccak256(ethers.utils.toUtf8Bytes("ADMIN_ROLE")), addr1Address)).to.equal(false);
  });

  it("should allow add admins maximum 5", async () => {
    const addr1Address = await addr1.getAddress();
    for (let index = 0; index < 5; index++) {
      await openseaNFT721.connect(owner).addAdmin(await addrs[index].getAddress());
    }
    await expect(openseaNFT721.connect(owner).addAdmin(addr1Address)).to.be.rejectedWith('Maximum limit');
  });

  it("should reverted remove non-admin from admin list", async () => {
    const addr1Address = await addr1.getAddress();
    const addr2Address = await addr2.getAddress();
    await openseaNFT721.connect(owner).addAdmin(addr1Address);
    await expect(openseaNFT721.connect(owner).removeAdmin(addr2Address)).to.be.rejectedWith('Invalid admin');
  });

  it("should allow only admins to mint nft", async () => {
    const addr1Address = await addr1.getAddress();
    await expect(openseaNFT721.connect(addr2).safeMint(addr1Address, 300)).to.be.rejectedWith('Not allowed');
  });

  it("should allow only admins to transfer nft", async () => {
    const addr1Address = await addr1.getAddress();
    const addr2Address = await addr2.getAddress();
    await openseaNFT721.connect(owner).safeMint(addr1Address, 300);
    await expect(openseaNFT721.connect(addr1)["safeTransfer(address,uint256)"](addr2Address, 1)).to.be.rejectedWith('Not allowed');
    await openseaNFT721.connect(owner).addAdmin(addr1Address);
    await openseaNFT721.connect(addr1)["safeTransfer(address,uint256)"](addr2Address, 1);
    expect(await openseaNFT721.ownerOf(1)).to.equal(addr2Address);
  });

  it("should allow only admins to burn nft", async () => {
    const addr1Address = await addr1.getAddress();
    await openseaNFT721.connect(owner).safeMint(addr1Address, 300);
    await expect(openseaNFT721.connect(addr1)["burn(uint256)"](1)).to.be.rejectedWith('Not allowed');
    await openseaNFT721.connect(owner).addAdmin(addr1Address);
    await openseaNFT721.connect(addr1)["burn(uint256)"](1);
    await expect(openseaNFT721.ownerOf(1)).to.be.rejectedWith("ERC721: invalid token ID");
  });
});
