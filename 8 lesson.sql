--1.Определим кто больше поставил лайков (всего)- мужчины или женщины:
SELECT p.gender, COUNT(l.user_id) AS total
  FROM profiles AS p
    JOIN likes AS l
  ON p.user_id = l.user_id
  GROUP BY p.gender
  ORDER BY total DESC LIMIT 1;
  
--2.Подсчитать количество лайков, которые получили десять самых молодых пользователей:
SELECT SUM(total_likes) total FROM
  (SELECT COUNT(l.target_id) AS total_likes
    FROM profiles AS p
      LEFT JOIN likes AS l
        ON p.user_id = l.target_id AND l.target_type_id = 2
    GROUP BY p.user_id
    ORDER BY p.birthday 
    DESC LIMIT 10) as user_likes;

--3.Найти 10 пользователей, которые проявляют наименьшую активность в использовании социальной сети (наименьшее количество лайков и исходящих сообщений):
SELECT
  users.id,
  CONCAT(first_name, ' ', last_name) AS user,
  (COALESCE(likes_count, 0) + COALESCE(message_count, 0)) AS overall_activity
FROM users
LEFT JOIN (
  SELECT user_id, COUNT(*) AS likes_count
  FROM likes
  GROUP BY user_id
) likes_counts ON likes_counts.user_id = users.id
LEFT JOIN (
  SELECT from_user_id, COUNT(*) AS message_count
  FROM messages
  GROUP BY from_user_id
) message_counts ON message_counts.from_user_id = users.id
GROUP BY users.id
ORDER BY overall_activity
LIMIT 10;
