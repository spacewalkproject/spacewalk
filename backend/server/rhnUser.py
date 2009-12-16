#
# Copyright (c) 2008 Red Hat, Inc.
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
import string

# Global Modules
from common import UserDictCase, rhnFault, rhnException
from common import CFG, log_debug, log_error
from common.rhnTranslate import _

import rhnSQL
import rhnSession

# Main User class
class User:
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
        self.customer["customer_type"] = "B"
        # web_user_personal_info
        self.__init_info()
        # web_user_contact_permission
        self.__init_perms()
        # web_user_site_info
        self.__init_site()
        self._session = None
        
    # init web_user_personal_info
    def __init_info(self):
        # web_user_personal_info
        self.info = rhnSQL.Row("web_user_personal_info",
                                         "web_user_id")
        self.info['first_names'] =  "Valued"
        self.info['last_name'] = "Customer"
        self.info['prefix'] = "Mr."
    # init web_user_contact_permission
    def __init_perms(self):
        # web_user_contact_permission
        self.perms = rhnSQL.Row("web_user_contact_permission",
                                          "web_user_id")
        self.perms["email"] = "Y"
        self.perms["mail"] = "Y"
        self.perms["call"] = "Y"
        self.perms["fax"] = "Y"      
    # init web_user_site_info
    def __init_site(self):
        # web_user_site_info
        self.site = rhnSQL.Row("web_user_site_info", "id")
        self.site['city'] = "."
        self.site['address1'] = "."
        self.site['country'] = "US"
        self.site['type'] = "M"
        self.site['notes'] = "Entry created by Spacewalk registration process"

    # simple check for a password that might become more complex sometime
    def check_password(self, password):
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
                    
    # handling of contact permissions
    def set_contact_perm(self, name, value):
        if not name: return -1
        n = string.lower(name)
        v = 'N'
        if value:
            v = 'Y'
        if n == "contact_phone":   self.perms["call"] = v
        elif n == "contact_mail":  self.perms["mail"] = v
        elif n == "contact_email": self.perms["email"] = v
        elif n == "contact_fax":   self.perms["fax"] = v
        return 0

    # set a certain value for the userinfo field. This is BUTT ugly.
    def set_info(self, name, value):
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
        name = string.lower(name)
        if type(value) == type(""):
            value = string.strip(value)
        # We have to watch over carefully for different field names
        # being sent from rhn_register (up2date --register)
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
            values = ["Mr.", "Mrs.", "Ms.", "Dr.", "Hr.", "Sr."]
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

    # Save this record in the database
    def __save(self):
        is_admin = 0
        if self.customer.real:
            # get the org_id and the applicant group id for this org
            org_id = self.customer["id"]
            h = rhnSQL.prepare("""
            select ug.id
            from rhnUserGroup ug, rhnUserGroupType ugt
            where ugt.label = 'org_applicant'
            and ug.group_type = ugt.id
            and ug.org_id = :org_id
            """)
            h.execute(org_id=org_id)
            data = h.fetchone_dict()
            # XXX: prone to errors, but we'll need to see them first
            grp_id = data["id"]
        else: # an org does not exist... create one
            create_new_org = rhnSQL.Procedure("create_new_org")
            ret = create_new_org(
                self.customer["name"],
                self.customer["password"],
                None, None, "B", 
                rhnSQL.types.NUMBER(),
                rhnSQL.types.NUMBER(),
                rhnSQL.types.NUMBER(),
            )
            org_id, adm_grp_id, app_grp_id = ret[-3:]
            # We want to make sure we set the group limits right
            tbl = rhnSQL.Row("rhnUserGroup", "id")
            # Set the default admin limits to Null
            tbl.load(adm_grp_id)
            # bz:210230: this value should default to Null
            tbl.save()
            # Set the default applicats limit to 0
            tbl.load(app_grp_id)
            tbl["max_members"] = 0
            tbl.save()
            # reload the customer table
            self.customer.load(org_id)
            # and finally, we put this one in the admin group
            grp_id = adm_grp_id
            is_admin = 1
            
        # save the contact
        if self.contact.real:
            if not self.contact["org_id"]:
                raise rhnException("Undefined org_id for existing user entry",
                                   self.contact.data)
            userid = self.contact["id"]
            self.contact.save()
        else:
            userid = self.getid()
            self.contact["org_id"] = org_id
            # if not admin, obfuscate the password
            # (and leave the old_password set)
            if not is_admin: # we only do this for new users.
                log_debug(5, "Obfuscating user password")
                user_pwd = self.contact["password"]
                crypt_pwd = crypt.crypt(user_pwd, str(userid)[-2:])
                self.contact["password"] = crypt_pwd
            self.contact.create(userid)
            # rhnUserInfo
            h = rhnSQL.prepare("insert into rhnUserInfo (user_id) "
                               "values (:user_id)")
            h.execute(user_id=userid)
            # now add this user to the admin/applicant group for his org
            create_ugm = rhnSQL.Procedure("rhn_user.add_to_usergroup")
            # grp_id is the admin or the applicant, depending on whether we
            # just created the org or not
            create_ugm(userid, grp_id)
            # and now reload this data
            self.contact.load(userid)
            
        # do the same for the other structures indexed by web_user_id
        # personal info
        if self.info.real:      self.info.save()
        else:                   self.info.create(userid) 
        # contact permissions
        if self.perms.real:     self.perms.save()
        else:                   self.perms.create(userid)
            
        # And now save the site information
        if self.site.real:
            siteid = self.site["id"]
            self.site.save()
        else:
            siteid = rhnSQL.Sequence("web_user_site_info_id_seq")()
            self.site["web_user_id"] = userid            
            self.site.create(siteid)

        return 0

    def get_roles(self):
        user_id = self.getid()

        h = rhnSQL.prepare("""
            select ugt.label role
              from rhnUserGroup ug,
                   rhnUserGroupType ugt,
                   rhnUserGroupMembers ugm
             where ugm.user_id = :user_id
               and ugm.user_group_id = ug.id
               and ug.group_type = ugt.id
        """)
        h.execute(user_id=user_id)
        return map(lambda x: x['role'], h.fetchall_dict() or [])

    # This is a wrapper for the above class that allows us to rollback
    # any changes in case we don't succeed completely
    def save(self):
        log_debug(3, self.username)
        rhnSQL.commit()
        try:
            self.__save()
        except:            
            rhnSQL.rollback()
            # shoot the exception up the chain
            raise
        else:
            rhnSQL.commit()
        return 0
    
    # Reload the current data from the SQL database using the given id
    def reload(self, user_id):
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



# hrm.  it'd be nice to move importlib.userAuth stuff here
def auth_username_password(username, password):
    user = search(username)

    if not user:
        raise rhnFault(2, _("Invalid username/password combination"))

    if not user.check_password(password):
        raise rhnFault(2, _("Invalid username/password combination"))

    return user


# placeholder for future OCS user <-> org access checks
def auth_org_access(user_obj, org_id):
    if user_obj.contact["org_id"] != org_id:
        raise rhnFault(42)


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

# search for an userid
def get_user_id(username):
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

# search the database for a user
def search(user):
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

# create a reservation record
def reserve_user(username, password):
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

# create a new user account
def new_user(username, password, email, org_id, org_password):
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
        
    # From this point on, the password may be encrypted
    if encrypted_password:
        password = encrypt_password(password)

    is_real = 0
    # the password matches, do we need to create a new entry?
    if not data.has_key("id"):
        user = User(username, password)
    else: # we have to reload this entry into a User structure
        user = User(username, password)
        if not user.reload(data["id"]) == 0:
            # something horked during reloading entry from database
            # we can not really say that the entry does not exist...
            raise rhnFault(10)
        is_real = 1
        
    # now we have user reloaded, check for updated email
    if email:

        # don't update the user's email address in the satellite context...
        # we *must* in the live context, but user creation through up2date --register
        # is disallowed in the satellite context anyway...
        if not pre_existing_user:
            user.set_info("email", email)
            
    # XXX This should go away eventually
    if org_id and org_password: # check out this org
        h = rhnSQL.prepare("""
        select id, password from web_customer
        where oracle_customer_number = :org_id
        """)
        h.execute(org_id=str(org_id))
        data = h.fetchone_dict()
        if not data: # wrong organization
            raise rhnFault(2, _("Invalid Organization Credentials"))
        # The org password is not encrypted, easy comparison
        if string.lower(org_password) != string.lower(data["password"]):
            # Invalid org password
            raise rhnFault(2, _("Invalid Organization Credentials"))
        if is_real: # this is a real entry, don't clobber the org_id
            old_org_id = user.contact["org_id"]
            new_org_id  = data["id"]
            if old_org_id != new_org_id:
                raise rhnFault(42, 
                    _("User `%s' not a member of organization %s") % 
                        (username, org_id))
        else: # new user, set its org
            user.set_org_id(data["id"])
        
    # force the save if this is a new entry
    ret = user.save()
    if not ret == 0:
        raise rhnFault(5)
    # check if we need to remove the reservation
    if not data.has_key("id"):
        # remove reservation
        h = rhnSQL.prepare("""
        delete from rhnUserReserved where login_uc = upper(:username)
        """)
        h.execute(username=username)
    return 0


# Do some minimal checks on the data thrown our way
def check_user_password(username, password):
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

# Do some minimal checks on the e-mail address
def check_email(email):
    if email is not None:
        email = string.strip(email)

    if not email:
        # Still supported
        return None

    if len(email) > CFG.MAX_EMAIL_LEN:
        raise rhnFault(100, _("Please limit your e-mail address to %s chars") %
            CFG.MAX_EMAIL_LEN)
    # XXX More to come (check the format is indeed foo@bar.baz
    return email
    
def check_unique_email(email):
    return __check_unique_email_db(email)

def __check_unique_email_db(email):
    h = rhnSQL.prepare("""
        select 1
        from web_user_personal_info
        where email = :email
    """)
    h.execute(email=email)
    row = h.fetchone_dict()
    if row:
        # e-mail already exists
        raise rhnFault(102, 
            _("A user with the supplied e-mail address (%s)\n"
            "    is already registered with Red Hat Network") % email)

# Validates the given key against the current or old password
# If encrypted_password is false, it compares key with pwd1 and pwd2
# If encrypted_password is true, it compares the encrypted key
# with pwd1 and pwd2
#
# Historical note: we used to compare the passwords case-insensitive, and that
# was working fine until we started to encrypt passwords. -- misa 20030530
#
# Old password is no longer granting access -- misa 20040205
def check_password(key, pwd1, pwd2=None):
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


# Encrypt the key
# If no salt is supplied, generates one (md5-crypt salt)
def encrypt_password(key, salt=None):
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

# Perform all the checks required for new passwords
def validate_new_password(password):
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


# Perform all the checks required for new usernames
def validate_new_username(username):
    log_debug(3)
    if len(username) < CFG.MIN_NEW_USER_LEN:
        raise rhnFault(13, _("username should be at least %d characters long")
                             % CFG.MIN_NEW_USER_LEN)
        
    disallowed_suffixes = CFG.DISALLOWED_SUFFIXES or []
    if not isinstance(disallowed_suffixes, type([])):
        disallowed_suffixes = [ disallowed_suffixes ]

    log_debug(4, "Disallowed suffixes", disallowed_suffixes)

    for suffix in disallowed_suffixes:
        if string.upper(username[-len(suffix):]) == string.upper(suffix):
            raise rhnFault(106, _("Cannot register usernames ending with %s") %
                suffix)
