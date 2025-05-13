module unko100_nft::nft {
    use sui::vec_map::VecMap;
    use std::string::String;
    use sui::object::UID;
    use sui::table::{Self, Table};

    // NFT本体
    public struct UnkoNFT has key, store {
        id: UID,
        token_id: u64,        // #001-#100
        name: String,         // "Unko #001" など
        image_url: String,    // WalrusのURL
        attributes: VecMap<String, String>,
        minted_by: address,   // ミントしたアドレス
        minted_at: u64,       // ミント日時
    }

    // コレクション設定
    public struct UnkoCollection has key {
        id: UID,
        total_supply: u64,    // 現在の発行数
        max_supply: u64,      // 最大発行数（100）
        mint_price: u64,      // ミント価格（3 SUI）
        whitelist_size: u64,  // ホワイトリスト数（10）
        public_mint_start: u64, // 一般販売開始日時
        daily_mint_limit: u64,  // 1日のミント制限（3）
        whitelist: Table<address, bool>, // ホワイトリスト
    }

    // アクセサ関数
    public fun token_id(nft: &UnkoNFT): u64 {
        nft.token_id
    }

    /// ホワイトリストにアドレスを追加（管理者用）
    public fun add_to_whitelist(collection: &mut UnkoCollection, addr: address) {
        table::insert(&mut collection.whitelist, addr, false);
    }
}


