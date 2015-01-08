<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>



<html>
<head>
</head>
<body>
<rhn:toolbar base="h1" icon="header-channel"
 helpUrl=""
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
<rhn:csrf />
<rhn:submitted />
<rl:listset  name="entitlements">
  <rl:list emptykey="entitlements.jsp.noentitlements">


    <rl:column headerkey="entitlements.jsp.channel"
          sortattr="name"
          filterattr="name"
          defaultsort="asc"
          width="40%">
        <a href="/rhn/software/channels/ChannelFamilyTree.do?cfid=${current.id}">${current.name}</a>
    </rl:column>

    <rl:column headerkey="entitlements.jsp.consumed" sortattr="currentMembers">
        <c:if test="${current.currentMembers == 0}">
            ${current.currentMembers}
        </c:if>
        <c:if test="${current.currentMembers > 0}">
            <a href="/rhn/channels/software/EntitledSystems.do?cfam_id=${current.id}&type=regular">
                ${current.currentMembers}</a>
        </c:if>
    </rl:column>

    <rl:column headerkey="entitlements.jsp.available"   >
        <c:if test="${current.orgId == null}">
                ${current.maxMembers - current.currentMembers}
            </c:if>
        <c:if test="${current.orgId != null}">
                Unlimited
            </c:if>
    </rl:column>

    <rl:column headerkey="entitlements.jsp.subscribed_flex" sortattr="currentFlex">
        <c:if test="${current.currentFlex == 0}">
            ${current.currentFlex}
        </c:if>
        <c:if test="${current.currentFlex > 0}">
            <a href="/rhn/channels/software/EntitledSystems.do?cfam_id=${current.id}&type=flex">${current.currentFlex}</a>
        </c:if>
    </rl:column>

    <rl:column headerkey="entitlements.jsp.avaible_flex" >
        <c:if test="${current.orgId == null}">
                ${current.maxFlex - current.currentFlex}
            </c:if>
        <c:if test="${current.orgId != null}">
                Unlimited
            </c:if>
    </rl:column>

    <rl:column headerkey="entitlements.jsp.subscribed" sortattr="subscribeCount">
        <c:if test="${current.subscribeCount == 0}">
            ${current.subscribeCount}
        </c:if>
        <c:if test="${current.subscribeCount > 0}">
            <a href="/rhn/channels/software/EntitledSystems.do?cfam_id=${current.id}&type=all">
                ${current.subscribeCount}</a>
        </c:if>
    </rl:column>


  </rl:list>
</rl:listset>
</form>
</body>
</html>
