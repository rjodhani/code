--eachCat + DELIMITER + xP.getHash() + DELIMITER + xP.getUrl() + DELIMITER + postive + DELIMITER + negative + DELIMITER + xP.getUsercount();
	
a = load '/tmp/out/' using PigStorage(',') 
	as (category:chararray ,hash:chararray, url:chararray , positive:int , negative:int ,totalreview:int );



url_cat = foreach a generate hash ,TRIM(category)   ; 
store url_cat into '/tmp/url_cat/'   ;

url_review =  foreach a generate  hash  , url , positive, negative, totalreview; 
url_review_distinct = distinct url_review;
store url_review_distinct into '/tmp/url_review_distict/'  ;

