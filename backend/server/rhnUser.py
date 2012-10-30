#
# Copyright (c) 2008--2012 Red Hat, Inc.
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
#
# Stuff for handling Certificates and Servers
#

import re
import crypt

# Global Modules
from rhn.UserDictCase import UserDictCase
from spacewalk.common.rhnLog import log_debug, log_error
from spacewalk.common.rhnConfig import CFG
from spacewalk.common.rhnException import rhnFault, rhnException
from spacewalk.common.rhnTranslate import _

import rhnSQL
import rhnSession

class User:
    """ Main User class """
    def __init__(self, username, password):
        # compatibilty with the rest of the code
        self.username = username
        
        # placeholders for the table schemas
        # web_contact
        self.contact = rhnSQL.Row("web_contact", "id")
        self.contact["login"] = username
        self.contact["password"] = password
        self.contact["old_password"] = password
        # web_customer
        self.customer = rhnSQL.Row("web_customer", "id")
        self.customer["name"] = username
        self.customer["password"] = password
        # web_user_personal_info
        self.__init_info()
        # web_user_contact_permission
        self.__init_perms()
        # web_user_site_info
        self.__init_site()
        self._session = None
        
    def __init_info(self):
        """ init web_user_personal_info """
        # web_user_personal_info
        self.info = rhnSQL.Row("web_user_personal_info",
                                         "web_user_id")
        self.info['first_names'] =  "Valued"
        self.info['last_name'] = "Customer"
        self.info['prefix'] = "Mr."
    def __init_perms(self):
        """ init web_user_contact_permission """
        # web_user_contact_permission
        self.perms = rhnSQL.Row("web_user_contact_permission",
                                          "web_user_id")
        self.perms["email"] = "Y"
        self.perms["mail"] = "Y"
        self.perms["call"] = "Y"
        self.perms["fax"] = "Y"      
    def __init_site(self):
        """ init web_user_site_info """
        # web_user_site_info
        self.site = rhnSQL.Row("web_user_site_info", "id")
        self.site['city'] = "."
        self.site['address1'] = "."
        self.site['country'] = "US"
        self.site['type'] = "M"
        self.site['notes'] = "Entry created by Spacewalk registration process"

    def check_password(self, password):
        """ simple check for a password that might become more complex sometime """
        good_pwd = str(self.contact["password"])
        old_pwd = str(self.contact["old_password"])
        if CFG.pam_auth_service:
            # a PAM service is defined
            # We have to check the user's rhnUserInfo.use_pam_authentication
            # XXX Should we create yet another __init_blah function? 
            # since it's the first time we had to lool at rhnUserInfo, 
            # I'll assume it's not something to happen very frequently, 
            # so I'll use a query for now
            # - misa
            # 
            h = rhnSQL.prepare("""
                select ui.use_pam_authentication
                from web_contact w, rhnUserInfo ui
                where w.login_uc = UPPER(:login)
                and w.id = ui.user_id""")
            h.execute(login=self.contact["login"])
            data = h.fetchone_dict()
            if not data:
                # This should not happen
                raise rhnException("No entry found for user %s" %
                    self.contact["login"])
            if data['use_pam_authentication'] == 'Y':
                # use PAM
                import rhnAuthPAM 
                return rhnAuthPAM.check_password(self.contact["login"], 
                    password, CFG.pam_auth_service)
            # If the entry in rhnUserInfo is 'N', perform regular
            # authentication
        return check_password(password, good_pwd, old_pwd)
        
    def set_org_id(self, org_id):
        if not org_id:
            raise rhnException("Invalid org_id requested for user", org_id)
        self.contact["org_id"] = int(org_id)
        self.customer.load(int(org_id))
        
    def getid(self):
        if not self.contact.has_key("id"):
            userid = rhnSQL.Sequence("web_contact_id_seq")()
            self.contact.data["id"] = userid # kind of illegal, but hey!
        else:
            userid = self.contact["id"]
        return userid
                    
    def set_contact_perm(self, name, value):
        """ handling of contact permissions """
        if not name: return -1
        n = name.lower()
        v = 'N'
        if value:
            v = 'Y'
        if n == "contact_phone":   self.perms["call"] = v
        elif n == "contact_mail":  self.perms["mail"] = v
        elif n == "contact_email": self.perms["email"] = v
        elif n == "contact_fax":   self.perms["fax"] = v
        return 0

    def set_info(self, name, value):
        """ set a certain value for the userinfo field. This is BUTT ugly. """
        log_debug(3, name, value)
        # translation from what the client send us to real names of the fields
        # in the tables.
        mapping = {
            "first_name" : "first_names",
            "position"   : "title",
            "title"      : "prefix"
            }       
        if not name:
            return -1
        name = name.lower()
        if type(value) == type(""):
            value = value.strip()
        # We have to watch over carefully for different field names
        # being sent from rhn_register
        changed = 0

        # translation
        if name in mapping.keys():
            name = mapping[name]
        # Some fields can not have null string values
        if name in ["first_names", "last_name", "prefix", # personal_info
                    "address1", "city", "country"]:       # site_info
            # we require something of it
            if len(str(value)) == 0:
                return -1
        # fields in personal_info (and some in site)
        if name in ["last_name", "first_names",
                    "company", "phone", "fax", "email", "title"]:
            self.info[name] = value[:128]
            changed = 1            
        elif name == "prefix":
            values = ["Mr.", "Mrs.", "Ms.", "Dr.", "Hr.", "Sr.", " "]
            # Now populate a dictinary of valid values
            valids = UserDictCase()
            for v in values: # initialize from good values, with and w/o the dot
                valids[v] = v
                valids[v[:-1]] = v
            # commonly encountered values            
            valids["Miss"] = "Miss"
            valids["Herr"] = "Hr."
            valids["Sig."] = "Sr."
            valids["Sir"]  = "Mr."
            # Now check it out
            if valids.has_key(value):
                self.info["prefix"] = valids[value]
                changed = 1
            else:
                log_error("Unknown prefix value `%s'. Assumed `Mr.' instead"
                          % value)
                self.info["prefix"] = "Mr."
                changed = 1

        # fields in site
        if name in ["phone", "fax", "zip"]:
            self.site[name] = value[:32]
            changed = 1
        elif name in ["city",  "country", "alt_first_names", "alt_last_name",
                      "address1", "address2", "email",
                      "last_name", "first_names"]:
            if name == "last_name":
                self.site["alt_last_name"] = value
                changed = 1
            elif name == "first_names":
                self.site["alt_first_names"] = value
                changed = 1
            else:
                self.site[name] = value[:128]
                changed = 1
        elif name in ["state"]: # stupid people put stupid things in here too
            self.site[name] = value[:60]
            changed = 1
        if not changed:
            log_error("SET_INFO: Unknown info `%s' = `%s'" % (name, value))
        return 0

    def get_roles(self):
        user_id = self.getid()

        h = rhnSQL.prepare("""
            select ugt.label as role
              from rhnUserGroup ug,
                   rhnUserGroupType ugt,
                   rhnUserGroupMembers ugm
             where ugm.user_id = :user_id
               and ugm.user_group_id = ug.id
               and ug.group_type = ugt.id
        """)
        h.execute(user_id=user_id)
        return map(lambda x: x['role'], h.fetchall_dict() or [])
    
    def reload(self, user_id):
        """ Reload the current data from the SQL database using the given id """
        log_debug(3, user_id)

        # If we can not load these we have a fatal condition
        if not self.contact.load(user_id):
            raise rhnException("Could not find contact record for id", user_id)        
        if not self.customer.load(self.contact["org_id"]):
            raise rhnException("Could not find org record",
                               "user_id = %s" % user_id,
                               "org_id = %s" % self.contact["org_id"])        
        # These other ones are non fatal because we can create dummy records
        if not self.info.load(user_id):
            self.__init_info()           
        if not self.perms.load(user_id):
            self.__init_perms()       
        # The site info is trickier, we need to find it first
        if not self.site.load_sql("web_user_id = :userid and type = 'M'",
                                  { "userid" : user_id }):
            self.__init_site()
        # Fix the username
        self.username = self.contact['login']
        return 0

    def create_session(self):
        if self._session:
            return self._session

        self.session = rhnSession.generate(web_user_id=self.getid())
        return self.session



def auth_username_password(username, password):
    # hrm.  it'd be nice to move importlib.userAuth stuff here 
    user = search(username)

    if not user:
        raise rhnFault(2, _("Invalid username/password combination"))

    if not user.check_password(password):
        raise rhnFault(2, _("Invalid username/password combination"))

    return user


def session_reload(session_string):
    log_debug(4, session_string)
    session = rhnSession.load(session_string)
    web_user_id = session.uid
    if not web_user_id:
        raise rhnSession.InvalidSessionError("No user associated with session")

    u = User("", "")
    ret = u.reload(web_user_id)
    if ret != 0:
        # Something horked
        raise rhnFault(10)
    return u

def get_user_id(username):
    """ search for an userid """
    username = str(username)
    h = rhnSQL.prepare("""
    select w.id from web_contact w
    where w.login_uc = upper(:username)
    """)
    h.execute(username=username)
    data = h.fetchone_dict()
    if data:
        return data["id"]
    return None

def search(user):
    """ search the database for a user """
    log_debug(3, user)
    userid = get_user_id(user)
    if not userid: # no user found
        return None
    ret = User(user, "")
    if not ret.reload(userid) == 0:
        # something horked during reloading entry from database
        # we can not realy say that the entry does not exist...
        raise rhnFault(10)
    return ret

def is_user_disabled(user):
    log_debug(3, user)
    username = str(user)
    h = rhnSQL.prepare("""
    select 1 from rhnWebContactDisabled
    where login_uc = upper(:username)
    """)
    h.execute(username=username)
    row = h.fetchone_dict()
    if row:
        return 1
    return 0

def reserve_user(username, password):
    """ create a reservation record """
    return __reserve_user_db(username, password)

def __reserve_user_db(user, password):
    encrypted_password = CFG.encrypted_passwords
    log_debug(3, user, CFG.disallow_user_creation, encrypted_password, CFG.pam_auth_service)
    user = str(user)
    h = rhnSQL.prepare("""
    select w.id, w.password, w.old_password, w.org_id, ui.use_pam_authentication
    from web_contact w, rhnUserInfo ui
    where w.login_uc = upper(:p1)
    and w.id = ui.user_id
    """)
    h.execute(p1=user)
    data = h.fetchone_dict()
    if data and data["id"]:
        # contact exists, check password
        if data['use_pam_authentication'] == 'Y' and CFG.pam_auth_service:
            # We use PAM for authentication
            import rhnAuthPAM
            if rhnAuthPAM.check_password(user, password, CFG.pam_auth_service) > 0:
                return 1
            return -1

        if check_password(password, data['password'], data['old_password']) > 0:
            return 1
        return -1

    # user doesn't exist.  now we fail, instead of reserving user.
    if CFG.disallow_user_creation:
        raise rhnFault(2001)
    user, password = check_user_password(user, password)

    # now check the reserved table
    h = rhnSQL.prepare("""
    select r.login, r.password from rhnUserReserved r
    where r.login_uc = upper(:p1)
    """)
    h.execute(p1=user)
    data = h.fetchone_dict()   
    if data and data["login"]:
        # found already reserved
        if check_password(password, data["password"], None) > 0: 
            return 1
        return -2

    validate_new_username(user)
    log_debug(3, "calling validate_new_password" )
    validate_new_password(password)

    # this is not reserved either, register it
    if encrypted_password:
        # Encrypt the password, let the function pick the salt
        password = encrypt_password(password)

    h = rhnSQL.prepare("""
    insert into rhnUserReserved (login, password)
    values (:username, :password)
    """)
    h.execute(username=user, password=password)
    rhnSQL.commit()
    
    # all should be dandy
    return 0

def new_user(username, password, email, org_id, org_password):
    """ create a new user account """
    return __new_user_db(username, password, email, org_id, org_password)

def __new_user_db(username, password, email, org_id, org_password):
    encrypted_password = CFG.encrypted_passwords
    log_debug(3, username, email, encrypted_password)

    # now search it in the database        
    h = rhnSQL.prepare("""
    select w.id, w.password, w.old_password, ui.use_pam_authentication
    from web_contact w, rhnUserInfo ui
    where w.login_uc = upper(:username)
    and w.id = ui.user_id
    """)
    h.execute(username=username)
    data = h.fetchone_dict()

    pre_existing_user = 0
    
    if not data:
        # the username is not there, check the reserved user table
        h = rhnSQL.prepare("""
        select login, password, password old_password from rhnUserReserved
        where login_uc = upper(:username)
        """)
        h.execute(username=username)
        data = h.fetchone_dict()
        if not data: # nope, not reserved either
            raise rhnFault(1, _("Username `%s' has not been reserved") % username)
    else:
        pre_existing_user = 1

    if not pre_existing_user and not email:
        # New accounts have to specify an e-mail address
        raise rhnFault(30, _("E-mail address not specified"))

    # we have to perform PAM authentication if data has a field called
    # 'use_pam_authentication' and its value is 'Y', and we do have a PAM
    # service set in the config file.
    # Note that if the user is only reserved we don't do PAM authentication
    if data.get('use_pam_authentication') == 'Y' and CFG.pam_auth_service:
        # Check the password with PAM
        import rhnAuthPAM
        if rhnAuthPAM.check_password(username, password, CFG.pam_auth_service) <= 0:
            # Bad password
            raise rhnFault(2)
        # We don't care about the password anymore, replace it with something
        import time
        password = 'pam:%.8f' % time.time()
    else:
        # Regular authentication
        if check_password(password, data["password"], data["old_password"]) == 0: 
            # Bad password
            raise rhnFault(2)
        
    # creation of user was never supported in spacewalk but this call was mis-used
    # to check username/password in the past
    # so let's skip other checks and return now
    return 0


def check_user_password(username, password):
    """ Do some minimal checks on the data thrown our way. """
    # username is required
    if not username:
        raise rhnFault(11)
    # password is required
    if not password:
        raise rhnFault(12)
    if len(username) < CFG.MIN_USER_LEN:
        raise rhnFault(13, _("username should be at least %d characters")
                             % CFG.MIN_USER_LEN)
    if len(username) > CFG.MAX_USER_LEN:
        raise rhnFault(700, _("username should be less than %d characters")
                              % CFG.MAX_USER_LEN)
    username = username[:CFG.MAX_USER_LEN]

    # Invalid characters
    # ***NOTE*** Must coordinate with web and installer folks about any
    # changes to this set of characters!!!!
    invalid_re = re.compile(".*[\s&+%'`\"=#]", re.I)
    tmp = invalid_re.match(username)
    if tmp is not None:
        pos = tmp.regs[0]
        raise rhnFault(15, _("username = `%s', invalid character `%s'") % (
            username, username[pos[1]-1]))

    # use new password validation method
    validate_new_password(password)

    return username, password

def check_email(email):
    """ Do some minimal checks on the e-mail address """
    if email is not None:
        email = email.strip()

    if not email:
        # Still supported
        return None

    if len(email) > CFG.MAX_EMAIL_LEN:
        raise rhnFault(100, _("Please limit your e-mail address to %s chars") %
            CFG.MAX_EMAIL_LEN)
    # XXX More to come (check the format is indeed foo@bar.baz
    return email
    
def check_password(key, pwd1, pwd2=None):
    """ Validates the given key against the current or old password
        If encrypted_password is false, it compares key with pwd1 and pwd2
        If encrypted_password is true, it compares the encrypted key
        with pwd1 and pwd2

        Historical note: we used to compare the passwords case-insensitive, and that
        was working fine until we started to encrypt passwords. -- misa 20030530

        Old password is no longer granting access -- misa 20040205
    """
    encrypted_password = CFG.encrypted_passwords
    log_debug(4, "Encrypted password:", encrypted_password)
    # We don't trust the origin for key, so stringify it
    key = str(key)
    if len(key) == 0:
        # No zero-length passwords accepted
        return 0

    if not encrypted_password:
        # Unencrypted passwords
        if key == pwd1: # good password
            return 1
        log_debug(4, "Unencrypted password doesn't match")
        return 0 # Invalid

    # Crypted passwords in the database
    if pwd1 == encrypt_password(key, pwd1):
        # Good password
        return 1

    log_debug(4, "Encrypted password doesn't match")
    return 0 # invalid


def encrypt_password(key, salt=None):
    """ Encrypt the key
        If no salt is supplied, generates one (md5-crypt salt)
    """
    # Case insensitive key
    if not salt:
        # No salt supplied, generate it ourselves
        import base64
        import time
        import os
        # Get the first 7 digits after the decimal point from time.time(), and
        # add the pid too
        salt = (time.time() % 1) * 1e7 + os.getpid()
        # base64 it and keep only the first 8 chars
        salt = base64.encodestring(str(salt))[:8]
        # slap the magic in front of the salt
        salt = "$1$%s$" % salt
    salt = str(salt)
    return crypt.crypt(key, salt)

def validate_new_password(password):
    """ Perform all the checks required for new passwords """
    log_debug(3, "Entered validate_new_password")
    #
    # We're copying the code because we don't want to
    # invalidate any of the existing passwords.
    #

    # Validate password based on configurable length
    # regular expression
    if not password:
        raise rhnFault(12)
    if len(password) < CFG.MIN_PASSWD_LEN:
        raise rhnFault(14, _("password must be at least %d characters")
                           % CFG.MIN_PASSWD_LEN)
    if len(password) > CFG.MAX_PASSWD_LEN:
        raise rhnFault(701, _("Password must be shorter than %d characters")
                            % CFG.MAX_PASSWD_LEN)

    password = password[:CFG.MAX_PASSWD_LEN]
    invalid_re = re.compile(
        r"[^ A-Za-z0-9`!@#$%^&*()-_=+[{\]}\\|;:'\",<.>/?~]")
    asterisks_re = re.compile(r"^\**$")

    # make sure the password isn't all *'s
    tmp = asterisks_re.match(password)
    if tmp is not None:
        raise rhnFault(15, "password cannot be all asterisks '*'")

    # make sure we have only printable characters
    tmp = invalid_re.search(password)
    if tmp is not None:
        pos = tmp.regs[0]
        raise rhnFault(15, 
            _("password contains character `%s'") % password[pos[1]-1])


def validate_new_username(username):
    """ Perform all the checks required for new usernames. """
    log_debug(3)
    if len(username) < CFG.MIN_NEW_USER_LEN:
        raise rhnFault(13, _("username should be at least %d characters long")
                             % CFG.MIN_NEW_USER_LEN)
        
    disallowed_suffixes = CFG.DISALLOWED_SUFFIXES or []
    if not isinstance(disallowed_suffixes, type([])):
        disallowed_suffixes = [ disallowed_suffixes ]

    log_debug(4, "Disallowed suffixes", disallowed_suffixes)

    for suffix in disallowed_suffixes:
        if username[-len(suffix):].upper() == suffix.upper():
            raise rhnFault(106, _("Cannot register usernames ending with %s") %
                suffix)
