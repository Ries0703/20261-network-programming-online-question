# Functional Design — Checkpoint 1

This document defines the planned behavior for every required feature. It is a
design baseline, not a claim that these features already run.

## Accounts, sessions, and permissions

- A user registers a unique username and password, logs in, views their account,
  changes their password, and logs out. Passwords are hashed with libsodium's
  Argon2id password hashing; plaintext passwords never enter logs or storage.
- One authenticated TCP connection is allowed per account. Login creates a
  server-side session bound to that connection. Requests use the connection's
  identity, never a client-supplied user ID. Disconnect/logout/expiry ends it.
- A session expires after eight hours. Expiry rejects further authenticated
  requests. It does not stop the server timer or discard an existing attempt.
- On server startup, previously open connection sessions are invalidated.
- All logged-in users may create rooms and practice tests. A room's creator is
  its owner; ownership is a relationship, not a permanent administrator role.
- Only an owner may start/end their room. Only members may receive its questions
  and view its completed scoreboard. Users read only their own history/statistics.

## Test Mode

1. **Create:** select title, question count (1–100), duration (60–7,200 seconds),
   topics, and difficulties. Empty filter lists mean all values. The server checks
   that enough active questions match. The owner automatically joins the room.
2. **Browse/join:** show room ID, title, owner, member count, settings, and status.
   A user may join a `NOT_STARTED` room once. Joining an ongoing/finished room is
   rejected. A participant may leave before start; the owner must stay. A room
   supports up to 50 members.
3. **Start:** owner starts the room. In one transaction the server rechecks the
   pool, selects distinct questions, fixes their order, sets a shared deadline,
   and creates one attempt per member. A user may have only one active attempt;
   if any member is busy, start fails atomically with `PARTICIPANT_BUSY`. Only
   after a successful start are questions available to participants.
4. **Answer:** only an active member's `IN_PROGRESS` attempt accepts changes.
   Saving again replaces the old choice. A null choice clears an answer. Every
   accepted change is committed before the acknowledgement is sent.
5. **Submit:** early submission finalizes that participant's attempt only and
   returns their correct-answer count. Repeating submit returns the saved result.
6. **Finish:** deadline or owner-end finalizes all remaining attempts. The room
   also finishes early when all attempts have been submitted. Finalized attempts
   are never rescored or reopened.
7. **Results:** once the room is `FINISHED`, members may view its scoreboard.
   Each user may also retrieve their own result and history. Correct answer keys
   are not exposed by the client-facing protocol.

Room states: `NOT_STARTED → ONGOING → FINISHED`.

Attempt states: `IN_PROGRESS → SUBMITTED | EXPIRED | ENDED_BY_OWNER`.

Unanswered questions count as incorrect. Each question is worth one point;
`correct_count` ranges from zero to the test's question count. A submitted user
can still receive the room-finished event and use history/account features.

## Practice Mode

The user chooses count, duration, topics, and difficulties using the same limits.
The server creates a private `PRACTICE` test, selects its questions, and starts its
single attempt immediately. Starting practice while another attempt is active
is rejected. Answer changes and scoring use the same handlers as
Test Mode. Submission or the deadline finishes the attempt and private test.
Practice tests do not appear in the public room list.

## Question bank and customization

- Each question has one topic, one difficulty (`EASY`, `MEDIUM`, or `HARD`), four
  choices (`A`–`D`), and exactly one correct choice.
- The initial bank is prepared/imported offline as project data. GUI question
  authoring and an import/export feature are not part of the required application.
- Selection uses all selected topics and difficulties as allowed sets; duplicate
  questions are forbidden. The same room delivers the same questions/order to all.
- Question text, choices, topic, difficulty, and correct key become immutable once
  used by a test. A corrected question is a new bank record. This preserves history.
- Creating/starting a test with too few matching questions returns
  `INSUFFICIENT_QUESTIONS`; the server does not silently relax the filters.

## History and graphical statistics

History lists finalized test/practice attempts with mode, title, date, question
count, correct count, percentage, and completion reason. The GUI supports a
date/mode filter and a detail view of the user's saved selected choices.

Statistics use finalized attempts only. The GUI shows an attempt-by-attempt
percentage chart and accuracy by topic/difficulty. Overall accuracy is
`sum(correct_count) / sum(question_count) × 100`, not an unweighted mean of raw
scores. Unanswered selected questions remain in the denominator. An empty
history produces an empty chart and zero completed attempts, not a fake score.

## GUI screens

1. Connection/login/registration.
2. Home with room list and practice setup.
3. Create-room form and waiting room (owner controls are shown only to the owner).
4. Test/practice screen with question navigation, selected choices, countdown,
   save state, and submit confirmation.
5. Personal result and completed-room scoreboard.
6. History/statistics and account/password settings.

Network reads run off the Tkinter UI thread. A queue and `after()` callbacks
update widgets. The displayed timer is based on server time/deadline; only the
server decides whether a submission is on time.

## Concurrency, deadlines, and failures

- One pthread serves each connection; a scheduler checks active deadlines.
- A service mutex serializes shared room state and SQLite write transactions.
  A per-connection send mutex prevents responses and events interleaving bytes.
  No socket write occurs while the service mutex is held.
- Events are delivered only if the destination connection still has a valid
  session for the intended user. Logout/account changes must not send the old
  user's result to a newly authenticated user on the same connection. Saved
  results remain available through an authorized later login.
- Each answer/submit validates server time inside the transaction. At
  `now >= deadline`, the attempt is finalized before the request is rejected;
  scheduler delay cannot extend a test.
- Disconnect does not pause a room or remove saved answers. The attempt remains
  active until the normal finish rule. A fresh login can fetch the active attempt
  through `ATTEMPT_CURRENT`; this uses ordinary login and state retrieval.
- Deadline, owner-end, and submission share one finalization path. Transactions
  guarantee a result is finalized only once.
- Startup marks overdue active attempts expired before serving results. An
  unfinished room whose deadline is still in the future continues with its
  persisted questions, answers, and deadline.
- Activity records include register/login/logout, room changes, submissions,
  and finalization. Logs store IDs/action/time/outcome, never passwords or keys.

## Requirement coverage

| Required feature | Design | Persistent data | Main protocol messages |
| --- | --- | --- | --- |
| Accounts and sessions | Connection-bound identity | users, sessions | REGISTER, LOGIN, LOGOUT, ACCOUNT_GET, PASSWORD_CHANGE |
| Room create/list/join | Waiting-room membership | tests, test_members, test_topics, test_difficulties | ROOM_CREATE, ROOM_LIST, ROOM_JOIN, ROOM_LEAVE |
| Start/end and delivery | Owner permission, fixed question set | tests, test_questions, attempts | ROOM_START, ROOM_END, TEST_STARTED, TEST_FINISHED |
| Revise/submit/timeout/score | Shared attempt finalization | attempts, answers | ANSWER_SET, ATTEMPT_SUBMIT, ATTEMPT_FINISHED |
| Practice | Private single-user test | same test/attempt tables | PRACTICE_START |
| Completed room results | Members-only scoreboard | finalized attempts | ROOM_RESULTS_GET, ATTEMPT_RESULT_GET |
| Topic/difficulty | Filtered question selection | topics, questions, question_choices | QUESTION_FILTERS_GET and setup filters |
| History and charts | Finalized attempts and grouped accuracy | tests, attempts, answers, test_questions | HISTORY_GET, STATS_GET |
| Logging/access control/GUI | Service checks and GUI states | sessions, test_members, activity_log | Authentication and authorization on every handler |
