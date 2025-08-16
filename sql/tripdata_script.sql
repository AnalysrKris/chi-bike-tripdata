-- ========================
-- Bike Rental Member Analysis
-- Business Question: How do members differ from casual users?
-- Data Source: 
-- ========================

-- Split the dataset into two parts: members and non-members
-- Used Permanent tables for local development
-- Would use temporary tables in production for DB cleanliness

-- Clean up any existing tables first
DROP TABLE IF EXISTS member_analysis;
DROP TABLE IF EXISTS casual_analysis;

-- Create fresh tables
CREATE TABLE member_analysis AS
SELECT *
FROM tripdata 
WHERE member_casual = 'member';

CREATE TABLE casual_analysis AS
SELECT *
FROM tripdata 
WHERE member_casual = 'casual';

-- Uses Haversine formula to calculate distance and then adds it to the member_analysis table
ALTER TABLE member_analysis 
ADD COLUMN distance_miles REAL;

-- Update with calculated values
UPDATE member_analysis 
SET distance_miles = (
    3959 * acos(
        cos(radians(start_lat)) 
        * cos(radians(end_lat)) 
        * cos(radians(end_lng) - radians(start_lng)) 
        + sin(radians(start_lat)) 
        * sin(radians(end_lat))
    )
)
WHERE start_lat IS NOT NULL 
  AND start_lng IS NOT NULL 
  AND end_lat IS NOT NULL 
  AND end_lng IS NOT NULL;

-- Add distance column to casual_analysis table
ALTER TABLE casual_analysis 
ADD COLUMN distance_miles REAL;

-- Update with calculated values
UPDATE casual_analysis 
SET distance_miles = (
    3959 * acos(
        cos(radians(start_lat))
        * cos(radians(end_lat))
        * cos(radians(end_lng) - radians(start_lng))
        + sin(radians(start_lat))
        * sin(radians(end_lat))
    )
)
WHERE start_lat IS NOT NULL 
  AND start_lng IS NOT NULL 
  AND end_lat IS NOT NULL 
  AND end_lng IS NOT NULL;

  -- ===========================================================
-- Analysis of round trips
-- A round trip is defined as a trip that starts and ends at the same station.
-- This is a proxy for leisure trips, as commuters are less likely to return to the starting station.
-- We will compare the count of round trips between members and casual users.
-- =============================================================

-- count of round trips for casual users by comparing start and end stations
SELECT COUNT(*) AS same_station_returns
FROM casual_analysis 
WHERE start_station_id = end_station_id;

-- count of round trips for members by comparing start and end stations
SELECT COUNT(*) AS same_station_returns
FROM member_analysis 
WHERE start_station_id = end_station_id;

-- discovered during this anaysis of the following data quality issues:
-- Missing start and end station IDs in both member and casual datasets.
-- following query is to find how many of the records have complete station IDs
SELECT 
    COUNT(*) AS complete_station_ids
FROM casual_analysis 
WHERE start_station_id IS NOT NULL 
  AND end_station_id IS NOT NULL;

-- returned 208740 records. This indicates 65% of the casual records have complete station IDs.
-- now to find how many of those are true round trips
SELECT 
    COUNT(*) AS true_round_trips
FROM casual_analysis 
WHERE start_station_id IS NOT NULL 
  AND end_station_id IS NOT NULL
  AND start_station_id = end_station_id;

-- returned 21353 entries. This indicates 10.2% of the casual records with complete station IDs are true round trips.
-- Now let's do the same for members
SELECT 
    COUNT(*) AS complete_station_ids
FROM member_analysis 
WHERE start_station_id IS NOT NULL 
  AND end_station_id IS NOT NULL; 

-- returned 285553 records out of 440095. This indicates 64.9% of the member records have complete station IDs.
-- now to find how many of those are true round trips
SELECT 
    COUNT(*) AS true_round_trips
FROM member_analysis 
WHERE start_station_id IS NOT NULL 
  AND end_station_id IS NOT NULL
  AND start_station_id = end_station_id; 

-- returned 9475 entries. This indicates 3.3% of the member records with complete station IDs are true round trips.

-- business insight: casual users are about 3 times more likely to take a round trip than members. 
-- this indicates casual users are more likely to use bikes for leisure. Members are more likely to use bikes for commuting or one-way trips.
-- This assumes that these decisions are preferential. Further analysis would be needed to 
-- determine if this is due to availability, convenience, pricing, or other factors.
-- however, this is a good starting point for understanding user behavior with the available data.

-- ===========================================================
-- Bike Type Usage Analysis
-- This analysis compares the usage of different bike types between members and casual users.
-- We will look at the distribution of bike types used by each group.
-- ===========================================================  

-- Data quality check: count of entries with non-null bike types for members
SELECT COUNT(*) AS count, rideable_type
FROM casual_analysis 
WHERE rideable_type IS NOT NULL

-- Total of 323337 entries with non-null bike types for casual users
-- This means 100% of casual users have valid bike types

GROUP BY rideable_type;

-- Distribution of bike types for casual users
-- returned:
-- count | rideable_type
-- 109555 | classic_bike
-- 213782 | electric_bike

-- Data quality check: count of entries with non-null bike types for members
SELECT COUNT(*) AS count, rideable_type
FROM member_analysis 
WHERE rideable_type IS NOT NULL

-- Total of 440095 entries with non-null bike types for members
-- This means 100% of members have valid bike types

GROUP BY rideable_type;

-- Distribution of bike types for members
-- returned:
-- count | rideable_type
-- 155696 | classic_bike
-- 284399 | electric_bike

-- Business Insight:
-- Casual users show a preference for electric bikes, with approximately 66% of their rides being on electric bikes.
-- Members also prefer electric bikes, but to a slightly lesser extent, with about 64.6% of their rides on electric bikes.
-- This suggests that both user groups value the convenience and ease of electric bikes, but casual users may prioritize this even more, possibly due to
-- less frequent usage and a desire for a more effortless riding experience.
-- Further analysis could explore if this preference is influenced by factors such as trip distance, terrain, or demographics.;


-- ===========================================================
-- Peak Usage Times Analysis
-- This analysis examines the peak usage times for both members and casual users.
-- We will look at the distribution of trips by hour of the day and weekday vs weekend.
-- ===========================================================

-- Peak usage times for Members
SELECT 
    CASE 
        WHEN CAST(strftime('%w', started_at) AS INTEGER) IN (1, 2, 3, 4, 5) THEN 'Weekday'
        WHEN CAST(strftime('%w', started_at) AS INTEGER) IN (0, 6) THEN 'Weekend'
    END as day_type,
    CAST(strftime('%H', started_at) AS INTEGER) as hour_of_day,
    COUNT(*) as member_trips
FROM member_analysis
GROUP BY day_type, hour_of_day
ORDER BY member_trips DESC

-- top 18 results are all weekday trips generally. 
-- Top 3 are 4, 5, and 6 PM respectively
-- This indicates members are likely using bikes for commuting home from work.

-- Peak usage times for Casual Users
SELECT 
    CASE 
        WHEN CAST(strftime('%w', started_at) AS INTEGER) IN (1, 2, 3, 4, 5) THEN 'Weekday'
        WHEN CAST(strftime('%w', started_at) AS INTEGER) IN (0, 6) THEN 'Weekend'
    END as day_type,
    CAST(strftime('%H', started_at) AS INTEGER) as hour_of_day,
    COUNT(*) as casual_trips
FROM casual_analysis
GROUP BY day_type, hour_of_day
ORDER BY casual_trips DESC 

-- top 10 results are all weekday afternoon trips, but less concentrated around commute times.
-- same top 3 of 4, 5, and 6 PM respectively
-- This indicates casual users also use bikes for commuting, but likely also for other purposes.
-- it should alsobe noted that there are 5 weekdays and 2 weekend days, so the weekday data is more heavily represented.
-- This still means weekends are overperforming for casual users, indicating more leisure usage. 
-- Slightly underperforming for members compared to an expected 29% of trips on weekends.
-- Business Insight:
-- Members predominantly use bikes during weekday peak hours, especially around typical commute times (4-6 PM).
-- This suggests that members are likely using bikes for commuting purposes.
-- Casual users also show a peak during these hours but have a more distributed usage pattern throughout the day.
-- This indicates that casual users may be using bikes for a variety of purposes, including leisure activities.
-- Further analysis could explore the specific reasons for bike usage during these times, potentially through surveys or additional data collection.
