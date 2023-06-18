USE [CoverTable]
GO

IF OBJECT_ID ( 'ABC_algorithm', 'P' ) IS NOT NULL
    DROP PROCEDURE ABC_algorithm;
	PRINT 'DELETE';
GO

CREATE PROCEDURE ABC_Algorithm  (
		@tableName VARCHAR(80), -- название таблицы с покрытием (например "Cover_Table")
		@n_bees INT = 50,
		@n_scouts INT = 5,
		@max_echops INT = 1000,
		@max_trials INT = 100,
		@n INT = 1, -- фиктивный параметр
		@m INT = 1 -- фиктивный параметр
)
AS

DECLARE @requestTable NVARCHAR(max)

SET @requestTable = 'SELECT ['+@tableName+'].I, ['+@tableName+'].J FROM ['+@tableName+']';

BEGIN
	-- создать таблицу результат (просто набор номеров вошедших рядов)
	IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'ABC_Algorithm_Result')
	BEGIN
		PRINT 'NOT EXISTS'
		Create Table ABC_Algorithm_Result (RowInCover INT);
	END
	TRUNCATE TABLE ABC_Algorithm_Result;

INSERT INTO ABC_Algorithm_Result 
	EXECUTE sp_execute_external_script @language = N'myPython',
	@script = N'
import numpy as np
import time
from copy import deepcopy
import pandas as pd

np.random.seed(42)

coverage_table = pd.read_csv("coverage_table.csv").values


n_bees = 50
n_scouts = 5
max_epochs = 1000
max_trials = 100

def initial_solution():
    return np.random.choice([0, 1], size=coverage_table.shape[0])

def evaluate_solution(solution):
    return np.sum(np.any(coverage_table[solution==1], axis=0))

def employed_bees_phase(solutions):
    for i in range(n_bees):
        if np.random.rand() < 0.8:
            k = np.random.choice(np.where(solutions[i]==0)[0])
            solutions[i][k] = 1
        if evaluate_solution(solutions[i]) != coverage_table.shape[1]:
            k = np.random.choice(np.where(solutions[i]==1)[0])
            solutions[i][k] = 0
    return solutions

def onlooker_bees_phase(solutions):
    best_solution = max(solutions, key=evaluate_solution)
    for i in range(n_bees):
        if evaluate_solution(solutions[i]) != coverage_table.shape[1]:
            solutions[i] = deepcopy(best_solution)
            k = np.random.choice(np.where(solutions[i]==1)[0])
            solutions[i][k] = 0
    return solutions

def scout_bees_phase(solutions, trials):
    for i in range(n_bees):
        if trials[i] >= max_trials:
            solutions[i] = initial_solution()
            trials[i] = 0
    return solutions

def artificial_bee_colony():
    start = time.time()
    solutions = np.array([initial_solution() for _ in range(n_bees)])
    trials = np.zeros(n_bees)
    for _ in range(max_epochs):
        solutions = employed_bees_phase(solutions)
        solutions = onlooker_bees_phase(solutions)
        solutions = scout_bees_phase(solutions, trials)
        if np.any([evaluate_solution(s) == coverage_table.shape[1] for s in solutions]):
            break
    end = time.time()
    best_solution = max(solutions, key=evaluate_solution)
    print("Время:", end - start, "секунд.")
    print("Покрытие всех столбцов достигается строками:", np.where(best_solution==1)[0])

artificial_bee_colony()
'

, @input_data_1 = @requestTable
	, @params = N'@n_bees INT, @n_scouts INT, @max_echops INT, @max_trials INT, @m INT, @n INT'
	, @n_bees = @n_bees
	, @n_scouts = @n_scouts
	, @max_echops = @max_echops
	, @max_trials = @max_trials
	, @m = @m
	, @n = @n

END;