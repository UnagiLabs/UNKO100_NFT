module unko100_nft::collection {
    use sui::object::{Self, UID};
    use sui::table::{Self, Table};
    use unko100_nft::nft::{Self, UnkoNFT};

    // コレクション管理
    public struct Collection has key {
        id: UID,
        nfts: Table<u64, UnkoNFT>,  // token_id -> NFT
        holders: Table<address, u64>, // アドレス -> 保有数
    }

    // コレクション統計
    public struct CollectionStats has key {
        id: UID,
        total_holders: u64,
        total_transfers: u64,
        floor_price: u64,
    }

    // イベント
    public struct TransferEvent has copy, drop {
        token_id: u64,
        from: address,
        to: address,
        price: Option<u64>,
    }

    // NFTの追加
    public fun add_nft(
        collection: &mut Collection,
        nft: UnkoNFT,
        holder: address
    ) {
        let token_id = nft::token_id(&nft);
        table::add(&mut collection.nfts, token_id, nft);
        update_holder_count(collection, holder, 1);
    }

    // 保有者数の更新
    fun update_holder_count(
        collection: &mut Collection,
        holder: address,
        delta: u64
    ) {
        if (table::contains(&collection.holders, holder)) {
            let count = table::borrow_mut(&mut collection.holders, holder);
            *count = *count + delta;
        } else {
            table::add(&mut collection.holders, holder, delta);
        };
    }
} 