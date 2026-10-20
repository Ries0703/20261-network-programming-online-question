-- Illustrative records only. Load after schema.sql into an empty test database.
BEGIN;
INSERT INTO users (id,username,password_hash,created_at) VALUES
    (7,'sample_owner','illustrative-hash-not-a-login-credential',1792486700),
    (9,'sample_member','illustrative-hash-not-a-login-credential',1792486700);
INSERT INTO topics (id,name) VALUES (1,'TCP');
WITH RECURSIVE ids(id) AS (
    SELECT 8 UNION ALL SELECT id+1 FROM ids WHERE id < 17
)
INSERT INTO questions (id,topic_id,difficulty,prompt,correct_choice_key)
SELECT id,1,'EASY','Sample question ' || id,'B' FROM ids;
INSERT INTO question_choices (question_id,choice_key,text)
SELECT q.id,k.choice_key,'Sample option ' || k.choice_key
FROM questions q CROSS JOIN (
    SELECT 'A' AS choice_key UNION ALL SELECT 'B' UNION ALL SELECT 'C' UNION ALL SELECT 'D'
) k;
INSERT INTO tests (id,mode,owner_user_id,title,question_count,duration_seconds,
                   status,created_at,started_at,deadline_at)
VALUES (41,'ROOM',7,'TCP quiz',10,600,'ONGOING',1792486740,1792486800,1792487400);
INSERT INTO test_members (test_id,user_id,joined_at) VALUES
    (41,7,1792486740),(41,9,1792486770);
INSERT INTO test_questions (test_id,question_id,ordinal)
SELECT 41,id,id-7 FROM questions;
INSERT INTO attempts (id,test_id,user_id,status,started_at,finalized_at,correct_count)
VALUES (11,41,7,'SUBMITTED',1792486800,1792487040,8),
       (12,41,9,'IN_PROGRESS',1792486800,NULL,NULL);
INSERT INTO answers (attempt_id,test_id,question_id,choice_key,updated_at)
SELECT 11,41,id,CASE WHEN id <= 15 THEN 'B' ELSE 'A' END,1792486860 FROM questions;
INSERT INTO answers (attempt_id,test_id,question_id,choice_key,updated_at)
VALUES (12,41,8,'A',1792487100);
INSERT INTO activity_log (user_id,test_id,action,outcome,created_at)
VALUES (7,41,'ATTEMPT_SUBMIT','SUCCESS',1792487040);
COMMIT;
