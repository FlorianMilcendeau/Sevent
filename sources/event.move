module sevent::event {
    use sui::object::{Self, UID};
    use std::string::{Self, String};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;

    struct Event has key, store {
        id: UID,
        /// Event's title 
        title: String,
        /// Event's description 
	    description: String,
        /// Event's Status
	    status: String,
        /// minimum price ticket of event
	    price_min: u64,
        /// minimum price ticket of event
	    price_max: u64,
        /// Event start date
	    start_date: u64,
        /// Event end date
	    end_date: u64,
    }

    public entry fun create_event(
        title: vector<u8>, 
        description: vector<u8>, 
        status: vector<u8>, 
        price_min: u64, 
        price_max: u64,
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
            price_min,
            price_max,
            end_date,
            start_date,
        };

        transfer::transfer(event, sender);
    }
}