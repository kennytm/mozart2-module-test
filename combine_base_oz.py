#!/usr/bin/env python3

# Combine MVM's BaseBuilt.oz and our customized Base.oz together.

import sys
import re

base_built_path = sys.argv[1]
custom_base_path = sys.argv[2]

rx = re.compile(r'require(.+)prepare(.+)end', re.S)

with open(base_built_path, 'r') as f1, open(custom_base_path, 'r') as f2:
    content1 = f1.read()
    content2 = f2.read()

    m1 = rx.search(content1)
    m2 = rx.search(content2)

    print('functor\nrequire{0}{2}prepare{1}{3}end'.format(*(m1.groups() + m2.groups())))

