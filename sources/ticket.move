module sevent::ticket {
    use sui::event;
    use sui::object::{Self, ID, UID};
    use sevent::event::Event;
    use std::string::{Self, String};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::url::{Self, Url};

    struct Ticket has key, store {
        id: UID,
        /// Title for the token
        title: String,
        /// URL for the token
        url: Url,
        /// The parent ID of the NFT
        parent_id: ID
    }

    struct TicketMinted has copy, drop {
        /// The Object ID of the NFT
        object_id: ID,
        /// The creator of the NFT
        creator: address,
        /// The name of the NFT
        title: String,
    }

    public entry fun mint_to_sender(
        event: &Event,
        title: vector<u8>,
        url: vector<u8>,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);
        let nft = Ticket {
            id: object::new(ctx),
            title: string::utf8(title),
            url: url::new_unsafe_from_bytes(url),
            parent_id: object::id(event)
        };

        event::emit(TicketMinted {
            object_id: object::id(&nft),
            creator: sender,
            title: nft.title,
        });

        transfer::transfer(nft, sender);
    }
}