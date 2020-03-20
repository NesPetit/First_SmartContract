pragma solidity ^0.6.0;

contract ticketingSystem {

	struct Artist {
		bytes32 name;
		uint artistCategory;
		address payable owner;
		uint totalTicketSold;
	}

	mapping(uint => Artist) public artistsRegister;

	uint public nextArtistId;

	constructor() public
	{
		nextArtistId = 1;
	}

	function createArtist(bytes32 _name, uint _artistCategory) public returns (uint artistNumber)
	{
		require(_name != 0x0);
		artistsRegister[nextArtistId] = Artist(_name, _artistCategory, msg.sender);
		artistNumber = nextArtistId;
		nextArtistId += 1;
	}

	function modifyArtist(uint _artistId, bytes32 _name, uint _artistCategory, address payable _newOwner) public
	{
		require(_name != 0x0);
		require(artistsRegister[_artistId].owner == msg.sender);
		artistsRegister[_artistId] = Artist(_name, _artistCategory, _newOwner);
	}

}