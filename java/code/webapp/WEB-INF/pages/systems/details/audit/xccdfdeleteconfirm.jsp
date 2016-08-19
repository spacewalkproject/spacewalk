<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>


<html>

<body>

<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

<h2><bean:message key="system.audit.xccdfdeleteconfirm.jsp.overview"/></h2>

<rl:listset name="xccdfScans">
        <rhn:csrf/>
        <rhn:hidden name="sid" value="${param.sid}" />

        <rl:list dataset="pageList" name="xccdfScans">
                <rl:decorator name="ElaborationDecorator"/>

                <%@ include file="/WEB-INF/pages/common/fragments/audit/scap-list-columns.jspf" %>

                <rl:column headerkey="system.audit.xccdfdeleteconfirm.jsp.deletable">
                        <c:choose>
                                <c:when test="${current.deletable}">
                                        <rhn:icon type="item-enabled" />
                                </c:when>
                                <c:otherwise>
                                        <rhn:icon type="item-disabled" />
                                </c:otherwise>
                        </c:choose>
                </rl:column>
        </rl:list>

        <div class="text-right">
                <hr />
                <input class="btn btn-default" type="submit" name="dispatch"  value="<bean:message key='confirm.jsp.confirm'/>">
        </div>
</rl:listset>

<span class="small-text">
        <bean:message key="system.audit.xccdfdeleteconfirm.jsp.tip"/>
</span>
</body>
</html>
