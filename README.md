# Online Multiple-Choice Testing Application

A separate course project for an online testing and practice application. The
server will implement the application protocol in C over TCP sockets. The GUI
client is planned in Python with Tkinter. This keeps the networking work in C
while providing a practical desktop interface.

## Project status

The project environment and design baseline are prepared for Checkpoint 1.
Functional flows, ERD, SQLite schema, and protocol contracts are documented.
The C application handlers and GUI features are not implemented yet.

The delivery scope includes all specified functions: both test modes, accounts
and access control, topic/difficulty filters, persistent history, graphical
statistics, activity logging, and the GUI.

## Development environment

The project has its own Docker Compose setup and does not modify the workspace's
existing C Dev Container. Start the development container from this directory:

```bash
docker compose up -d dev
docker compose exec dev bash
```

The container includes the C toolchain, SQLite, cJSON, and libsodium development packages,
and Python/Tkinter for client development and testing. The client can also run
on Windows with Python 3 and Tkinter installed; it connects to the server using
the server host and TCP port. The persistent SQLite data directory inside the
container is `/var/lib/online-testing-app` (`APP_DATA_DIR`).

## Planned components

- `server/`: C TCP server, account/session handling, room lifecycle, scoring,
  activity logging, and SQLite persistence.
- `client/`: Tkinter GUI for registration, login, room management, tests,
  practice, history, and statistics.
- `common/`: shared protocol definitions and message documentation.
- `docs/`: architecture, application protocol, and checkpoint preparation.
- `tests/`: protocol and server tests.

## Project team and task allocation

| Member | Responsibility |
| --- | --- |
| Trần Hữu Đức (`20225963`) | C sockets and stream I/O; connection threads, room/attempt state, deadlines, and scoring |
| Trần Anh Dũng (`20226031`) | Project lead; coordinate scope and architecture, maintain the protocol contract, integrate modules, and lead the final demo |
| Trần Cao Phong (`20226061`) | Account registration/login, sessions and access control, SQLite schema/persistence, and activity logging |
| Lê Diễm Hằng (`20225970`) | Python TCP client, Tkinter UI, practice/history/statistics screens, and end-to-end tests |

See [`docs/checkpoint-1.md`](docs/checkpoint-1.md) for the presentation outline.

Design references: [functional flows](docs/functional-design.md),
[ERD/data model](docs/data-model.md), [SQL schema](server/schema.sql), and
[protocol](docs/application-protocol.md). Run schema validation in the running
development container with `make schema-check` from the host, or
`python3 -m unittest discover -s tests -p test_schema.py -v` inside the container.

## Checkpoint presentation

The [full English speaking script](docs/presentation-script-en.md) is timed
for Trần Anh Dũng to present all 13 slides in approximately 15 minutes. It includes
per-slide clock checkpoints, pauses, and rehearsal adjustments.
The [Vietnamese reference script](docs/presentation-script-vi.md) is retained for
the earlier 11-slide version; the English script matches the current deck.
The [worked room example](docs/worked-example.md) connects sample messages to
real schema rows. Validate it with `python3 tests/check_worked_example.py`.

The self-contained HTML slide deck is at
[`presentation/checkpoint-1.html`](presentation/checkpoint-1.html). Start the
project's Compose service and serve the workspace folder:

```bash
docker compose up -d dev
docker compose exec -d dev python3 -m http.server 5050 --bind 0.0.0.0 --directory /workspace/online-testing-app
```

Open `http://localhost:5050/presentation/checkpoint-1.html`. Use the arrow keys
to navigate, `N` to toggle Vietnamese speaker notes, `F` for fullscreen, and
`P` to print.

## End the development container

```bash
docker compose down
```
