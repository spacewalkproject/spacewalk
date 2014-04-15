<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn"%>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean"%>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html"%>
<html:xhtml />
<html>
<head>
<meta http-equiv="Pragma" content="no-cache" />
</head>

<body>
    <%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf"%>
    <br />

    <rhn:toolbar base="h2" icon="header-power"
        helpUrl="/rhn/help/user/en-US/s2-sm-system-list.jsp#s5-sdc-provisioning-powermgnt">
        <bean:message key="kickstart.powermanagement.jsp.heading" />
    </rhn:toolbar>

    <c:if test="${fn:length(types) >= 1}">
        <html:form styleClass="form-horizontal"
            action="/systems/details/kickstart/PowerManagement.do?sid=${sid}">

            <c:set var="showRequired" value="true" />
            <c:set var="showPowerStatus" value="true" />
            <%@ include
                file="/WEB-INF/pages/common/fragments/kickstart/powermanagement-options.jspf"%>

            <div class="form-group">
                <label class="col-md-3 control-label"> <bean:message
                        key="kickstart.powermanagement.jsp.save_and" />
                </label>
                <div class="col-md-6">
                    <button type="submit" name="dispatch" class="btn btn-default"
                        value="<bean:message key="kickstart.powermanagement.jsp.get_status"/>">
                        <i class="fa fa-th-list"></i>
                        <bean:message key="kickstart.powermanagement.jsp.get_status" />
                    </button>

                    <%@ include
                        file="/WEB-INF/pages/common/fragments/kickstart/powermanagement-operations.jspf"%>
                </div>
            </div>
            <div class="form-group">
                <div class="col-md-offset-3 col-md-6">
                    <button type="submit" name="dispatch" class="btn btn-default"
                        value="<bean:message key="kickstart.powermanagement.jsp.save_only"/>">
                        <bean:message key="kickstart.powermanagement.jsp.save_only" />
                    </button>
                </div>
            </div>
        </html:form>
    </c:if>
</body>
</html>
