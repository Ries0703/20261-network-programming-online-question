"""Check the proposed SQLite schema independently of the future C server."""

from pathlib import Path
import sqlite3
import unittest


class SchemaChecks(unittest.TestCase):
    def setUp(self):
        self.db = sqlite3.connect(":memory:")
        schema = Path(__file__).resolve().parents[1] / "server" / "schema.sql"
        self.db.executescript(schema.read_text(encoding="utf-8"))
        with self.db:
            self.db.executemany(
                "INSERT INTO users VALUES (?, ?, ?, ?)",
                [(1, "owner", "hash", 900), (2, "member", "hash", 900),
                 (3, "practice", "hash", 900)],
            )
            self.db.execute("INSERT INTO topics VALUES (1, 'TCP')")
            for question_id in (1, 2):
                self.db.execute(
                    "INSERT INTO questions VALUES (?,1,'EASY',?,'B',1)",
                    (question_id, f"Question {question_id}"),
                )
                self.db.executemany(
                    "INSERT INTO question_choices VALUES (?,?,?)",
                    [(question_id, key, f"Choice {key}") for key in "ABCD"],
                )
            self.db.executemany(
                "INSERT INTO tests (id,mode,owner_user_id,title,question_count,"
                "duration_seconds,status,created_at,started_at,deadline_at) "
                "VALUES (?,?,?,?,1,60,'ONGOING',900,1000,1060)",
                [(1, "ROOM", 1, "Room"), (2, "PRACTICE", 3, "Practice")],
            )
            self.db.executemany("INSERT INTO test_members VALUES (?,?,950)",
                                [(1, 1), (1, 2), (2, 3)])
            self.db.executemany("INSERT INTO test_questions VALUES (?,?,1)",
                                [(1, 1), (2, 2)])
            self.db.executemany(
                "INSERT INTO attempts (id,test_id,user_id,status,started_at) "
                "VALUES (?,?,?,'IN_PROGRESS',1000)",
                [(11, 1, 1), (12, 1, 2), (13, 2, 3)],
            )

    def tearDown(self):
        self.db.close()

    def test_schema_has_valid_foreign_keys(self):
        self.assertEqual(self.db.execute("PRAGMA foreign_key_check").fetchall(), [])

    def test_username_is_case_insensitive(self):
        with self.assertRaises(sqlite3.IntegrityError):
            self.db.execute("INSERT INTO users VALUES (4,'OWNER','hash',900)")

    def test_membership_is_unique(self):
        with self.assertRaises(sqlite3.IntegrityError):
            self.db.execute("INSERT INTO test_members VALUES (1,2,951)")

    def test_only_one_open_session_per_user(self):
        self.db.execute(
            "INSERT INTO sessions (user_id,created_at,expires_at) VALUES (1,1000,2000)"
        )
        with self.assertRaises(sqlite3.IntegrityError):
            self.db.execute(
                "INSERT INTO sessions (user_id,created_at,expires_at) VALUES (1,1010,2010)"
            )
        self.db.execute("UPDATE sessions SET ended_at=1010,end_reason='LOGOUT' WHERE user_id=1")
        self.db.execute(
            "INSERT INTO sessions (user_id,created_at,expires_at) VALUES (1,1011,2011)"
        )

    def test_answer_must_belong_to_attempt_test(self):
        with self.assertRaises(sqlite3.IntegrityError):
            self.db.execute("INSERT INTO answers VALUES (11,1,2,'B',1010)")

    def test_answer_cannot_claim_another_test(self):
        with self.assertRaises(sqlite3.IntegrityError):
            self.db.execute("INSERT INTO answers VALUES (11,2,2,'B',1010)")

    def test_choice_must_exist(self):
        with self.assertRaises(sqlite3.IntegrityError):
            self.db.execute("INSERT INTO answers VALUES (11,1,1,'Z',1010)")

    def test_only_one_active_attempt_per_user(self):
        self.db.execute("INSERT INTO test_members VALUES (2,1,1010)")
        with self.assertRaises(sqlite3.IntegrityError):
            self.db.execute(
                "INSERT INTO attempts (id,test_id,user_id,status,started_at) "
                "VALUES (14,2,1,'IN_PROGRESS',1010)"
            )

    def test_active_test_requires_deadline(self):
        with self.assertRaises(sqlite3.IntegrityError):
            self.db.execute("UPDATE tests SET deadline_at=NULL WHERE id=1")

    def test_finalized_attempt_requires_timestamp_and_score(self):
        with self.assertRaises(sqlite3.IntegrityError):
            self.db.execute("UPDATE attempts SET status='SUBMITTED' WHERE id=11")

    def test_correct_key_references_existing_choice(self):
        self.db.execute("INSERT INTO questions VALUES (99,1,'EASY','Bad','A',1)")
        with self.assertRaises(sqlite3.IntegrityError):
            self.db.commit()
        self.db.rollback()

    def test_score_includes_unanswered_and_changed_answers(self):
        query = (
            "SELECT count(*), coalesce(sum(a.choice_key=q.correct_choice_key),0) "
            "FROM test_questions tq JOIN questions q ON q.id=tq.question_id "
            "LEFT JOIN answers a ON a.test_id=tq.test_id "
            "AND a.question_id=tq.question_id AND a.attempt_id=11 "
            "WHERE tq.test_id=1"
        )
        self.assertEqual(self.db.execute(query).fetchone(), (1, 0))
        self.db.execute("INSERT INTO answers VALUES (11,1,1,'B',1010)")
        self.assertEqual(self.db.execute(query).fetchone(), (1, 1))
        self.db.execute("UPDATE answers SET choice_key='C' WHERE attempt_id=11")
        self.assertEqual(self.db.execute(query).fetchone(), (1, 0))
        self.db.execute("DELETE FROM answers WHERE attempt_id=11")
        self.assertEqual(self.db.execute(query).fetchone(), (1, 0))


if __name__ == "__main__":
    unittest.main()
