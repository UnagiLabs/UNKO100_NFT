module unko100_nft::admin {
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use unko100_nft::nft::{Self, UnkoCollection};
    use unko100_nft::mint::{Self, MintState};

    // エラー定数
    const ENotAdmin: u64 = 1;
    const EInvalidPrice: u64 = 2;
    const EInvalidTime: u64 = 3;

    // 管理者権限
    public struct AdminCap has key {
        id: UID,
        admin: address,
    }

    // 管理者権限の検証
    public fun verify_admin(cap: &AdminCap, ctx: &TxContext) {
        assert!(cap.admin == tx_context::sender(ctx), ENotAdmin);
    }

    // ミント価格の設定
    public fun set_mint_price(
        cap: &AdminCap,
        collection: &mut UnkoCollection,
        new_price: u64,
        ctx: &TxContext
    ) {
        verify_admin(cap, ctx);
        assert!(new_price > 0, EInvalidPrice);
        collection.mint_price = new_price;
    }

    // 一般販売開始時間の設定
    public fun set_public_mint_start(
        cap: &AdminCap,
        collection: &mut UnkoCollection,
        start_time: u64,
        ctx: &TxContext
    ) {
        verify_admin(cap, ctx);
        assert!(start_time > tx_context::epoch_timestamp_ms(ctx), EInvalidTime);
        collection.public_mint_start = start_time;
    }

    // ホワイトリストへの追加
    public fun add_to_whitelist(
        cap: &AdminCap,
        state: &mut MintState,
        address: address,
        ctx: &TxContext
    ) {
        verify_admin(cap, ctx);
        table::add(&mut state.whitelist, address, true);
    }
} 