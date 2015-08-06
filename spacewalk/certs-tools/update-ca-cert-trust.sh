# Copyright (c) 2008--2015 Red Hat, Inc.
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
# Scripts that adds/removes RHN-ORG-TRUSTED-SSL-CERT into/from system-wide
# trusted certificates.
# The script checks if RHN-ORG-TRUSTED-SSL-CERT is present
# in /usr/share/rhn. If it's found then it's symlinked. If it's not found
# then it's ensured the symlink does not exists. Finally the trust update
# is run.
# Intended to run as post script in rhn-org-trusted-ssl-cert-*.rpm
#

CERT_DIR=/usr/share/rhn
CERT_FILE=RHN-ORG-TRUSTED-SSL-CERT
TRUST_DIR=/etc/pki/ca-trust/source/anchors

if [ -f $CERT_DIR/$CERT_FILE ]; then
    ln -sf $CERT_DIR/$CERT_FILE $TRUST_DIR
else
    rm -f $TRUST_DIR/$CERT_FILE
fi

/usr/bin/update-ca-trust extract

