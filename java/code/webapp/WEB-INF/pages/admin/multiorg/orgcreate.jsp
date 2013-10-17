<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html>
    <body>
        <script language="javascript" src="/javascript/display.js"></script>
        <rhn:toolbar base="h1" icon="icon-info-sign">
            <bean:message key="orgcreate.jsp.title"/>
        </rhn:toolbar>

        <html:form action="/admin/multiorg/OrgCreate" styleClass="form-horizontal">
            <rhn:csrf />
            <html:hidden property="submitted" value="true"/>
            <h4><bean:message key="orgdetails.jsp.header"/></h4>
            <div class="form-group">
                <label for="orgName" class="col-lg-3 control-label">
                    <rhn:required-field key="org.name.jsp"/>:
                </label>
                <div class="col-lg-6">
                    <html:text property="orgName" maxlength="128"
                               styleClass="form-control"
                               size="40" styleId="orgName" />
                    <span class="help-block">
                        <strong>
                            <bean:message key="tip" />
                        </strong>
                            <bean:message key="org.name.length.tip" />
                    </span>
                </div>
            </div>
            <h4><bean:message key="orgcreate.jsp.adminheader"/></h4>
            <p><bean:message key="orgcreate.header2"/></p>
            <div class="form-group">
                <label class="col-lg-3 control-label" for="login">
                    <rhn:required-field key="desiredlogin"/>:
                </label>
                <div class="col-lg-6">
                    <html:text property="login" size="15"
                               styleClass="form-control"
                               maxlength="45" styleId="login" />
                    <span class="help-block">
                        <strong><bean:message key="tip" /></strong>
                        <bean:message key="org.login.tip" arg0="${rhn:getConfig('java.min_user_len')}" /><br/>
                        <bean:message key="org.login.examples" />
                    </span>
                </div>
            </div>

            <div class="form-group">
                <label class="col-lg-3 control-label" for="desiredpass">
                    <bean:message key="desiredpass" />
                    <span name="password-asterisk" class="required-form-field">*</span>:
                </label>
                <div class="col-lg-6">
                    <html:password property="desiredpassword"
                                   size="15"
                                   styleClass="form-control"
                                   maxlength="32"
                                   styleId="desiredpass" />
                </div>
            </div>

            <div class="form-group">
                <label for="confirmpass" class="col-lg-3 control-label">
                    <bean:message key="confirmpass" />
                    <span name="password-asterisk" class="required-form-field">*</span>:
                </label>
                <div class="col-lg-6">
                    <html:password property="desiredpasswordConfirm" size="15"
                                   styleClass="form-control"
                                   maxlength="32" styleId="confirmpass"/>
                </div>
            </div>

            <div class="form-group">
                <label for="pam" class="col-lg-3 control-label">
                    <bean:message key="usercreate.jsp.pam"/>
                </label>
                <div class="col-lg-6">
                    <c:choose>
                        <c:when test="${displaypamcheckbox == 'true'}">
                            <label for="pam">
                                <html:checkbox property="usepam" onclick="toggleVisibilityByName('password-asterisk')" styleId="pam"/>
                                <bean:message key="usercreate.jsp.pam.instructions"/>
                            </label>
                            <span class="help-block">
                                <bean:message key="usercreate.jsp.pam.instructions.note"/>
                            </span>
                        </c:when>
                            <c:otherwise>
                                <bean:message key="usercreate.jsp.pam.reference"/>
                            </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <div class="form-group">
                <label for="email" class="col-lg-3 control-label">
                    <rhn:required-field key="email"/>:
                </label>
                <div class="col-lg-6">
                    <html:text property="email" size="45"
                               styleClass="form-control"
                               maxlength="128" styleId="email" />
                </div>
            </div>

            <div class="form-group">
                <label class="col-lg-3 control-label" for="firstNames">
                    <rhn:required-field key="firstNames"/>:
                </label>
                <div class="col-lg-1">
                    <html:select property="prefix" styleClass="form-control">
                        <html:options collection="availablePrefixes"
                                      property="value"
                                      labelProperty="label" />
                    </html:select>
                </div>
                <div class="col-lg-5">
                    <html:text property="firstNames" size="45"
                               styleClass="form-control"
                               maxlength="128" styleId="firstNames" />
                </div>
            </div>

            <div class="form-group">
                <label class="col-lg-3 control-label" for="lastName">
                    <rhn:required-field key="lastName"/>:
                </label>
                <div class="col-lg-6">
                    <html:text property="lastName" size="45"
                               styleClass="form-control"
                               maxlength="128" styleId="lastName"/>
                </div>
            </div>

            <div class="form-group">
                <div class="col-lg-offset-3 col-lg-6">
                    <span class="help-block">
                        <span class="required-form-field">*</span> - <bean:message key="usercreate.requiredField" />
                    </span>
                </div>
            </div>

            <div class="form-group">
                <div class="col-lg-offset-3 col-lg-6">
                    <html:submit styleClass="btn btn-success">
                        <bean:message key="orgcreate.jsp.submit"/>
                    </html:submit>
                </div>
            </div>
        </html:form>
        <%-- This makes sure that the asterisks toggle correctly. Before, they could get off
             if the user checked the usepam checkbox, submitted the form, and had errors. Then
             the form would start with the box checked but the asterisks visible.
        --%>
        <script language="javascript">
            var items = document.getElementsByName('password-asterisk');
            if (document.orgCreateForm.usepam.checked == true) {
                for (var i = 0; i < items.length; i++) {
                    items[i].style.display = "none";
                }
            }
            else {
                for (var i = 0; i < items.length; i++) {
                    items[i].style.display = "";
                }
            }
        </script>
    </body>
</html>

