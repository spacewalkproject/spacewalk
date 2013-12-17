<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>

<html>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/groups/header.jspf" %>

    <h2>
    <bean:message key="systemgroup.delete.title"/>
    </h2>

    <div class="page-summary">
    <p><bean:message key="systemgroup.delete.subtitle"
                  arg0="${systemgroup.name}"
                  arg1="<strong>"
                  arg2="</strong>"/></p>
    <bean:message key="systemgroup.delete.summary"
                  arg0="<strong>"
                  arg1="</strong>"/>
    </div>

        <html:form method="post"
                   action="/groups/Delete.do"
                   styleClass="form-horizontal">
            <rhn:csrf />
            <rhn:submitted/>
            <html:hidden property="sgid" value="${param.sgid}" />
            <html:submit property="delete_button" styleClass="btn">
                 <bean:message key="systemgroup.delete.confirm"/>
            </html:submit>
        </html:form>
    </body>
</html>
