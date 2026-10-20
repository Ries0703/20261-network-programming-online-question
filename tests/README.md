# Tests

`test_schema.py` creates an in-memory SQLite database from `server/schema.sql`.
It checks foreign keys, membership/session-related uniqueness, answer ownership,
required state timestamps, and changed/unanswered answer scoring queries. Run:

```bash
python3 -m unittest discover -s tests -p test_schema.py -v
```

These checks validate the proposed data schema, not the unimplemented C services.

`python3 tests/check_worked_example.py` also validates the presentation's receive
chunks and sample room/attempt records against an isolated in-memory database.

Planned test layers:

- Unit tests for message framing and room/scoring rules.
- Socket integration tests for partial reads, multiple clients, and disconnects.
- End-to-end scenarios for practice, room lifecycle, answer changes, early
  submission, timeout scoring, and access control.
