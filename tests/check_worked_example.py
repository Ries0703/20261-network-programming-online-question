"""Validate the presentation's illustrative room data in an isolated database."""
from pathlib import Path
import json
import sqlite3


def main():
    chunks = ['{"type":"ACCOUNT_', 'GET","request_id":1,"data":{}}\n{"type":"LOGOUT","request_id":2,"data":{}}\n']
    messages = [json.loads(line) for line in "".join(chunks).splitlines()]
    if [(m["type"], m["request_id"]) for m in messages] != [("ACCOUNT_GET", 1), ("LOGOUT", 2)]:
        raise RuntimeError("TCP framing illustration does not reconstruct the intended messages")
    root = Path(__file__).resolve().parents[1]
    with sqlite3.connect(":memory:") as db:
        db.executescript((root / "server/schema.sql").read_text(encoding="utf-8"))
        db.executescript((root / "tests/fixtures/room-example.sql").read_text(encoding="utf-8"))
        if db.execute("PRAGMA foreign_key_check").fetchall():
            raise RuntimeError("Example violates foreign keys")
        expected = [(11, 41, 7, "SUBMITTED", 8), (12, 41, 9, "IN_PROGRESS", None)]
        actual = db.execute(
            "SELECT id,test_id,user_id,status,correct_count FROM attempts ORDER BY id"
        ).fetchall()
        if actual != expected:
            raise RuntimeError(f"Unexpected attempts: {actual}")
        score = db.execute(
            "SELECT count(*),coalesce(sum(a.choice_key=q.correct_choice_key),0) "
            "FROM test_questions tq JOIN questions q ON q.id=tq.question_id "
            "LEFT JOIN answers a ON a.test_id=tq.test_id "
            "AND a.question_id=tq.question_id AND a.attempt_id=11 WHERE tq.test_id=41"
        ).fetchone()
        if score != (10, 8):
            raise RuntimeError(f"Unexpected selected question count/score: {score}")
        if db.execute("SELECT status FROM tests WHERE id=41").fetchone()[0] != "ONGOING":
            raise RuntimeError("Early submission must leave this two-user room ongoing")
        print("Worked example verified: room 41, attempts 11/12, score 8/10, second attempt still active.")
        print("Framing illustration verified: two receive chunks reconstruct ACCOUNT_GET and LOGOUT.")


if __name__ == "__main__":
    main()
