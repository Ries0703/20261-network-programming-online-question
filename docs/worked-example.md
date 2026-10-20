# Worked Example — One Room, Two Attempts

This is illustrative design data, not a capture of a running application. It
uses the actual schema and message contracts. The corresponding fixture is
[`tests/fixtures/room-example.sql`](../tests/fixtures/room-example.sql).

## Scenario

Room 41 is a 10-question, 10-minute TCP quiz. User 7 is the owner and user 9 is a
participant. The room starts on 2026-10-20 at 09:00 UTC, Unix time 1792486800;
its deadline is 1792487400. It selects question IDs 8–17. All fixture questions
have correct choice B; that key remains server-side.

The fixture captures the room after user 7 submitted at 09:04, while user 9 is
still working. Eight of user 7's ten choices are correct.

| tests.id | mode | owner_user_id | question_count | duration_seconds | status |
| --- | --- | --- | --- | --- | --- |
| 41 | ROOM | 7 | 10 | 600 | ONGOING |

| test_members.test_id | user_id |
| --- | --- |
| 41 | 7 |
| 41 | 9 |

| attempts.id | test_id | user_id | status | correct_count |
| --- | --- | --- | --- | --- |
| 11 | 41 | 7 | SUBMITTED | 8 |
| 12 | 41 | 9 | IN_PROGRESS | null |

Selected answer rows, with the other rows omitted from this table only:

| attempt_id | test_id | question_id | choice_key |
| --- | --- | --- | --- |
| 11 | 41 | 8 | B |
| 12 | 41 | 8 | A |

User 7's submission finalizes attempt 11, not test 41 or attempt 12. Member 7 may
retrieve their own final result now. ROOM_RESULTS_GET still returns
ROOM_NOT_FINISHED. At the shared deadline, attempt 12 is finalized and the room
can become FINISHED.

## Messages and database effects

Before finalization, the authenticated connection for user 7 saves a choice:

```json
{"type":"ANSWER_SET","request_id":42,"data":{"attempt_id":11,"question_id":8,"choice_key":"B"}}
{"type":"RESPONSE","request_id":42,"ok":true,"data":{"attempt_id":11,"question_id":8,"choice_key":"B","saved":true}}
```

The server validates user 7 owns attempt 11, question 8 is selected for test 41,
choice B exists, and time remains. It inserts or replaces the answer before ACK.

At 09:04 the same connection submits:

```json
{"type":"ATTEMPT_SUBMIT","request_id":43,"data":{"attempt_id":11}}
{"type":"RESPONSE","request_id":43,"ok":true,"data":{"attempt_id":11,"test_id":41,"mode":"ROOM","status":"SUBMITTED","correct_count":8,"question_count":10,"percentage":80,"finalized_at":1792487040}}
```

The server computes 8/10 from saved answers, finalizes attempt 11, and records the
submission. A later ANSWER_SET for attempt 11 returns ATTEMPT_FINISHED; repeated
ATTEMPT_SUBMIT returns the same final result. User 9 cannot write to attempt 11.

## Verify the illustrative records

```bash
python3 tests/check_worked_example.py
```

This creates an in-memory SQLite database only, verifies foreign keys and score
queries, and checks the submitted/active distinction. It does not execute a C
request handler or demonstrate the GUI.
