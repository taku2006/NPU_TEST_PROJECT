'''
Function:
1.opt 1: generate code like
		16'hE000 : reg_mdio_s_prdata <= dbg_rxdata_fir_err[15:0];
        16'hE001 : reg_mdio_s_prdata <= dbg_rxdata_fir_err[31:16];
        16'hE002 : reg_mdio_s_prdata <= dbg_rxdata_fir_err[47:32];
        ......
        16'hE01F : reg_mdio_s_prdata <= dbg_rxdata_fir_err[511:496];
2. opt 2: generate read register file
3. opt 3: parse ilk_in.ipf and get the counter of opcode

''' 

def fwrite_opcode(line,cnt0,cnt1,cnt2,cnt3,cnt4,cnt5):
	fp_out.write(line+"\t"+"opcode_0: "+hex(cnt0)+"\n\topcode_1: "+hex(cnt1)+"\n\topcode_2: "+hex(cnt2)+"\n\topcode_3: "+hex(cnt3)+"\n\topcode_4: "+hex(cnt4)+"\n\topcode_5: "+hex(cnt5)+"\n")
	return

opt = input("Select the options (positive integer) :")
opt = int(opt)
###generate code
if opt == 1:
	print("Select function: generate repetitive verilog code")
	signal = input("input signal name is :")
	addr_start = input("start addr is :")
	#signal = "dbg_rxdata_fir_err"
	#addr_start = "E000"
	fp_out = open("temp.v","a+")
	bit_left = 15;
	bit_right = 0;
	print ("type of bit_left is",type(bit_left))
	addr = int(addr_start,16);
	for i in range(1,33):
		print ("i is :",i)
		#print("addr is",addr)
		#print("bit range is : [%u:%u]" % (bit_left,bit_right)) 
		hex_addr = hex(addr).upper()[2:]
		print_str = "16'h" + hex_addr + " : " + "reg_mdio_s_prdata <= " + str(signal) + "[" + str(bit_left) + ":" + str(bit_right) + "];\n"
		print("print string is",print_str)
		fp_out.write(print_str)
		addr = addr + 1;
		bit_right = bit_right + 16;
		bit_left = bit_left + 16;
elif opt == 2:
	###generate read register
	print("Select function: generate read register code")
	addr_start = input("start addr is :")
	#signal = "dbg_rxdata_fir_err"
	#addr_start = "E000"
	fp_out = open("temp.v","a+")

	addr = int(addr_start,16);
	for i in range(1,33):
		print ("i is :",i)
		#print("addr is",addr)
		#print("bit range is : [%u:%u]" % (bit_left,bit_right)) 
		hex_addr = hex(addr).upper()[2:]
		print_str = "r 1f.1." + hex_addr + "\n"
		print("print string is",print_str)
		fp_out.write(print_str)
		addr = addr + 1;
elif opt == 3:
	###parse ilk_in.ipf and get counters of opcode
	print("Select function: parse ilk_in.ipf and get counters of opcode")
	file_path = input("ilk_in.ipf path is :")
	print("ILK Input file is",file_path)
	fp_in = open(file_path,"r")
	fp_out = open("opcode_res.txt","w+")
	opcode_0_cnt = 0
	opcode_1_cnt = 0
	opcode_2_cnt = 0
	opcode_3_cnt = 0
	opcode_4_cnt = 0
	opcode_5_cnt = 0
	for line in fp_in:
		#print("line is:",line)
		if line.find('opcode:0') != -1:
			#print("Find opcode:0")
			opcode_0_cnt+=1;
			fwrite_opcode(line,opcode_0_cnt,opcode_1_cnt,opcode_2_cnt,opcode_3_cnt,opcode_4_cnt,opcode_5_cnt)
		elif line.find("opcode:1") != -1:
			#print("Find opcode:1")
			opcode_1_cnt+=1;
			fwrite_opcode(line,opcode_0_cnt,opcode_1_cnt,opcode_2_cnt,opcode_3_cnt,opcode_4_cnt,opcode_5_cnt)
		elif line.find("opcode:2") != -1:
			#print("Find opcode:2")
			opcode_2_cnt+=1;
			fwrite_opcode(line,opcode_0_cnt,opcode_1_cnt,opcode_2_cnt,opcode_3_cnt,opcode_4_cnt,opcode_5_cnt)
		elif line.find("opcode:3") != -1:
			#print("Find opcode:3")
			opcode_3_cnt+=1;
			fwrite_opcode(line,opcode_0_cnt,opcode_1_cnt,opcode_2_cnt,opcode_3_cnt,opcode_4_cnt,opcode_5_cnt)
		elif line.find("opcode:4") != -1:
			#print("Find opcode:4")
			opcode_4_cnt+=1;
			fwrite_opcode(line,opcode_0_cnt,opcode_1_cnt,opcode_2_cnt,opcode_3_cnt,opcode_4_cnt,opcode_5_cnt)
		elif line.find("opcode:5") != -1:
			#print("Find opcode:5")
			opcode_5_cnt+=1;
			fwrite_opcode(line,opcode_0_cnt,opcode_1_cnt,opcode_2_cnt,opcode_3_cnt,opcode_4_cnt,opcode_5_cnt)
		else:
			pass
	fp_in.close()
	print("opcode:0 pkt number is : ",opcode_0_cnt)
	print("opcode:1 pkt number is : ",opcode_1_cnt)
	print("opcode:2 pkt number is : ",opcode_2_cnt)
	print("opcode:3 pkt number is : ",opcode_3_cnt)
	print("opcode:4 pkt number is : ",opcode_4_cnt)
	print("opcode:5 pkt number is : ",opcode_5_cnt)
else:
	print("Not supported options")

