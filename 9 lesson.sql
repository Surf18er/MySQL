--Администрирование MySQL

--1.Создайте двух пользователей которые имеют доступ к базе данных shop. 
--Первому пользователю shop_read должны быть доступны только запросы на чтение данных, второму пользователю shop — любые операции в пределах базы данных shop:
CREATE USER 'shop_read'@'%' IDENTIFIED WITH sha256_password BY 'Test@123';
GRANT SELECT ON shop.* TO shop_read;

CREATE USER 'shop'@'%' IDENTIFIED WITH sha256_password BY 'Test@1234';
GRANT ALL ON shop.* TO shop;


--2.Пусть имеется таблица accounts содержащая три столбца id, name, password, содержащие первичный ключ, имя пользователя и его пароль. 
--Создайте представление username таблицы accounts, предоставляющий доступ к столбцам id и name. 
--Создайте пользователя user_read, который бы не имел доступа к таблице accounts, однако, мог бы извлекать записи из представления username:
CREATE TABLE accounts (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Имя пользователя',
  password VARCHAR(255) COMMENT 'Пароль пользователя',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Аккаунты';

INSERT INTO accounts
  (name, password)
VALUES
  ('test1', 'Test@123'),
  ('test2', 'Test@1234'),
  ('test3', 'Test@12345');

CREATE VIEW username (id, name) AS SELECT id, name FROM accounts;

CREATE USER 'user_read'@'%' IDENTIFIED WITH sha256_password BY 'Test@123456';
GRANT SELECT ON shop.username TO user_read;







--Хранимые процедуры и функции, триггеры

--1.Создайте хранимую функцию hello(), которая будет возвращать приветствие, в зависимости от текущего времени суток. 
--С 6:00 до 12:00 функция должна возвращать фразу "Доброе утро", с 12:00 до 18:00 функция должна возвращать фразу "Добрый день", с 18:00 до 00:00 — "Добрый вечер", с 00:00 до 6:00 — "Доброй ночи":
DELIMITER //

DROP PROCEDURE IF EXISTS hello//

CREATE PROCEDURE hello()
BEGIN
  CASE 
    WHEN CURRENT_TIME() BETWEEN '06:00:00' AND '12:00:00' THEN
	  SELECT 'Доброе утро';
	WHEN CURRENT_TIME() BETWEEN '12:00:00' AND '18:00:00' THEN
	  SELECT 'Добрый день';
	WHEN CURRENT_TIME() BETWEEN '18:00:00' AND '00:00:00' THEN
	  SELECT 'Добрый вечер';
	ELSE
	  SELECT 'Доброй ночи';
  END CASE;
END //

CALL hello()//

DELIMITER ;


--2.В таблице products есть два текстовых поля: name с названием товара и description с его описанием. Допустимо присутствие обоих полей или одно из них. 
--Ситуация, когда оба поля принимают неопределенное значение NULL неприемлема. 
--Используя триггеры, добейтесь того, чтобы одно из этих полей или оба поля были заполнены. При попытке присвоить полям NULL-значение необходимо отменить операцию:
DELIMITER //

DROP TRIGGER IF EXISTS check_null_insert//

CREATE TRIGGER check_null_insert BEFORE INSERT ON products
FOR EACH ROW
BEGIN
	IF NEW.name IS NULL AND NEW.description IS NULL THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Both name and description can not be NULL';
	END IF;
END //

DROP TRIGGER IF EXISTS check_null_update//

CREATE TRIGGER check_null_update BEFORE UPDATE ON products
FOR EACH ROW
BEGIN
	IF NEW.name IS NULL AND NEW.description IS NULL THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Both name and description can not be NULL';
	END IF;
END //

DELIMITER ;





--Транзакции, переменные, представления

--1.В базе данных shop и sample присутствуют одни и те же таблицы, учебной базы данных. Переместите запись id = 1 из таблицы shop.users в таблицу sample.users. Используйте транзакции:
CREATE DATABASE sample;

#exit
#mysqldump shop > sample.sql
#mysql sample < sample.sql
#mysql
#mysql -Nse 'SHOW TABLES' sample | WHILE READ TABLE; do mysql -e "TRUNCATE TABLE $table" sample; done

START TRANSACTION;
INSERT INTO sample.users SELECT * FROM shop.users WHERE id = 1;
DELETE FROM shop.users WHERE id = 1;
COMMIT;


--2.Создайте представление, которое выводит название name товарной позиции из таблицы products и соответствующее название каталога name из таблицы catalogs:
USE shop;
CREATE VIEW product_names (name, product_type) AS
  SELECT 
    p.name, 
    c.name 
  FROM products AS p JOIN catalogs as c
  ON c.id = p.catalog_id;
  

--3.Пусть имеется таблица с календарным полем created_at. В ней размещены разряженые календарные записи за август 2018 года '2018-08-01', '2018-08-04', '2018-08-16' и '2018-08-17'. 
--Составьте запрос, который выводит полный список дат за август, выставляя в соседнем поле значение 1, если дата присутствует в исходном таблице и 0, если она отсутствует:
USE shop;
DROP TABLE IF EXISTS testtb;
CREATE TABLE testtb (
	created_at DATE
);

INSERT INTO testtb VALUES
	('2018-08-01'),
	('2018-08-04'),
	('2018-08-16'),
	('2018-08-17');

SELECT 
	time_period.selected_date AS date,
	(SELECT EXISTS(SELECT * FROM testtb2 WHERE created_at = date)) AS valid
FROM
	(SELECT v.* FROM 
		(SELECT ADDDATE('1970-01-01',t4.i*10000 + t3.i*1000 + t2.i*100 + t1.i*10 + t0.i) selected_date FROM
			(SELECT 0 i UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t0,
		    (SELECT 0 i UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t1,
		    (SELECT 0 i UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t2,
		    (SELECT 0 i UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t3,
		    (SELECT 0 i UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t4) v
	WHERE selected_date BETWEEN '2018-08-01' AND '2018-08-31') AS time_period
    ORDER BY date;


--4.Пусть имеется любая таблица с календарным полем created_at. Создайте запрос, который удаляет устаревшие записи из таблицы, оставляя только 5 самых свежих записей:
USE shop;
DROP TABLE IF EXISTS testtb2;
CREATE TABLE testtb2 (
	created_at DATE
);

INSERT INTO testtb2 VALUES
	('2020-09-01'),
	('2020-09-02'),
	('2020-09-03'),
	('2020-09-04'),
	('2020-09-05'),
	('2020-09-06'),
	('2020-09-07'),
	('2020-09-08'),
	('2020-09-09'),
	('2020-09-10');

DELETE
  testtb2
FROM
  testtb2
JOIN
 (SELECT
    created_at
  FROM
    testtb2
  ORDER BY
    created_at DESC
  LIMIT 5, 1) AS new
ON
  testtb2.created_at <= new.created_at;
