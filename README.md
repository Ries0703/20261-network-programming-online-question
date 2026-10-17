# Online Multiple-Choice Testing Application

A separate course project for an online testing and practice application. The
server and application protocol are implemented in C over TCP sockets. The GUI
client is planned in Python with Tkinter. This keeps the networking work in C
while providing a practical desktop interface.

## Project status

The project environment and initial design documents are being prepared for
Checkpoint 1. The application features are not implemented yet.

## Development environment

The project has its own Docker Compose setup and does not modify the workspace's
existing C Dev Container. Start the development container from this directory:

```bash
docker compose up -d dev
docker compose exec dev bash
```

The container includes the C toolchain, SQLite and cJSON development packages,
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
| Trần Hữu Đức (`20225963`) | C TCP socket handling, message framing, multi-client connections, and test-room lifecycle/timers |
| Trần Anh Dũng (`20226031`) | Project lead; coordinate scope and architecture, maintain the protocol contract, integrate modules, and lead the final demo |
| Trần Cao Phong (`20226061`) | Account registration/login, sessions and access control, SQLite schema/persistence, and activity logging |
| Lê Diễm Hằng (`20225970`) | Tkinter GUI and client integration, practice/history/statistics screens, and end-to-end test scenarios |

See [`docs/checkpoint-1.md`](docs/checkpoint-1.md) for the presentation outline.

## Checkpoint presentation

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
