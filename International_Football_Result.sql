DROP DATABASE IF EXISTS football;
CREATE DATABASE IF NOT EXISTS football;

USE football;

CREATE TABLE results (
		Match_date date,
        home_team VARCHAR(72),
        away_team VARCHAR(72), 
        home_score INT, 
        away_score INT, 
        tournament VARCHAR(128), 
        city VARCHAR(128),
        country VARCHAR(128),
        neutral VARCHAR(32));

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/results.csv'
INTO TABLE results
FIELDS TERMINATED BY ','   
LINES TERMINATED BY '\n'  
IGNORE 1 LINES;

#Total Home-wins by every team

Select home_team, count(home_team) 
from results 
where home_score>away_score 
group by home_team;

#Total Away-wins by every team
Select away_team, count(away_team) as 'Num_away_wins' 
from results where home_score<away_score 
group by home_team 
order by Num_away_wins DESC;

# Total Home-wins by every team (excluding friendly matches)
select home_team, count(home_team) as Num_home_wins 
from results 
where home_score>away_score AND tournament!='Friendly' 
group by home_team 
order by Num_home_wins DESC;

# Total Away-wins by every team (excluding friendly matches)
Select away_team, count(away_team) as Num_away_wins 
from results 
where home_score<away_score AND tournament!='Friendly' 
group by away_team 
order by Num_away_wins DESC;

# Drawn matches (excluding friendly matches)
Select home_team, count(home_team) as Num_home_wins 
from results 
where home_score=away_score AND tournament!='Friendly' 
group by home_team 
order by Num_home_wins DESC;

# Home-wins where margin is greater than or equal to 3 goals (only non-friendly)
Select home_team, count(home_team) as Num_home_wins 
from results 
where (home_score-away_score)>=3 AND tournament!='Friendly' 
group by home_team 
order by Num_home_wins DESC;

# Away-wins where margin is greater than or equal to 3 goals (only non-friendly)
Select away_team, count(away_team) as Num_away_wins 
from results 
where (away_score-home_score)>=3 AND tournament!='Friendly' 
group by away_team 
order by Num_away_wins DESC;

# Now we alter results table and add another column for assigning decades to each observation since we have a date column. 
alter table results 
add Decade INT;

select * from results;

update results
       set Decade= ( 
           CASE 
           
           when match_date >= "1870-1-1" AND match_date < "1880-1-1" then 1870 
           when match_date >= "1880-1-1" AND match_date < "1890-1-1" then 1880 
           when match_date >= "1890-1-1" AND match_date < "1900-1-1" then 1890 
           when match_date >= "1900-1-1" AND match_date < "1910-1-1" then 1900
           when match_date >= "1910-1-1" AND match_date < "1920-1-1" then 1910 
           when match_date >= "1920-1-1" AND match_date < "1930-1-1" then 1920 
           when match_date >= "1930-1-1" AND match_date < "1940-1-1" then 1930 
           when match_date >= "1940-1-1" AND match_date < "1950-1-1" then 1940 
           when match_date >= "1950-1-1" AND match_date < "1960-1-1" then 1950 
           when match_date >= "1960-1-1" AND match_date < "1970-1-1" then 1960 
           when match_date >= "1970-1-1" AND match_date < "1980-1-1" then 1970 
           when match_date >= "1980-1-1" AND match_date < "1990-1-1" then 1980 
           when match_date >= "1990-1-1" AND match_date < "2000-1-1" then 1990 
           when match_date >= "2000-1-1" AND match_date < "2010-1-1" then 2000
           when match_date >= "2010-1-1" AND match_date < "2020-1-1" then 2010
           when match_date >= "2020-1-1" AND match_date < "2030-1-1" then 2020
                    
           else True END);
           

# the team with the most wins at home for every decade
select * 
from ( select *,  ROW_NUMBER() OVER(PARTITION BY Decade ORDER BY t.Num_wins DESC)  as ranks
from ( select home_team, Decade, count(home_team) as Num_wins
from results 
where home_score>away_score AND tournament!='friendly'
group by Home_team, Decade) t) p
where p.ranks=1
ORDER BY Decade ASC, p.Num_wins DESC;

### Note: Using this query we can actually find teams with second most home wins for every decade. (Change where condition to p.abc=2) 

# the team with the most away wins for every decade
select * 
from ( select *,  ROW_NUMBER() OVER(PARTITION BY Decade ORDER BY t.Num_wins DESC)  as ranks
from ( select away_team, Decade, count(away_team) as Num_wins
from results 
where home_score<away_score AND tournament!='friendly'
group by Home_team, Decade) t ) p
where p.ranks=1
ORDER BY Decade ASC, p.Num_wins DESC;
