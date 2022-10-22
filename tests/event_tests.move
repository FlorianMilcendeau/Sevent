#[test_only]
module sevent::event_tests {
    use sevent::event::{Self, Event};
    
    use sui::test_scenario;

    const ADMIN: address = @0xABBA;
    const USER1_ADDRESS: address = @0xA001;

    const TITLE: vector<u8> = vector[ 77, 121,  32, 116, 105, 116, 108, 101];
    const DESCRIPTION: vector<u8> = vector[ 73,  39, 109,  32,  97, 32, 100, 101, 115,  99, 114, 105, 112, 116, 105, 111, 110 ];
    const STATUS: vector<u8> = vector[ 84, 111, 100, 111 ];

    #[test]
    public fun test_create_event() {
        let scenario = test_scenario::begin(ADMIN);
        {
            event::create_event(
                TITLE, 
                DESCRIPTION, 
                STATUS,
                1664115386304, 
                1664015286304, 
                test_scenario::ctx(&mut scenario)
            );
        };

        test_scenario::next_tx(&mut scenario, USER1_ADDRESS);
        {
            let has_token = test_scenario::has_most_recent_for_sender<Event>(&mut scenario);
            assert!(!has_token, 0);
        };

        test_scenario::next_tx(&mut scenario, ADMIN);
        {
            let has_token = test_scenario::has_most_recent_for_sender<Event>(&mut scenario);
            assert!(has_token, 0);
        };

        test_scenario::end(scenario);
    }
}