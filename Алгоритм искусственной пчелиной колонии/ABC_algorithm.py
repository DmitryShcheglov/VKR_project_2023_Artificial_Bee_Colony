import numpy as np
import time
from copy import deepcopy

# Случайная генерация таблицы покрытия
np.random.seed(42)
import pandas as pd

# Чтение таблицы покрытия из CSV файла
coverage_table = pd.read_csv('coverage_table.csv').values

# Параметры ABC алгоритма
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
            where_zero = np.where(solutions[i]==0)[0]
            if where_zero.size > 0:
                k = np.random.choice(where_zero)
                solutions[i][k] = 1
        if evaluate_solution(solutions[i]) != coverage_table.shape[1]:
            where_one = np.where(solutions[i]==1)[0]
            if where_one.size > 0:
                k = np.random.choice(where_one)
                solutions[i][k] = 0
    return solutions


def onlooker_bees_phase(solutions):
    best_solution = max(solutions, key=evaluate_solution)
    for i in range(n_bees):
        if evaluate_solution(solutions[i]) != coverage_table.shape[1]:
            solutions[i] = deepcopy(best_solution)
            where_one = np.where(solutions[i]==1)[0]
            if where_one.size > 0:
                k = np.random.choice(where_one)
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
    print("Time:", end - start, "seconds.")
    best_rows = np.where(best_solution==1)[0]
    print("Coverage of all columns achieved by rows:", best_rows)
    print("Length of the list:", len(best_rows))

artificial_bee_colony()