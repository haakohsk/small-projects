# Adding all variations of 3179 to 08072021 and hashing it
import itertools
import hashlib

def foo(l):
    yield from itertools.product(*([l]*5)) 

for x in foo('3179'):
    print(hashlib.md5(("08072021"+"".join(x)).encode('utf-8')).hexdigest())
