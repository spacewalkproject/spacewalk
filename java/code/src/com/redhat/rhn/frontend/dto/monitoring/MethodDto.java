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
package com.redhat.rhn.frontend.dto.monitoring;

import com.redhat.rhn.frontend.dto.BaseDto;

/**
 * MethodDto
 * @version $Rev$
 */
public class MethodDto extends BaseDto {

    private Long recid;
    private String methodName;
    private String methodType;
    private String methodTarget;
    private String login;
    private Long userId;

    /**
     * {@inheritDoc}
     */
    public Long getId() {
        return recid;
    }

    /**
     * @return Returns the methodName.
     */
    public String getMethodName() {
        return methodName;
    }

    /**
     * @param methodNameIn The methodName to set.
     */
    public void setMethodName(String methodNameIn) {
        this.methodName = methodNameIn;
    }

    /**
     * @return Returns the methodType.
     */
    public String getMethodType() {
        return methodType;
    }

    /**
     * @param methodTypeIn The methodType to set.
     */
    public void setMethodType(String methodTypeIn) {
        this.methodType = methodTypeIn;
    }

    /**
     * @return Returns the recid.
     */
    public Long getRecid() {
        return recid;
    }

    /**
     * @param recidIn The recid to set.
     */
    public void setRecid(Long recidIn) {
        this.recid = recidIn;
    }

    /**
     * @return Returns the userId.
     */
    public Long getUserId() {
        return userId;
    }

    /**
     * @param userIdIn The userId to set.
     */
    public void setUserId(Long userIdIn) {
        this.userId = userIdIn;
    }

    /**
     * @return Returns the login.
     */
    public String getLogin() {
        return login;
    }

    /**
     * @param loginIn The login to set.
     */
    public void setLogin(String loginIn) {
        this.login = loginIn;
    }


    /**
     * @return Returns the methodTarget.
     */
    public String getMethodTarget() {
        return methodTarget;
    }


    /**
     * @param methodTargetIn The methodTarget to set.
     */
    public void setMethodTarget(String methodTargetIn) {
        this.methodTarget = methodTargetIn;
    }

}
