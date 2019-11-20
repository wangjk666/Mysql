USE cs122a_test;


DROP VIEW IF EXISTS APP_Users;
CREATE VIEW APP_Users as
(SELECT DISTINCT w.waste_bin_id, w.X, w.Y, 'Recycle' as "Type of bin"
FROM WasteBin w, Building b, RecycleBin r,(SELECT w.waste_bin_id as wid,
                                                 (SELECT MAX(lo.timestamp)
                                                  FROM  LoadObservation lo, LoadSensor ls
                                                  WHERE lo.sensor_id = ls.sensor_id
                                                  AND ls.waste_bin_id = wid
                                                  AND lo.timestamp < '2019-10-26 13:00:00'
                                                 ) as latest_record
				           FROM WasteBin w) as mem, LoadObservation lo, LoadSensor ls
WHERE w.waste_bin_id in (SELECT r.waste_bin_id FROM RecycleBin r)
      AND w.X >= b.boxLowX
      AND w.X <= b.boxUpperX
      AND w.Y >= b.boxLowY
      AND w.y <= b.boxUpperY
      AND w.waste_bin_id = ls.waste_bin_id
      AND ls.sensor_id = lo.sensor_id
      AND w.waste_bin_id = mem.wid
      AND lo.timestamp = mem.latest_record
      AND lo.Weight < w.capacity
)
UNION
(SELECT DISTINCT w.waste_bin_id, w.X, w.Y, 'CompostBin' as "Type of bin"
FROM WasteBin w, Building b, CompostBin c,(SELECT w.waste_bin_id as wid,
                                                 (SELECT MAX(lo.timestamp)
                                                  FROM  LoadObservation lo, LoadSensor ls
                                                  WHERE lo.sensor_id = ls.sensor_id
                                                  AND ls.waste_bin_id = wid
                                                  AND lo.timestamp < '2019-10-26 13:00:00'
                                                 ) as latest_record
				           FROM WasteBin w) as mem, LoadObservation lo, LoadSensor ls
WHERE w.waste_bin_id in (SELECT c.waste_bin_id FROM CompostBin c)
      AND w.X >= b.boxLowX
      AND w.X <= b.boxUpperX
      AND w.Y >= b.boxLowY
      AND w.y <= b.boxUpperY
      AND w.waste_bin_id = ls.waste_bin_id
      AND ls.sensor_id = lo.sensor_id
      AND w.waste_bin_id = mem.wid
      AND lo.timestamp = mem.latest_record
      AND lo.Weight < w.capacity
)
UNION
(SELECT DISTINCT w.waste_bin_id, w.X, w.Y, 'LandfillBin' as "Type of bin"
FROM WasteBin w, Building b, LandfillBin l,(SELECT w.waste_bin_id as wid,
                                                 (SELECT MAX(lo.timestamp)
                                                  FROM  LoadObservation lo, LoadSensor ls
                                                  WHERE lo.sensor_id = ls.sensor_id
                                                  AND ls.waste_bin_id = wid
                                                  AND lo.timestamp < '2019-10-26 13:00:00'
                                                 ) as latest_record
				           FROM WasteBin w) as mem, LoadObservation lo, LoadSensor ls
WHERE w.waste_bin_id in (SELECT l.waste_bin_id FROM LandfillBin l)
      AND w.X >= b.boxLowX
      AND w.X <= b.boxUpperX
      AND w.Y >= b.boxLowY
      AND w.y <= b.boxUpperY
      AND w.waste_bin_id = ls.waste_bin_id
      AND ls.sensor_id = lo.sensor_id
      AND w.waste_bin_id = mem.wid
      AND lo.timestamp = mem.latest_record
      AND lo.Weight < w.capacity
);

SELECT * FROM APP_Users;




DROP VIEW IF EXISTS Sustainability_Analysts;
CREATE VIEW Sustainability_Analysts as
SELECT pre.wid as "Waste bin id", pre.x as "x", pre.y as "y", pre.dept_name as "Department", pre.total_weight as "Total weight"
FROM 
(SELECT s.user_id, w.waste_bin_id as wid, any_value(w.X) as x, any_value(w.Y) as y, s.dept_name , SUM(lo.Weight) as total_weight
FROM WasteBin w, Student s, LoadObservation lo, LoadSensor ls, LocationSensor lcs, LocationObservation lco
WHERE lo.sensor_id = ls.sensor_id
      AND ls.Waste_bin_id = w.waste_bin_id
      AND lco.X = w.X
      AND lco.Y = w.Y
      AND lcs.sensor_id = lco.sensor_id
      AND lco.timestamp = lo.timestamp
      AND lcs.User_id = s.user_id
GROUP BY s.user_id, w.waste_bin_id) pre;

SELECT * FROM Sustainability_Analysts;



DROP VIEW IF EXISTS a;
CREATE VIEW a AS
SELECT u.name, DATE(lo.timestamp) AS days, count(*) as "Recycle Bin"
FROM User u, LocationObservation lco, LocationSensor lcs, WasteBin w, LoadSensor ls, LoadObservation lo
WHERE lcs.User_id = u.user_id
      AND lcs.sensor_id = lco.sensor_id
      AND lco.timestamp = lo.timestamp
      AND ls.sensor_id = lo.sensor_id
      AND ls.waste_bin_id = w.waste_bin_id
      AND lco.X = w.X
      AND lco.Y = w.Y
      AND w.waste_bin_id in (SELECT r.waste_bin_id FROM RecycleBin r)
GROUP BY u.name,days;




DROP VIEW IF EXISTS b;
CREATE VIEW b AS
SELECT u.name, DATE(lo.timestamp) AS days, count(*) as "Landfill Bin"
FROM User u, LocationObservation lco, LocationSensor lcs, WasteBin w, LoadSensor ls, LoadObservation lo
WHERE lcs.User_id = u.user_id
      AND lcs.sensor_id = lco.sensor_id
      AND lco.timestamp = lo.timestamp
      AND ls.sensor_id = lo.sensor_id
      AND ls.waste_bin_id = w.waste_bin_id
      AND lco.X = w.X
      AND lco.Y = w.Y
      AND w.waste_bin_id in (SELECT l.waste_bin_id FROM LandfillBin l)
GROUP BY u.name, days;



DROP VIEW IF EXISTS f;
CREATE VIEW f AS
SELECT u.name, DATE(lo.timestamp) AS days, count(*) as "Compost Bin"
FROM User u, LocationObservation lco, LocationSensor lcs, WasteBin w, LoadSensor ls, LoadObservation lo
WHERE lcs.User_id = u.user_id
      AND lcs.sensor_id = lco.sensor_id
      AND lco.timestamp = lo.timestamp
      AND ls.sensor_id = lo.sensor_id
      AND ls.waste_bin_id = w.waste_bin_id
      AND lco.X = w.X
      AND lco.Y = w.Y
      AND w.waste_bin_id in (SELECT c.waste_bin_id FROM CompostBin c)
GROUP BY u.name, days;
      


DROP VIEW IF EXISTS Facility_Managers;
CREATE VIEW Facility_Managers AS
SELECT * 
FROM a 
NATURAL JOIN b 
NATURAL JOIN f;

SELECT * FROM Facility_Managers;


DROP TRIGGER IF EXISTS throw;
DELIMITER $$
CREATE TRIGGER throw BEFORE INSERT ON LoadObservation
FOR EACH ROW
BEGIN 
    IF EXISTS( (SELECT * 
                FROM LoadObservation lo 
                WHERE lo.weight is NULL)
                UNION
               (SELECT *
                FROM LoadObservation lo
                WHERE TIMESTAMPDIFF(HOUR, lo.timestamp, new.timestamp) < 24
                      AND ABS(new.weight - lo.weight) > 1000)
             )
          THEN SET NEW.weight = NULL;
    END IF;
END $$
DELIMITER ;

DELETE FROM LoadObservation WHERE oid > 50000;

INSERT INTO LoadObservation(sensor_id, oid, Weight, timestamp) VALUES (350, 50001, 15000, '2017-07-07 20:00:55');
INSERT INTO LoadObservation(sensor_id, oid, Weight, timestamp) VALUES (350, 50002, 15500, '2017-07-17 22:00:55');
INSERT INTO LoadObservation(sensor_id, oid, Weight, timestamp) VALUES (350, 50003, 17000, '2017-07-18 20:45:55');
INSERT INTO LoadObservation(sensor_id, oid, Weight, timestamp) VALUES (350, 50004, 17500, '2017-07-20 20:50:55');

Select * from LoadObservation where sensor_id = 350 and oid > 50000;


DROP TABLE IF EXISTS `trash_violations`;
CREATE TABLE `trash_violations`(
    `tvid` INT NOT NULL,
    `user_id` INT NOT NULL,
    `timestamp` DATETIME NOT NULL,
    `waste_bin_id` INT NOT NULL,
    `trash_type` ENUM('Recycycle','Compost','Landfill') NOT NULL,
    PRIMARY KEY(`tvid`),
    FOREIGN KEY (`user_id`) REFERENCES `User`(`user_id`),
    FOREIGN KEY (`waste_bin_id`) REFERENCES `WasteBin`(`waste_bin_id`)
);


SET @rows:=( (SELECT COUNT(*) FROM trash_violations)+1 );
DELIMITER $$
DROP TRIGGER IF EXISTS throw;
CREATE TRIGGER throw AFTER INSERT ON ObjectRecognitionObservation
FOR EACH ROW
BEGIN 
    IF EXISTS ((SELECT r.waste_bin_id 
               FROM  ObjectRecognitionSensor ors, RecycleBin r
               WHERE NEW.sensor_id = ors.sensor_id 
                     AND ors.waste_bin_id = r.waste_bin_id
                     AND NEW.trash_type != 'Recycycle')
               UNION
               (SELECT  c.waste_bin_id
               FROM  ObjectRecognitionSensor ors, CompostBin c
               WHERE NEW.sensor_id = ors.sensor_id 
                     AND ors.waste_bin_id = c.waste_bin_id
                     AND NEW.trash_type != 'Compost')
               UNION
               (SELECT l.waste_bin_id
               FROM  ObjectRecognitionSensor ors, LandfillBin l
               WHERE NEW.sensor_id = ors.sensor_id 
                     AND ors.waste_bin_id = l.waste_bin_id
                     AND NEW.trash_type != 'Landfill')) 
         THEN INSERT INTO trash_violations(tvid, user_id, timestamp, waste_bin_id, trash_type) 
                     SELECT @rows, u.user_id, NEW.timestamp, w.waste_bin_id, NEW.trash_type
                     FROM  User u, WasteBin w, ObjectRecognitionSensor ocs, LocationSensor lcs, LocationObservation lco
                     WHERE NEW.sensor_id = ocs.sensor_id
                           AND NEW.timestamp = lco.timestamp
                           AND lco.sensor_id = lcs.sensor_id
                           AND lcs.user_id = u.user_id
                           AND ocs.waste_bin_id = w.waste_bin_id
                           AND w.X = lco.X
                           AND w.Y = lco.Y;
    END IF;
END $$
DELIMITER ;

DELETE FROM LocationObservation WHERE timestamp='2017-11-15 14:00:00';
DELETE FROM ObjectRecognitionObservation WHERE timestamp='2017-11-15 14:00:00';

INSERT INTO LocationObservation
(sensor_id, oid, timestamp, X, Y)
VALUES
(1, 100001, '2017-11-15 14:00:00', 5459, 3576);

INSERT INTO ObjectRecognitionObservation
(sensor_id, oid, timestamp, trash_type)
VALUES
(354, 200001, '2017-11-15 14:00:00','Landfill');

SELECT * 
FROM trash_violations;
