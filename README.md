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

See [`docs/checkpoint-1.md`](docs/checkpoint-1.md) for the presentation outline.

## End the development container

```bash
docker compose down
```
