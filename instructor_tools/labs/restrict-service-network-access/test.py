import socket
import pytest
import sys
import re
from contextlib import closing

inventory_file = './inventory'

with open(inventory_file) as fh:
    fstring = fh.readlines()

pattern = re.compile(r'\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}')

ls_ip = []

for line in fstring:
    ls_ip.append(pattern.search(line)[0])


for ip in ls_ip:

    print(f"testing instance {ip}")

    def test_port_22():
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        print(sys.argv)
        result =  sock.connect_ex((ip,22))
        assert result == 0

    def test_port_5000():
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        result =  sock.connect_ex((ip,5000))
        assert result == 110
