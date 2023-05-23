import numpy as np

def gen_dat_random(Hi, Wi, Ci, dat_w):
    Max_val = 2 ** dat_w
	
    return np.random.randint(0, Max_val, size = (Hi, Wi, Ci)) 

def gen_dat_seq(Hi, Wi, dat_w, lineidx):
	ar_size = [Hi, Wi]
	Fi = np.empty(ar_size)
	num_set = []

	for i in range(0,10):
		num_set.append(i)
	
	j = lineidx

	for i in range(0, Hi):
		for k in range(0, Wi):
			if j > len(num_set) -1:
				j = 0
			Fi[i][k] = num_set[j]
			j = j+1
	return Fi

def write_cfile(arr):
	output_name = "Fi_data.h"
	array_name = "Fi"
	input_height, input_width, input_channels = arr.shape

	with open(output_name, "w") as file:
		file.write(f"const unsigned uint8 {array_name}[{input_channels}][{input_height}][{input_width}] = {{\n")

		# 写入数组元素
		for k in range(input_channels):
			file.write(" {")
			for i in range(input_height):
				file.write("  {")
				for j in range(input_width):
					file.write("{")
					file.write(", ".join(str(int(x)) for x in arr[i, j]))
					file.write("}")
					if j < input_width - 1:
						file.write(", ")
				file.write("}")
				if i < input_height - 1:
					file.write(",\n")
			file.write("\n};\n")
		file.write("\n};\n")

def conv_op(Fi, conv):
	Ho = 46
	Wo = 46
	Co = 3
	Fo = np.empty((Ho, Wo, Co))

	for co in range(Co):
		for ho in range(Ho):
			for wo in range(Wo):
				part_region = Fi[ho: ho+3, wo: wo+3, co]
				conv_res = np.sum(part_region * conv[:,:,co])
				Fo[ho, wo, co] = conv_res
	
	return Fo


def write_txt(arr, name, mode):

	H1, W1, C1 = arr.shape
	new_arr = arr.astype(np.int)
	with open(name, "w") as file:
		if(mode == 'Test'):
			print("---------Mode : Test------------- \n")
			file.write(f"arr_size is {H1} x {W1} x {C1} \n")
			for k in range(C1):
				file.write("{\n")
				for i in range(H1):
					for j in range(W1):
						file.write("%d " %arr[i][j][k])
					file.write(" \n")
				file.write("} \n")

		if(mode == 'Run'):
			print("---------Mode : Run------------- \n")
			for k in range(C1):
				for i in range(H1):
					#48*8
					hex_value = ''.join([format(x, '02X') for x in new_arr[i, :, k]])
					#print(hex_value)
					file.write("%s \n" %hex_value)
				file.write("--------------\n")
		
		if(mode == 'Diff'):
			print("---------Mode : Diff------------- \n")
			for k in range(C1):
				for i in range(H1):
					#48*8
					hex_value = ''.join([format(x, '04X') for x in new_arr[i, :, k]])
					#print(hex_value)
					file.write("%s \n" %hex_value)
				file.write("--------------\n")				


def diff_test(dut_name, ref_name):

	with open(ref_name,'r') as ref_file:
		content_ref = ref_file.read()

	with open(dut_name,'r') as dut_file:
		content_dut = dut_file.read()

	for line_num, (line1, line2) in enumerate(zip(content_ref, content_dut), start=1):
		line1_lower = line1.lower()
		line2_lower = line2.lower()
    # 比较两个文件内容是否一致
		if line1_lower != line2_lower:
			print("-------------------\n")
			print("--------Fail-------\n")
			print("-------------------\n")
			print(f"SOR,ERROR IN {line_num} LINE \n")
			print(f"ref line: {line_num} row:{line1}")
			print(f"dut line: {line_num} row:{line2}")
			return False
		
	print("--------PASS-------\n")
	return True



if __name__ == '__main__' :

	#Fi = gen_dat_random(48, 48, 0, 8)
	#Fo = np.random.randint(0,8,size= (4,3,2))
	#print(Fi)
	#print(Fo)
	#print(Fo.shape)
	#print(Fi.shape)
	conv = np.empty((3,3,3))
	conv[:, :, 0] = np.array(
						[[ 1,   2,  3], 
						[ 5,   6,  7], 
						[ 9,  10, 11]])

	conv[:, :, 1] = np.array(
                        [[ 3,   4,  5], 
                         [ 7,   8,  9], 
                         [11,  12, 13]])

	conv[:, :, 2] = np.array(
                        [[ 5,   6,  7], 
                         [ 8,   9, 10], 
                         [11,  12, 13]])

	Ci = 3
	F2 = np.empty((48, 48, 3))
	
	for i in range(0 , Ci):
		F2[:, :, i] = gen_dat_seq(48, 48, 8, i)
		print(F2[:, :, i])
		print("----------\n")
	
	Fo = conv_op(F2,conv)


	write_txt(F2,"Fin.txt","Test")
	write_txt(conv,"Weight.txt","Test")
	write_txt(Fo,"Fo.txt","Test")

	write_txt(F2,"../data/image.txt","Run")
	write_txt(Fo,"../data/res_ref.txt","Diff")
	write_txt(conv,"../data/weight.txt","Run")


	dut1 = diff_test("../data/res_ref1", "../data/dut_diff_o1")
	dut2 = diff_test("../data/res_ref2", "../data/dut_diff_o2")
	dut3 = diff_test("../data/res_ref3", "../data/dut_diff_o3")

	if(dut1 and dut2 and dut3):
		print("\n");
		print("                                             / \\  //\\                      ");
		print("                              |\\___/|      /   \\//  \\\\                   ");
		print("                             /0  0  \\__  /    //  | \\ \\                   ");
		print("                            /     /  \\/_/    //   |  \\  \\                 ");
		print("                            @_^_@'/   \\/_   //    |   \\   \\               ");
		print("                            //_^_/     \\/_ //     |    \\    \\             ");
		print("                         ( //) |        \\///      |     \\     \\           ");
		print("                        ( / /) _|_ /   )  //       |      \\     _\\         ");
		print("                      ( // /) '/,_ _ _/  ( ; -.    |    _ _\\.-~        .-~~~^-.                      ");
		print(" ********************(( / / )) ,-{        _      `-.|.-~-.            .~         `.                   ");
		print(" **                   (( // / ))  '/\\      /                 ~-. _ .-~      .-~^-.  \                ");
		print(" **  Congratulations!  (( /// ))      `.   {            }                    /      \  \              ");
		print(" **  Simulation Passed!  (( / ))     .----~-.\\        \\-'                .~         \  `. \^-.      ");
		print(" **                      **           ///.----..>        \\             _ -~             `.  ^-`  ^-_ ");
		print(" **************************             ///-._ _ _ _ _ _ _}^ - - - -- ~                     ~-- ,.-~  ");
		print("\n");		
	#arr = np.array(
	#	[[ 1, 2 ,3, 0xff],
	#	   [ 2 , 3, 4, 5]])
	
	#hex_value = ''.join([format(x, '02X') for x in arr[1,:]])
	#print(hex_value)
	#write_cfile(F2)


