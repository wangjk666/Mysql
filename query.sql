/*
DROP DATABASE IF EXISTS cs122a_test;
CREATE DATABASE cs122a_test;
*/

USE cs122a_test;

/*
SOURCE /Users/wangjunke/Desktop/schema_data.sql;
*/


SELECT u.name,f.school_name
FROM Faculty f, User u
WHERE f.user_id = u.user_id
      AND f.research_area = 'RA1';

SELECT DISTINCT b.name
FROM Building b, CompostBin c, WasteBin w
WHERE c.waste_bin_id = w.waste_bin_id
      AND w.X >= b.boxLowX
      AND w.X <= b.boxUpperX
      AND w.Y >= b.boxLowY
      AND w.y <= b.boxUpperY;

SELECT DISTINCT w.waste_bin_id, w.X, w.Y
FROM WasteBin w, LoadSensor ls, LoadObservation lo
WHERE w.waste_bin_id = ls.Waste_bin_id
      AND ls.sensor_id = lo.sensor_id
      AND lo.timestamp > '2019-10-26 13:00:00'
      AND lo.Weight > w.capacity;

SELECT DISTINCT u.user_id
FROM User u,WasteBin w,LoadSensor ls,LoadObservation lo,LocationSensor lcs,LocationObservation lco
WHERE lo.timestamp > '2019-10-26 14:00:00' 
      AND lo.timestamp < '2019-10-26 15:00:00'
      AND lo.sensor_id = ls.sensor_id
      AND lo.timestamp = lco.timestamp
      AND w.waste_bin_id = ls.waste_bin_id
      AND w.X = lco.X
      AND w.Y = lco.Y
      AND lco.sensor_id = lcs.sensor_id
      AND lcs.User_id = u.user_id;


SELECT DISTINCT w.waste_bin_id
FROM WasteBin w,Building b,LocationObservation lco, LocationSensor lcs,Visitor v
WHERE w.X >= b.boxLowX
      AND w.X <= b.boxUpperX
      AND w.Y >= b.boxLowY
      AND w.Y <= b.boxUpperY
      AND lco.timestamp >= '2019-10-26 14:00:00'
      AND lco.timestamp <= '2019-10-26 15:00:00'
      AND lco.X = w.X
      AND lco.Y = w.Y
      AND lco.sensor_id = lcs.sensor_id
      AND lcs.User_id = v.user_id;
    


SELECT DISTINCT u.name
FROM Student s, RecycleBin r, WasteBin w, ObjectRecognitionSensor ors, ObjectRecognitionObservation oro, LocationSensor lcs, LocationObservation lco, User u
WHERE oro.sensor_id = ors.sensor_id
      AND oro.timestamp >= '2019-10-26 14:00:00'
      AND oro.timestamp <= '2019-10-26 15:00:00'
      AND oro.timestamp = lco.timestamp
      AND ors.Waste_bin_id = r.waste_bin_id
      AND r.waste_bin_id = w.waste_bin_id
      AND lco.X = w.X
      AND lco.Y = w.Y
      AND lco.sensor_id = lcs.sensor_id
      AND lcs.User_id = s.user_id
      AND s.user_id = u.user_id;

SELECT DISTINCT u.name
FROM Student s, RecycleBin r, WasteBin w, ObjectRecognitionSensor ors, ObjectRecognitionObservation oro, LocationSensor lcs, LocationObservation lco, User u
WHERE oro.sensor_id = ors.sensor_id
      AND oro.timestamp >= '2019-10-25 14:00:00'
      AND oro.timestamp <= '2019-10-26 15:00:00'
      AND oro.timestamp = lco.timestamp
      AND ors.Waste_bin_id = r.waste_bin_id
      AND r.waste_bin_id = w.waste_bin_id
      AND lco.X = w.X
      AND lco.Y = w.Y
      AND lco.sensor_id = lcs.sensor_id
      AND lcs.User_id = s.user_id
      AND s.user_id = u.user_id;


SELECT u.user_id
FROM User u, LandfillBin l, LocationObservation lco, LocationSensor lcs, WasteBin w, LoadObservation lo, LoadSensor ls
WHERE lo.timestamp = lco.timestamp
      AND lo.sensor_id = ls.sensor_id
      AND ls.waste_bin_id = l.waste_bin_id
      AND w.waste_bin_id = l.waste_bin_id
      AND lco.X = w.X
      AND lco.Y = w.Y
      AND lco.sensor_id = lcs.sensor_id
      AND lcs.User_id = u.user_id
GROUP BY u.user_id
HAVING COUNT(*) > 100;

 

SELECT DISTINCT u.user_id
FROM User u
WHERE u.user_id NOT IN
(SELECT DISTINCT u1.user_id
FROM  User u1, LocationObservation lco, LocationSensor lcs, RecycleBin r, LoadSensor ls, LoadObservation lo, WasteBin w
WHERE lco.timestamp = lo.timestamp
      AND lco.sensor_id = lcs.sensor_id
      AND lcs.User_id = u1.user_id
      AND lo.sensor_id = ls.sensor_id
      AND ls.Waste_bin_id = r.waste_bin_id
      AND ls.Waste_bin_id = w.waste_bin_id
      AND lco.X = w.X
      AND lco.Y = w.Y
);

SELECT b.name, count(*)
FROM Building b,WasteBin w,LoadObservation lo,LoadSensor ls
WHERE lo.timestamp >= '2019-10-01 13:00:00'
      AND lo.timestamp <= '2019-10-31 15:00:00'
      AND lo.sensor_id = ls.sensor_id
      AND ls.waste_bin_id = w.waste_bin_id
      AND w.X >= b.boxLowX
      AND w.X <= b.boxUpperX
      AND w.Y >= b.boxLowY
      AND w.Y <= b.boxUpperY
GROUP BY b.name;



SET @row_num:=0;
SELECT a.user_id,@row_num:=@row_num+1 as "Rank"
FROM (
SELECT u.user_id
FROM User u,WasteBin w, LoadObservation lo, LoadSensor ls,LocationSensor lcs, LocationObservation lco, CompostBin c
WHERE w.waste_bin_id = c.waste_bin_id
      AND w.X = lco.X
      AND w.Y = lco.Y
      AND lco.sensor_id = lcs.sensor_id
      AND lcs.User_id = u.user_id
      AND lo.sensor_id = ls.sensor_id
      AND ls.Waste_bin_id = c.waste_bin_id
GROUP BY u.user_id
ORDER BY SUM(lo.Weight) DESC
LIMIT 10) a;

