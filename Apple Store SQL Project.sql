--an app developer has requested to draw some insights from data taken from the apple app store
--this will help them decide what type of app to create 
create database applestore

select * 
from AppleStore
select * 
from appleStore_description

--exploratory analysis
--check number of unique apps
select count(distinct id) 
from applestore..AppleStore
select count(distinct id) 
from appleStore_description

--check for missing values in key fields
select count(*) as missing_values 
from AppleStore
where track_name is null or 
	  user_rating is null or 
	  prime_genre is null 

select count(*) as missing_values 
from appleStore_description
where app_desc is null

--finding insights
--found out number of apps per genre
select prime_genre, count(*) as Num_of_Apps 
from AppleStore
group by prime_genre
order by Num_of_Apps desc

--get overview of app rating
select max(user_rating) as MaxRating, min(user_rating) as MinRating, round(avg(user_rating),2) as AvgRating
from applestore..AppleStore


--determine whether paid apps have a higher rating then free apps
select case
	when price > 0 then 'paid'
	else 'free'
end as App_Type, round(avg(user_rating),2) AvgRating
from applestore..AppleStore
group by case
			when price > 0 then 'paid'
			else 'free'
		end

--check if apps that support more languages have a higher rating
select case
	when lang_num < 10 then '<10 Languages'
	when lang_num between 10 and 30 then '10-30 Languages'
	else '>30 Languages'
end as language_bucket, round(avg(user_rating),2) AvgRating
from applestore..AppleStore
group by case
			when lang_num < 10 then '<10 Languages'
			when lang_num between 10 and 30 then '10-30 Languages'
			else '>30 Languages'
		end

--check genres with low ratings
select top 10 prime_genre, avg(user_rating) as Avg_Rating 
from AppleStore
group by prime_genre
order by Avg_Rating asc

--check if there is any correlation between app description length and rating
select case
	when len(b.app_desc) <500 then 'short'
	when len(b.app_desc) between 500 and 1000 then 'medium'
	else 'long'
end as description_len_bucket, round(avg(a.user_rating),2) as AvgRating
from AppleStore a
join appleStore_description b
on a.id = b.id
group by case
	when len(b.app_desc) <500 then 'short'
	when len(b.app_desc) between 500 and 1000 then 'medium'
	else 'long'
end 
order by AvgRating desc

--check top rated apps divided by genre
select prime_genre, track_name, user_rating
from (
	select prime_genre, 
		   track_name, 
		   user_rating, 
		   rank() over (partition by prime_genre order by user_rating desc, rating_count_tot desc) as rank
		   from AppleStore
		   ) as a
where a.rank = 1

--check top rated price point
select case
		when price = 0 then 'free'
		when price <= 3 then 'up to 3'
		when price <= 6 then 'up to 6'
		when price <= 10 then 'up to 10'
		else 'over 10'
	end as price_bucket, 
	round(avg(user_rating),2) AvgRating,
	count(user_rating) as num_of_ratings
from applestore..AppleStore
group by case
			when price = 0 then 'free'
			when price <= 3 then 'up to 3'
			when price <= 6 then 'up to 6'
			when price <= 10 then 'up to 10'
			else 'over 10'
		end
order by AvgRating


--conclusions
--1. Paid apps have slightly better ratings, may be caused by more enagement due to higher initial investment.
--2. Apps supporting 10-30 languages score better. Focusing on languages relevant to the app would be more beneficial than trying to include as many as possible.
--3. Categories suchs as finance, books and navigation have lower average ratings suggestings user needs are not being met. 
--4. Apps with longer descriptions have better ratings, users may8 prefer to have a better understanding of an app before downloading.
--5. The games and entertainment categries have the largest volumne of apps showing a high user demand however it may be more difficult to stand out due to more competition