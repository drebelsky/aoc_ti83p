# http://merthsoft.com/linkguide/ti83+/fformat.html
from sys import argv, exit
if len(argv) != 3:
    print("Usage: {} <input_file> <output_file>".format(argv[0]))
    exit(1)
with open(argv[1], "rb") as f:
    cdata = f.read()
data = bytearray([11, 0])
data += (len(cdata) + 2).to_bytes(2, 'little')
data += bytearray([4])
data += b"\xaa\x00\0\0\0\0\0\0"
data += bytearray([0, 0])
data += (len(cdata) + 2).to_bytes(2, 'little')
data += len(cdata).to_bytes(2, 'little')
data += cdata
with open(argv[2], "wb") as f:
    f.write(b"**TI83F*")
    f.write(bytearray([0x1A, 0x0A, 0x00]))
    f.write(b"\000"*42)
    f.write(len(data).to_bytes(2, 'little'))
    f.write(data)
    f.write((sum(data) & 0xffff).to_bytes(2, 'little'))
