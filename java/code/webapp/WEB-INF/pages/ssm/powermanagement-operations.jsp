<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn"%>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl"%>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean"%>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html"%>

<html:xhtml />
<html>
<body>
    <%@ include file="/WEB-INF/pages/common/fragments/ssm/header.jspf"%>
    <rhn:toolbar base="h2" icon="header-power"
        helpUrl="/rhn/help/user/en-US/s2-sm-system-list.jsp#s5-sdc-provisioning-powermgnt">
        <bean:message key="ssm.provisioning.powermanagement.operations.header" />
    </rhn:toolbar>
    <div class="page-summary">
        <p>
            <bean:message key="ssm.provisioning.powermanagement.operations.summary" />
        </p>
    </div>

    <%@ include file="/WEB-INF/pages/common/fragments/ssm/system_list.jspf"%>

    <html:form action="/systems/ssm/provisioning/PowerManagementOperations.do">
        <rhn:csrf />
        <rhn:submitted />

        <%@ include file="/WEB-INF/pages/common/fragments/kickstart/powermanagement-operations.jspf"%>
    </html:form>
</body>
</html>
