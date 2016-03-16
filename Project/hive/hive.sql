
url_cat = foreach a generate hash ,TRIM(category)   ; 
store distinctcat into 'file:///tmp/url_cat/';

url_review =  foreach a generate  hash  , url , positive, negative, totalreview; 
url_review_distict = distinct url_review;
store url_review_distict into 'file:///tmp/url_review_distict/';



--hive

CREATE EXTERNAL TABLE URL_CAT(
hash string,
category string
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
LOCATION '/tmp/url_cat/';

LOAD DATA INPATH '/tmp/url_cat/part-m-00000_copy_1' into table URL_CAT;


CREATE EXTERNAL TABLE URL_REVIEW_DISTICT(
hash string,
url string,
positive int,
negative int ,
totalreview int
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
LOCATION '/tmp/url_review_distict/';

LOAD DATA INPATH '/tmp/url_review_distict/part-r-00000' into table URL_REVIEW_DISTICT;


select count(*) from url_cat u join url_review_distict r  on u.hash = r.hash where u.category = 'political';

select u.category as cat , max(r.positive) as pos from url_cat u join url_review_distict r  on u.hash = r.hash group by u.category having pos>0;


insert overwrite  directory '/tmp/reviewfinal/'
select url_data.cat , url_data.url , url_data.pos ,
url_data.neg , url_data.total, url_data.hash
from 
(
select u.category as cat , r.positive as pos, r.url as url , 
r.negative as neg ,r.totalreview as total , r.hash as hash
from url_cat u 
join url_review_distict r  on u.hash = r.hash 
)
url_data
join (
select u.category as cat , max(r.positive) as pos from url_cat u 
join url_review_distict r  on u.hash = r.hash group by u.category having pos>0
) max_reivew 
on   max_reivew.pos = url_data.pos
where max_reivew.cat = url_data.cat
and url_data.total > 500
order by url_data.cat;
























add jar /Users/rjodhani/cdh3/hive-0.14.1-cdh3u6/lib/rank-rjodhani.jar;

create temporary function rank as 'com.education.review.hive.Rank';






SELECT url, category, value
FROM (
    SELECT positive, category, rank(category) as rank
    from url_cat u join url_review_distict r  on u.hash = r.hash
    DISTRIBUTE BY category
    SORT BY category ,positive
    limit 10
) a
WHERE rank &lt; 5
ORDER BY user, rank;



SELECT  category, rank(category) as rank
    from url_cat u 
    DISTRIBUTE BY category
    SORT BY category 
    limit 10
