from __future__ import absolute_import
from __future__ import division
from __future__ import print_function

import itertools

import pandas as pd
import tensorflow as tf
from sklearn import datasets, metrics
import csv
tf.logging.set_verbosity(tf.logging.INFO)

COLUMNS = ["col1","col2","col3","col4","col5","col6","col7","col8","col9","col10","col11","col12","col13","col14","col15","col16","col17","col18","col19","col20","col21","col22","col23","col24","col25","col26","col27","col28","col29","col30","col31","col32","col33","col34","col35","col36","col37","col38","col39","col40","col41","col42","col43","col44","col45","col46","col47","col48","col49","col50","col51","col52","col53","col54","col55","col56","col57","col58","col59","col60","col61","col62","col63","col64","col65","col66","col67","col68","col69","col70","col71","col72","col73","col74","col75","col76","col77","col78","col79","col80","col81","col82","col83","col84","col85","col86","col87","col88","col89","col90","col91","col92","col93","col94","col95","col96","col97","col98","col99","col100","col101","col102","col103","col104","col105","col106","col107","col108","col109","col110","col111","col112","col113","col114","col115","col116","col117","col118","col119","col120","col121","col122","col123","col124","col125","col126","col127","col128","col129","col130","col131","col132","col133","col134","col135","col136","col137","col138","col139","col140","col141","col142","col143","col144","col145","col146","col147","col148","col149","col150","col151","col152","col153","col154","col155","col156","col157","col158","col159","col160","col161","col162","col163","col164","col165","col166","col167","col168","col169","col170","col171","col172","col173","col174","col175","col176","col177","col178","col179","col180","col181","col182","col183","col184","col185","col186","col187","col188","col189","col190","col191","col192","col193","col194","col195","col196","col197","col198","col199","col200","col201","col202","col203","col204","col205","col206","col207","col208","col209","col210","col211","col212","col213","col214"]

FEATURES = ["col1","col2","col3","col4","col5","col6","col7","col8","col9","col10","col11","col12","col13","col14","col15","col16","col17","col18","col19","col20","col21","col22","col23","col24","col25","col26","col27","col28","col29","col30","col31","col32","col33","col34","col35","col36","col37","col38","col39","col40","col41","col42","col43","col44","col45","col46","col47","col48","col49","col50","col51","col52","col53","col54","col55","col56","col57","col58","col59","col60","col61","col62","col63","col64","col65","col66","col67","col68","col69","col70","col71","col72","col73","col74","col75","col76","col77","col78","col79","col80","col81","col82","col83","col84","col85","col86","col87","col88","col89","col90","col91","col92","col93","col94","col95","col96","col97","col98","col99","col100","col101","col102","col103","col104","col105","col106","col107","col108","col109","col110","col111","col112","col113","col114","col115","col116","col117","col118","col119","col120","col121","col122","col123","col124","col125","col126","col127","col128","col129","col130","col131","col132","col133","col134","col135","col136","col137","col138","col139","col140","col141","col142","col143","col144","col145","col146","col147","col148","col149","col150","col151","col152","col153","col154","col155","col156","col157","col158","col159","col160","col161","col162","col163","col164","col165","col166","col167","col168","col169","col170","col171","col172","col173","col174","col175","col176","col177","col178","col179","col180","col181","col182","col183","col184","col185","col186","col187","col188","col189","col190","col191","col192","col193","col194","col195","col196","col197","col198","col199","col200","col201","col202","col203","col204","col205","col206","col207","col208","col209","col211","col212","col213"]


LABEL = "col214"


def get_input_fn(data_set, num_epochs=None, shuffle=True):
  return tf.estimator.inputs.pandas_input_fn(
      x=pd.DataFrame({k: data_set[k].values for k in FEATURES}),
      y=pd.Series(data_set[LABEL].values),
      num_epochs=num_epochs,
      shuffle=shuffle)

def get_mae(y_pre, y_target):
	absError = []
	for i in range(len(y_pre)):
		absError.append(abs(y_pre[i] - y_target[i]))
	return sum(absError) / len(absError)

def get_mse(y_pre, y_target):
	squaredError = []
	for i in range(len(y_pre)):
		val = y_pre[i] - y_target[i]
		squaredError.append(val * val)
	return sum(squaredError) / len (squaredError)

training_set = pd.read_csv("train.csv", skipinitialspace=True, skiprows=1, names=COLUMNS)
test_set = pd.read_csv("test.csv", skipinitialspace=True, skiprows=1, names=COLUMNS) 
predict_set = pd.read_csv("predict.csv", skipinitialspace=True, skiprows=1, names=COLUMNS) 


feature_cols = [tf.feature_column.numeric_column(k) for k in FEATURES]
regressor = tf.estimator.DNNRegressor(feature_columns=feature_cols, hidden_units=[250, 200, 100, 50], model_dir="./boston_model")

regressor.train(input_fn=get_input_fn(training_set), steps=8000)

ev = regressor.evaluate(input_fn=get_input_fn(test_set, num_epochs=1, shuffle=False))
loss_score = ev["loss"]
print("Loss: {0:f}".format(loss_score))

predict = regressor.predict(input_fn=get_input_fn(predict_set, num_epochs=1, shuffle=False))
y_predict = predict_set[LABEL].values.tolist()
print(type(y_predict))
print(y_predict)
list_predict = list(predict)
print(type(list_predict))
y_predicted = []
for i in range(len(list_predict)):
	y_predicted.append(list_predict[i]['predictions'][0])
print(y_predicted)

fileObject = open('time_prediction.txt', 'w')
for time in y_predicted:
        fileObject.write(str(time))
        fileObject.write('\n')
fileObject.close()

mae = get_mae(y_predict, y_predicted)
mse = get_mse(y_predict, y_predicted)
print("Mean Absolute Error:" + str(mae) + " Mean Squared Error:" + str(mse))

#mae = tf.metrics.mean_absolute_error(y_predict, list_predict)
#print(mea)
