<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>


<html:xhtml/>
<html>
<head>
    <meta name="page-decorator" content="none" />
</head>
<body>
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
<rl:listset  name="entitlements">
  <rl:list emptykey="entitlements.jsp.noentitlements">


    <rl:column headerkey="entitlements.jsp.channel"
          styleclass="first-column"
          sortattr="name"
          filterattr="name"
          defaultsort="asc"
          width="40%">
        <a href="/rhn/software/channels/ChannelFamilyTree.do?cfid=${current.id}">${current.name}</a>
    </rl:column>

    <rl:column headerkey="entitlements.jsp.consumed" >
        <c:if test="${current.currentMembers == 0}">
            ${current.currentMembers}
        </c:if>
        <c:if test="${current.currentMembers > 0}">
            <a href="/network/systems/system_list/in_channel_family.pxt?cfam_id=${current.id}">
                ${current.currentMembers}</a>
        </c:if>
    </rl:column>

    <rl:column headerkey="entitlements.jsp.available" 	>
    	<c:if test="${current.orgId == null}">
	        ${current.maxMembers - current.currentMembers}
	    </c:if>
    	<c:if test="${current.orgId != null}">
	        Unlimited
	    </c:if>
    </rl:column>

    <rl:column headerkey="entitlements.jsp.subscribed_flex"  >
            ${current.currentFlex}
    </rl:column>

    <rl:column headerkey="entitlements.jsp.avaible_flex" >
	<c:if test="${current.orgId == null}">
	        ${current.maxFlex - current.currentFlex}
	    </c:if>
	<c:if test="${current.orgId != null}">
	        Unlimited
	    </c:if>
    </rl:column>

    <rl:column headerkey="entitlements.jsp.subscribed" styleclass="last-column" >
        <c:if test="${current.subscribeCount == 0}">
            ${current.subscribeCount}
        </c:if>
        <c:if test="${current.subscribeCount > 0}">
            <a href="/network/systems/system_list/in_channel_family.pxt?cfam_id=${current.id}">
                ${current.subscribeCount}</a>
        </c:if>
    </rl:column>


  </rl:list>
</rl:listset>
</form>
</body>
</html>
