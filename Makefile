.PHONY: env-up env-shell env-down env-check

env-up:
	docker compose up -d dev

env-shell:
	docker compose exec dev bash

env-down:
	docker compose down

env-check:
	docker compose exec -T dev bash -lc 'gcc --version | head -1 && pkg-config --modversion sqlite3 libcjson && python3 --version'
