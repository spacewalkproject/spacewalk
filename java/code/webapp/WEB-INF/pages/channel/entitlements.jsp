<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>

<html:xhtml/>
<html>
<head>
    <meta name="page-decorator" content="none" />
</head>
<body>

<html:messages id="message" message="true">
    <rhn:messages><c:out escapeXml="false" value="${message}" /></rhn:messages>
</html:messages>

<rhn:toolbar base="h1" img="/img/rhn-icon-channels.gif"
 helpUrl="/rhn/help/reference/en-US/s1-sm-your-rhn.jsp#s2-sm-systems-entitlements"
 imgAlt="channels.jsp.alt">
  <bean:message key="entitlements.jsp.header"/>
</rhn:toolbar>

<div class="page-summary">
    <p>
    <bean:message key="entitlements.jsp.summary"/>
    </p>
</div>

<c:set var="pageList" value="${requestScope.pageList}" />
<form method="post" name="rhn_list" action="/rhn/channels/software/EntitlementsSubmit.do">
<rhn:list pageList="${requestScope.pageList}" noDataText="entitlements.jsp.noentitlements">
  <rhn:listdisplay>
    <rhn:column header="entitlements.jsp.channel"
         url="/rhn/software/channels/ChannelFamilyTree.do?cfid=${current.id}">
        ${current.name}
    </rhn:column>
    <rhn:column header="entitlements.jsp.subscribed">
        <c:if test="${current.currentMembers == 0}">
            ${current.currentMembers}
        </c:if>
        <c:if test="${current.currentMembers > 0}">
            <a href="/network/systems/system_list/in_channel_family.pxt?cfam_id=${current.id}">
                ${current.currentMembers}</a>
        </c:if>
    </rhn:column>
    <rhn:column header="entitlements.jsp.available">
    	<c:if test="${current.orgId == null}">
	        ${current.maxMembers - current.currentMembers}
	    </c:if>
    	<c:if test="${current.orgId != null}">
	        Unlimited
	    </c:if>
        
    </rhn:column>
  </rhn:listdisplay>
</rhn:list>
</form>
</body>
</html>
