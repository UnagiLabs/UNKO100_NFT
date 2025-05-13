module unko100_nft::mint {
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;
    use sui::table::{Self, Table};
    use sui::kiosk::{Self, Kiosk, KioskOwnerCap};
    use sui::transfer_policy::{Self, TransferPolicy};
    use std::string::String;
    use unko100_nft::nft::{Self, UnkoNFT, UnkoCollection};

    // エラー定数
    const EInvalidPaymentAmount: u64 = 1;
    const ENotWhitelisted: u64 = 2;
    const EDailyLimitExceeded: u64 = 3;
    const EMintNotStarted: u64 = 4;
    const EMaxSupplyReached: u64 = 5;

    // ミント状態管理
    public struct MintState has key {
        id: UID,
        whitelist: Table<address, bool>,  // ホワイトリスト
        daily_mints: Table<address, u64>, // 1日あたりのミント数
        last_mint_time: Table<address, u64>, // 最後のミント日時
    }

    // イベント
    public struct MintEvent has copy, drop {
        token_id: u64,
        minter: address,
        timestamp: u64,
    }

    // ホワイトリストミント
    public fun whitelist_mint(
        state: &mut MintState,
        collection: &mut UnkoCollection,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);
        // コレクションのホワイトリストに登録されているか、かつ未使用か
        assert!(table::contains(&collection.whitelist, sender), ENotWhitelisted);
        let used = table::borrow(&collection.whitelist, sender);
        assert!(!used, ENotWhitelisted); // 既に使ったらエラー

        // 無料ミント処理
        table::insert(&mut collection.whitelist, sender, true); // 1回使ったのでtrue
        // NFT発行・イベント発行などの処理（既存ロジックに合わせて追加）
        // TODO: NFT発行・イベント発行
    }

    // 一般ミント
    public fun public_mint(
        state: &mut MintState,
        collection: &mut UnkoCollection,
        payment: Coin<SUI>,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);
        let current_time = tx_context::epoch_timestamp_ms(ctx);
        
        assert!(current_time >= collection.public_mint_start, EMintNotStarted);
        assert!(coin::value(&payment) == collection.mint_price, EInvalidPaymentAmount);
        
        // 1日3個の制限チェック
        // TODO: 実装
    }
} 