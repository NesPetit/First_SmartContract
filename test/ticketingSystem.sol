pragma solidity ^0.6.0;

contract ticketingSystem {

	struct Artist {
		bytes32 name;
		uint artistCategory;
		uint totalTicketSold;
		address payable owner;
	}
	struct Venue {
		bytes32 name;
		uint capacity;
		uint standardComission;
		address payable owner;
	}

	struct Concert {
		uint artistId;
		uint venueId;
		uint concertDate;
		uint ticketPrice;
		uint totalSoldTicket;
		uint totalMoneyCollected;
		bool validatedByArtist;
		bool validatedByVenue;
	}

	struct Ticket {
		uint concertId;
		uint ticketNumber;
		uint amountPaid;
		bool isAvailable;
		address payable owner;
		//bool isAvailableForSale;
		//uint salePrice;
	}

	mapping(uint => Artist) public artistsRegister;
	mapping(uint => Venue) public venuesRegister;
	mapping(uint => Concert) public concertsRegister;
	mapping(uint => Ticket) public ticketsRegister;

	uint public nextArtistId;
	uint public nextVenueId;
	uint public nextConcertId;
	uint public nextTicketId;

	constructor() public
	{
		nextArtistId = 1;
		nextVenueId = 1;
		nextConcertId = 1;
		nextTicketId = 1;
	}

	function createArtist(bytes32 _name, uint _artistCategory) 
	public 
	returns (uint artistNumber)
	{
		require(_name != 0x0);
		artistsRegister[nextArtistId] = Artist(_name, _artistCategory, 0, msg.sender);
		artistNumber = nextArtistId;
		nextArtistId += 1;
	}

	function modifyArtist(uint _artistId, bytes32 _name, uint _artistCategory, address payable _newOwner) 
	public
	{
		require(_name != 0x0);
		require(artistsRegister[_artistId].owner == msg.sender);
		artistsRegister[_artistId] = Artist(_name, _artistCategory, artistsRegister[_artistId].totalTicketSold, _newOwner);
	}

	function createVenue(bytes32 _name, uint _capacity, uint _standardComission) 
	public 
	returns (uint venueNumber)
	{
		require(_name != 0x0);
		venuesRegister[nextVenueId] = Venue(_name, _capacity, _standardComission, msg.sender);
		venueNumber = nextVenueId;
		nextVenueId += 1;
	}

    function modifyVenue(uint _venueId, bytes32 _name, uint _capacity, uint _standardComission, address payable _newOwner) 
	public 
	{
		require(_name != 0x0);
		require(venuesRegister[_venueId].owner == msg.sender);
		venuesRegister[_venueId] = Venue(_name, _capacity, _standardComission, _newOwner);
	}

    function createConcert(uint _artistId, uint _venueId, uint _concertDate, uint _ticketPrice) 
	public 
	returns (uint concertNumber)
	{
		bool _validatedArtist = false;
		if(artistsRegister[_artistId].owner == msg.sender)
		{
			_validatedArtist = true;
		}
		concertsRegister[nextConcertId] = Concert(_artistId, _venueId, _concertDate, _ticketPrice, 0, 0, _validatedArtist, false);
		concertNumber = nextConcertId;
		nextConcertId += 1;
	}
	
	function validateConcert(uint _concertId) 
	public 
	returns (bool validatedConcert)
	{
		concertsRegister[_concertId].validatedByArtist = true;
		concertsRegister[_concertId].validatedByVenue = true;
		validatedConcert = true;
	}

	function emitTicket(uint _concertId, address payable _ticketOwner) 
	public 
	returns (uint ticketNumber)
	{
		require(artistsRegister[1].owner == msg.sender);
		ticketsRegister[nextTicketId] = Ticket(_concertId, nextTicketId, 0, true, _ticketOwner);
		concertsRegister[_concertId].totalSoldTicket += 1;
		nextTicketId += 1;
	}

	function useTicket(uint _ticketId)
	public
	{
		require(ticketsRegister[_ticketId].owner == msg.sender);
		require(concertsRegister[nextConcertId].concertDate <= 60*60*24);
		require(concertsRegister[nextConcertId].validatedByVenue == true);
		//ticketsRegister[_ticketId].isAvailable = false;

	}
}