-- 1 задание


SELECT DISTINCT
	concat(sender_name.firstname, ' ', sender_name.lastname) AS sender_name,
	concat(recipient_name.firstname, ' ', recipient_name.lastname) AS recipient_name,
	messages.from_user_id AS sender_id,
	messages.to_user_id AS recipient_id,
	friend_requests.status,
	messages.body
-- 	count(*) AS number_of_posts
FROM messages
JOIN friend_requests ON friend_requests.initiator_user_id = messages.to_user_id
	OR friend_requests.target_user_id = messages.from_user_id
JOIN users AS sender_name ON sender_name.id = messages.from_user_id
JOIN users AS recipient_name ON recipient_name.id = messages.to_user_id
WHERE (messages.to_user_id = 1 OR messages.from_user_id = 1) AND friend_requests.status = 'approved'
ORDER BY sender_id ASC, recipient_id DESC
;


-- 2 задание



ALTER TABLE vk_less_6.profiles ADD age varchar(100) NOT NULL;
UPDATE profiles
SET age = TIMESTAMPDIFF(YEAR, birthday, NOW());

SELECT
-- 	u.firstname,
-- 	u.lastname,
-- 	p.age,
-- 	p.user_id,
-- 	l.media_id,
	count(*) AS count_likes_children_less_than_ten_years
FROM users AS u
LEFT JOIN profiles AS p ON p.user_id = u.id
LEFT JOIN likes AS l ON l.user_id = u.id
WHERE p.age < 10 AND l.media_id IS NOT NULL
-- WHERE TIMESTAMPDIFF(YEAR, birthday, NOW()) < 10 AND l.media_id IS NOT NULL -- Можно не добавлять колонку age, а записать так
ORDER BY p.age
;


-- 3 задание

SELECT
	case (p.gender)
		when 'm' then 'male'
		when 'f' then 'female'
		else 'it'
	end as gender,
	count(p.gender) AS number_of_likes
FROM users AS u
LEFT JOIN profiles AS p ON p.user_id = u.id
LEFT JOIN likes AS l ON l.user_id = u.id
WHERE l.media_id IS NOT NULL AND p.gender = 'm'
UNION
SELECT
	case (p.gender)
		when 'm' then 'male'
		when 'f' then 'female'
		else 'it'
	end as gender,
	count(p.gender) AS counter_likes
FROM users AS u
LEFT JOIN profiles AS p ON p.user_id = u.id
LEFT JOIN likes AS l ON l.user_id = u.id
WHERE l.media_id IS NOT NULL AND p.gender = 'f'
;
