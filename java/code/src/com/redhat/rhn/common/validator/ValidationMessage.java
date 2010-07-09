/**
 * Copyright (c) 2009--2010 Red Hat, Inc.
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
package com.redhat.rhn.common.validator;

import com.redhat.rhn.common.localization.LocalizationService;


/**
 * ValidationMessage
 * @version $Rev$
 */
public abstract class ValidationMessage {
    private String key;
    private Object[] values;

    /**
     * Construct a ValidationMessage with the proper
     * key and values
     * @param keyIn the key to use to lookup the localized string
     * @param valuesIn the values to substitute in the message
     */
     public ValidationMessage(String keyIn, Object... valuesIn) {
         this.key = keyIn;
         this.values = valuesIn;
     }

     /**
      * Construct a new ValidationMessage with the specified
      * l10n key
      * @param keyIn the key to use to lookup the localized string
      */
     public ValidationMessage(String keyIn) {
         this(keyIn, (Object[])null);
     }

     /**
      * Get the key value
      * @return String key to use to lookup the localized string
      */
      public String getKey() {
          return this.key;
      }

      /**
      * Get the values array
      * @return Object[] array of values to substitute
      */
      public Object[] getValues() {
          return values;
      }

      /** {@inheritDoc} */
      public String toString() {
          return "ValidatorMessage [Key: " + key + "]";
      }

      /**
       * Returns the Text message associated to the given key
       * @return returns the message associated to the given key
       */
      public String getMessage() {
          LocalizationService ls = LocalizationService.getInstance();
          if (values == null || values.length == 0) {
              return ls.getPlainText(key);
          }
          return ls.getPlainText(key, values);
      }

      /**
       * Returns the internationalized
       * message associated to this error
       * @return the i18ned message
       */
      public String getLocalizedMessage() {
          LocalizationService ls = LocalizationService.getInstance();
          if (values == null || values.length == 0) {
              return ls.getMessage(key);
          }
          return ls.getMessage(key, values);
      }
}
