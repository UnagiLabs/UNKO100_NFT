# Unko100 NFT

Suiブロックチェーン上で動作するNFTコレクション「Unko100」のスマートコントラクト。

## 概要

- 総供給量: 100個
- ホワイトリスト: 最初の10アドレスは無料ミント可能
- ミント価格: 3 SUI
- 1日あたりのミント制限: 3個/アドレス

## 機能

- ホワイトリスト無料ミント
- 一般販売（有料ミント）
- Kioskを使用したNFTの取引
- 転送ポリシーによる取引制御

## 技術スタック

- Sui Move
- Sui Kiosk
- Sui Transfer Policy

## セットアップ

1. Sui CLIのインストール:
```bash
cargo install --locked --git https://github.com/MystenLabs/sui.git --branch devnet sui
```

2. プロジェクトのビルド:
```bash
cd contract
sui move build
```

## コントラクトの構造

- `unko100_nft.move`: NFTの基本構造とコレクション管理
- `unko100_mint.move`: ミント機能の実装
- `unko100_kiosk.move`: Kioskを使用した取引機能
- `unko100_events.move`: イベント定義
- `unko100_admin.move`: 管理者機能

## ライセンス

MIT License 