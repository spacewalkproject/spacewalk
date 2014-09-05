<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>


<html:html >
<body>
<%@ include file="/WEB-INF/pages/common/fragments/package/package_header.jspf" %>

<h2>
<bean:message key="newversions.jsp.title"/>
</h2>

<div>

<rhn:list pageList="${requestScope.pageList}" noDataText="newversions.jsp.noversions">
  <rhn:listdisplay>
    <rhn:column header="newversions.jsp.newerversion">
      <a href="/rhn/software/packages/Details.do?pid=${current.id}">${current.nvrea}</a>
    </rhn:column>

    <rhn:column header="newversions.jsp.providingchannel">
      <a href="/rhn/channels/ChannelDetail.do?cid=${current.channel_id}">${current.channel_name}</a>
    </rhn:column>

    <rhn:column header="newversions.jsp.relatederrata">
      <c:if test="${not empty current.errata_id}">
        <c:if test="${current.advisory_type=='Security Advisory'}">
          <rhn:icon type="errata-security" title="erratalist.jsp.securityadvisory" />
        </c:if>
        <c:if test="${current.advisory_type=='Bug Fix Advisory'}">
          <rhn:icon type="errata-bugfix" title="erratalist.jsp.bugadvisory" />
        </c:if>
        <c:if test="${current.advisory_type=='Product Enhancement Advisory'}">
          <rhn:icon type="errata-enhance" title="erratalist.jsp.productenhancementadvisory" />
        </c:if>
        <a href="/rhn/errata/details/Details.do?eid=${current.errata_id}">${current.advisory}</a>
      </c:if>
    </rhn:column>

  </rhn:listdisplay>
</rhn:list>

</div>

</body>
</html:html>
