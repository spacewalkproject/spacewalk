<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>

<html>
    <body>
        <h1>
            <i class="fa spacewalk-icon-system-groups" title="system group"></i>
            <bean:message key="systemgroup.create.header"/>
            <a href="/rhn/help/reference/en-US/s1-sm-systems.jsp#s3-sm-system-group-creation" target="_new" class="help-title">
                <i class="fa fa-question-circle" title="Help Icon"></i>
            </a>
        </h1>
        <p><bean:message key="systemgroup.create.summary"/></p>
        <c:if test="${not empty emptynameordesc}">
            <div class="local-alert"><bean:message key="systemgroup.create.requirements"/><br /></div>
        </c:if>
        <c:if test="${not empty alreadyexists}">
            <div class="local-alert"><bean:message key="systemgroup.create.alreadyexists"/><br /></div>
        </c:if>
        <html:form method="post"
                   action="/groups/CreateGroup.do"
                   styleClass="form-horizontal">
            <rhn:csrf />
            <html:hidden property="submitted" value="true"/>

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

            <%--
                  <div class="text-right">
                    <hr />
                    <input type="hidden" name="pxt:trap" value="rhn:server_group_create_cb" />
                    <input type="hidden" name="redirect_to" value="/rhn/systems/SystemGroupList.do" />
                    <input type="submit" name="make_group" value="<bean:message key='systemgroup.create.creategroup'/>" />
            --%>

            <div class="form-group">
                <div class="col-lg-offset-3 col-lg-6">
                    <html:submit styleClass="btn btn-success">
                        <bean:message key="systemgroup.create.creategroup"/>
                    </html:submit>
                </div>
            </div>
        </html:form>
    </body>
</html>