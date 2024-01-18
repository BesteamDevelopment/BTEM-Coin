// SPDX-License-Identifier: MIT

/*
M#"""""""'M                      dP                                M""""""'YMM MMP"""""""MM MMP"""""YMM 
##  mmmm. `M                     88                                M  mmmm. `M M' .mmmm  MM M' .mmm. `M 
#'        .M .d8888b. .d8888b. d8888P .d8888b. .d8888b. 88d8b.d8b. M  MMMMM  M M         `M M  MMMMM  M 
M#  MMMb.'YM 88ooood8 Y8ooooo.   88   88ooood8 88'  `88 88'`88'`88 M  MMMMM  M M  MMMMM  MM M  MMMMM  M 
M#  MMMM'  M 88.  ...       88   88   88.  ... 88.  .88 88  88  88 M  MMMM' .M M  MMMMM  MM M. `MMM' .M 
M#       .;M `88888P' `88888P'   dP   `88888P' `88888P8 dP  dP  dP M       .MM M  MMMMM  MM MMb     dMM 
M#########M                                                        MMMMMMMMMMM MMMMMMMMMMMM MMMMMMMMMMM 


          _           __            ______________  __             
   ____ _(_)_  ______/ /__ _   __  / ____/_  __/ / / /             
  / __ `/ / / / / __  / _ \ | / / / __/   / / / /_/ /              
 / /_/ / / /_/ / /_/ /  __/ |/ / / /___  / / / __  /               
 \__, /_/\__,_/\__,_/\___/|___(_)_____/ /_/ /_/ /_/                
/____/                                                             
                                                                                                  
*/

pragma solidity ^0.8.20;
import "./interface.sol";
import "./contract.sol";

contract besteamDAO is Ownable, ReentrancyGuard {

    IERC20 public tokenBesteam;
    
    constructor(address _tokenBesteam) {
        tokenBesteam = IERC20(_tokenBesteam);
    }

    //ROLE ____________________________________________________________________________________________________________________________________________________________________________________________________

    enum Role { None, Player, President, Counselor, Shareholder, Besteam }
    
    struct Member {
        Role role;
        uint256 membershipExpiry;
    }

    mapping(address => Member) public members;
    uint256 public constant playerCost = 3 ether; // Costo in wei (esempio)
    uint256 public constant presidentCost = 10 ether; // Costo in wei (esempio)

    function joinAsPlayer() external payable nonReentrant {
        require(msg.value >= playerCost, "Insufficient funds");
        members[msg.sender] = Member({role: Role.Player, membershipExpiry: block.timestamp + 365 days});
    }

    function joinAsPresident() external payable nonReentrant {
        require(msg.value >= presidentCost, "Insufficient funds");
        members[msg.sender] = Member({role: Role.President, membershipExpiry: block.timestamp + 365 days});
    }
    
    function checkMembershipStatus(address user) external view returns (Role, bool) {
        Member memory member = members[user];
        return (member.role, member.membershipExpiry > block.timestamp);
    }

    //ELECTION ________________________________________________________________________________________________________________________________________________________________________________________________

    struct Election {
        uint256 startTime;
        uint256 endTime;
        bool isActive;
        mapping(address => uint256) votes;
        address[] candidates;
        bool isCandidateRegistrationOpen;
    }

    Election public currentElection;

    // Funzione per avviare la registrazione dei candidati
    function openCandidateRegistration() public onlyOwner {
        require(!currentElection.isActive, "An election is already active");
        currentElection.isCandidateRegistrationOpen = true;
    }

    // Funzione per chiudere la registrazione dei candidati e avviare l'elezione
    function closeCandidateRegistrationAndStartElection(uint256 _durationInDays) public onlyOwner {
        require(currentElection.isCandidateRegistrationOpen, "Candidate registration is not open");

        currentElection.isCandidateRegistrationOpen = false;
        currentElection.startTime = block.timestamp;
        currentElection.endTime = block.timestamp + (_durationInDays * 1 days); 
        currentElection.isActive = true;
    }

    // Funzione per permettere ai membri di candidarsi
    function registerAsCandidate() public nonReentrant {
        require(members[msg.sender].role >= Role.Player, "Not eligible to be a candidate");
        require(currentElection.isCandidateRegistrationOpen, "Candidate registration is not open");

        // Assicurati che l'utente non sia già un candidato
        for (uint256 i = 0; i < currentElection.candidates.length; i++) {
            require(currentElection.candidates[i] != msg.sender, "Already registered as a candidate");
        }

        currentElection.candidates.push(msg.sender);
    }

    // Funzione per votare in una elezione
    function voteForCounselor(address _candidate) public nonReentrant {
        require(members[msg.sender].role >= Role.Player, "Not eligible to vote");
        require(currentElection.isActive, "No active election");
        require(block.timestamp < currentElection.endTime, "Election has ended");
        
        // Assicurati che l'indirizzo per cui si vota sia un candidato valido
        bool isValidCandidate = false;
        for (uint256 i = 0; i < currentElection.candidates.length; i++) {
            if (currentElection.candidates[i] == _candidate) {
                isValidCandidate = true;
                break;
            }
        }
        require(isValidCandidate, "Invalid candidate");

        currentElection.votes[_candidate] += 1;
    }

    //PROPOSAL ________________________________________________________________________________________________________________________________________________________________________________________________

    struct Proposal {
        string description;
        uint256 deadline;
        uint voteCount;
        mapping(address => bool) voted;
    }

    // Array per conservare gli ID delle proposte
    uint256[] private proposalIds;
    uint256 private nextProposalId = 0;
    // Mapping per conservare le proposte utilizzando un ID
    mapping(uint256 => Proposal) private proposals;
    // Eventi
    event NewProposal(uint256 indexed proposalId, string description, uint256 deadline);
    event Voted(uint256 indexed proposalId, address voter);
    
    // Funzione per creare una nuova proposta di voto
    function createProposal(string memory _description, uint256 _durationInDays) public onlyOwner {
        require(members[msg.sender].role == Role.Besteam, "Not a DAO Admin");
        uint256 proposalId = nextProposalId++;
        Proposal storage proposal = proposals[proposalId];
        proposal.description = _description;
        proposal.deadline = block.timestamp + (_durationInDays * 1 days);
        proposal.voteCount = 0;

        proposalIds.push(proposalId);
        emit NewProposal(proposalId, _description, proposal.deadline);
    }

    // Funzione per votare su una proposta
    function voteOnProposal(uint256 _proposalId) public {
        require(members[msg.sender].role != Role.None, "Not a DAO member");
        Proposal storage proposal = proposals[_proposalId];
        require(block.timestamp < proposal.deadline, "Voting has ended for this proposal");
        require(!proposal.voted[msg.sender], "Already voted");

        proposal.voted[msg.sender] = true;
        proposal.voteCount += 1;

        emit Voted(_proposalId, msg.sender);
    }

    // Funzione per ottenere il conteggio dei voti di una proposta
    function getVoteCount(uint256 _proposalId) public view returns (uint256) {
        return proposals[_proposalId].voteCount;
    }
}
