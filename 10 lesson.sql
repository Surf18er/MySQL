--1.Проанализировать какие запросы могут выполняться наиболее часто в процессе работы приложения и добавить необходимые индексы:
CREATE UNIQUE INDEX users_email_uq ON users(email);
CREATE INDEX users_name_surname_idx ON users(first_name, last_name);
CREATE INDEX profiles_birthday_idx ON profiles(birthday);
CREATE INDEX messages_from_user_id_to_user_id_idx ON messages(from_user_id, to_user_id);

--2.Построить запрос, который будет выводить следующие столбцы:
-- - имя группы
-- - среднее количество пользователей в группах
-- - самый молодой пользователь в группе
-- - самый старший пользователь в группе
-- - общее количество пользователей в группе
-- - всего пользователей в системе
-- - отношение в процентах (общее количество пользователей в группе / всего пользователей в системе) * 100
SELECT DISTINCT c.name, 
  COUNT(*) OVER() / (SELECT COUNT(*) FROM communities) AS 'average number of users',
  MAX(p.birthday) OVER w AS youngest,
  MIN(p.birthday) OVER w AS oldest,
  COUNT(*) OVER w AS 'total in group',
  (SELECT COUNT(*) FROM profiles) AS 'total',
  COUNT(*) OVER w / (SELECT COUNT(*) FROM profiles) * 100 AS "%%"
    FROM communities AS c
     JOIN communities_users AS cu
       ON c.id = cu.community_id
     JOIN profiles AS p
       ON cu.user_id = p.user_id
       WINDOW w AS (PARTITION BY cu.community_id); 
