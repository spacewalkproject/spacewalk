/**
 * Copyright (c) 2010 Red Hat, Inc.
 *
 * This software is licensed to you under the GNU General Public License,
 * version 2 (GPLv2). There is NO WARRANTY for this software, express or
 * implied, including the implied warranties of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
 * along with this software; if not, see
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 *
 * Red Hat trademarks are not licensed under GPLv2. No permission is
 * granted to use or replicate Red Hat trademarks that are incorporated
 * in this software or its documentation.
 */
package com.redhat.rhn.domain.kickstart;


/**
 * RegistrationType
 * @version $Rev$
 */
public enum RegistrationType {
    REACTIVATION ("reactivation"),
    DELETION ("deletion"),
    NONE ("none");
    public static final String COBBLER_VAR = "SPACEWALK_registration_type";
    private String type;
    RegistrationType(String regType) {
        type = regType;
    }

    /**
     * @return the registration type
     */
    public String getType() {
        return type;
    }

    /**
     * Find the registration type given a string
     * @param regType the string to search on
     * @return a registration type
     */
     public static RegistrationType find(String  regType) {
        return findDefault(regType, getDefault());
    }

     /**
      * Find the registration type given a string
      * @param regType the string to search on
      * @param def is not registration type is found the default will be returned
      * @return a registration type
      */
      public static RegistrationType findDefault(String  regType, RegistrationType def) {
         if (NONE.type.equals(regType)) {
             return NONE;
         }
         else if (DELETION.type.equals(regType)) {
             return DELETION;
         }
         else if (REACTIVATION.type.equals(regType)) {
             return REACTIVATION;
         }

         return def;
     }

      /**
       * @return the default registration type
       */
      public static RegistrationType getDefault() {
          return REACTIVATION;
      }
}
