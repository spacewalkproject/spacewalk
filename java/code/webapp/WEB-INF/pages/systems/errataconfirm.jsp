<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>

<html>
    <head>
        <meta name="name" value="System Details" />
    </head>
    <body>
        <%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>
        <h2>
            <rhn:icon type="header-errata" /><bean:message key="errataconfirm.jsp.header" />
        </h2>
        <rhn:systemtimemessage server="${system}" />
        <rl:listset name="erratConfirmListSet">
            <rhn:csrf />
            <rhn:submitted />
            <rl:list width="100%" styleclass="list" emptykey="erratalist.jsp.noerrata">
                <rl:decorator name="PageSizeDecorator" />
                <rl:decorator name="ElaborationDecorator" />
                <rl:column headerkey="erratalist.jsp.type" styleclass="text-align: center;">
                    <c:if test="${current.securityAdvisory}">
                        <rhn:icon type="errata-security" />
                    </c:if>
                    <c:if test="${current.bugFix}">
                        <rhn:icon type="errata-bugfix" />
                    </c:if>
                    <c:if test="${current.productEnhancement}">
                        <rhn:icon type="errata-enhance" />
                    </c:if>
                </rl:column>
                <rl:column headerkey="erratalist.jsp.advisory">
                    <a href="/rhn/errata/details/Details.do?eid=${current.id}">
                        ${current.advisoryName}
                    </a>
                </rl:column>
                <rl:column headerkey="erratalist.jsp.synopsis">${current.advisorySynopsis}</rl:column>
                <rl:column headerkey="erratalist.jsp.updated">${current.updateDate}</rl:column>
            </rl:list>
            <div class="form-horizontal">
                <jsp:include page="/WEB-INF/pages/common/fragments/schedule-options.jspf"/>
                <div class="form-group">
                    <div class="col-md-offset-3 col-md-6">
                        <html:submit styleClass="btn btn-success" property="dispatch">
                            <bean:message key="errataconfirm.jsp.confirm" />
                        </html:submit>
                    </div>
                </div>
            </div>
            <html:hidden property="sid" value="${param.sid}" />
            <input type="hidden" name="use_date" value="true">
        </rl:listset>
    </body>
</html>
