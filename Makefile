# プロジェクト名
PROJECT_NAME := granappvantan

# Docker Composeコマンド
DC := docker-compose -p $(PROJECT_NAME)

# 各サービスの定義
SERVICES := roulette vanx slot poker
BACKEND_SERVICES := $(addsuffix -backend, $(SERVICES))
FRONTEND_SERVICES := $(addsuffix -frontend, $(SERVICES))

# デフォルトターゲット
.PHONY: help
help: ## ヘルプを表示
	@echo "\033[1;34m=== 基本コマンド ===\033[0m"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {if ($$1 !~ /-/ && $$1 != "help") printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'
	
	@echo "\n\033[1;34m=== データベースコマンド ===\033[0m"
	@echo "  \033[36mmigration\033[0m           全バックエンドのマイグレーションを実行"
	@echo "  \033[36m<サービス名>-migration\033[0m 特定サービスのマイグレーションを実行"
	
	@echo "\n\033[1;34m=== 個別サービスコマンド ===\033[0m"
	@echo "  使用例: make <サービス名>-<コマンド名>"
	@echo "  サービス名: vanx, roulette, slot, poker"
	@echo "  コマンド: up, down, install, logs, migration, bash-be, bash-fe"
	
	@echo "\n詳細なヘルプは各コマンドに 'make help' を付けて実行してください"

# 全サービスの起動
.PHONY: up
up: ## 全サービスを起動
	@echo "Starting all services..."
	@$(DC) up

# 全サービスの起動
.PHONY: up-d
up-d: ## 全サービスを起動
	@echo "Starting all services..."
	@$(DC) up -d

# 全サービスの停止
.PHONY: down
down: ## 全サービスを停止
	@echo "Stopping all services..."
	@$(DC) down

.PHONY: build
build: ## 全サービスを再ビルド
	@echo "Building all services..."
	@$(DC) build

# 全サービスの再ビルド
.PHONY: rebuild
rebuild: ## 全サービスを再ビルド
	@echo "Rebuilding all services..."
	@$(DC) up -d --build

# 全バックエンドでcomposer installを実行
.PHONY: backend-install
backend-install: ## 全バックエンドでcomposer installを実行
	@for service in $(BACKEND_SERVICES); do \
		echo "Running composer install in $$service..."; \
		$(DC) run $$service composer install; \
	done

# 全フロントエンドでnpm installを実行
.PHONY: frontend-install
frontend-install: ## 全フロントエンドでnpm installを実行
	@for service in $(FRONTEND_SERVICES); do \
		echo "Running npm install in $$service..."; \
		$(DC) run $$service npm install; \
	done

# 全依存関係のインストール
.PHONY: install
install: backend-install frontend-install ## 全依存関係をインストール


.PHONY: migration
migration: ## 全backendのマイグレーション
	@echo "Running fresh migrations for all services..."
	@echo "vanx-backend:"
	@$(DC) run --rm vanx-backend bash -c "echo 'yes' | php artisan migrate:fresh --force"
	@echo "roulette-backend:"
	@$(DC) run --rm roulette-backend bash -c "echo 'yes' | php artisan migrate:fresh --force"
	@echo "slot-backend:"
	@$(DC) run --rm slot-backend bash -c "echo 'yes' | php artisan migrate:fresh --force"
	@echo "poker-backend:"
	@$(DC) run --rm poker-backend bash -c "echo 'yes' | php artisan migrate:fresh --force"

# 全サービスのログを表示
.PHONY: logs
logs: ## 全サービスのログを表示
	@$(DC) logs -f

# 特定のサービスのログを表示
# 使用例: make logs-service SERVICE=roulette-frontend
.PHONY: logs-service
logs-service: ## 特定のサービスのログを表示
	@$(DC) logs -f $(SERVICE)

# 実行中のコンテナを一覧表示
.PHONY: ps
ps: ## 実行中のコンテナを一覧表示
	@$(DC) ps

# 全コンテナを停止
.PHONY: stop
stop: ## 全コンテナを停止
	@echo "Stopping all containers..."
	@$(DC) stop

# 全コンテナとボリュームを削除
.PHONY: clean
clean: ## 全コンテナとボリュームを削除
	@echo "Removing all containers and volumes..."
	@$(DC) down -v

# 使用されていないDockerリソースを削除
.PHONY: prune
prune: ## 使用されていないDockerリソースを削除
	@echo "Pruning Docker resources..."
	@docker system prune -f

.PHONY: clone
clone: ## 全サービスをリポジトリからクローンして
	@echo "Cloning all services..."
	@git clone https://github.com/Gran-App-Vantan/vanx-backend.git ./Vanx/backend
	@git clone https://github.com/Gran-App-Vantan/vanx-frontend.git ./Vanx/frontend
	@git clone https://github.com/Gran-App-Vantan/Indian-Poker.git ./Poker
	@git clone https://github.com/Gran-App-Vantan/Roulette.git ./Roulette
	@git clone https://github.com/Gran-App-Vantan/Slot.git ./Slot
	@echo "Copying .env.example to .env for each service..."
	# Laravelアプリ用
	@for dir in \
		Roulette/backend/laravel_app; do \
		mkdir -p "$$dir" && \
		if [ ! -f "$$dir/.env" ]; then \
			if [ -f "$$dir/.env.example" ]; then \
				cp "$$dir/.env.example" "$$dir/.env" && \
				echo "Created $$dir/.env from example"; \
			else \
				touch "$$dir/.env" && \
				echo "Created empty $$dir/.env"; \
			fi; \
		fi; \
	done
	# サービスルートディレクトリ用
	@for dir in \
		Roulette; do \
		mkdir -p "$$dir" && \
		if [ ! -f "$$dir/.env" ]; then \
			if [ -f "$$dir/.env.example" ]; then \
				cp "$$dir/.env.example" "$$dir/.env" && \
				echo "Created $$dir/.env from example"; \
			else \
				touch "$$dir/.env" && \
				echo "Created empty $$dir/.env"; \
			fi; \
		fi; \
	done
	# フロントエンド用（ルーレットのみ）
	@dir="Roulette/frontend" && \
	mkdir -p "$$dir" && \
	if [ ! -f "$$dir/.env" ]; then \
		if [ -f "$$dir/.env.example" ]; then \
			cp "$$dir/.env.example" "$$dir/.env" && \
			echo "Created $$dir/.env from example"; \
		else \
			touch "$$dir/.env" && \
			echo "Created empty $$dir/.env"; \
		fi; \
	fi
	@echo "Complete!"

.PHONY: env
env: ## .envファイルを各Laravelアプリにコピー
	@for dir in \
		Vanx/backend/laravel_app \
		Poker/backend/laravel_poker \
		Roulette/backend/laravel_app \
		Slot/backend/slot_app; do \
		if [ ! -f "$$dir/.env" ]; then \
			if [ -f "$$dir/.env.example" ]; then \
				cp "$$dir/.env.example" "$$dir/.env" && \
				echo "Created $$dir/.env from example"; \
			else \
				mkdir -p "$$dir" && \
				touch "$$dir/.env" && \
				echo "Created empty $$dir/.env"; \
			fi; \
		fi; \
	done
	@echo "Complete!"


.PHONY: delete
delete: ## 一旦デリート
	@rm -rf ./Vanx ./Poker ./Roulette ./Slot
	@echo "Complete!"


# 全ゲームリポジトリをプル
.PHONY: pull
pull: ## 全ゲームリポジトリを更新
	@for game in $(SERVICES); do \
		if [ -d "./$$game" ]; then \
			echo "Pulling $$game..."; \
			cd ./$$game && git pull && cd ..; \
		else \
			echo "Warning: $$game ディレクトリが見つかりません"; \
		fi \
	done

# 各ゲームごとの個別コマンド
define SERVICE_TEMPLATE
# $(1)サービス用のコマンド
.PHONY: $(1)-up
$(1)-up: ## $(1)サービスを起動
	@echo "Starting $(1) services..."
	@$(DC) up -d $(1)-backend $(1)-frontend $(1)-db

.PHONY: $(1)-down
$(1)-down: ## $(1)サービスを停止
	@echo "Stopping $(1) services..."
	@$(DC) stop $(1)-backend $(1)-frontend $(1)-db

.PHONY: $(1)-backend-install
$(1)-backend-install: ## $(1)のバックエンドでcomposer installを実行
	@echo "Running composer install in $(1)-backend..."
	@$(DC) run $(1)-backend composer install

.PHONY: $(1)-frontend-install
$(1)-frontend-install: ## $(1)のフロントエンドでnpm installを実行
	@echo "Running npm install in $(1)-frontend..."
	@$(DC) run $(1)-frontend npm install

.PHONY: $(1)-install
$(1)-install: $(1)-backend-install $(1)-frontend-install ## $(1)の依存関係をインストール

.PHONY: $(1)-logs
$(1)-logs: ## $(1)のログを表示
	@$(DC) logs -f $(1)-backend $(1)-frontend

.PHONY: $(1)-migration
$(1)-migration: ## $(1)のマイグレーションを実行
	@$(DC) run $(1)-backend bash -c "php artisan migrate:fresh --force"

.PHONY: $(1)-bash-be
$(1)-bash-be: ## $(1)のバックエンドコンテナに接続
	@$(DC) run $(1)-backend bash

.PHONY: $(1)-bash-fe
$(1)-bash-fe: ## $(1)のフロントエンドコンテナに接続
	@$(DC) run $(1)-frontend bash


.PHONY: $(1)-pull
$(1)-pull: ## $(1)のリポジトリを更新
	@if [ -d "./$(shell echo $(1) | tr '[:upper:]' '[:lower:]')" ]; then \
		echo "Pulling $(1)..."; \
		cd ./$(shell echo $(1) | tr '[:upper:]' '[:lower:]') && git pull; \
	else \
		echo "Error: $(1) ディレクトリが見つかりません"; \
		exit 1; \
	fi

endef

# 各サービスに対してテンプレートを展開
$(foreach service,$(SERVICES),$(eval $(call SERVICE_TEMPLATE,$(service))))
```](cascade:incomplete-link)