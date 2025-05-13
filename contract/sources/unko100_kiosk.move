module unko100_nft::kiosk {
    use sui::object::{Self, ID, UID};
    use sui::kiosk::{Self, Kiosk, KioskOwnerCap};
    use sui::transfer_policy::{Self, TransferPolicy, TransferRequest};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;
    use sui::event;
    use std::option::{Self, Option};
    use unko100_nft::nft::{Self, UnkoNFT};
    use unko100_nft::events;
    use sui::table::{Self, Table};

    const EInvalidKioskOwnerCap: u64 = 0;
    const EInvalidPrice: u64 = 1;
    const EInsufficientPayment: u64 = 2;
    const ENftNotListed: u64 = 3;
    const EInvalidTransferPolicy: u64 = 5;

    struct NftListedEvent has copy, drop {
        kiosk_id: ID,
        nft_id: ID,
        price: u64,
        seller: address,
    }

    struct NftPurchasedEvent has copy, drop {
        kiosk_id: ID,
        nft_id: ID,
        price: u64,
        seller: address,
        buyer: address,
    }

    public struct UnkoCollection has key {
        id: UID,
        whitelist: Table<address, bool>,
    }

    public fun list_nft(
        kiosk: &mut Kiosk,
        cap: &KioskOwnerCap,
        nft: UnkoNFT,
        price: Coin<SUI>,
        policy: &TransferPolicy<UnkoNFT>,
        ctx: &mut TxContext
    ) {
        assert!(kiosk::owner(kiosk) == tx_context::sender(ctx), EInvalidKioskOwnerCap);
        let nft_id: ID = object::id(&nft);
        kiosk::place(kiosk, cap, nft);
        let price_value = coin::value(&price);
        kiosk::list(kiosk, cap, nft_id, price_value);
        transfer::public_transfer(price, kiosk::owner(kiosk));

        event::emit(NftListedEvent {
            kiosk_id: object::id(kiosk),
            nft_id,
            price: price_value,
            seller: tx_context::sender(ctx),
        });
    }

    public fun purchase_nft(
        kiosk: &mut Kiosk,
        payment: Coin<SUI>,
        nft_id: ID,
        policy: &TransferPolicy<UnkoNFT>,
        ctx: &mut TxContext
    ): (UnkoNFT, TransferRequest<UnkoNFT>) {
        assert!(kiosk::owner(kiosk) != tx_context::sender(ctx), EInvalidKioskOwnerCap);
        let payment_value = coin::value(&payment);
        let seller = kiosk::owner(kiosk);
        let buyer = tx_context::sender(ctx);

        // 支払いをKioskの所有者に転送
        transfer::public_transfer(payment, seller);

        // KioskからNFTを購入し、TransferRequestを取得
        let (nft, transfer_request) = kiosk::purchase(kiosk, nft_id, payment_value);

        // TransferPolicyのルールを確認
        transfer_policy::confirm_request(policy, transfer_request);

        event::emit(NftPurchasedEvent {
            kiosk_id: object::id(kiosk),
            nft_id,
            price: payment_value,
            seller,
            buyer,
        });

        // 転送イベントの発行
        let token_id = nft::token_id(&nft);
        events::emit_transfer_event(
            token_id,
            seller,
            buyer,
            option::some(payment_value)
        );

        (nft, transfer_request)
    }

    public fun delist_nft(
        kiosk: &mut Kiosk,
        cap: &KioskOwnerCap,
        nft_id: ID,
        _policy: &TransferPolicy<UnkoNFT>,
        ctx: &mut TxContext
    ): UnkoNFT {
        assert!(kiosk::owner(kiosk) == tx_context::sender(ctx), EInvalidKioskOwnerCap);
        kiosk::delist(kiosk, cap, nft_id);
        let nft: UnkoNFT = kiosk::take(kiosk, cap, nft_id);
        nft
    }

    public fun transfer_nft(
        kiosk: &mut Kiosk,
        cap: &KioskOwnerCap,
        nft_id: ID,
        to: address,
        _policy: &TransferPolicy<UnkoNFT>,
        ctx: &mut TxContext
    ) {
        assert!(kiosk::owner(kiosk) == tx_context::sender(ctx), EInvalidKioskOwnerCap);
        let nft: UnkoNFT = kiosk::take(kiosk, cap, nft_id);
        transfer::public_transfer(nft, to);
    }

    public fun borrow_nft(
        kiosk: &Kiosk,
        cap: &KioskOwnerCap,
        nft_id: ID,
        ctx: &TxContext
    ): &UnkoNFT {
        assert!(kiosk::owner(kiosk) == tx_context::sender(ctx), EInvalidKioskOwnerCap);
        kiosk::borrow(kiosk, cap, nft_id)
    }
} 