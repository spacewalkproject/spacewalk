<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html>

<head>
    <meta name="name" value="activationkeys.jsp.header" />
</head>

<body>
<%@ include file="/WEB-INF/pages/common/fragments/activationkeys/common-header.jspf" %>

<html:form action="/activationkeys/packages/Packages">

    <div class="page-summary">
        <p>
            <bean:message key="activation-key.packages.jsp.summary"/>
        </p>
        <h2><bean:message key="activation-key.packages.jsp.enter-names"/></h2>

        <table class="details">
            <tr>
                <td><html:textarea property="packages" rows="8" cols="64" />
            </tr>
        </table>

        <div align="right">
            <rhn:submitted/>
            <hr/>
            <input type="submit" name ="dispatch" value='<bean:message key="keyedit.jsp.submit"/>'/>
        </div>

        <html:hidden property="submitted" value="true" />
        <c:if test='${not empty param.tid}'>
            <html:hidden property="tid" value="${param.tid}" />
        </c:if>

    </div>
</html:form>

</body>
</html>

