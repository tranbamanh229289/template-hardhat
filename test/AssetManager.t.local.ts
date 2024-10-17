import { loadFixture, time } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { AssetManager, ERC20, ERC721, ERC1155 } from "../typechain-types";
import { Signer } from "ethers";
import { setTimeout } from "timers/promises";

describe("AssetsManager", function () {
  enum AssetType {
    ERC20,
    ERC721,
    ERC1155,
  }
  type WithdrawParam = {
    amount: bigint;
    asset: string;
    assetType: AssetType;
  };
  type DepositParam = {
    asset: string;
    user: string;
    amount: bigint;
    depositTime: bigint;
    assetType: AssetType;
  };

  async function deployFixture() {
    const [deployer, signer1, signer2] = await ethers.getSigners();

    const erc20: ERC20 = await ethers.deployContract("ERC20", deployer);
    erc20.waitForDeployment();
    await erc20
      .connect(deployer)
      .initialize(deployer.address, deployer.address);
    await erc20
      .connect(deployer)
      .mint(signer1.address, ethers.parseEther("1000"));

    const erc721 = await ethers.deployContract("ERC721", deployer);
    await erc721.waitForDeployment();
    await erc721
      .connect(deployer)
      .initialize(deployer.address, deployer.address);
    await erc721.connect(deployer).safeMint(signer1.address);

    const erc1155: ERC1155 = await ethers.deployContract("ERC1155", deployer);
    await erc1155.waitForDeployment();
    await erc1155
      .connect(deployer)
      .initialize(deployer.address, deployer.address);

    const assetManager: AssetManager = await ethers.deployContract(
      "AssetManager",
      deployer
    );
    await assetManager.waitForDeployment();

    return { deployer, signer1, signer2, erc20, erc721, erc1155, assetManager };
  }

  async function getTimestamp(): Promise<number> {
    return await time.latest();
  }
  async function getBalance(account: string): Promise<bigint> {
    return await ethers.provider.getBalance(account);
  }

  async function depositETH(
    signer: Signer,
    assetManager: AssetManager,
    amount: bigint
  ): Promise<void> {
    await signer.sendTransaction({
      to: await assetManager.getAddress(),
      value: amount,
    });
  }

  async function withdrawETH(
    signer: Signer,
    assetManager: AssetManager,
    amount: bigint
  ): Promise<void> {
    await assetManager.connect(signer).withdrawETH(amount);
  }

  async function deposit(
    signer: Signer,
    assetManager: AssetManager,
    depositParam: DepositParam
  ): Promise<void> {
    await assetManager.connect(signer).deposit(depositParam);
  }

  async function withdraw(
    signer: Signer,
    assetManager: AssetManager,
    withdrawParam: WithdrawParam
  ): Promise<void> {
    await assetManager.connect(signer).withdraw(withdrawParam);
  }

  /* Deployment */
  describe("deployment", () => {
    it("Initialize Erc20 Success", async () => {
      const { deployer, erc20 } = await loadFixture(deployFixture);
      const ADMIN_ROLE = await erc20.DEFAULT_ADMIN_ROLE();
      const MINTER_ROLE = await erc20.MINTER_ROLE();
      expect(await erc20.hasRole(ADMIN_ROLE, deployer.address)).to.equal(true);
      expect(await erc20.hasRole(MINTER_ROLE, deployer.address)).to.equal(true);
      expect(await erc20.name()).to.equals("ERC20 Token");
      expect(await erc20.symbol()).to.equals("ERC20TK");
    });
    it("Initialize Erc721 Success", async () => {
      const { deployer, erc721 } = await loadFixture(deployFixture);
      const ADMIN_ROLE = await erc721.DEFAULT_ADMIN_ROLE();
      const MINTER_ROLE = await erc721.MINTER_ROLE();
      expect(await erc721.hasRole(ADMIN_ROLE, deployer.address)).to.equal(true);
      expect(await erc721.hasRole(MINTER_ROLE, deployer.address)).to.equal(
        true
      );
      expect(await erc721.name()).to.equals("ERC721 Token");
      expect(await erc721.symbol()).to.equals("ERC721TK");
    });
    it("Initialize Erc1155 Success", async () => {
      const { deployer, erc1155 } = await loadFixture(deployFixture);
      const ADMIN_ROLE = await erc1155.DEFAULT_ADMIN_ROLE();
      const MINTER_ROLE = await erc1155.MINTER_ROLE();
      expect(await erc1155.hasRole(ADMIN_ROLE, deployer.address)).to.equal(
        true
      );
      expect(await erc1155.hasRole(MINTER_ROLE, deployer.address)).to.equal(
        true
      );
    });
  });

  describe("withdraw, deposit ETH", function () {
    it("deposit ETH success", async () => {
      const { signer1, assetManager } = await loadFixture(deployFixture);
      const amount: bigint = ethers.parseEther("100");

      const assetManagerBalance: bigint = await getBalance(
        await assetManager.getAddress()
      );
      const ethAssets: bigint = await assetManager.ethAssets(signer1.address);

      await depositETH(signer1, assetManager, amount);

      expect(await getBalance(await assetManager.getAddress())).to.equals(
        assetManagerBalance + amount
      );
      expect(await assetManager.ethAssets(signer1.address)).to.equals(
        ethAssets + amount
      );
    });
    it.only("deposit ETH emit DepositETH event", async () => {
      const { signer1, assetManager } = await loadFixture(deployFixture);
      const amount: bigint = ethers.parseEther("100");

      const timestamp: number = await getTimestamp();

      await expect(depositETH(signer1, assetManager, amount))
        .to.emit(assetManager, "DepositETH")
        .withArgs(signer1.address, amount, await getTimestamp());
    });

    it("withdraw ETH success", async () => {
      const { signer1, assetManager } = await loadFixture(deployFixture);

      const amountDeposit: bigint = ethers.parseEther("100");
      const amountWithdraw: bigint = ethers.parseEther("50");

      const assetManagerBalance: bigint = await getBalance(
        await assetManager.getAddress()
      );
      const ethAsset: bigint = await assetManager.ethAssets(signer1.address);

      await depositETH(signer1, assetManager, amountDeposit);
      await withdrawETH(signer1, assetManager, amountWithdraw);

      expect(await getBalance(await assetManager.getAddress())).to.equals(
        assetManagerBalance + amountDeposit - amountWithdraw
      );
      expect(await assetManager.ethAssets(signer1.address)).to.equals(
        ethAsset + amountDeposit - amountWithdraw
      );
    });

    it("withdraw ETH emit WithdrawETH event", async () => {
      const { signer1, assetManager } = await loadFixture(deployFixture);

      const amountDeposit: bigint = ethers.parseEther("100");
      const amountWithdraw: bigint = ethers.parseEther("50");

      await depositETH(signer1, assetManager, amountDeposit);
      const timestamp: number = await getTimestamp();

      await expect(withdrawETH(signer1, assetManager, amountWithdraw))
        .to.emit(assetManager, "WithdrawETH")
        .withArgs(signer1.address, amountWithdraw, timestamp);
    });

    it("withdraw ETH revert not enough ETH", async () => {
      const { signer1, assetManager } = await loadFixture(deployFixture);

      await depositETH(signer1, assetManager, ethers.parseEther("100"));

      await expect(
        withdrawETH(signer1, assetManager, ethers.parseEther("200"))
      ).to.be.revertedWithCustomError(assetManager, "NotEnoughETH");
    });
  });

  describe("deposit, withdraw erc20", function () {
    it("deposit ERC20 success", async () => {
      const { signer1, assetManager, erc20 } = await loadFixture(deployFixture);
      const amount = ethers.parseEther("100");
      const depositParam: DepositParam = {
        asset: await erc20.getAddress(),
        user: signer1.address,
        amount: amount,
        depositTime: BigInt("100"),
        assetType: AssetType.ERC20,
      };
      const asset = await assetManager.erc20Asset(
        await erc20.getAddress(),
        signer1.address
      );

      const assetManagerERC20Balance: bigint = await erc20.balanceOf(
        await assetManager.getAddress()
      );

      await erc20
        .connect(signer1)
        .approve(await assetManager.getAddress(), amount);

      await deposit(signer1, assetManager, depositParam);
      const timestamp: number = await getTimestamp();

      expect(await erc20.balanceOf(await assetManager.getAddress())).to.equals(
        assetManagerERC20Balance + amount
      );

      expect(
        (
          await assetManager.erc20Asset(
            await erc20.getAddress(),
            signer1.address
          )
        ).amount
      ).to.equals(asset.amount + amount);
      expect(
        (
          await assetManager.erc20Asset(
            await erc20.getAddress(),
            signer1.address
          )
        ).depositTime
      ).to.equals(depositParam.depositTime);
      expect(
        (
          await assetManager.erc20Asset(
            await erc20.getAddress(),
            signer1.address
          )
        ).modifiedTime
      ).to.equals(BigInt(timestamp));
    });

    it("deposit ERC20 emit Deposit event", async () => {
      const { signer1, assetManager, erc20 } = await loadFixture(deployFixture);
      const amount = ethers.parseEther("100");
      const depositTime = BigInt("100");
      const depositParam: DepositParam = {
        asset: await erc20.getAddress(),
        user: signer1.address,
        amount: amount,
        depositTime: depositTime,
        assetType: AssetType.ERC20,
      };

      await erc20
        .connect(signer1)
        .approve(await assetManager.getAddress(), amount);

      const timestamp: number = await getTimestamp();

      await expect(await deposit(signer1, assetManager, depositParam))
        .to.emit(assetManager, "Deposit")
        .withArgs(
          signer1.address,
          await erc20.getAddress(),
          AssetType.ERC20,
          amount,
          timestamp
        );
    });

    it("withdraw ERC20 success", async () => {
      const { signer1, assetManager, erc20 } = await loadFixture(deployFixture);
      const depositAmount: bigint = ethers.parseEther("100");
      const withdrawAmount: bigint = ethers.parseEther("50");
      const depositTime: bigint = BigInt("0");

      const depositParam: DepositParam = {
        asset: await erc20.getAddress(),
        user: signer1.address,
        amount: depositAmount,
        depositTime: depositTime,
        assetType: AssetType.ERC20,
      };

      const withdrawParam: WithdrawParam = {
        asset: await erc20.getAddress(),
        amount: withdrawAmount,
        assetType: AssetType.ERC20,
      };
      const asset = await assetManager.erc20Asset(
        await erc20.getAddress(),
        signer1.address
      );
      const assetManagerERC20Balance: bigint = await erc20.balanceOf(
        await assetManager.getAddress()
      );
      await erc20
        .connect(signer1)
        .approve(await assetManager.getAddress(), depositAmount);
      await deposit(signer1, assetManager, depositParam);

      await withdraw(signer1, assetManager, withdrawParam);
      const timestamp: number = await getTimestamp();
      expect(
        (
          await assetManager.erc20Asset(
            await erc20.getAddress(),
            signer1.address
          )
        ).amount
      ).to.equals(asset.amount + depositAmount - withdrawAmount);

      expect(
        (
          await assetManager.erc20Asset(
            await erc20.getAddress(),
            signer1.address
          )
        ).modifiedTime
      ).to.equals(BigInt(timestamp));

      expect(await erc20.balanceOf(await assetManager.getAddress())).to.equals(
        assetManagerERC20Balance + depositAmount - withdrawAmount
      );
    });
    it("withdraw ERC20 emit Withdraw event", async () => {
      const { signer1, assetManager, erc20 } = await loadFixture(deployFixture);
      const depositAmount: bigint = ethers.parseEther("100");
      const withdrawAmount: bigint = ethers.parseEther("50");
      const depositTime: bigint = BigInt("0");

      const depositParam: DepositParam = {
        asset: await erc20.getAddress(),
        user: signer1.address,
        amount: depositAmount,
        depositTime: depositTime,
        assetType: AssetType.ERC20,
      };

      const withdrawParam: WithdrawParam = {
        asset: await erc20.getAddress(),
        amount: withdrawAmount,
        assetType: AssetType.ERC20,
      };
      await erc20
        .connect(signer1)
        .approve(await assetManager.getAddress(), depositAmount);
      await deposit(signer1, assetManager, depositParam);
      const timestamp: number = await getTimestamp();

      await expect(withdraw(signer1, assetManager, withdrawParam))
        .to.emit(assetManager, "Withdraw")
        .withArgs(
          signer1.address,
          await erc20.getAddress(),
          AssetType.ERC20,
          withdrawAmount,
          timestamp
        );
    });
    it("withdraw ERC20 revert NotEnoughWithdraw", async () => {
      const { signer1, assetManager, erc20 } = await loadFixture(deployFixture);
      const depositAmount: bigint = ethers.parseEther("100");
      const withdrawAmount: bigint = ethers.parseEther("200");
      const depositTime: bigint = BigInt("0");

      const depositParam: DepositParam = {
        asset: await erc20.getAddress(),
        user: signer1.address,
        amount: depositAmount,
        depositTime: depositTime,
        assetType: AssetType.ERC20,
      };

      const withdrawParam: WithdrawParam = {
        asset: await erc20.getAddress(),
        amount: withdrawAmount,
        assetType: AssetType.ERC20,
      };
      await erc20
        .connect(signer1)
        .approve(await assetManager.getAddress(), depositAmount);
      await deposit(signer1, assetManager, depositParam);
      await expect(
        withdraw(signer1, assetManager, withdrawParam)
      ).to.be.revertedWithCustomError(assetManager, "NotEnoughWithdraw");
    });
  });

  describe("deposit, withdraw erc721", function () {
    it("deposit EC721 success", async () => {
      const { signer1, assetManager, erc721 } = await loadFixture(
        deployFixture
      );
      const tokenId = BigInt("0");
      const depositParam: DepositParam = {
        asset: await erc721.getAddress(),
        user: signer1.address,
        amount: tokenId,
        depositTime: BigInt("1"),
        assetType: AssetType.ERC721,
      };

      await erc721
        .connect(signer1)
        .approve(await assetManager.getAddress(), tokenId);
      await deposit(signer1, assetManager, depositParam);
      const timestamp: number = await getTimestamp();

      expect(await erc721.ownerOf(tokenId)).to.equals(
        await assetManager.getAddress()
      );

      expect(
        (await assetManager.erc721Asset(await erc721.getAddress(), tokenId))
          .user
      ).to.equals(signer1.address);

      expect(
        (await assetManager.erc721Asset(await erc721.getAddress(), tokenId))
          .depositTime
      ).to.equals(depositParam.depositTime);
      expect(
        (await assetManager.erc721Asset(await erc721.getAddress(), tokenId))
          .modifiedTime
      ).to.equals(BigInt(timestamp));
    });
  });

  it("deposit EC721 emit Deposit event", async () => {
    const { signer1, assetManager, erc721 } = await loadFixture(deployFixture);
    const tokenId = BigInt("0");
    const depositParam: DepositParam = {
      asset: await erc721.getAddress(),
      user: signer1.address,
      amount: tokenId,
      depositTime: BigInt("1"),
      assetType: AssetType.ERC721,
    };

    await erc721
      .connect(signer1)
      .approve(await assetManager.getAddress(), tokenId);
    const timestamp: number = await getTimestamp();
    await expect(deposit(signer1, assetManager, depositParam))
      .to.emit(assetManager, "Deposit")
      .withArgs(
        signer1.address,
        await erc721.getAddress(),
        AssetType.ERC721,
        tokenId,
        timestamp
      );
  });

  it("withdraw ERC721 success", async () => {
    const { signer1, assetManager, erc721 } = await loadFixture(deployFixture);
    const depositTime: bigint = BigInt("0");
    const tokenId = BigInt("0");
    const depositParam: DepositParam = {
      asset: await erc721.getAddress(),
      user: signer1.address,
      amount: tokenId,
      depositTime: depositTime,
      assetType: AssetType.ERC721,
    };

    const withdrawParam: WithdrawParam = {
      asset: await erc721.getAddress(),
      amount: tokenId,
      assetType: AssetType.ERC721,
    };

    await erc721
      .connect(signer1)
      .approve(await assetManager.getAddress(), tokenId);
    await deposit(signer1, assetManager, depositParam);

    await withdraw(signer1, assetManager, withdrawParam);
    const timestamp: number = await getTimestamp();

    expect(
      (await assetManager.erc721Asset(await erc721.getAddress(), tokenId)).user
    ).to.equals(signer1.address);
    expect(
      (await assetManager.erc721Asset(await erc721.getAddress(), tokenId))
        .modifiedTime
    ).to.equals(BigInt(timestamp));
    expect(await erc721.ownerOf(tokenId)).to.equals(signer1.address);
  });

  it("withdraw ERC721 emit Withdraw event", async () => {
    const { signer1, assetManager, erc721 } = await loadFixture(deployFixture);
    const depositTime: bigint = BigInt("0");
    const tokenId = BigInt("0");
    const depositParam: DepositParam = {
      asset: await erc721.getAddress(),
      user: signer1.address,
      amount: tokenId,
      depositTime: depositTime,
      assetType: AssetType.ERC721,
    };

    const withdrawParam: WithdrawParam = {
      asset: await erc721.getAddress(),
      amount: tokenId,
      assetType: AssetType.ERC721,
    };

    await erc721
      .connect(signer1)
      .approve(await assetManager.getAddress(), tokenId);
    await deposit(signer1, assetManager, depositParam);
    const timestamp: number = await getTimestamp();
    await expect(withdraw(signer1, assetManager, withdrawParam))
      .to.emit(assetManager, "Withdraw")
      .withArgs(
        signer1.address,
        await erc721.getAddress(),
        AssetType.ERC20,
        tokenId,
        timestamp
      );
  });
});
