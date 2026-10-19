.PHONY: env-up env-shell env-down env-check schema-check

env-up:
	docker compose up -d dev

env-shell:
	docker compose exec dev bash

env-down:
	docker compose down

env-check:
	docker compose exec -T dev bash -lc 'gcc --version | head -1 && pkg-config --modversion sqlite3 libcjson libsodium && python3 --version'

schema-check:
	docker compose exec -T dev python3 -m unittest discover -s tests -p 'test_schema.py' -v
