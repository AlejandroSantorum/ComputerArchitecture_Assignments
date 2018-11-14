import sys

filename = str(sys.argv[1])
M = int(sys.argv[2])
array = []
for i in range(M):
	array.append(0)

f = open(filename, "r")
lines = f.readlines()
n_lines = len(lines)
i=0
for line in lines:
	data = line.split()
	array[i] += int(data[1])
	i = (i+1)%M

print(array)

for i in range(M):
	array[i] /= (n_lines/M)

f1 = open("pru32.txt", "w")
for i in range(M):
	f1.write(str(data[0]+" "+str(array[i])+"\n"))
