PRAGMA foreign_keys = ON;

CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    username TEXT NOT NULL COLLATE NOCASE UNIQUE,
    password_hash TEXT NOT NULL,
    created_at INTEGER NOT NULL,
    CHECK (length(username) BETWEEN 3 AND 32)
);

CREATE TABLE sessions (
    id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id),
    created_at INTEGER NOT NULL,
    expires_at INTEGER NOT NULL,
    ended_at INTEGER,
    end_reason TEXT CHECK (end_reason IN ('LOGOUT','DISCONNECT','EXPIRED','SERVER_RESTART')),
    CHECK (expires_at > created_at),
    CHECK ((ended_at IS NULL AND end_reason IS NULL) OR
           (ended_at IS NOT NULL AND ended_at >= created_at AND end_reason IS NOT NULL))
);
CREATE UNIQUE INDEX one_open_session_per_user ON sessions(user_id) WHERE ended_at IS NULL;

CREATE TABLE topics (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL COLLATE NOCASE UNIQUE
);

CREATE TABLE questions (
    id INTEGER PRIMARY KEY,
    topic_id INTEGER NOT NULL REFERENCES topics(id),
    difficulty TEXT NOT NULL CHECK (difficulty IN ('EASY','MEDIUM','HARD')),
    prompt TEXT NOT NULL,
    correct_choice_key TEXT NOT NULL CHECK (correct_choice_key IN ('A','B','C','D')),
    active INTEGER NOT NULL DEFAULT 1 CHECK (active IN (0,1)),
    FOREIGN KEY (id, correct_choice_key)
        REFERENCES question_choices(question_id, choice_key)
        DEFERRABLE INITIALLY DEFERRED
);

CREATE TABLE question_choices (
    question_id INTEGER NOT NULL REFERENCES questions(id),
    choice_key TEXT NOT NULL CHECK (choice_key IN ('A','B','C','D')),
    text TEXT NOT NULL,
    PRIMARY KEY (question_id, choice_key)
);

CREATE TABLE tests (
    id INTEGER PRIMARY KEY,
    mode TEXT NOT NULL CHECK (mode IN ('ROOM','PRACTICE')),
    owner_user_id INTEGER NOT NULL REFERENCES users(id),
    title TEXT NOT NULL,
    question_count INTEGER NOT NULL CHECK (question_count BETWEEN 1 AND 100),
    duration_seconds INTEGER NOT NULL CHECK (duration_seconds BETWEEN 60 AND 7200),
    status TEXT NOT NULL CHECK (status IN ('NOT_STARTED','ONGOING','FINISHED')),
    created_at INTEGER NOT NULL,
    started_at INTEGER,
    deadline_at INTEGER,
    finished_at INTEGER,
    end_reason TEXT CHECK (end_reason IN ('TIMEOUT','OWNER_END','ALL_SUBMITTED')),
    CHECK ((status = 'NOT_STARTED' AND started_at IS NULL AND deadline_at IS NULL
                AND finished_at IS NULL AND end_reason IS NULL)
        OR (status = 'ONGOING' AND started_at IS NOT NULL AND deadline_at IS NOT NULL AND deadline_at > started_at
                AND finished_at IS NULL AND end_reason IS NULL)
        OR (status = 'FINISHED' AND started_at IS NOT NULL AND deadline_at IS NOT NULL AND deadline_at > started_at
                AND finished_at IS NOT NULL AND finished_at >= started_at AND end_reason IS NOT NULL))
);

CREATE TABLE test_topics (
    test_id INTEGER NOT NULL REFERENCES tests(id),
    topic_id INTEGER NOT NULL REFERENCES topics(id),
    PRIMARY KEY (test_id, topic_id)
);
CREATE TABLE test_difficulties (
    test_id INTEGER NOT NULL REFERENCES tests(id),
    difficulty TEXT NOT NULL CHECK (difficulty IN ('EASY','MEDIUM','HARD')),
    PRIMARY KEY (test_id, difficulty)
);
CREATE TABLE test_members (
    test_id INTEGER NOT NULL REFERENCES tests(id),
    user_id INTEGER NOT NULL REFERENCES users(id),
    joined_at INTEGER NOT NULL,
    PRIMARY KEY (test_id, user_id)
);
CREATE TABLE test_questions (
    test_id INTEGER NOT NULL REFERENCES tests(id),
    question_id INTEGER NOT NULL REFERENCES questions(id),
    ordinal INTEGER NOT NULL CHECK (ordinal > 0),
    PRIMARY KEY (test_id, question_id),
    UNIQUE (test_id, ordinal)
);
CREATE TABLE attempts (
    id INTEGER PRIMARY KEY,
    test_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('IN_PROGRESS','SUBMITTED','EXPIRED','ENDED_BY_OWNER')),
    started_at INTEGER NOT NULL,
    finalized_at INTEGER,
    correct_count INTEGER CHECK (correct_count >= 0),
    UNIQUE (test_id, user_id),
    UNIQUE (id, test_id),
    FOREIGN KEY (test_id, user_id) REFERENCES test_members(test_id, user_id),
    CHECK ((status = 'IN_PROGRESS' AND finalized_at IS NULL AND correct_count IS NULL)
        OR (status <> 'IN_PROGRESS' AND finalized_at IS NOT NULL AND finalized_at >= started_at AND correct_count IS NOT NULL))
);
CREATE UNIQUE INDEX one_active_attempt_per_user ON attempts(user_id) WHERE status = 'IN_PROGRESS';
CREATE TABLE answers (
    attempt_id INTEGER NOT NULL,
    test_id INTEGER NOT NULL,
    question_id INTEGER NOT NULL,
    choice_key TEXT NOT NULL,
    updated_at INTEGER NOT NULL,
    PRIMARY KEY (attempt_id, question_id),
    FOREIGN KEY (attempt_id, test_id) REFERENCES attempts(id, test_id),
    FOREIGN KEY (test_id, question_id) REFERENCES test_questions(test_id, question_id),
    FOREIGN KEY (question_id, choice_key) REFERENCES question_choices(question_id, choice_key)
);
CREATE TABLE activity_log (
    id INTEGER PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    test_id INTEGER REFERENCES tests(id),
    action TEXT NOT NULL,
    outcome TEXT NOT NULL CHECK (outcome IN ('SUCCESS','REJECTED','ERROR')),
    created_at INTEGER NOT NULL
);

CREATE INDEX question_selection ON questions(active, topic_id, difficulty);
CREATE INDEX room_listing ON tests(mode, status, created_at);
CREATE INDEX user_attempt_history ON attempts(user_id, finalized_at);
CREATE INDEX test_attempt_status ON attempts(test_id, status);
CREATE INDEX activity_by_user_time ON activity_log(user_id, created_at);
