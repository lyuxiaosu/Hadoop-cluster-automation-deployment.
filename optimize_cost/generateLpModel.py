from pulp import *
prob = LpProblem("Minimize the total cost", LpMinimize)

#define varaibles
X1_1 = LpVariable("x11", 0 , None, LpInteger) # 0 is the lower bound;
X1_2 = LpVariable("x12", 0 , None, LpInteger) # 0 is the lower bound;
X1_3 = LpVariable("x13", 0 , None, LpInteger) # 0 is the lower bound;
X1_4 = LpVariable("x14", 0 , None, LpInteger) # 0 is the lower bound;
X1_5 = LpVariable("x15", 0 , None, LpInteger) # 0 is the lower bound;
X1_6 = LpVariable("x16", 0 , None, LpInteger) # 0 is the lower bound;
X1_7 = LpVariable("x17", 0 , None, LpInteger) # 0 is the lower bound;
X1_8 = LpVariable("x18", 0 , None, LpInteger) # 0 is the lower bound;
X1_9 = LpVariable("x19", 0 , None, LpInteger) # 0 is the lower bound;
X1_10 = LpVariable("x110", 0 , None, LpInteger) # 0 is the lower bound;


X2_1 = LpVariable("x21", 0 , None, LpInteger) # 0 is the lower bound;
X2_2 = LpVariable("x22", 0 , None, LpInteger) # 0 is the lower bound;
X2_3 = LpVariable("x23", 0 , None, LpInteger) # 0 is the lower bound;
X2_4 = LpVariable("x24", 0 , None, LpInteger) # 0 is the lower bound;
X2_5 = LpVariable("x25", 0 , None, LpInteger) # 0 is the lower bound;
X2_6 = LpVariable("x26", 0 , None, LpInteger) # 0 is the lower bound;
X2_7 = LpVariable("x27", 0 , None, LpInteger) # 0 is the lower bound;
X2_8 = LpVariable("x28", 0 , None, LpInteger) # 0 is the lower bound;
X2_9 = LpVariable("x29", 0 , None, LpInteger) # 0 is the lower bound;
X2_10 = LpVariable("x210", 0 , None, LpInteger) # 0 is the lower bound;

X3_1 = LpVariable("x31", 0 , None, LpInteger) # 0 is the lower bound;
X3_2 = LpVariable("x32", 0 , None, LpInteger) # 0 is the lower bound;
X3_3 = LpVariable("x33", 0 , None, LpInteger) # 0 is the lower bound;
X3_4 = LpVariable("x34", 0 , None, LpInteger) # 0 is the lower bound;
X3_5 = LpVariable("x35", 0 , None, LpInteger) # 0 is the lower bound;
X3_6 = LpVariable("x36", 0 , None, LpInteger) # 0 is the lower bound;
X3_7 = LpVariable("x37", 0 , None, LpInteger) # 0 is the lower bound;
X3_8 = LpVariable("x38", 0 , None, LpInteger) # 0 is the lower bound;
X3_9 = LpVariable("x39", 0 , None, LpInteger) # 0 is the lower bound;
X3_10 = LpVariable("x310", 0 , None, LpInteger) # 0 is the lower bound;

#define objective function
prob += 19774.881*X1_1 + 24471.31*X2_1 + 16717.104*X3_1 + 27177.372*X1_2 + 33202.692*X2_2 + 22329.936*X3_2 + 20458.839*X1_3 + 25083.648*X2_3 + 17048.586*X3_3 + 17417.687*X1_4 + 20887.671*X2_4 + 14446.229*X3_4 + 17310.744*X1_5 + 20798.928*X2_5 + 14130.432*X3_5 + 19287.639*X1_6 + 23421.393*X2_6 + 15770.7*X3_6 + 9793.549*X1_7 + 12782.815*X2_7 + 8503.371*X3_7 + 10004.67*X1_8 + 12525.804*X2_8 + 8414.184*X3_8 + 8258.058*X1_9 + 10490.292*X2_9 + 6628.382*X3_9 + 8359.04*X1_10 + 10884.22*X2_10 + 6986.624*X3_10 , "The total cost"
#add constraints (1)

prob += X1_1 + X2_1 + X3_1 <= 10, "constraint 1"
prob += X1_2 + X2_2 + X3_2 <= 10, "constraint 2"
prob += X1_3 + X2_3 + X3_3 <= 10, "constraint 3"
prob += X1_4 + X2_4 + X3_4 <= 10, "constraint 4"
prob += X1_5 + X2_5 + X3_5 <= 10, "constraint 5"
prob += X1_6 + X2_6 + X3_6 <= 10, "constraint 6"
prob += X1_7 + X2_7 + X3_7 <= 10, "constraint 7"
prob += X1_8 + X2_8 + X3_8 <= 10, "constraint 8"
prob += X1_9 + X2_9 + X3_9 <= 10, "constraint 9"
prob += X1_10 + X2_10 + X3_10 <= 10, "constraint 10"
#add constraints (2)
prob += +1767*X1_1 + 1593*X2_1 + 1880*X3_1 >= 0, "constraint 11"
prob += +1745*X1_2 + 1577* X2_2 + 1879*X3_2 >= 0, "constraint 12"
prob += +2141*X1_3 + 2059*X2_3 + 2200*X3_3 >= 0, "constraint 13"
prob += +2144*X1_4 + 2073*X2_4 + 2205*X3_4 >= 0, "constraint 14"
prob += +2259*X1_5 + 2211*X2_5 + 2303*X3_5 >= 0, "constraint 15"
prob += +2261*X1_6 + 2210*X2_6 + 2305*X3_6 >= 0, "constraint 16"
prob += +2404*X1_7 + 2375*X2_7 + 2417*X3_7 >= 0, "constraint 17"
prob += +2401*X1_8 + 2377*X2_8 + 2417*X3_8 >= 0, "constraint 18"
prob += +2432*X1_9 + 2414*X2_9 + 2445*X3_9 >= 0, "constraint 19"
prob += +2434*X1_10 + 2414*X2_10 + 2445*X3_10 >= 0, "constraint 20"
#add constraints (3)
prob += X1_1 + X1_2 + X1_3 + X1_4 + X1_5 + X1_6 + X1_7 + X1_8 + X1_9 + X1_10 == 5, "constraint 21"
prob += X2_1 + X2_2 + X2_3 + X2_4 + X2_5 + X2_6 + X2_7 + X2_8 + X2_9 + X2_10 == 4, "constraint 22"
prob += X3_1 + X3_2 + X3_3 + X3_4 + X3_5 + X3_6 + X3_7 + X3_8 + X3_9 + X3_10 == 7, "constraint 23"

prob.writeLP("problem.lp")
prob.solve()
print("Status:", LpStatus[prob.status])
for v in prob.variables():
	print(v.name, "=", v.varValue)
print("Total Cost of Ingredients per can = ", value(prob.objective))
