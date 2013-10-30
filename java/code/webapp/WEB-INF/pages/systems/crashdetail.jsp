<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>


<html:html >
<body>
    <%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

    <br/>

    <rhn:toolbar base="h2" img="/img/rhn-icon-bug-ex.gif" imgAlt="info.alt.img"
                 deletionUrl="SoftwareCrashDelete.do?crid=${crid}&sid=${sid}"
                 deletionType="crash">
        ${fn:escapeXml(crash.crash)}
    </rhn:toolbar>

    <br />
    <br />

    <%@ include file="/WEB-INF/pages/common/fragments/systems/crash-header.jspf" %>
    <br />
    <%@ include file="/WEB-INF/pages/common/fragments/systems/crash_details.jspf" %>
</body>
</html:html>
