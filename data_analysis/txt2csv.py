from __future__ import absolute_import
from __future__ import division
from __future__ import print_function

import itertools

import pandas as pd
import tensorflow as tf
import csv
import sys
tf.logging.set_verbosity(tf.logging.INFO)


def convert_txt2csv(file1, file2, file3):
	array1 = file1.split(".")
	train_file = array1[0] + ".csv"

	array2 = file2.split(".")
	test_file = array2[0] + ".csv"

	array3 = file3.split(".")
	predict_file = array3[0] + ".csv"

	with open(train_file, 'w') as csvfile:
		spamwriter = csv.writer(csvfile, dialect='excel')
		with open(file1, 'r') as filein:
			for line in filein:
				line_list = line.strip('\n').split(' ')
				spamwriter.writerow(line_list)

	with open(test_file, 'w') as csvfile:
                spamwriter = csv.writer(csvfile, dialect='excel')
                with open(file2, 'r') as filein:
                        for line in filein:
                                line_list = line.strip('\n').split(' ')
                                spamwriter.writerow(line_list)

	with open(predict_file, 'w') as csvfile:
                spamwriter = csv.writer(csvfile, dialect='excel')
                with open(file3, 'r') as filein:
                        for line in filein:
                                line_list = line.strip('\n').split(' ')
                                spamwriter.writerow(line_list)


convert_txt2csv(sys.argv[1], sys.argv[2], sys.argv[3])


