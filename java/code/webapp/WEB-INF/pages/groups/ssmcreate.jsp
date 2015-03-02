<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>

<html>
    <body>
        <%@ include file="/WEB-INF/pages/common/fragments/ssm/header.jspf" %>
        <h2>
            <bean:message key="systemgroup.create.header"/>
        </h2>

        <p><bean:message key="systemgroup.create.summaryssm"/></p>
	
        <html:form method="post"
                   action="/systems/ssm/groups/Create.do"
                   styleClass="form-horizontal">
            <rhn:csrf />

            <div class="form-group">
                <label class="col-lg-3 control-label" for="name">
                    <bean:message key="systemgroup.create.name"/>
                    <span class="required-form-field">*</span>:
                </label>
                <div class="col-lg-6">
                    <html:text property="name" size="30" styleId="name"
                               maxlength="64" styleClass="form-control" />
                </div>
            </div>
            <div class="form-group">
                <label class="col-lg-3 control-label" for="description">
                    <bean:message key="systemgroup.create.description" />
                    <span class="required-form-field">*</span>:
                </label>
                <div class="col-lg-6">
                    <html:textarea property="description" cols="40"
                                   styleClass="form-control"
                                   rows="4" styleId="description"/>
                </div>
            </div>

            <div class="form-group">
                <div class="col-lg-offset-3 col-lg-6">
                    <c:choose>
                        <c:when test='${empty param.sgid}'>
                            <html:submit property="create_button" styleClass="btn btn-success">
                                <bean:message key="systemgroup.create.creategroup"/>
                            </html:submit>
                        </c:when>
                        <c:otherwise>
                            <html:submit property="edit_button" styleClass="btn btn-success">
                                <bean:message key="systemgroup.edit.editgroup"/>
                            </html:submit>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
            <html:hidden property="is_ssm" value="true" />
            <html:hidden property="submitted" value="true" />
        </html:form>
    </body>
</html>
