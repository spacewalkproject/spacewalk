<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>


<html:html >
<body>
    <%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

    <br/>

    <rhn:toolbar base="h2" icon="header-crash" iconAlt="info.alt.img">
        ${fn:escapeXml(crash.crash)}
    </rhn:toolbar>

    <br />
    <br />
    <%@ include file="/WEB-INF/pages/common/fragments/systems/crash-header.jspf" %>

    <div class="page-summary">
        <p><bean:message key="crashes.jsp.delete.summary"/></p>
    </div>

    <form method="POST" name="rhn_list" action="/rhn/systems/details/SoftwareCrashDelete.do">
        <rhn:csrf />
        <rhn:submitted/>

        <%@ include file="/WEB-INF/pages/common/fragments/systems/crash_details.jspf" %>

        <div class="text-right">
            <hr/>
            <html:hidden property="crid" value="${crid}"/>
            <html:hidden property="sid" value="${sid}"/>
            <html:submit property="delete_button">
                <bean:message key="crashes.jsp.delete"/>
            </html:submit>
        </div>
    </form>

</body>
</html:html>
