#
# Copyright (c) 2008--2016 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
#
# Red Hat trademarks are not licensed under GPLv2. No permission is
# granted to use or replicate Red Hat trademarks that are incorporated
# in this software or its documentation.
#

import os
import pwd
import sys

def get_home_dir():
    userid = os.getuid()
    info = pwd.getpwuid(userid)
    return info[5]


# If Object1 and Object2 have any common attributes, set the attribute in Object1
# to the value of the attribute in Object2. Does not make functions or variables starting with '_' equivalent.
def make_common_attr_equal(object1, object2):

    # Go through every attribute in object1
    for attr in object1.__dict__.keys():

        # Make sure that the attribute name doesn't begin with "_"
        if len(attr) < 1 or attr[0] == "_":
            continue

        # Make sure that object2 has the attribute as well. and that it's not equal to ''.
        if attr not in object2.__dict__ or object2.__dict__[attr] == '':
            continue

        # Make sure the attributes are the same type OR that the attribute in object1 is None.
        if isinstance(object1.__dict__[attr], type(object2.__dict__[attr])) or \
        isinstance(object1.__dict__[attr], type(None)):
            if object1.__dict__[attr] != object2.__dict__[attr]:
                object1.__dict__[attr] = object2.__dict__[attr]
            else:
                continue
        else:
            continue

    return (object1, object2)


# Pylint is too stupid to understand subclasses of tuples apparently.
# This is just to make it shut up.
def tupleify_urlparse(urlparse_object):
    ret = []
    if hasattr(urlparse_object, 'scheme'):
        ret.append(urlparse_object.scheme)
        ret.append(urlparse_object.netloc)
        ret.append(urlparse_object.path)
        ret.append(urlparse_object.params)
        ret.append(urlparse_object.query)
        ret.append(urlparse_object.fragment)
    else:
        ret = [urlparse_object[i] for i in range(0, 6)]

    if sys.version_info[0] == 3:
        for i in range(0, 6):
            if not isinstance(ret[i], str):
                ret[i] = ret[i].decode('ascii')
    return tuple(ret)

if __name__ == "__main__":
    # This is just for testing purposes.
    # pylint: disable=R0903
    class class1:

        def __init__(self):
            self.a = "aaaa"

    class class2:

        def __init__(self):
            self.a = 1

    obj1 = class1()
    obj2 = class2()

    obj1, obj2 = make_common_attr_equal(obj1, obj2)

    print(obj1.a)
    print(obj2.a)
