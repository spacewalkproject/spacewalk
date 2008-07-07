<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>

<html:xhtml/>
<html>
<head>
    <meta name="name" value="System Details" />
</head>
<body>

<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

<h2><img src="/img/rhn-icon-packages.gif" /><bean:message key="download.jsp.header"/></h2>

<div class="page-summary">
  <p><bean:message key="download.jsp.summary1"/></p>
  <p><bean:message key="download.jsp.summary2"/></p>
  <strong>
    <code>tar -xvf rhn-packages.tar</code>
  </strong>
  <p><bean:message key="download.jsp.summary3"/></p>
</div>


<c:set var="pageList" value="${requestScope.pageList}" />
<form method="POST" name="rhn_list" action="/rhn/systems/details/packages/DownloadConfirmSubmit.do?sid=${param.sid}">
<rhn:list pageList="${requestScope.pageList}" noDataText="download.jsp.none">
  <rhn:listdisplay button="download.jsp.download">
    <rhn:column header="download.jsp.package"
                url="/network/software/packages/details.pxt?pid=${current.id}">
      ${current.nvre}
    </rhn:column>

    <rhn:column header="download.jsp.arch">
      ${current.arch}
    </rhn:column>

    <rhn:column header="download.jsp.channels">
      <c:forEach items="${current.channels}" var="channel">
        <a href="/rhn/channels/ChannelDetail.do?cid=${channel.id}">${channel.name}</a>
      </c:forEach>
    </rhn:column>
  </rhn:listdisplay>
</rhn:list>

</form>
</body>
</html>