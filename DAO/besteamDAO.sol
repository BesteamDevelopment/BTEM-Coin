// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

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

// Importa le interfacce necessarie per il funzionamento del contratto.
import "./interface.sol";

// Definizione del contratto principale della DAO Besteam.
contract besteamDAO is Ownable, ReentrancyGuard, Pausable {

    // Mapping per gestire i manager del contratto, oltre all'owner.
    mapping(address => bool) public contractManagers;
    // Evento emesso quando un manager del contratto viene aggiunto o rimosso.
    event ContractManager(address indexed manager, bool status);

    // Modificatore per controllare che la funzione sia chiamata solo dall'owner o da un manager.
    modifier onlyOwnerOrContractManager() {
        require(msg.sender == owner() || contractManagers[msg.sender], "Caller is not authorized");
        _;
    }

    // Permette all'owner di aggiungere o rimuovere manager del contratto.
    function manageContractManager(address _manager, bool _status) public onlyOwner {
        require(_manager != address(0), "Invalid address");
        contractManagers[_manager] = _status;
        emit ContractManager(_manager, _status);
    }

    // Metodi per mettere in pausa o riprendere le operazioni del contratto.
    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    // Permette il trasferimento di token ERC20 da questo contratto.
    function transferAnyNewERC20Token(address _tokenAddr, address _to, uint _amount) public onlyOwner {  
        require(NewIERC20(_tokenAddr).transfer(_to, _amount), "Could not transfer out tokens!");
    }

    function transferAnyOldERC20Token(address _tokenAddr, address _to, uint _amount) public onlyOwner {    
        OldIERC20(_tokenAddr).transfer(_to, _amount);
    }

    // Funzione per ricevere Ether nel contratto.
    receive() external payable {}

    // Permette all'owner di ritirare l'Ether accumulato nel contratto.
    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No GAS balance to withdraw");
        (bool success, ) = owner().call{value: balance}("");
        require(success, "GAS withdrawal failed");
    }

    // Token Besteam e relative funzioni.
    IERC20 public tokenBesteam;
    uint256 public besteamDecimals;

    // Imposta l'indirizzo del token Besteam e i suoi decimali.
    function setBesteamAddress(address _tokenBesteam, uint256 _besteamDecimals) public onlyOwnerOrContractManager {
        tokenBesteam = IERC20(_tokenBesteam);
        besteamDecimals = _besteamDecimals;
    }

    // Restituisce il saldo di token Besteam di un utente.
    function getBesteamBalance(address _userAddress) public view returns (uint256) {
        return tokenBesteam.balanceOf(_userAddress);
    }

    // Definizione dei ruoli all'interno della DAO e struttura dei membri.
    enum Role { None, Player, President, Counselor, Shareholder, Besteam }
    struct Member {
        Role role;
        uint256 membershipExpiry;
    }
    struct PendingMember {
        address addr;
        Role role;
        uint256 payment;
    }

    mapping(address => Member) public members;
    PendingMember[] public pendingMembers;

    uint256 public playerCost = 30 * (10 ** 18); // Costo in wei per diventare un Player.
    uint256 public presidentCost = 100 * (10 ** 18); // Costo in wei per diventare un President.

    // Imposta un membro con un ruolo e una durata della membership.
    function setMember(address _userAddress, uint256 _days, Role _role) public onlyOwnerOrContractManager {
        members[_userAddress] = Member({role: _role, membershipExpiry: block.timestamp + ((1 days) * _days)});
    }

    // Imposta i costi per diventare Player o President.
    function setPlayerCost(uint256 _amountPlayer, uint256 _amountPresident, uint256 _decimals) public onlyOwner {
        playerCost = _amountPlayer * (10 ** _decimals);
        presidentCost = _amountPresident * (10 ** _decimals);
    }

    // Permette agli utenti di unirsi alla DAO pagando in token Besteam.
    function joinDAO(Role _roleType) external nonReentrant {
        uint256 cost = 0;
        if (_roleType == Role.Player) {
            cost = playerCost;
        } else if (_roleType == Role.President) {
            cost = presidentCost;
        }
        require(tokenBesteam.allowance(msg.sender, address(this)) >= cost, "Token allowance too low");
        require(tokenBesteam.transferFrom(msg.sender, address(this), cost), "Token transfer failed");
        uint256 memberIndex = getPendingMemberIndex(msg.sender);
        require(memberIndex == 9999999999, "Member already pending");
        if (members[msg.sender].role == Role.None) {
            pendingMembers.push(PendingMember({
                addr: msg.sender,
                role: _roleType,
                payment: cost
            }));
        } else {
            members[msg.sender].role = _roleType;
            members[msg.sender].membershipExpiry = block.timestamp + 365 days;
        }
    }

    // Restituisce l'indice di un membro pendente, se presente.
    function getPendingMemberIndex(address memberAddress) public view returns (uint256) {
        for (uint256 i = 0; i < pendingMembers.length; i++) {
            if (pendingMembers[i].addr == memberAddress) {
                return i;
            }
        }
        return 9999999999; // Indica che il membro non è stato trovato.
    }

    // Approva o rifiuta un membro pendente, trasferendo i token o rimborsandoli.
    function approveMember(address memberAddress, bool approved) external onlyOwnerOrContractManager {
        uint256 index = getPendingMemberIndex(memberAddress);
        require(index != 9999999999, "Member not found in pending list");
        PendingMember memory pendingMember = pendingMembers[index];
        if (approved) {
            require(tokenBesteam.transfer(owner(), pendingMember.payment), "Token transfer to company failed");
            members[pendingMember.addr] = Member({
                role: pendingMember.role,
                membershipExpiry: block.timestamp + 365 days
            });
        } else {
            uint256 refundAmount = pendingMember.payment * 95 / 100;
            require(tokenBesteam.transfer(pendingMember.addr, refundAmount), "Token refund failed");
        }
        removePendingMember(index);
    }

    // Rimuove un membro pendente dall'elenco.
    function removePendingMember(uint256 index) internal {
        require(index < pendingMembers.length, "Invalid index");
        for (uint i = index; i < pendingMembers.length - 1; i++) {
            pendingMembers[i] = pendingMembers[i + 1];
        }
        pendingMembers.pop();
    }

    // Verifica lo stato della membership di un utente.
    function checkMembershipStatus(address user) external view returns (Role, bool) {
        Member memory member = members[user];
        return (member.role, member.membershipExpiry > block.timestamp);
    }

    // Struttura e mapping per gestire le elezioni.
    struct Election {
        uint256 id;
        uint256 endTime;
        bool isActive;
        mapping(address => uint256) votes;
        uint256 maxCandidates;
        address[] candidates;
        bool isCandidateRegistrationOpen;
    }

    mapping(address => mapping(uint256 => bool)) public alreadyVoted;
    mapping(address => mapping(uint256 => bool)) public isAlreadyACandidate;
    Election public currentElection;
    uint256 public nextElectionId;

    // Apre la registrazione dei candidati per una nuova elezione.
    function openCandidateRegistration(uint256 _maxCandidates) public onlyOwner {
        require(!currentElection.isActive, "An election is already active");
        currentElection.maxCandidates = _maxCandidates;
        currentElection.isCandidateRegistrationOpen = true;
        currentElection.id = nextElectionId;
        nextElectionId += 1;
    }

    // Permette ai membri di registrarsi come candidati se idonei.
    function registerAsCandidate() public nonReentrant {
        require(currentElection.isCandidateRegistrationOpen, "Candidate registration is not open");
        require(currentElection.maxCandidates > 0, "No available slots");
        require(members[msg.sender].role == Role.Player || members[msg.sender].role == Role.President, "Not eligible to be a candidate");
        require(!isAlreadyACandidate[msg.sender][currentElection.id], "Member already registered as a candidate");
        currentElection.candidates.push(msg.sender);
        isAlreadyACandidate[msg.sender][currentElection.id] = true;
        currentElection.maxCandidates -= 1;
    }

    // Chiude la registrazione dei candidati e avvia l'elezione.
    function closeCandidateRegistrationAndStartElection(uint256 _durationInDays) public onlyOwner {
        require(currentElection.isCandidateRegistrationOpen, "Candidate registration is not open");
        currentElection.isCandidateRegistrationOpen = false;
        currentElection.endTime = block.timestamp + (_durationInDays * 1 days);
        currentElection.isActive = true;
    }

    // Permette ai membri di votare per i candidati durante l'elezione.
    function voteForCounselor(address _candidate) public nonReentrant {
        require(members[msg.sender].role >= Role.Player, "Not eligible to vote");
        require(currentElection.isActive, "No active election");
        require(block.timestamp < currentElection.endTime, "Election has ended");
        require(!alreadyVoted[msg.sender][currentElection.id], "Already voted");
        require(isAlreadyACandidate[_candidate][currentElection.id], "Invalid candidate");
        currentElection.votes[_candidate] += 1;
        alreadyVoted[msg.sender][currentElection.id] = true;
    }

    // Restituisce i risultati dell'elezione, includendo i candidati e i loro voti.
    function getElectionResults() public view returns (address[] memory, uint256[] memory) {
        require(!currentElection.isActive, "Election is still active");
        address[] memory candidates = currentElection.candidates;
        uint256[] memory votes = new uint256[](candidates.length);
        for (uint256 i = 0; i < candidates.length; i++) {
            votes[i] = currentElection.votes[candidates[i]];
        }
        return (candidates, votes);
    }

    // Struttura, mapping e eventi per la gestione delle proposte.
    struct Proposal {
        string description; // Descrizione generale della proposta.
        string[10] optionDescriptions; // Descrizioni delle 10 opzioni di voto.
        uint256 deadline; // Data e ora di scadenza della proposta.
        uint256[10] voteCounts; // Conteggio dei voti per ciascuna opzione.
        uint256 roleType; // 1 per Sondaggi Collettivi, 2 per Votazioni Nominative.
        uint256 quorum; // Numero minimo di voti necessari per considerare la proposta valida.
        mapping(address => bool) voted; // Tracciamento di chi ha già votato.
        bool isPending; // Indica se la proposta è in attesa di essere permessa.
        bool isPermitted; // Indica se la proposta è permessa per la votazione.
        bool isPassed; // Indica se la proposta è stata approvata.
        uint256 winningOptionIndex; // Indice dell'opzione vincente.
        uint256 highestVoteCount; // Conteggio dei voti per l'opzione vincente.
    }

    uint256 public nextProposalId = 0; // ID per la prossima proposta.
    mapping(uint256 => Proposal) public proposals; // Mapping delle proposte.
    event NewProposal(uint256 indexed proposalId, string description, uint256 deadline);
    event Voted(uint256 indexed proposalId, address voter);
    
    // Crea una nuova proposta, specificando descrizione, opzioni, durata, ruolo e quorum.
    function createProposal(
        string memory _description, 
        string[10] memory _optionDescriptions, 
        uint256 _durationInDays, 
        uint256 _roleType, 
        uint256 _quorum
    ) public nonReentrant {
        uint256 proposalId = nextProposalId;
        Proposal storage proposal = proposals[proposalId];
        if(_roleType == 1) {
            require(members[msg.sender].role == Role.Besteam, "Not a DAO Admin");
            proposal.isPermitted = true;
        } else if (_roleType == 2) {
            require(
                members[msg.sender].role == Role.Besteam || 
                members[msg.sender].role == Role.Counselor || 
                members[msg.sender].role == Role.Shareholder, 
                "Not a DAO Admin"
            );
            if (members[msg.sender].role == Role.Besteam) {
                proposal.isPermitted = true;
            } else {
                proposal.isPending = true;
            }
        } else {
            revert("Invalid role type for proposal");
        }
        proposal.description = _description;
        for (uint i = 0; i < _optionDescriptions.length; i++) {
            proposal.optionDescriptions[i] = _optionDescriptions[i];
        }
        proposal.deadline = block.timestamp + (_durationInDays * 1 days);
        proposal.roleType = _roleType;
        proposal.quorum = _quorum;
        emit NewProposal(proposalId, _description, proposal.deadline);
        nextProposalId++;
    }
    
    // Permette ai membri di votare su una proposta, specificando l'ID della proposta e l'opzione scelta.
    function voteOnProposal(uint256 _proposalId, uint256 _optionIndex) public nonReentrant {
        require(_proposalId < nextProposalId, "Invalid proposal ID");
        require(_optionIndex < 10, "Invalid option index");
        require(members[msg.sender].role != Role.Besteam, "DAO Admin not allowed to vote");
        Proposal storage proposal = proposals[_proposalId];
        require(block.timestamp < proposal.deadline, "Voting has ended for this proposal");
        require(!proposal.voted[msg.sender], "Already voted");
        uint256 voteWeight = 1;
        if (proposal.roleType == 1) {
            require(members[msg.sender].role == Role.Player || members[msg.sender].role == Role.President, "Not a Player or President");
            if (members[msg.sender].role == Role.President){
                voteWeight = 3;
            }
        } else if (proposal.roleType == 2) {
            require(members[msg.sender].role == Role.Counselor || members[msg.sender].role == Role.Shareholder, "Not a Counselor or Shareholder");
            require(proposal.isPermitted == true, "Proposal not permitted at the moment");
        } else {
            revert("Not eligible to vote on this proposal");
        }
        proposal.voted[msg.sender] = true;
        proposal.voteCounts[_optionIndex] += voteWeight;
        emit Voted(_proposalId, msg.sender);
    }

    // Gestisce il permesso di una proposta in base al verdetto dell'owner o manager.
    function manageProposal(uint256 _proposalId, bool _verdict) public onlyOwnerOrContractManager {
        Proposal storage proposal = proposals[_proposalId];
        if (_verdict) {
            proposal.isPermitted = true;
            proposal.isPending = false;
        } else {
            proposal.isPermitted = false;
        }
    }

    // Restituisce le opzioni di voto, i conteggi dei voti e se il quorum è stato raggiunto per una proposta.
    function getProposalOptionsAndVoteCounts(uint256 _proposalId) public view returns (string[10] memory, uint256[10] memory, bool) {
        require(_proposalId < nextProposalId, "Invalid proposal ID");
        Proposal storage proposal = proposals[_proposalId];
        uint256 totalVotes = 0;
        for (uint256 i = 0; i < proposal.voteCounts.length; i++) {
            totalVotes += proposal.voteCounts[i];
        }
        bool quorumReached = totalVotes >= proposal.quorum;
        return (proposal.optionDescriptions, proposal.voteCounts, quorumReached);
    }

    // Restituisce gli ID delle proposte attive in un dato intervallo.
    function getActiveProposalsInRange(uint256 startIndex, uint256 endIndex) public view returns (uint256[] memory) {
        require(startIndex < endIndex, "Start index must be less than end index");
        require(endIndex <= nextProposalId, "End index out of bounds");
        uint256 activeCount = 0;
        for (uint256 i = startIndex; i < endIndex; i++) {
            if (proposals[i].deadline > block.timestamp) {
                activeCount++;
            }
        }
        uint256[] memory activeProposals = new uint256[](activeCount);
        uint256 currentIndex = 0;
        for (uint256 i = startIndex; i < endIndex; i++) {
            if (proposals[i].deadline > block.timestamp) {
                activeProposals[currentIndex++] = i;
            }
        }
        return activeProposals;
    }

    // Verifica il risultato di una proposta dopo la chiusura della votazione, determinando se il quorum è stato raggiunto e quale opzione ha vinto.
    function checkResult(uint256 _proposalId) public onlyOwnerOrContractManager returns (bool, uint256, uint256) {
        require(_proposalId < nextProposalId, "Invalid proposal ID");
        Proposal storage proposal = proposals[_proposalId];
        require(block.timestamp > proposal.deadline, "Voting is still active");
        uint256 totalVotes = 0;
        uint256 highestVoteCount = 0;
        uint256 winningOptionIndex = 0;
        for (uint256 i = 0; i < proposal.voteCounts.length; i++) {
            uint256 optionVotes = proposal.voteCounts[i];
            totalVotes += optionVotes;
            if (optionVotes > highestVoteCount) {
                highestVoteCount = optionVotes;
                winningOptionIndex = i;
            }
        }
        bool quorumReached = totalVotes >= proposal.quorum;
        proposal.isPassed = quorumReached && highestVoteCount > 0;
        if (proposal.isPassed) {
            proposal.winningOptionIndex = winningOptionIndex;
            proposal.highestVoteCount = highestVoteCount;
        }
        return (proposal.isPassed, winningOptionIndex, totalVotes);
    }
}
