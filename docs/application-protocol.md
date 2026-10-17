# Preliminary Application-Layer Protocol

## Transport and framing

The client and server communicate through a TCP connection. Each application
message is one UTF-8 JSON object followed by a newline (`\n`). TCP does not
preserve message boundaries, so the C server must buffer received bytes until a
newline is found, handle multiple messages in one read, and retain incomplete
messages for the next read. Sending uses a `send_all()` helper to handle partial
writes. The initial maximum message size is 64 KiB.

Each client request uses this envelope:

```json
{"type":"LOGIN","request_id":12,"data":{"username":"student"}}
```

Each server response uses this envelope:

```json
{"type":"RESPONSE","request_id":12,"ok":true,"data":{"session_token":"..."}}
```

Errors use `ok: false` and a stable error code, for example
`{"type":"ERROR","request_id":12,"ok":false,"error":{"code":"INVALID_CREDENTIALS","message":"Login failed"}}`.

## Initial message types

| Area | Client request | Server response/event |
| --- | --- | --- |
| Accounts | `REGISTER`, `LOGIN`, `LOGOUT` | `RESPONSE`, `AUTH_STATE` |
| Rooms | `ROOM_CREATE`, `ROOM_LIST`, `ROOM_JOIN`, `ROOM_START`, `ROOM_END` | `ROOM_LIST`, `ROOM_STATE`, `TEST_STARTED` |
| Test answers | `ANSWER_SET`, `TEST_SUBMIT` | `ANSWER_SAVED`, `RESULT` |
| Practice | `PRACTICE_START`, `ANSWER_SET`, `PRACTICE_SUBMIT` | `PRACTICE_STARTED`, `RESULT` |
| History/statistics | `HISTORY_GET`, `STATS_GET` | `HISTORY`, `STATS` |

## Important protocol rules

- The server never sends correct answers with `TEST_STARTED` or
  `PRACTICE_STARTED`.
- The server validates that a participant joined before a room started.
- A room owner can start/end only their own room; participants cannot change
  room settings.
- `ANSWER_SET` replaces the participant's previous answer for that question.
- The server rejects answer changes after submission or after the deadline.
- Early submission is final; the server immediately scores and returns `RESULT`.
- When the deadline expires, the server scores remaining participants and sends
  `RESULT` even if their GUI is idle.

## Example question delivery

```json
{"type":"TEST_STARTED","request_id":0,"data":{"room_id":41,"deadline":"2026-10-20T09:30:00Z","questions":[{"id":8,"text":"...","choices":[{"id":"A","text":"..."},{"id":"B","text":"..."}]}]}}
```

The exact field names, timestamps, message limits, and reconnect behavior remain
to be validated during implementation.
