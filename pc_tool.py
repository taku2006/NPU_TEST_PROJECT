#
#  PC Tool version 0.1
#

import os
import cmd
import subprocess
import socket
import time
from struct import *
import binascii
from array import *
import argparse

HOST = '169.254.255.255'    # The remote host
PORT = [0xfff0, 0xfff1, 0xfff2, 0xfff3]

class CLI(cmd.Cmd):

    def __init__(self):
        cmd.Cmd.__init__(self)
        self.prompt = "CMD> "    # define command prompt
        self.use_rawinput = False
        self.s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.s.settimeout(10)
        print(str(socket.gethostbyname_ex(socket.gethostname())))
        a = socket.gethostbyname_ex(socket.gethostname())
        ip = None
        for x in a[2]:
            if "169.254" in x:
                ip = x
        if ip is None:
            print("Not connected with NSE, or IP is not right, \
                   or Please check Fire Wall!")
            quit()
        print(ip)
        self.s.bind((ip, 0))

    def send_data(self, data, port):
        #print("send data",(data))
        #p = bytes(data, encoding="utf-8")
        #print(binascii.b2a_hex(data))
        self.s.sendto(data, (HOST, port))
        ack = self.s.recvfrom(1024)
        #print("receive data: 0x%02x%02x" % (ack[0][0], ack[0][1]))
        return ack
    
    def conver2hex(self, line):
        dp = b''
        a = []
        for x in range(63, -1, -1):
            d = line[2 * x] + line[2 * x + 1]
            #print(d)
            a.append(pack('=B', int(d, 16)))
        return dp.join(a)
    
    def do_testtx(self, arg):
        global d
        fp_ilk_in = open(d + "/txt_out/new_in.txt", 'r')
        self.send_file(fp_ilk_in,PORT[0])

    def do_testrx(self, arg):
        global d
        fp_ilk_in = open(d + "/txt_out/new_out.txt", 'r')
        self.send_file(fp_ilk_in,PORT[1])       

    def do_testtx2(self, arg):
        global d
        fp_ilk_in = open(d + "/txt_out/new_in_2.txt", 'r')
        self.send_file(fp_ilk_in,PORT[2])

    def do_testrx2(self, arg):
        global d
        fp_ilk_in = open(d + "/txt_out/new_out_2.txt", 'r')
        self.send_file(fp_ilk_in,PORT[3])
    
    def send_file(self, arg ,port):
        dp=b''
        p = b''
        k=1
        i = 1
        print(port)
        for line in arg:
            line = line.strip()
            if len(line) != 128:
                continue
            dp = self.conver2hex(line)
            p = p + dp
            #print(dp)
            if(k == 128/8) : 
                #print(p)
                #print(port)
                self.s.sendto(p, (HOST, port))
                data = self.s.recvfrom(1024)
                k = 0
                print('Port0 TX Line %d : Sent' %(i))
                i = i + 1
                p = b''
            k = k + 1
        if(k != 1):
            self.s.sendto(p, (HOST, port))
            data = self.s.recvfrom(1024)
            print('Port0 TX Line %d : Sent' %(i))

    def do_mdiow(self, arg):
        #print(arg.split())
        phy = arg.split()[0].split('.')[0]
        port = arg.split()[0].split('.')[1]
        addr = arg.split()[0].split('.')[2]
        data = arg.split()[1]
        #print("w",phy, port, addr, data)
        #print(int(phy, 16), int(port, 16),
        #      int(addr, 16), int(data, 16))
        dp = pack('=bbbHH', 1, int(phy, 16), int(port, 16),
                  socket.htons(int(addr, 16)), socket.htons(int(data, 16)))
        #print(dp, len(dp))
        print("mdiow prtad=%02x, devad=%02x, memad=%02x%02x, data=%02x%02x" % (dp[1], dp[2], dp[3], dp[4], dp[5], dp[6]))
        #print("dp: 0x%02x%02x%02x%02x%02x%02x%02x" % (dp[0], dp[1], dp[2], dp[3], dp[4], dp[5], dp[6]))
        self.send_data(dp, 0xfff4)
        #self.do_mdior(arg) 

    def do_w(self, arg):
        self.do_mdiow(arg)

    def do_mdiowb(self, arg):
        #print(arg.split())
        phy = arg.split()[0].split('.')[0]
        port = arg.split()[0].split('.')[1]
        addr = arg.split()[0].split('.')[2]
        highbit = arg.split()[1].split(':')[0]
        lowbit = arg.split()[1].split(':')[1]
        num = arg.split()[2].split('\'b')[0]
        data = arg.split()[2].split('\'b')[1]
        print("wb", phy, port, addr, highbit, lowbit, num, data)
        if(int(highbit) - int(lowbit) + 1 != int(num)):
            print("bit width is error")
            return
        #print(int(data, 2))
        dp = pack('=bbbH', 3, int(phy, 16), int(port, 16),
                  socket.htons(int(addr, 16)))
        #print(dp)
        value = self.send_data(dp, 0xfff4)
        #print("v00 = %02x" % value[0][0])
        #print("v01 = %02x" % value[0][1])
        value5 = int(value[0][0]) << 8 | int(value[0][1])
        value6 = (int(data, 2) << int(lowbit))
        value7 = value5 & ~((1<<int(highbit) + 1) - (1<<int(lowbit)))
        #print("v5=%02x, v6=%02x, v7=%02x" % (value5, value6, value7))
        value1 = value7 | ((int(data, 2) << int(lowbit)))
        #print("value1=%02x" % (value1))
        data2 = int(data, 2)
        #print("data2=%02x" % (data2))
        dp = pack('=bbbHH', 1, int(phy, 16), int(port, 16),
                  socket.htons(int(addr, 16)), socket.htons(value1))
        #print(dp)
        self.send_data(dp, 0xfff4)

 
    def do_wb(self, arg):
        self.do_mdiowb(arg) 

    def do_waitb(self, arg):
        #print(arg.split())
        phy = arg.split()[0].split('.')[0]
        port = arg.split()[0].split('.')[1]
        addr = arg.split()[0].split('.')[2]
        highbit = arg.split()[1].split(':')[0]
        lowbit = arg.split()[1].split(':')[1]
        num = arg.split()[2].split('\'b')[0]
        data = arg.split()[2].split('\'b')[1]
        print("waitb",phy, port, addr, highbit, lowbit, num, data)
        if(int(highbit) - int(lowbit) + 1 != int(num)):
            print("bit width is error")
            return
        #print(int(data, 2))
        dp = pack('=bbbH', 3, int(phy, 16), int(port, 16),
                  socket.htons(int(addr, 16)))
        #print(dp)
        i = 0
        while i != 10:
            value = self.send_data(dp, 0xfff4)
            value = int(value[0][0]) << 8 | int(value[0][1])
            value = (value & ((1 << (int(highbit) + 1)) - (1 << int(lowbit)))) >> int(lowbit)
            if(value == int(data, 2)):
                break
            time.sleep(0.5)
            i = i + 1

    def do_mdior(self, arg):
        #print(arg.split())
        phy = arg.split()[0].split('.')[0]
        port = arg.split()[0].split('.')[1]
        addr = arg.split()[0].split('.')[2]
        #print("r", phy, port, addr)
        #print(int(phy, 16), int(port, 16),
        #      int(addr, 16))
        dp = pack('=bbbH', 3, int(phy, 16), int(port, 16),
                  socket.htons(int(addr, 16)))
        #print(str(dp), len(dp))
        value = self.send_data(dp, 0xfff4)
        print("mdior prtad=%02x, devad=%02x, memad=%02x%02x, data=%02x%02x" % (dp[1], dp[2], dp[3], dp[4], value[0][0], value[0][1]))

    def do_r(self, arg):
        self.do_mdior(arg)

    def do_ldmmdio(self, arg):
        print("unknow command ldmmdio")

    def do_rdmspi(self, arg):
        print("unknow command rdmspi")

    def do_i2cw(self, arg):
        print("unknow command i2cw")

    def do_gpiow(self, arg):
        pin = arg.split()[0].strip('p')
        value = arg.split()[1]
        print("gpiow", pin, value)
        dp = pack('=bb', int(pin), int(value))
        self.send_data(dp, 0xfff5)

    def do_parse(self, arg):
        print("do parse", arg)

    def do_ldmspi(self, arg):
        print("unknow command ldmspi")

    def do_source(self, arg):
        print("do_source", arg)
        for line in open(arg):
            if not line[:-1].strip():
                pass
            elif line.strip()[0] != '#':
                self.onecmd(line)

    def do_delay(self, arg):
        num = arg.split()[0].split('\'b')[0]
        num2 = int(num)
        print("do delay",num2)
        for k in range(0, num2):
            time.sleep(0.001)
            #print("Delay")
            
    def do_exec(self, arg):
        subprocess.run(arg, shell=True)

    def do_quit(self, arg):
        quit()

    def do_file(slef, arg):
        print("do_file")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='PC Tool.')
    parser.add_argument('-d', help='specify the dir')
    #parser.add_argument('-f', help='specify the file')

    args = parser.parse_args()
    print(args.d)
    global d
    d = args.d
    cli = CLI()
    if d:
        f = open(args.d + "/test.ini", "r")
        if f:
            for line in f:
                if not line[:-1].strip():
                    pass
                elif line.strip()[0] != '#':
                    cli.onecmd(line)
        quit()
    else:
        cli.cmdloop()
        
