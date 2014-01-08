<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<html>
    <head>
        <meta name="name" value="Systems Affected" />
    </head>
    <body>
        <%@ include file="/WEB-INF/pages/common/fragments/errata/errata-header.jspf" %>
        <h2>
            <bean:message key="confirm.jsp.header" /> ${errata.advisoryName}
        </h2>
        <p>
            <bean:message key="confirm.jsp.summary" arg0="${errata.advisoryName}" />
        </p>
        <c:set var="pageList" value="${requestScope.pageList}" />
        <html:form method="POST"
                   styleClass="form-horizontal"
                   action="errata/details/ErrataConfirmSubmit.do">
            <rhn:csrf />
            <rhn:list pageList="${requestScope.pageList}" noDataText="nosystems.message">
                <rhn:listdisplay>
                    <rhn:column header="actions.jsp.system">
                        ${current.name}
                    </rhn:column>
                    <rhn:column header="actions.jsp.basechannel">
                        ${current.channelLabels}
                    </rhn:column>
                </rhn:listdisplay>
                <div class="form-group">
                    <div class="col-md-offset-3 col-md-6">
                        <span class="help-block">
                            <bean:message key="applyerrata.disclaimer" />
                        </span>
                    </div>
                </div>
                <jsp:include page="/WEB-INF/pages/common/fragments/schedule-options.jspf"/>
                <div class="form-group">
                    <div class="col-md-offset-3 col-md-6">
                          <html:submit styleClass="btn btn-default" property="dispatch">
                            <bean:message key="confirm.jsp.confirm" />
                        </html:submit>
                    </div>
                </div>
                <html:hidden property="eid" value="${param.eid}" />
                <input type="hidden" name="use_date" value="true" />
            </rhn:list>
        </html:form>
    </body>
</html>
