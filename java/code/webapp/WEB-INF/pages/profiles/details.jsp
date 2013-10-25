<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html>
<body>

<%@ include file="/WEB-INF/pages/common/fragments/profile/header.jspf" %>
<div>
    <html:form action="/profiles/Details">
    <rhn:csrf />

    <div class="page-summary">
        <bean:message key="profile.table.summary"/>
    </div>

    <hr>

    <table class="table">
        <tr>
            <th nowrap="nowrap">
                <bean:message key="row.name"/>:
            </th>
            <td>
                <html:text property="name" size="40"/>
            </td>
        </tr>
        <tr>
            <th nowrap="nowrap">
                <bean:message key="row.description"/>:
            </th>
            <td>
                <html:textarea property="description" cols="50" rows="6"/>
            </td>
        </tr>
    </table>

    <div align="right">
        <hr />
        <html:submit property="edit_button">
            <bean:message key="button.update"/>
        </html:submit>
    </div>

    <html:hidden property="submitted" value="true" />
    <c:if test='${not empty param.prid}'>
        <html:hidden property="prid" value="${param.prid}" />
    </c:if>

</html:form>
</div>

</body>
</html>

