import {
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import hre, { ethers} from "hardhat"

describe("VotingContract", function () {

  async function deployVoting() {
    // Contracts are deployed using the first signer/account by default
    const [owner, otherAccount] = await hre.ethers.getSigners();

    const Voting = await hre.ethers.getContractFactory("VotingContract");
    const votingAddress = await Voting.deploy();

    return { votingAddress, owner, otherAccount };
  }
  describe("createPoll and fetch poll", function () {
    it("Should create poll successfully", async function () {
      const { votingAddress, owner, otherAccount} = await loadFixture(deployVoting);


      await votingAddress.createPoll("President", ["Trump", "Harris", "Johnson"]);

      const pollCandidates = await votingAddress.fetchPollCandidate("President");
      
      expect(pollCandidates[0][0]).to.equal("Trump");
      expect(pollCandidates[1][0]).to.equal("Harris");
      expect(pollCandidates[2][0]).to.equal("Johnson");

      ;

     it("Fetch poll successfully", async function() {
         const pollCandidates = await votingAddress.fetchPollCandidate("President");
         expect(pollCandidates.length).to.equal(3);
        await expect(votingAddress.fetchPollCandidate("Governor")).to.be.revertedWithCustomError(votingAddress, "POLLNOTEXIST");
     }
    );
});

})

 describe("vote", function () {
    it("user can vote succesffully", async function() {
        const { votingAddress, owner, otherAccount} = await loadFixture(deployVoting);
        await votingAddress.createPoll("President", ["Trump", "Harris", "Johnson"]);

        await expect(votingAddress.vote("Governor", 0)).to.be.revertedWithCustomError(votingAddress, "POLLNOTEXIST");

        await votingAddress.vote("President", 1)

        expect(await votingAddress.checkIfVoted(owner)).to.equal(true);
        expect(await votingAddress.checkVotedFor(owner)).to.equal(1);
    })
  })

 describe("winner", function () {
    it("get Winner", async function() {
        const { votingAddress, owner, otherAccount} = await loadFixture(deployVoting);
        await votingAddress.createPoll("President", ["Trump", "Harris", "Johnson"]);

        await votingAddress.vote("President", 0)

        await votingAddress.getWinner("President")

        expect(await votingAddress.winnerName()).to.equal("Trump");
    })
  })

});
