# All-Up-Container

Docker Compose ベースのマルチサービス環境

## 主な機能

- 複数のバックエンド/フロントエンドサービスを一括管理
- 個別のサービス操作が可能
- 依存関係の自動インストール
- データベースマイグレーション

```
主要コマンドはmake helpで表示できます
```

## セットアップ

```bash
make clone
make install
- ここでenvファイルの編集
make migration
make up-d
```

