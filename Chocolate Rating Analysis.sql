-- Набір даних Chocolate Ratings
-- Джерело https://www.kaggle.com/datasets/joebeachcapital/chocolate-ratings


use chocolate;
-- Загальна статистика 
-- Вигляд даних 
SELECT *
FROM chocolate_rating;

-- Кількість рядків
SELECT count(*)
FROM chocolate_rating;

-- Перевірка цілісності даних
-- Рядки зі нульовим значенням  рейтингу. Якщо такі є, їх треба змінити
SELECT count(*)
FROM chocolate_rating
WHERE rating = 0; -- відсутні

-- Рядки де рейтинг <1 або >5. Такі рядки потребують змін, адже мають не коректні дані 
SELECT COUNT(*)
FROM chocolate_rating
WHERE rating < 1 OR rating > 5; -- відсутні

-- Перевірка на дублікати
SELECT id,
	ref,
    company_manufacturer,
    company_location,
    review_date,
    country_of_bean_origin,
    specific_bean_origin_or_bar_name,
    cocoa_percent,
    ingredients ,
    most_memorable_characteristics,
    rating, 
    count(*)
FROM chocolate_rating
WHERE rating = 0
GROUP BY
	id,
	ref,
    company_manufacturer,
    company_location,
    review_date,
    country_of_bean_origin,
    specific_bean_origin_or_bar_name,
    cocoa_percent,
    ingredients ,
    most_memorable_characteristics,
    rating
HAVING count(*) > 1; -- відсутні

-- Середнє значення рейтингу 
SELECT ROUND(AVG(rating),2)
FROM chocolate_rating;

-- Аналіз за країнами виробниками
-- Список країн виробників 
SELECT DISTINCT
    company_location
FROM
    chocolate_rating;

-- Середній рейтинг шоколаду в кожній країні виробнику
SELECT 
    company_location, ROUND(AVG(rating), 2) AS avg_rating
FROM
    chocolate_rating
GROUP BY company_location
ORDER BY avg_rating DESC;

-- Середній рейтинг шоколаду для кожної фабрики в кожній країні виробнику
SELECT 
    company_location,
    company_manufacturer,
    ROUND(AVG(rating), 2) AS avg_rating
FROM
    chocolate_rating
GROUP BY company_location , company_manufacturer
ORDER BY avg_rating DESC;

-- Знайдемо країну, де найбільше компаній з середнім рейтингом більшим 4 
WITH rating_4 AS (
SELECT 
	company_location, 
    company_manufacturer, 
    ROUND(AVG(rating),2) AS avg_rating
FROM 
	chocolate_rating
GROUP BY company_location, company_manufacturer
HAVING ROUND(AVG(rating),2) >= 4
ORDER BY avg_rating DESC)

SELECT 
    company_location,
    COUNT(company_manufacturer) AS number_of_company
FROM
    rating_4
GROUP BY company_location
ORDER BY number_of_company DESC; -- найбільшу кількість таких компаній має США

-- Дослідимо як на рейтинг шоколаду впливає відсоток какао
-- Додамо нову колонку, яка визначає тип шоколаду залежно від вмісту какао
ALTER TABLE chocolate_rating
ADD COLUMN chocolate_type VARCHAR(255);

UPDATE chocolate_rating
SET chocolate_type = 
	CASE 
		WHEN cocoa_percent >= '0,7' THEN 'Dark'
        WHEN cocoa_percent < '0,7'  AND cocoa_percent >= '0,3' THEN 'Milk'
		WHEN cocoa_percent < '0,3' THEN 'White'
        END;

-- Середній рейтинг залежно від відсотку какао
SELECT 
    cocoa_percent,
    chocolate_type,
    ROUND(AVG(rating), 2) AS avg_rating
FROM
    chocolate_rating
GROUP BY cocoa_percent , chocolate_type
ORDER BY cocoa_percent;

-- Середній рейтиг залежно від типу
SELECT 
    chocolate_type, ROUND(AVG(rating), 2) AS avg_rating
FROM
    chocolate_rating
GROUP BY chocolate_type
ORDER BY avg_rating; -- Для чорного та молочного шоколаду середній рейтинг однаковий, для білого трохи нижчий

-- Аналіз інгредієнтів шоколаду
-- У таблицю chocolate_ingredients скопіюємо дані про інгредієнти та рейтинг шоколаду із таблиці chocolate_rating
INSERT INTO chocolate_ingredients
SELECT id,
    cocoa_percent,
    ingredients,
    rating
FROM chocolate_rating;

SELECT *
FROM chocolate_ingredients;

SELECT DISTINCT ingredients
FROM chocolate_ingredients;

-- Створимо нову колонку в таблиці chocolate_ingredients із повним описом інгредієнтів
ALTER TABLE chocolate_ingredients
ADD COLUMN full_ingredients VARCHAR(255);

UPDATE chocolate_ingredients
SET full_ingredients =
	CASE
		WHEN ingredients = '1- B' THEN 'Beans' -- 1
        WHEN ingredients = '2- B,C' THEN 'Beans,Cocoa Butter' -- 2
        WHEN ingredients = '2- B,S' THEN 'Beans,Sugar' -- 3
        WHEN ingredients = '2- B,S*' THEN 'Beans,Other Sweetener' -- 4
        WHEN ingredients = '3- B,S*,C' THEN 'Beans,Other Sweetener,Cocoa Butter' -- 5
        WHEN ingredients = '3- B,S*,Sa' THEN 'Beans,Other Sweetener,Salt' -- 6
        WHEN ingredients = '3- B,S,C' THEN 'Beans,Sugar,Cocoa Butter' --  7
        WHEN ingredients = '3- B,S,L' THEN 'Beans,Sugar,Lecithin' -- 8
        WHEN ingredients = '3- B,S,V' THEN 'Beans,Sugar,Vanilla' -- 9
        WHEN ingredients = '4- B,S*,C,L' THEN 'Beans,Other Sweetener,Cocoa Butter,Lecithin' -- 10
        WHEN ingredients = '4- B,S*,C,Sa' THEN 'Beans,Other Sweetener,Cocoa Butter,Salt' -- 11
        WHEN ingredients = '4- B,S*,C,V' THEN 'Beans,Other Sweetener,Cocoa Butter,Vanilla' -- 12
        WHEN ingredients = '4- B,S*,V,L' THEN 'Beans,Other Sweetener,Vanilla,Lecithin' -- 13
        WHEN ingredients = '4- B,S,C,L' THEN 'Beans,Sugar,Cocoa Butter,Lecithin' --  14
        WHEN ingredients = '4- B,S,C,Sa' THEN 'Beans,Sugar,Cocoa Butter,Salt' --  15
        WHEN ingredients = '4- B,S,C,V' THEN 'Beans,Sugar,Cocoa Butter,Vanilla' --  16
        WHEN ingredients = '4- B,S,V,L' THEN 'Beans,Sugar,Vanilla,Lecithin' --  17
        WHEN ingredients = '5- B,S,C,L,Sa' THEN 'Beans,Sugar,Cocoa Butter,Lecithin,Salt' --  18
        WHEN ingredients = '5- B,S,C,V,L' THEN 'Beans,Sugar,Cocoa Butter,Vanilla,Lecithin' --  19
        WHEN ingredients = '5-B,S,C,V,Sa' THEN 'Beans,Sugar,Cocoa Butter,Vanilla,Salt' --  20
        WHEN ingredients = '6-B,S,C,V,L,Sa' THEN 'Beans,Sugar,Cocoa Butter,Vanilla,Lecithin,Salt' --  21
        ELSE ' '
        END;
        
-- Додамо колонку в якій вказана кількість інгредієнтів
ALTER TABLE chocolate_ingredients
ADD COLUMN number_of_ingredients INT;

UPDATE chocolate_ingredients
SET number_of_ingredients = 
	CASE
		WHEN POSITION('1' IN ingredients) != 0 THEN 1
        WHEN POSITION('2' IN ingredients) != 0 THEN 2
        WHEN POSITION('3' IN ingredients) != 0 THEN 3
        WHEN POSITION('4' IN ingredients) != 0 THEN 4
        WHEN POSITION('5' IN ingredients) != 0 THEN 5
        WHEN POSITION('6' IN ingredients) != 0 THEN 6
        END;
        
SELECT *
FROM chocolate_ingredients;

-- Видалимо записи, де не вказані інгредієнти 
DELETE FROM chocolate_ingredients WHERE ingredients = '';

-- Середній рейтинг залежно від кількості інгредієнтів 
SELECT 
    number_of_ingredients, ROUND(AVG(rating), 2) AS avg_rating
FROM
    chocolate_ingredients
GROUP BY number_of_ingredients
ORDER BY avg_rating;

-- Проаналізуємо залежність рейтингу від наявності окремих інгредієнтів 
-- Знайдемо середній рейтинг залежно від наявності кожного інгредієнту та кількість екземплярів, які мають цей ігредієнт в складі
SELECT 
    'Cocoa Butter' AS ingregient,
    AVG(rating) AS avg_rating,
    COUNT(id) AS number_of_ingredient
FROM
    chocolate_ingredients
WHERE
    POSITION('C' IN ingredients) != 0
UNION 
SELECT 
    'Sugar' AS ingregient,
    AVG(rating) AS avg_rating,
    COUNT(id) AS number_of_chocolate
FROM
    chocolate_ingredients
WHERE
    POSITION('S' IN ingredients) != 0
UNION 
SELECT 
    'Other Sweetener' AS ingregient,
    AVG(rating) AS avg_rating,
    COUNT(id) AS number_of_chocolate
FROM
    chocolate_ingredients
WHERE
    POSITION('S*' IN ingredients) != 0
UNION 
SELECT 
    'Salt' AS ingregient,
    AVG(rating) AS avg_rating,
    COUNT(id) AS number_of_chocolate
FROM
    chocolate_ingredients
WHERE
    POSITION('Sa' IN ingredients) != 0
UNION 
SELECT 
    'Lecithin' AS ingregient,
    AVG(rating) AS avg_rating,
    COUNT(id) AS number_of_chocolate
FROM
    chocolate_ingredients
WHERE
    POSITION('L' IN ingredients) != 0
UNION 
SELECT 
    'Vanilla' AS ingregient,
    AVG(rating) AS avg_rating,
    COUNT(id) AS number_of_chocolate
FROM
    chocolate_ingredients
WHERE
    POSITION('V' IN ingredients) != 0
ORDER BY avg_rating;

