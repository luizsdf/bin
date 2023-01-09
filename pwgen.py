#!/usr/bin/env python

import string
import secrets
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('-a', '--no-lowercase', action='store_true')
parser.add_argument('-A', '--no-uppercase', action='store_true')
parser.add_argument('-n', '--no-numbers', action='store_true')
parser.add_argument('-s', '--no-symbols', action='store_true')
parser.add_argument('-l', '--length', default=16, type=int)
args = parser.parse_args()

alphabet = ''
if not args.no_lowercase:
    alphabet += string.ascii_lowercase
if not args.no_uppercase:
    alphabet += string.ascii_uppercase
if not args.no_numbers:
    alphabet += string.digits
if not args.no_symbols:
    alphabet += string.punctuation

print(''.join(secrets.choice(alphabet) for i in range(args.length)))
