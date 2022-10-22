#[test_only]
module sevent::ticket_tests {
    use std::vector;

    use sui::object;
    use sui::test_scenario;
    use sui::transfer;
    
    use sevent::ticket::{Self, Ticket};
    use sevent::event::{Self, Event};

    const ADMIN: address = @0xABBA;
    const USER1_ADDRESS: address = @0xA001;

    /// ========= data Event =========
    const TITLE_EVENT: vector<u8> = vector[ 77, 121,  32, 116, 105, 116, 108, 101 ];
    const DESCRIPTION_EVENT: vector<u8> = vector[ 73,  39, 109,  32,  97, 32, 100, 101, 115,  99, 114, 105, 112, 116, 105, 111, 110 ];
    const STATUS_EVENT: vector<u8> = vector[ 84, 111, 100, 111 ];

    /// ========= data Ticket =========
    const TITLE_TICKET: vector<u8> = vector[
        80,  65,  83,  83, 32,  50,  32, 100,
        97, 121, 115,  32, 45,  32,  67, 114,
        121, 112, 116, 111, 99, 117, 114, 114,
        101, 110,  99, 121, 32, 109, 101, 101,
        116, 105, 110, 103
    ];
    const URL_TICKET: vector<u8> = vector[
        104, 116, 116, 112, 115,  58,  47,  47, 104, 105, 103, 104,
        119, 111, 114, 116, 104,  99, 105, 116, 105, 122, 101, 110,
        46,  99, 111, 109,  47, 119, 112,  45,  99, 111, 110, 116,
        101, 110, 116,  47, 117, 112, 108, 111,  97, 100, 115,  47,
        50,  48,  49,  57,  47,  49,  50,  47,  98, 108, 111,  99,
        107,  99, 104,  97, 105, 110,  45, 116, 114, 101, 110, 100,
        115,  45,  50,  48,  50,  48,  46, 106, 112, 103
    ];

    #[test]
    public fun test_mint_ticket() {
        let scenario = test_scenario::begin(ADMIN);

        {
            event::create_event(
                TITLE_EVENT, 
                DESCRIPTION_EVENT, 
                STATUS_EVENT,
                1664115386304, 
                1664015286304, 
                test_scenario::ctx(&mut scenario)
            );
            
        };

        test_scenario::next_tx(&mut scenario, ADMIN);
        {
            let event = test_scenario::take_from_address<Event>(&mut scenario, ADMIN);
            
            ticket::mint_to_sender(&mut event, TITLE_TICKET, URL_TICKET, 10, test_scenario::ctx(&mut scenario));
            test_scenario::return_to_sender(&mut scenario, event);
        };

        test_scenario::next_tx(&mut scenario, USER1_ADDRESS);
        {
            assert!(vector::length(&test_scenario::ids_for_sender<Ticket>(&mut scenario)) == 0, 0);
        };

        test_scenario::next_tx(&mut scenario, ADMIN);
        {
            let ticketsID = test_scenario::ids_for_sender<Ticket>(&mut scenario);
            let numberTicket: u64 = vector::length(&ticketsID); 
            assert!(numberTicket == 10, 0);
            
            while (numberTicket > 0) {
                let ticket = test_scenario::take_from_sender_by_id<Ticket>(&mut scenario, vector::pop_back(&mut ticketsID));
                assert!(test_scenario::was_taken_from_address(ADMIN, object::id(&ticket)), 2);
                transfer::transfer(ticket, ADMIN);
                numberTicket = numberTicket - 1;
            }

        };
        test_scenario::end(scenario);
    }
}