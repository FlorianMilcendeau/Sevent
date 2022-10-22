module sevent::inventory {
    use sui::object::{Self, ID, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::vec_set::{Self, VecSet};

    struct Inventory has key {
        id: UID,
        objects: VecSet<ID>
    }

    struct Item<T: store> has key {
        id: UID,
        value: T
    }

    public fun new_inventory(ctx: &mut TxContext): Inventory {
        Inventory {
            id: object::new(ctx),
            objects: vec_set::empty()
        }
    }

    public entry fun create(ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx);
        let inventory = new_inventory(ctx);

        transfer::transfer(inventory, sender);
    }

    public fun new_item<T: store>(value: T, ctx: &mut TxContext): Item<T> {
        Item {
            id: object::new(ctx),
            value
        }
    }

    public entry fun add_item<T: store>(inventory: &mut Inventory, item: T,  ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx);
        let item_created = new_item<T>(item, ctx);
        
        vec_set::insert(&mut inventory.objects, object::id(&item_created));
        transfer::transfer(item_created, sender);
    }
}