CREATE TABLE IF NOT EXISTS contact_data
(
    contact_data_id serial PRIMARY KEY,
    email varchar(32) NOT NULL UNIQUE,
    phone varchar(32) NOT NULL UNIQUE
);

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'qualification_name') THEN
        CREATE TYPE qualification_name AS ENUM ('бакалавр', 'магістр', 'доктор філософії', 'доктор наук');
    END IF;
END$$;

CREATE TABLE IF NOT EXISTS teacher
(
    teacher_id serial PRIMARY KEY,
    name varchar(32) NOT NULL,
    surname varchar(32) NOT NULL,
    contact_data_id integer not null references contact_data(contact_data_id),
    qualification qualification_name
);

CREATE TABLE IF NOT EXISTS student_group
(
    group_id serial PRIMARY KEY,
    name char(7) NOT NULL CHECK (name LIKE '__-%'),
    start_year SMALLINT NOT NULL CHECK (start_year >= 1898),
    curator_id INTEGER NOT NULL REFERENCES teacher(teacher_id)
);

CREATE TABLE IF NOT EXISTS student
(
    student_id serial PRIMARY KEY,
    name varchar(32) NOT NULL,
    surname varchar(32) NOT NULL,
    profession SMALLINT,
    contact_data_id integer not null references contact_data(contact_data_id),
    group_id integer not null references student_group(group_id)
);

CREATE TABLE IF NOT EXISTS course
(
    course_id serial PRIMARY KEY,
    name varchar(32) NOT NULL,
    credits SMALLINT NOT NULL CHECK (credits > 0 AND credits < 100),
    student_year SMALLINT NOT NULL CHECK (student_year >= 1 AND student_year <= 4),
    is_active BOOLEAN NOT NULL,
    teacher_id INTEGER NOT NULL REFERENCES teacher(teacher_id)
);

CREATE TABLE IF NOT EXISTS enrolment
(
    course_id INTEGER not null references course(course_id),
    student_id INTEGER not null references student(student_id),
    grade SMALLINT,
    PRIMARY KEY (course_id, student_id)
);

CREATE TABLE IF NOT EXISTS course_prerequisite
(
    course_id INTEGER NOT NULL references course(course_id),
    prerequisite_course_id INTEGER NOT NULL references course(course_id) CHECK (course_id <> prerequisite_course_id),
    PRIMARY KEY (course_id, prerequisite_course_id)
);

TRUNCATE TABLE course_prerequisite RESTART IDENTITY CASCADE;
TRUNCATE TABLE enrolment RESTART IDENTITY CASCADE;
TRUNCATE TABLE course RESTART IDENTITY CASCADE;
TRUNCATE TABLE student RESTART IDENTITY CASCADE;
TRUNCATE TABLE student_group RESTART IDENTITY CASCADE;
TRUNCATE TABLE teacher RESTART IDENTITY CASCADE;
TRUNCATE TABLE contact_data RESTART IDENTITY CASCADE;

INSERT INTO contact_data (email, phone)
VALUES ('ivan.sirenko@email.com', '+380501234567'),
       ('maria.chernenko@email.com', '+380672345678'),
       ('oleksandr.volkov@email.com', '+380933456789'),
       ('natalia.yakovenko@email.com', '+380504567890'),
       ('viktor.zhurenko@email.com', '+380675678901'),
       ('oksana.doroshenko@email.com', '+380936789012'),
       ('dmytro.rudenko@email.com', '+380507890123'),
       ('tetiana.mikhailenko@email.com', '+380678901234'),
       ('sergiy.timoshenko@email.com', '+380939012345'),
       ('yulia.andrienko@email.com', '+380501023456'),
       ('andriy.kovalchuk@email.com', '+380671134567'),
       ('lesia.pavlenko@email.com', '+380932245678'),
       ('pavlo.demchenko@email.com', '+380503356789'),
       ('iryna.bilenko@email.com', '+380674467890'),
       ('maksym.novenko@email.com', '+380935578901'),
       ('inna.kornenko@email.com', '+380506689012'),
       ('roman.belenko@email.com', '+380677790123'),
       ('svitlana.petrushenko@email.com', '+380938801234'),
       ('vitaliy.semenko@email.com', '+380509912345'),
       ('anna.trofimenko@email.com', '+380671023456');

INSERT INTO teacher (name, surname, contact_data_id, qualification)
VALUES ('Іван', 'Сіренко', 1, 'доктор наук'),
       ('Марія', 'Черненко', 2, 'доктор філософії'),
       ('Олександр', 'Волков', 3, NULL),
       ('Наталія', 'Яковенко', 4, 'доктор наук'),
       ('Віктор', 'Журенко', 5, NULL),
       ('Оксана', 'Дорошенко', 6, 'магістр'),
       ('Дмитро', 'Руденко', 7, 'доктор наук'),
       ('Тетяна', 'Михайленко', 8, 'доктор філософії'),
       ('Сергій', 'Тимошенко', 9, NULL),
       ('Юлія', 'Андрієнко', 10, 'магістр');

INSERT INTO student_group (name, start_year, curator_id)
VALUES ('КН-01', 2020, 1),
       ('ІТ-12', 2021, 2),
       ('МА-92', 2019, 3),
       ('ФІ-23', 2022, 4),
       ('ЕК-04', 2020, 5),
       ('БІ-14', 2021, 6),
       ('ПС-91', 2019, 7),
       ('ХІ-22', 2022, 8);

INSERT INTO student (name, surname, profession, contact_data_id, group_id)
VALUES ('Андрій', 'Ковальчук', 121, 11, 1),
       ('Леся', 'Павленко', 121, 12, 1),
       ('Павло', 'Демченко', 122, 13, 2),
       ('Ірина', 'Біленко', 122, 14, 2),
       ('Максим', 'Новенко', 123, 15, 3),
       ('Інна', 'Корненко', 123, 16, 3),
       ('Роман', 'Беленко', NULL, 17, 4),
       ('Світлана', 'Петрушенко', NULL, 18, 4),
       ('Віталій', 'Семенко', 121, 19, 5),
       ('Анна', 'Трофименко', 121, 20, 5),
       ('Олег', 'Гавриленко', 123, 1, 6),
       ('Катерина', 'Мироненко', 123, 2, 6),
       ('Михайло', 'Костенко', 122, 3, 7),
       ('Тамара', 'Юрченко', 122, 4, 7),
       ('Богдан', 'Самойленко', NULL, 5, 8);

INSERT INTO course (name, credits, student_year, is_active, teacher_id)
VALUES ('Програмування', 6, 1, true, 1),
       ('Математичний аналіз', 8, 1, true, 2),
       ('Дискретна математика', 5, 1, true, 3),
       ('Алгоритми та структури даних', 7, 2, true, 4),
       ('ООП', 6, 2, true, 5),
       ('Операційні системи', 5, 2, true, 6),
       ('Архітектура комп''ютерів', 4, 2, true, 7),
       ('Веб-технології', 5, 3, true, 8),
       ('Машинне навчання', 6, 3, true, 9),
       ('Комп''ютерні мережі', 5, 3, true, 10),
       ('Інженерія ПЗ', 7, 4, true, 1),
       ('Кібербезпека', 5, 4, false, 2);

INSERT INTO enrolment (course_id, student_id, grade)
VALUES (1, 1, 85),
       (1, 2, 92),
       (1, 3, NULL),
       (2, 1, 88),
       (2, 2, 95),
       (2, 4, NULL),
       (3, 1, 90),
       (3, 3, 76),
       (4, 5, NULL),
       (4, 6, 93),
       (5, 5, 87),
       (5, 7, NULL),
       (6, 7, 84),
       (6, 8, 79),
       (8, 9, NULL),
       (8, 10, 88),
       (9, 11, 92),
       (9, 12, NULL),
       (10, 13, 83),
       (11, 14, NULL);

INSERT INTO course_prerequisite (course_id, prerequisite_course_id)
VALUES (4, 1),  -- Алгоритми потребують Програмування
       (5, 1),  -- ООП потребує Програмування
       (8, 1),  -- Веб-технології потребують Програмування
       (9, 2),  -- Машинне навчання потребує Математичний аналіз
       (9, 4),  -- Машинне навчання потребує Алгоритми
       (10, 6), -- Комп'ютерні мережі потребують Операційні системи
       (11, 5); -- Інженерія ПЗ потребує ООП

SELECT 
    course_id,
    name AS course_name,
    student_year AS year_of_study,
    ((student_year * 2) - 1) AS semester_vstupu
FROM course
WHERE is_active = true
ORDER BY year_of_study, course_name;


SELECT 
    stud_res.student_id,
    stud_res.name,
    stud_res.surname,
    stud_res.course_count,
    ROUND(CAST(avg_data.global_avg AS numeric), 2) AS average_per_all
FROM (
    SELECT 
        st.student_id, st.name, st.surname, 
        COUNT(enr.course_id) AS course_count
    FROM student st
    LEFT JOIN enrolment enr ON st.student_id = enr.student_id
    GROUP BY st.student_id, st.name, st.surname
) AS stud_res
CROSS JOIN (
    SELECT AVG(counts.cnt) AS global_avg
    FROM (
        SELECT COUNT(course_id) AS cnt 
        FROM enrolment 
        GROUP BY student_id
    ) AS counts
) AS avg_data
WHERE stud_res.course_count > avg_data.global_avg
ORDER BY stud_res.course_count DESC;


SELECT 
    current_course.name AS course_name,
    current_stud.surname || ' ' || current_stud.name AS student_pib,
    current_enrol.grade AS mark
FROM enrolment AS current_enrol
JOIN course AS current_course ON current_enrol.course_id = current_course.course_id
JOIN student AS current_stud ON current_enrol.student_id = current_stud.student_id
WHERE (
    SELECT COUNT(*) 
    FROM enrolment AS auxiliary_enrol
    WHERE auxiliary_enrol.course_id = current_enrol.course_id 
      AND auxiliary_enrol.grade > current_enrol.grade
) < 3 
AND current_enrol.grade IS NOT NULL
ORDER BY course_name, mark DESC;