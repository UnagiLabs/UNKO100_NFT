module unko100_nft::events {
    use sui::event;

    // ミントイベント
    public struct MintEvent has copy, drop {
        token_id: u64,
        minter: address,
        timestamp: u64,
    }

    // 転送イベント
    public struct TransferEvent has copy, drop {
        token_id: u64,
        from: address,
        to: address,
        price: Option<u64>,
    }

    // イベント発行関数
    public fun emit_mint_event(
        token_id: u64,
        minter: address,
        timestamp: u64
    ) {
        event::emit(MintEvent {
            token_id,
            minter,
            timestamp,
        });
    }

    public fun emit_transfer_event(
        token_id: u64,
        from: address,
        to: address,
        price: Option<u64>
    ) {
        event::emit(TransferEvent {
            token_id,
            from,
            to,
            price,
        });
    }
} 