module sevent::marketplace {
    use sui::coin::{Self, Coin};
    use sui::dynamic_field;
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;

    const ENotOwner: u64 = 1;
    const EAmountIncorrect: u64 = 2;
    
    struct Marketplace has key {
        id: UID
    }

    struct Listing<T: key + store, phantom C> has store {
        item: T,
        price: u64,
        owner: address
    }

    public entry fun create(ctx: &mut TxContext) {
        let id = object::new(ctx);
        let marketplace = Marketplace { id };

        transfer::share_object(marketplace);
    }

    public entry fun list<T: key + store, C>(marketplace: &mut Marketplace, item: T, price: u64, ctx: &mut TxContext) {
        let item_id = object::id(&item);
        let sender = tx_context::sender(ctx);
        let listing = Listing<T, C> {
            item,
            price,
            owner: sender
        };

        dynamic_field::add(&mut marketplace.id, item_id, listing);
    }

    public fun delist<T: key + store, C>(marketplace: &mut Marketplace, item_id: ID , sender: address): T {
        let Listing<T, C> { item, owner, price: _ } = dynamic_field::remove(&mut marketplace.id, item_id);

        assert!(sender == owner, ENotOwner);
        item
    }

    public entry fun delist_and_take<T: key + store, C>(marketplace: &mut Marketplace, item_id: ID , ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx);
        let item = delist<T, C>(marketplace, item_id, sender);

        transfer::public_transfer(item, sender);
    }

    public fun buy<T: key + store, C>(marketplace: &mut Marketplace, item_id: ID, received_amount: Coin<C>): T {
        let Listing<T, C> { item, owner, price } = dynamic_field::remove(&mut marketplace.id, item_id);
        
        assert!(price == coin::value(&received_amount), EAmountIncorrect);
        transfer::public_transfer(received_amount, owner);

        item
    }

    public entry fun buy_and_take<T: key + store, C>(marketplace: &mut Marketplace, item_id: ID, received_amount: Coin<C>,ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx);
        let item = buy<T, C>(marketplace, item_id, received_amount);

        transfer::public_transfer(item, sender);
    }
}