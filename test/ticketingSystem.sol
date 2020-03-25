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
		bool isAvailableForSale;
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
		require(_name != 0x0, "enter a valid name plz");

		artistsRegister[nextArtistId] = Artist(_name, _artistCategory, 0, msg.sender);
		artistNumber = nextArtistId;
		nextArtistId += 1;
	}

	function modifyArtist(uint _artistId, bytes32 _name, uint _artistCategory, address payable _newOwner)
	public
	{
		require(_name != 0x0, "enter a valid name plz");
		require(artistsRegister[_artistId].owner == msg.sender, "you aren't the owner");

		artistsRegister[_artistId] = Artist(_name, _artistCategory, artistsRegister[_artistId].totalTicketSold, _newOwner);
	}

	function createVenue(bytes32 _name, uint _capacity, uint _standardComission)
	public
	returns (uint venueNumber)
	{
		require(_name != 0x0, "enter a valid name plz");

		venuesRegister[nextVenueId] = Venue(_name, _capacity, _standardComission, msg.sender);
		venueNumber = nextVenueId;
		nextVenueId += 1;
	}

    function modifyVenue(uint _venueId, bytes32 _name, uint _capacity, uint _standardComission, address payable _newOwner)
	public
	{
		require(_name != 0x0, "enter a valid name plz");
		require(venuesRegister[_venueId].owner == msg.sender, "you aren't the owner");

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
	{
		require(artistsRegister[1].owner == msg.sender, "you aren't the owner");

		ticketsRegister[nextTicketId] = Ticket(_concertId, nextTicketId, 0, true, _ticketOwner, true);
		concertsRegister[_concertId].totalSoldTicket += 1;
		nextTicketId += 1;
	}

	function useTicket(uint _ticketId)
	public
	{
		uint day = 60*60*24;
		uint _concertDate = concertsRegister[ticketsRegister[_ticketId].concertId].concertDate;
		require(ticketsRegister[_ticketId].owner == msg.sender, "you aren't the owner");
        require(now > _concertDate - day, "you can't use the ticket before the day of the event");
		require(concertsRegister[ticketsRegister[_ticketId].concertId].validatedByVenue == true, "the venue didn't validate the event");

		ticketsRegister[_ticketId].isAvailable = false;
        ticketsRegister[_ticketId].owner = 0x0000000000000000000000000000000000000000;
	}

	function buyTicket(uint _concertId)
	public payable
	{
        require(concertsRegister[_concertId].ticketPrice <= msg.value, "give more money");

		concertsRegister[_concertId].totalSoldTicket += 1;
		concertsRegister[_concertId].totalMoneyCollected += concertsRegister[_concertId].ticketPrice;

		ticketsRegister[nextTicketId].concertId = 1;
		ticketsRegister[nextTicketId].amountPaid = concertsRegister[_concertId].ticketPrice;
		ticketsRegister[nextTicketId].isAvailable = true;
		ticketsRegister[nextTicketId].owner = msg.sender;
		ticketsRegister[nextTicketId].isAvailableForSale = false;
		artistsRegister[concertsRegister[_concertId].artistId].totalTicketSold += 1;
		nextTicketId += 1;
	}

	function transferTicket(uint _ticketId, address payable _newOwner)
	public
	{
		require(ticketsRegister[_ticketId].owner == msg.sender, "don't own");

		ticketsRegister[_ticketId].owner = _newOwner;
	}

	function cashOutConcert(uint _concertId, address payable _cashOutAddress)
	public
	{
		require(now > concertsRegister[_concertId].concertDate, "Wait the start of the concert");
		require(artistsRegister[concertsRegister[_concertId].artistId].owner == msg.sender, "you're not an artist");

		uint venueMoney = venuesRegister[concertsRegister[_concertId].venueId].standardComission;

		_cashOutAddress.transfer(concertsRegister[_concertId].totalMoneyCollected - venueMoney);
		venuesRegister[concertsRegister[_concertId].venueId].owner.transfer(venueMoney);
	}

	function offerTicketForSale(uint _ticketId, uint _salePrice)
	public
	{
		require(ticketsRegister[_ticketId].owner == msg.sender, "you aren't the owner");
		require(_salePrice < concertsRegister[ticketsRegister[_ticketId].concertId].ticketPrice, "the price is too expensive");

		ticketsRegister[_ticketId].isAvailableForSale = true;
		ticketsRegister[_ticketId].amountPaid = _salePrice;
	}

	function buySecondHandTicket(uint _ticketId)
	public payable
	{
		require(ticketsRegister[_ticketId].amountPaid <= msg.value, "give more money");
		require(ticketsRegister[_ticketId].isAvailable == true, "ticket isn't available");
		require(ticketsRegister[_ticketId].isAvailableForSale == true,  "ticket isn't available for sale");

		ticketsRegister[_ticketId].owner = msg.sender;
		ticketsRegister[_ticketId].isAvailable = false;
	}

}