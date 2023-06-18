use [CoverTable]


DECLARE 
@table1 VARCHAR(80), 
@n_bees INT,
@n_scouts INT,
@max_echops INT,
@max_trials INT,
@n INT,
@m INT 

SET @n_bees = 50;
SET @n_scouts = 5;
SET @max_echops = 1000;
SET @max_trials = 100;
SET @n = 1;
SET @m = 1;

EXECUTE [CoverTable] @table1, @n_bees, @n_scouts, @max_echops, @max_trials, @m, @n;