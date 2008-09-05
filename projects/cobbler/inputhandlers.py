#!/usr/bin/env python
# encoding: utf-8
"""
InputHandlers.py

Created by Partha Aji on 2007-11-17.
Copyright (c) 2007 __MyCompanyName__. All rights reserved.
"""

import sys
import os
from decimal import Decimal

try:
    import readline
    readline.parse_and_bind("tab: complete")
except: pass

"""
Helper method to gather input from the console. This method has a bunch of useful addons
like validators and transformers.  Validators are a chain of objects that validate the input
and raise an exception in the case of bad data, while transformers are methods that
transform the input to int or decimals..
"""
def ask(caption, validators=[], transformers =[],
                    default = None, required=True, max_len = None):
    default_label = default and (" (default=%s)" % default) or ""
    label = caption + default_label +": "

    input = raw_input(label).strip()
    try:
        if input or not default:
            if required:
                len_check(min_len = 1)(input)
            if max_len:
                len_check(max_len = max_len)(input)
            for validate in validators:
                validate(input)
        else:
            input = default
        for transform in transformers:
            input = transform(input)
    except Exception, e:
        print "Invalid value: %s " % (e.message)
        return ask(caption, validators = validators,
                        transformers = transformers, default = default,
                        required = required, max_len = max_len)
    return input

"""
A transformer emthod to convert a string input to an integer
"""
def to_int(input):
    try:
        return int(input)
    except ValueError:
        raise Exception ('Input is not an integer')
        
        
"""
A transformer emthod to convert a string input to a float.
"""
def to_float(input):
    try:
        return float(input)
    except ValueError, e:
        raise Exception ('Input needs to be a number')

"""
A transformer emthod to convert a string input to an decimal
"""
def to_decimal(input):
    try:
        return Decimal(input)
    except:
        raise Exception ('Input needs to be a number (can be a decimal)')        

def translator(transdict = {}):
    def translate (input,transdict = transdict):
        return transdict[input]
    return translate

def yes_no_translator():
    return translator(dict(y=1, Y = 1, n =0, N = 0))
"""
Validator method to ensure the input has a max_len,  a min_len o an exact len
each of these options are used in different instances, for example if we
want the state name = 2 characters we would have exact_len = 2...
"""
def len_check(min_len = None, max_len = None, exact_len = None):
    def exact(input, length = exact_len):
        if len(input) != length:
            raise Exception ('Input needs to be exactly %d characters' % length)

    def min_check(input, length = min_len):
        if len(input) < length:
            raise Exception('Input needs to be atleast %d characters' % length)

    def max_check(input, length = max_len):
        if len(input) > length:
            raise Exception('Input needs to be atmost %d characters' % length)

    def check_both(input, min_len = min_len, max_len = max_len):
        if not min_len <= len(input) <= max_len:
            raise Exception('Input needs to be atleast %d  and atmost %d characters' % (min_len, max_len))
    if exact_len:
        return exact
    if min_len and max_len:
        return check_both
    if min_len:
        return min_check
    if max_len:
        return max_check

"""
Validator to ensure all input chars are numbers
"""
def digits_check(input):
    if not input.isdigit():
        raise Exception ('Input needs to be a number')

"""
Validator method to ensure all input chars are alpha numeric characters.. Used while generating login names.
"""
def alpha_num_check(input):
    if not input.isalnum():
        raise Exception ('Input needs to be a number or letter or a combination of both')

"""
Userful validator to ensure that the user's input conforms to a list of enum values. This is particularly
useful for Y/N inputs.. 
"""
def enum_check(enums):
    def check(input, enums = enums):
        if input not in enums:
            raise Exception('Input needs to be one of (%s)' % '/'.join(enums))
    return check

def yes_no_check():
    return enum_check(["y","n"])

"""
Ensures that the numeric value o an input falls between a given range.
"""
def range_check(min_val = None, max_val = None):
    def check(input, min_val = min_val, max_val = max_val):
        input = to_decimal(input)
        if min_val and max_val and not (min_val <= input <= max_val):
            raise Exception('Input needs to be between %d  and %d ' % (min_val, max_val))
        elif min_val and input < min_val:
            raise Exception('Input needs to be >= %d' % min_val)
        elif max_val and input > max_val:
            raise Exception('Input needs to be <= %d' % max_val)

    return check

"""
Main method to deal with Input menus. The caller provides a bunch of (key, methodName) tuples to this method.
It prints a bunch of inputs to the user and Calls the right methods whern user selections are made. 
"""
def run_inputs(keys, exit_on_return = None):
    if exit_on_return:
        keys = keys + [('Quit', None)]
    else:
        keys = keys + [('Return to previous menu', None)]
    return_key = len(keys)
    while True:
        print ""
        print "Select one of the following"
        for index, (key, value) in enumerate(keys):
            print '%d  -  %s' % (index + 1, key)
        input = ask('', validators=[range_check(1, len(keys))], transformers=[to_int])

        if input == return_key:
            print "\nYou Selected - '%s'" % keys[input - 1][0]
            if exit_on_return:
                quit()
            return
        print "\nYou Selected - '%s'" % keys[input - 1][0]
        try:
            keys[input - 1][1]()
        except Exception, e:
            print "Error: %s " % e.message

"""
Method to quit a program
"""
def quit():
    print "Good Bye"
    sys.exit()

def main():
    pass


if __name__ == '__main__':
    main()

