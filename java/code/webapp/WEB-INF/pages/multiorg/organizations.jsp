<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<html>
<body>

<c:set var="pageList" value="${requestScope.pageList}" />

<rhn:toolbar base="h1" icon="header-organisation" >
  <bean:message key="organizations.jsp.toolbar"/>
</rhn:toolbar>

<h2><bean:message key="org.trust.header" arg0="${fn:escapeXml(orgName)}" arg1="${fn:escapeXml(orgId)}"/></h2>

<div>
<rl:listset name="orgListSet">
<rhn:csrf />
<rhn:submitted />
<!-- Start of org list -->
<rl:list dataset="pageList"
         width="100%"
         name="orgList"
         styleclass="list"
         filter="com.redhat.rhn.frontend.action.multiorg.OrgListFilter"
         emptykey="orglist.jsp.noOrgs">

        <!-- Organization name column -->
        <rl:column bound="false"
                   sortable="true"
                   headerkey="org.nopunc.displayname"
                   sortattr="name">
                <c:out value="<a href=\"/rhn/multiorg/OrgTrustDetails.do?oid=${current.id}\">${current.name}</a>" escapeXml="false" />
                <c:if test="${current.id == 1}">*</c:if>
        </rl:column>
        <rl:column bound="false"
                   sortable="false"
                   headerkey="org.nopunc.sharedchannels"
                   attr="sharedChannels">
            <c:choose>
            <c:when test="${current.sharedChannels > 0}">
                  <c:out value="<a href=\"/rhn/multiorg/channels/Consumed.do?oid=${current.id}\">${current.sharedChannels}</a>" escapeXml="false" />
                </c:when>
                <c:otherwise>
                  <c:out value="${current.sharedChannels}" />
                </c:otherwise>
                </c:choose>
        </rl:column>
</rl:list>

</rl:listset>
</div>

</body>
</html>

