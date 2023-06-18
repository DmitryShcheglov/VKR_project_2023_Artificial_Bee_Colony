import csv


data = []
with open('gen_test.csv', 'r') as csvfile:
    reader = csv.reader(csvfile, delimiter=',')
    for row in reader:
        data.append([int(cell) for cell in row])


max_row = max(row[0] for row in data)
max_col = max(row[1] for row in data)


matrix = [[0] * max_col for _ in range(max_row)]


for row in data:
    matrix[row[0] - 1][row[1] - 1] = 1


with open('output.csv', 'w', newline='') as csvfile:
    writer = csv.writer(csvfile)
    writer.writerow(list(range(max_col)))
    for row in matrix:
        writer.writerow(row)

print("Результат сохранен в output.csv")