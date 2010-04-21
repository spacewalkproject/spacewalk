# This Python file uses the following encoding: utf-8
#
# String constants for the RHN Register TUI/GUI.
# Copyright (c) 2000-2010 Red Hat, Inc.
#
# Author:
#       James Slagle <jslagle@redhat.com>


import gettext
_ = gettext.gettext

COPYRIGHT_TEXT        = _("Copyright © 2006--2010 Red Hat, Inc. All rights reserved.")

# Connect Window
CONNECT_WINDOW        = _("Attempting to contact the Red Hat Network server.")
CONNECT_WINDOW_TEXT   = _("We are attempting to contact the Red Hat "
                          "Network server at %s.")
CONNECT_WINDOW_TEXT2  = _("A proxy was specified at %s.")                          

# Start Window
START_REGISTER_WINDOW = _("Setting up Software updates")
START_REGISTER_TEXT   = _("This assistant will guide you through " 
                          "connecting your system to "
                          "Red Hat Network (RHN) to receive software "
                          "updates, including "
                          "security updates, to keep your system supported "
                          "and compliant.  "
                          "You will need the following at this time:\n\n"
                          " * A network connection\n"
                          " * Your Red Hat Login & password\n"
                          " * The location of a Red Hat Network Satellite "
                          "or Proxy (optional)\n\n")

# Why Register Window
WHY_REGISTER          = _("Why Should I Connect to RHN? ...")                  
WHY_REGISTER_WINDOW   = _("Why connect to Red Hat Network?")
WHY_REGISTER_TEXT     = _("Connecting your system to Red Hat Network allows you to take full "
                          "advantage of the benefits of a paid subscription, including:")
WHY_REGISTER_SEC      = _("Security & Updates:")
WHY_REGISTER_DLD      = _("Downloads & Upgrades:")
WHY_REGISTER_SUPP     = _("Support:")
WHY_REGISTER_COMP     = _("Compliance:")
WHY_REGISTER_SEC_TXT  = _("Receive the latest software updates, including security updates, keeping this "
                          "Red Hat Enterprise Linux system updated and secure.")
WHY_REGISTER_DLD_TXT  = _("Download installation images for Red Hat Enterprise Linux releases, "
                          "including new releases.")
WHY_REGISTER_SUPP_TXT = _("Access to the technical support experts at Red Hat or Red Hat's partners for help "
                          "with any issues you might encounter with this system.")
WHY_REGISTER_COMP_TXT = _("Stay in compliance with your subscription agreement "
                          "and manage subscriptions "
                          "for systems connected to your account at "
                          "http://rhn.redhat.com/.")
WHY_REGISTER_TIP      = _("Tip: Red Hat values your privacy: "
                          "http://www.redhat.com/legal/privacy_statement.html")
BACK_REGISTER         = _("Take me back to the setup process.")

# Confirm Quit Window
CONFIRM_QUIT           = _("Software update setup unsuccessful")
CONFIRM_QUIT_SURE       = _("Are you sure you don't want to connect your system to Red Hat Network? "
                           "You'll miss out on the benefits of a Red Hat Enterprise Linux subscription:\n")
CONFIRM_QUIT_WILLNOT       = _("You will not be able to take advantage of these subscription privileges without connecting "
                           "your system to Red Hat Network.\n")
CONTINUE_REGISTERING   = _("Take me back to the setup process.")
REGISTER_LATER2        = _("I'll register later.")

# Info Window
REGISTER_WINDOW   = _("Setting up software updates")
LOGIN_PROMPT      = _("Please enter your login information for the %s Red "
                    "Hat Network Satellite:\n\n")
HOSTED_LOGIN      = _("Red Hat Login:")
LOGIN             = _("Login:")
PASSWORD          = _("Password:")
LOGIN_TIP         = _("Tip: Forgot your login or password?  Contact your "
                      "Satellite's Organization Administrator.")
USER_REQUIRED     = _("Please enter a desired login.")
PASSWORD_REQUIRED = _("Please enter and verify a password.")

# Product Window
HOSTED_LOGIN_PROMPT    = _("Please enter your login information for Red "
                           "Hat Network (http://rhn.redhat.com/):\n\n")
HOSTED_LOGIN_TIP       = _("Tip: Forgot your login or password? " 
                            "Visit: https://rhn.redhat.com/rhn/sales/LoginInfo.do")
EMAIL                  = _("*Email Address:")

SYSTEM_ALREADY_REGISTERED = _("It appears this system has already been set up for software updates:")
SYSTEM_ALREADY_REGISTERED_CONT = _("Are you sure you would like to continue?")

# Send Window
SEND_WINDOW             = _("We are finished collecting information for the System Profile.\n\n"
                            "Press \"Next\" to send this System Profile to Red Hat Network.  "
                            "Click \"Cancel\" and no information will be sent.  "
                            "You can run the registration program later by "
                            "typing `rhn_register` at the command line.")

# Finish Window
FINISH_WINDOW           = _("Finish setting up software updates")
FINISH_WINDOW_TEXT_TUI  = _("You may now run 'yum update' from this system's "
                            "command line to get the latest "
                            "software updates from Red Hat Network. You will need to run this "
                            "periodically to "
                            "get the latest updates. Alternatively, you may configure this "
                            "system for automatic software updates (also known as 'auto errata update') "
                            "via the Red Hat Network web interface.  (Instructions for this are in chapter 6 "
                            "of the RHN Reference Guide, available from the 'Help' button in the main Red "
                            "Hat Network web interface.)")

# Review Window
REVIEW_WINDOW           = _("Review system subscription details")
REVIEW_WINDOW_PROMPT    = _("Please review the subscription details below:")
SUB_NUM                 = _("The installation number %s was activated during "
                            "this system's initial connection to Red Hat Network.")
SUB_NUM_RESULT          = _("Subscriptions have been activated for the following "
                            "Red Hat products/services:")
CHANNELS_TITLE          = _("Software channel subscriptions:")
OK_CHANNELS             = _("This system will receive updates from the "
                            "following Red Hat Network software channels:")
CHANNELS_SAT_WARNING    = _("Warning: If an installed product on this system "
                            "is not listed above, you "
                            "will not receive updates or support for that "
                            "product. If you would like "
                            "to receive updates for that product, please "
                            "login to your satellite web interface "
                            "and subscribe this system to the appropriate "
                            "software channels to get updates for that "
                            "product. See Kbase article 6227 "
                            "for more details. "
                            "(http://kbase.redhat.com/faq/FAQ_58_6227.shtm)")
CHANNELS_HOSTED_WARNING = _("Warning: If an installed product on this system "
                            "is not listed above, you "
                            "will not receive updates or support for that "
                            "product. If you would like "
                            "to receive updates for that product, please "
                            "visit http://rhn.redhat.com/ "
                            "and subscribe this system to the appropriate "
                            "software channels to get updates for that "
                            "product. See Kbase article 6227 "
                            "for more details. "
                            "(http://kbase.redhat.com/faq/FAQ_58_6227.shtm)")
FAILED_CHANNELS         = _("You were unable to be subscribed to the following "
                            "software channels because there were insufficient "
                            "subscriptions available in your account:")
NO_BASE_CHANNEL            = _(
"This system was unable to subscribe to any software channels. Your system "
"will not receive any software updates to keep it secure and supported. There "
"are a few things you can try to resolve this situation:\n(1) Log in to "
"http://rhn.redhat.com/ and unentitle an inactive system at "
"Your RHN > Subscription Management > System Entitlements.\n"
"(2) Purchase an additional Red Hat Enterprise Linux subscription at "
"http://www.redhat.com/store/.\n(3) Activate a new "
"installation number at http://www.redhat.com/now/. Once you make the "
"appropriate active subscriptions available in your account, you may browse "
"to this system's profile in the RHN web interface and subscribe this system "
"to software channels via the software > software channels tab.")
SLOTS_TITLE             = _("RHN service level:")
OK_SLOTS                = _("Depending on what RHN modules are associated with a system, you'll "
                            "enjoy different benefits of Red Hat Network. The following are the "
                            "RHN modules associated with this system:")
SLOTS                   =  SLOTS_TITLE + "\n" + OK_SLOTS + "\n%s"
FAILED_SLOTS            = _("This system was unable to be associated with the "
                            "following RHN module(s) because there were "
                            "insufficient subscriptions available in your account:")
UPDATES                 = _("Update module: per-system updates, email errata "
                            "notifications, errata information")
MANAGEMENT              = _("Management module: automatic updates, systems "
                            "grouping, systems permissions, system package profiling")
PROVISIONING            = _("Provisioning module: bare-metal provisioning, existing state provisioning, "
                            "rollbacks, configuration management")
MONITORING              = _("Monitoring module: pre-defined and custom system " 
                            "performance probes, system performance email "
                            "notifications, graphs of system performance")

VIRT = _("Virtualization module: software updates for a limited number of "
        "virtual guests on this system.")

VIRT_PLATFORM = _("Virtualization Platform module: software updates for an "
        "unlimited number virtual guests of this system, access to additional "
        "software channels for guests of this system.")

VIRT_FAILED = _("<b>Warning:</b> Any guest systems you create on this system "
        "and register to RHN will consume Red Hat Enterprise Linux "
        "subscriptions beyond this host system's subscription. You will need "
        "to: (1) make a virtualization or virtualization platform system "
        "entitlement available and (2) apply that system entitlement to this "
        "system in RHN's web interface if you do not want virtual guests of "
        "this system to consume additional subscriptions.")

NO_SYS_ENTITLEMENT         = _("This system was unable to be associated with "
"any RHN service level modules. This system will not receive any software "
"updates to keep it secure and supported. There "
"are a few things you can try to resolve this situation:\n(1) Log in to "
"http://rhn.redhat.com/ and unentitle an inactive system at "
"Your RHN > Subscription Management > System Entitlements.\n"
"(2) Purchase an additional Red Hat Enterprise Linux subscription at "
"http://www.redhat.com/store/.\n(3) Activate a new "
"installation number at http://www.redhat.com/now/. Once you make the "
"appropriate active subscriptions available in your account, you may browse "
"to this system's profile in the RHN web interface, delete the profile, and "
"re-connect this system to Red Hat Network.")
ACTIVATION_KEY          = _("Universal default activation key detected\n"
                            "A universal default activation key was detected in your RHN organization. "
                            "What this means is that a set of properties (software channel subscriptions, " 
                            "Red Hat Network service, package installations, system group memberships, etc.) "
                            "for your system's connection to Red Hat Network "
                            "have been determined by the activation key rather than your "
                            "installation number.  " 
                            "You may also refer to the RHN Reference Guide, section 6.4.6 for more details "
                            "about activation keys (http://rhn.redhat.com/rhn/help/reference/)\n"
                            "Universal Default activation key: %s")

# Error Messages.
FATAL_ERROR                = _("Fatal Error")
WARNING                    = _("Warning")
HOSTED_CONNECTION_ERROR    = _("We can't contact the Red Hat Network Server.\n\n"
                               "Double check the location provided - is '%s' correct?\n"
                               "If not, you can correct it and try again.\n\n"
                               "Make sure that the network connection on this system is operational.\n\n"
                               "This system will not be able to successfully receive software updates "
                               "from Red Hat without connecting to a Red Hat Network server")

BASECHANNELERROR           = _("Architecture: %s, OS Release: %s, OS "
                               "Version: %s")
SERVER_TOO_OLD             = _("This server doesn't support functionality "
                               "needed by this version of the software update"
                               " setup client. Please try again with a newer "
                               "server.")


SSL_CERT_ERROR_MSG         = _("<b><span size=\"16000\">Incompatible Certificate File</span></b>\n\n"
                               "The certificate you provided, <b>%s</b>, is not compatible with "
                               " the Red Hat Network server at <b>%s</b>. You may want to double-check"
                               " that you have provided a valid certificate file."
                               " Are you sure you have provided the correct certificate, and that" 
                               " the certificate file has not been corrupted?\n\n"
                               "Please try again with a different certificate file.")

SSL_CERT_EXPIRED           = _("<b><span size=\"12000\">Incompatible Certificate File</span></b>\n\n"
                               " The certificate is expired. Please ensure you have the correct "
                               " certificate and your system time is correct.")

SSL_CERT_FILE_NOT_FOUND_ERRER = _("Please verify the value of sslCACert in "
                                  "/etc/sysconfig/rhn/up2date")

ACT_KEY_USAGE_LIMIT_ERROR = _("Problem registering system.\n\n"
                              "A universal default activation key limits the "
                              "number of systems which can connect to "
                              "the RHN organization associated with your "
                              "login. To allow this system to connect, "
                              "please contact your RHN organization "
                              "administrator to increase the number of "
                              "systems allowed to connect or to disable "
                              "this universal default activation key. "
                              "More details can be found in Red Hat "
                              "Knowledgebase Article #7924 at "
                              "http://kbase.redhat.com/faq/FAQ_61_7924.shtm ")

CHANNEL_PAGE_TIP       = _("\n Tip: Minor releases with a '*' are currently"
                           " supported by Red Hat.\n\n")

CHANNEL_PAGE_WARNING = _("Warning:You will not be able to limit this"
                          " system to minor release that is older than"
                          " the recent minor release if you select this"
                          " option.\n")
 
CONFIRM_OS_WARNING      = _("Your system will be subscribed to %s \n"
                            "base software channel. You will not be\n"
                            "able to move this system to an earlier\n"
                            "(you will be able to move to a newer release.)\n"
                            "Are you sure you Would like to Continue?")



# Navigation
OK        = _("OK")
ERROR     = _("Error")
NEXT      = _("Next")
BACK      = _("Back")
CANCEL    = _("Cancel")
NO_CANCEL = _("No, Cancel")
YES_CONT  = _("Yes, Continue")
DESELECT  = _("Press <space> to deselect the option.")


