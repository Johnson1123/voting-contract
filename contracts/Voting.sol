// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.27;

contract VotingContract {
    struct Candidate {
       string name;
       uint32 amountOfVoteGot;
    }

    struct Voter {
        bool hasVoted;
        uint32 candidateVotedFor;
    }

    mapping(address => Voter) public voter;
    mapping(string => Candidate[])  poll;

    string public winnerName;

    error POLLALREADYEXIST();
    error POLLNOTEXIST();
    error ALREADYVOTED();

    event CreatePoll(string indexed _pollName, string[] indexed _nameOfCandidate);
    event FETCHPOLLCANDIDATE(string indexed _pollName, string[] indexed _nameOfCandidate);
    event WINNER(string indexed winnerName, uint32 indexed winnerScore);


    function createPoll(string calldata _poll, string[] calldata _name ) external {
        Candidate[] storage pollCandidate = poll[_poll];

        if(pollCandidate.length > 0 ){
            revert POLLALREADYEXIST();
        }

         for(uint8 i = 0;  i < _name.length; i++){
            pollCandidate.push(Candidate({
                name: _name[i],
                amountOfVoteGot: 0
            }));
         }
    }

    function fetchPollCandidate(string memory _poll) public view returns(Candidate[] memory) {
        Candidate[] storage pollCandidates = poll[_poll];

        if(pollCandidates.length == 0){
           revert POLLNOTEXIST();
         }

         return pollCandidates;
    }

    function checkIfVoted(address _voter) external view returns(bool){
        Voter storage voted = voter[_voter];
        return voted.hasVoted;
    }

    function checkVotedFor(address _voter) external view returns(uint){
        Voter storage voted = voter[_voter];
        return voted.candidateVotedFor;
    }

    function vote(string memory _poll, uint8 _candidate) external {
        Voter memory _voter = voter[msg.sender];
        if(_voter.hasVoted){
            revert ALREADYVOTED();
        }
        Candidate[] storage pollCandidates = poll[_poll];
        if(pollCandidates.length == 0){
           revert POLLNOTEXIST();
        }
        voter[msg.sender].hasVoted = true;
        voter[msg.sender].candidateVotedFor = _candidate;
         poll[_poll][_candidate].amountOfVoteGot += 1; 
    }

    function getWinner(string memory _poll) external{
        Candidate[] storage pollCandidates = poll[_poll];

        uint32 win = 0; 
        uint32 winnerScore;

        if(pollCandidates.length == 0){
           revert POLLNOTEXIST();
        }

        for (uint32 p = 0; p < pollCandidates.length; p++) {
            if (pollCandidates[p].amountOfVoteGot > win) {
                win = pollCandidates[p].amountOfVoteGot;
                winnerName = pollCandidates[p].name;
                winnerScore = pollCandidates[p].amountOfVoteGot;
            }
        }

    
        emit WINNER(winnerName,winnerScore);


        
    }
}

