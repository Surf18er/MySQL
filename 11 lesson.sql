--1.В базе данных Redis подберите коллекцию для подсчета посещений с определенных IP-адресов:

SADD ipaddr `127.0.0.1` `10.10.10.100` `192.168.236.128`

SMEMBERS ipaddr


--2.При помощи базы данных Redis решите задачу поиска имени пользователя по электронному адресу и наоборот, поиск электронного адреса пользователя по его имени:

SET fedor@geekbrains.ru fedor
SET fedor fedor@geekbrains.ru

GET fedor@geekbrains.ru
GET fedor


--3.Организуйте хранение категорий и товарных позиций учебной базы данных shop в СУБД MongoDB:

--catalogs:
use catalogs

db.catalogs.insertMany(
  [{"name": "Процессоры"}, {"name": "Материнские платы"}, {"name": "Видеокарты"}, {"name": "Жесткие диски"}, {"name": "Оперативная память"}]
)

db.catalogs.find()

--products:
use products

db.products.insertMany([
	{"name": "Intel Core i3-8100", "description": "Процессор для настольных ПК Intel", "price": "7890.00", "catalog_id": "Процессоры", "created_at": new Date(), "updated_at": new Date()},
	{"name": "Intel Core i5-7400", "description": "Процессор для настольных ПК Intel", "price": "12700.00", "catalog_id": "Процессоры", "created_at": new Date(), "updated_at": new Date()},
	{"name": "AMD FX-8320E", "description": "Процессор для настольных ПК AMD", "price": "4780.00", "catalog_id": "Процессоры", "created_at": new Date(), "updated_at": new Date()},
	{"name": "AMD FX-8320", "description": "Процессор для настольных ПК AMD", "price": "7120.00", "catalog_id": "Процессоры", "created_at": new Date(), "updated_at": new Date()},
	{"name": "ASUS ROG MAXIMUS X HERO", "description": "Материнская плата ASUS ROG MAXIMUS X HERO, Z370, Socket 1151-V2, DDR4, ATX", "price": "19310.00", "catalog_id": "Материнские платы", "created_at": new Date(), "updated_at": new Date()},
	{"name": "Gigabyte H310M S2H", "description": "Материнская плата Gigabyte H310M S2H, H310, Socket 1151-V2, DDR4, mATX", "price": "4790.00", "catalog_id": "Материнские платы", "created_at": new Date(), "updated_at": new Date()},
	{"name": "MSI B250M GAMING PRO", "description": "Материнская плата MSI B250M GAMING PRO, B250, Socket 1151, DDR4, mATX", "price": "5060.00", "catalog_id": "Материнские платы", "created_at": new Date(), "updated_at": new Date()}
	])

db.products.find().pretty()
