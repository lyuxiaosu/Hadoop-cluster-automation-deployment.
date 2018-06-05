import random
fid = open("sample_data.txt", "r")
li = fid.readlines()
fid.close()
print(li)

random.shuffle(li)
print(li)

fid = open("shuffled_data.txt", "w")
fid.writelines(li)
fid.close()
