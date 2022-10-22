module sevent::ticket {
    use std::string::{Self, String};

    use sui::event::emit;
    use sui::object::{Self, ID, UID};
    use sui::url::{Self, Url};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    
    use sevent::event::Event;

    struct Ticket has key, store {
        id: UID,
        /// Title for the NFT
        title: String,
        /// URL for the NFT
        url: Url,
        /// The Event ID of the NFT
        event_id: ID,
    }

    struct TicketMinted has copy, drop {
        /// The Object ID of the NFT
        object_id: ID,
        /// The creator of the NFT
        creator: address,
        /// The title of the NFT
        title: String,
    }

    public entry fun mint_to_sender(
        event_ref: &mut Event,
        title: vector<u8>,
        url: vector<u8>,
        supply: u64,
        ctx: &mut TxContext,
    ) {
        let sender = tx_context::sender(ctx);
        let i = 0;

        while (i < supply) {
            let ticket = Ticket {
                id: object::new(ctx),
                title: string::utf8(title),
                url: url::new_unsafe_from_bytes(url),
                event_id: object::id(event_ref),
            };

            emit(TicketMinted {
                object_id: object::id(&ticket),
                creator: sender,
                title: ticket.title,
            });

            transfer::transfer(ticket, sender);
            i = i + 1; 
        }
    }
}