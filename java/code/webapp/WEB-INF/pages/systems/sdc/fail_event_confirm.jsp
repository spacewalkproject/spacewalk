<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<html>
<body>

<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

<rhn:toolbar base="h2">
    <bean:message key="system.event.failheader"/>
</rhn:toolbar>
<html:form method="post"
           action="/systems/details/history/FailEventConfirmation.do?sid=${requestScope.sid}&aid=${requestScope.aid}">
    <html:hidden property="submitted" value="true"/>
    <rhn:csrf/>

    <p><bean:message key="system.event.failwarning"/></p>
    <div class="form-group col-lg-6">
        <label class="control-label">
            <rhn:required-field key = "system.event.faildescription"/>:
        </label>
        <div class="">
            <html:textarea property="description" styleClass="form-control"/>
        </div>
        <rhn:submitted/>
        <hr>
        <html:submit styleClass="btn btn-danger" property="dispatch">
            <bean:message key="system.event.failconfirm"/>
        </html:submit>
    </div>
</html:form>
</body>
</html>
