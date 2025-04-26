# モデル設計書

![ERD Diagram](./docs/images/ERD.PNG)

## テーブル・カラム・リレーション構成

| テーブル名 | 主キー | カラム名 | データ型 | 外部キー | 説明 | リレーション | 
|:---|:---|:---|:---|:---|:---|:---|
| user | id | emai | string | なし | メールアドレス | user_organizations, task_users と関連 | 
|  |  | password | string | なし | パスワード |  | 
|  |  | username | string | なし | ユーザー名 |  | 
| organization | id | name | string | なし | 組織名 | user_organizations と関連 | 
| user_organizations | id | userId | int | user(id) | ユーザーID | users と organizations を中間テーブルで関連 | 
|  |  | organizationId | int | organization(id) | 組織ID |  | 
| task | id | title | string | なし | タスクタイトル | task_users, categories と関連 | 
|  |  | contents | string | なし | タスク内容 |  | 
|  | status | int | なし | タスクステータス（開始前/進行中/完了） |  | 
|  |  | deadline | date | なし | 締切日 |  | 
|  |  | categoryId | id | category(id) | カテゴリーID |  | 
| task_users | id | taskId | int | task(id) | タスクID | tasks と users を中間テーブルで関連 | 
|  |  | userId | int | user(id) | ユーザーID |  | 
| category | id | name | string | なし | カテゴリー名 | taskと関連 | 