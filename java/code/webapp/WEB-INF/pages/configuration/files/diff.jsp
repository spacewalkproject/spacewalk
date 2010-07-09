<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html:xhtml/>
<html>
<head><style type="text/css">
.filename {
    color: #ffffff;
    font-weight: bold;
    text-align: center;
    padding: 4px;
    background-color: #b4b19a;
    -moz-border-radius: 15px;
}

.config-toolbar {
    color: #666; padding: 4px;
    background-color: #f1ebdc;
    margin-bottom: 8px;
    padding-left: 8px;
    padding-right: 12px;
    text-align: right;
    -moz-border-radius: 15px;
}

</style>
</head>
<body>

<%@ include file="/WEB-INF/pages/common/fragments/configuration/files/header.jspf" %>
<h2>
  <bean:message key="diff.jsp.header" />
</h2>

<!-- Full or Changed selection -->
<c:if test="${showdiff == 'true'}">
  <div class="config-toolbar" >
    <span id="config-file-compare-view" style="float: left;">
      <strong><bean:message key="diff.jsp.viewtype" /></strong>&nbsp;&nbsp;
      <c:if test="${view != 'full'}">
        <a href="/rhn/configuration/file/Diff.do?cfid=${file.id}&amp;crid=${revision.id}&amp;ocrid=${orevision.id}&amp;view=full">
      </c:if>
      <bean:message key="diff.jsp.full" />
      <c:if test="${view != 'full'}">
        </a>
      </c:if>

      &nbsp;&nbsp;|&nbsp;&nbsp;
      <c:if test="${view != 'changed'}">
        <a href="/rhn/configuration/file/Diff.do?cfid=${file.id}&amp;crid=${revision.id}&amp;ocrid=${orevision.id}&amp;view=changed">
      </c:if>
      <bean:message key="diff.jsp.onlychanged" />
      <c:if test="${view != 'changed'}">
        </a>
      </c:if>
    </span>
    <span>
      <a href="/rhn/configuration/file/DownloadDiff.do?cfid=${file.id}&amp;crid=${revision.id}&amp;ocrid=${orevision.id}">
        <img src="/img/action-download.gif"
             alt='<bean:message key="diff.jsp.downloadAlt" />'
             title='<bean:message key="diff.jsp.downloadAlt" />' />
        <bean:message key="diff.jsp.download" />
      </a>
    </span>
  </div>
</c:if>

<!-- File meta-data -->
<div class="oldfile">
  <jsp:include page="/WEB-INF/pages/common/fragments/configuration/files/file_info.jsp">
    <jsp:param name="configchan" value="channel"/>
    <jsp:param name="configfile" value="file"/>
    <jsp:param name="configrev" value="revision"/>
  </jsp:include>
</div>

<div class="newfile">
  <jsp:include page="/WEB-INF/pages/common/fragments/configuration/files/file_info.jsp">
    <jsp:param name="configchan" value="ochannel"/>
    <jsp:param name="configfile" value="ofile"/>
    <jsp:param name="configrev" value="orevision"/>
  </jsp:include>
</div>

<!-- The file diff -->
<c:if test="${showdiff == 'true'}">
  ${requestScope.diff}
</c:if>

</body>
</html>