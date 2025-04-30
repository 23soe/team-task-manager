# Team Task Manager

簡易なタスク共有SaaSツール

## 🚀 Web Service
[https://team-task-manager-chgc.onrender.com](https://team-task-manager-chgc.onrender.com)

## 📌 概要

Team Task Managerは、複数の組織・担当者でタスクを共有・管理できるSaaS型Webアプリケーションです。Ruby on Rails（APIモード）と Vue.js 3 を用いて構築されており、以下のような機能を提供します。

## 🛠 使用技術

### バックエンド

- Ruby on Rails 7（APIモード）
  ruby version = "3.1.6"
  Rails version = "7.0.7"
- PostgreSQL
- JWT認証
- RSpec（ユニットテスト）
- Rakeタスク（バッチ処理）

### フロントエンド

- Vue.js 3
- Vite
- Pug（テンプレート言語）
- Axios（API通信）
- Pinia（状態管理）

## 🔐 主な機能

- ユーザー認証（サインアップ / ログイン / ログアウト）
- ワークスペース管理（ユーザーが複数組織に所属可能）
- タスク管理
  - タスク作成 / 編集 / 削除
  - 担当者アサイン（複数人可）
  - 状態（開始前・進行中・完了）切替
  - カテゴリ設定
- タスクのフィルタリング（担当者 / カテゴリ / 完了状態）
- タスク進捗率のバッチ集計（Rakeタスクで定期処理）

## 📂 ディレクトリ構成

team-task-manager/ 
├── backend/ # Rails API 
├── frontend/ # Vue 3 + Vite + Pug 
├── docs/ # 設計書（画面仕様書、モデル設計書など） 
└── README.md 

# ① 開発者向けの使用方法（ローカル環境起動手順）

## 💻 使用方法（ローカル開発環境）

### 1. リポジトリをクローン

```bash
git clone https://github.com/your-username/team-task-manager.git
cd team-task-manager
```

### 2. バックエンド（Rails API）

```bash
cd backend
bundle install
rails db:create db:migrate
rails s

※ PostgreSQLを使用しています。必要に応じて .env や seeds.rb を活用して初期データを投入してください。
```

### 3. フロントエンド（Vue.js）
```bash
cd ../frontend
npm install
npm run dev
```

# ② ユーザー向けの利用方法（UI操作ガイド）

## 👩🏻‍💻 利用方法（ユーザー視点）

1. サインアップページにて以下の情報を入力し登録：
   - 名前
   - 組織名
   - メールアドレス
   - パスワード
2. ログイン後、所属しているワークスペースが自動で選択され、タスク一覧が表示されます。
3. 「作成」ボタンを押して新しいタスクを登録。
   - タイトル、説明、期限、カテゴリ、担当者、状態などを入力。
4. 一覧画面では以下の操作が可能です：
   - タスクの編集・削除
   - 状態の変更（開始前 → 進行中 → 完了）
   - 担当者、カテゴリ、状態によるフィルター
5. タスク進捗率は、バッチ処理（Rakeタスク）により定期的に集計され、各担当者ごとに表示されます。