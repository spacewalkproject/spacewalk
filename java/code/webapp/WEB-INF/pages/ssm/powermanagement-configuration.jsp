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
        <bean:message key="ssm.provisioning.powermanagement.configuration.header" />
    </rhn:toolbar>
    <div class="page-summary">
        <p>
            <bean:message key="ssm.provisioning.powermanagement.configuration.summary" />
        </p>
    </div>


    <c:if test="${fn:length(types) >= 1}">
        <%@ include file="/WEB-INF/pages/common/fragments/ssm/system_list.jspf"%>

        <html:form styleClass="form-horizontal"
            action="/systems/ssm/provisioning/PowerManagementConfiguration.do">

            <%@ include file="/WEB-INF/pages/common/fragments/kickstart/powermanagement-options.jspf"%>

            <div class="form-group">
                <div class="col-md-offset-3 col-md-6">
                    <input type="submit" name="dispatch"
                        value="<bean:message key="ssm.provisioning.powermanagement.configuration.update" />"
                        class="btn btn-success" />
                </div>
            </div>
        </html:form>
    </c:if>
</body>
</html>
