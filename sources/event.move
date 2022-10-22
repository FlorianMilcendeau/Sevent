module sevent::event {
    use std::string::{Self, String};

    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    struct Event has key, store {
        id: UID,
        /// Event's title 
        title: String,
        /// Event's description 
	    description: String,
        /// Event's Status
	    status: String,
        /// Event start date
	    start_date: u64,
        /// Event end date
	    end_date: u64,
    }

    public entry fun create_event(
        title: vector<u8>, 
        description: vector<u8>, 
        status: vector<u8>, 
        start_date: u64,
        end_date: u64,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);

        let event = Event {
            id: object::new(ctx),
            title: string::utf8(title),
            description: string::utf8(description),
            status: string::utf8(status),
            end_date,
            start_date,
        };

        transfer::transfer(event, sender);
    }
}