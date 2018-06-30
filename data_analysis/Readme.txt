1. grap_data_v2.pl ---> collected_log_data.txt

2. aggregate_datas_v2.pl --> sample_data.txt, shuffled_data.txt, test.txt, train.txt, predict.txt

3. python3 txt2csv.py train.txt  test.txt predict.txt ---> train.csv test.csv predict.csv

4. remove "," in first line of train.csv, test.csv and predict.cs

5. python3 tf_dnn.py ----> time_prediction.txt

6. compare_real_predict.pl ---> compare_real_predict.csv 

