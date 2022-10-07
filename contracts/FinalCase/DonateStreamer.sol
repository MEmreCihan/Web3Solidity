// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

contract DonateStreamer {

    uint256 public balance;
    address public admin;

    constructor() {
        admin = msg.sender;
    }

    //Bağış adında bir obje oluşturduk
    struct Donation {
        address creator;
        string name;
        uint256 amount;
        address payable streamer;
    }

    uint256 totalDonations; //Toplam bağış objesi sayısı
    mapping(uint256 => Donation) public donations;  //Bağış objemizi id numarası alacak şekilde listeledik

    event Donate(uint256 donationsId, uint256 amount); //index numarası ve miktarı parametre olan event oluşturduk

    function createDonation(    //bağışın miktarını ve yayıncının belirtilmesini sağlayan fonsiyon
        string memory _name,
        address payable _streamer,
        uint256 _amount
    ) public returns(uint256 donationsId){
        Donation storage donation = donations[totalDonations];

        donation.creator = msg.sender;
        donation.name = _name;
        donation.streamer = _streamer;
        donation.amount = _amount;

        require(balance>donation.amount, "Not enough balance");
        totalDonations += 1;
        return totalDonations -1;
    }

    function sendEtherToContract() payable external{     //akıllı kontrağa ether transferi
        require(msg.value >0, "You should specify amount");
        balance += msg.value;
    }

    function donate(uint256 id) external {             //yayıncıya etherin aktarılması
        Donation storage donation = donations[id];
        require(msg.sender == donation.creator, "You have to create donation for send ether");
        donation.streamer.transfer(donation.amount);
        balance -= donation.amount;

        emit Donate(id, donation.amount);
    }
}