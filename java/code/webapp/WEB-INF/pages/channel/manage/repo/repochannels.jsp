<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<html>
<body>
<rhn:toolbar base="h1" icon="header-info">
  <c:out value="${requestScope.repo_name}"/>
</rhn:toolbar>
<rhn:dialogmenu mindepth="0" maxdepth="1" definition="/WEB-INF/nav/repo_detail.xml" renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />
<h2><bean:message key="repos.jsp.channelHeader" arg0="${fn:escapeXml(repo_name)}"/></h2>
<div class="page-summary">
<p><bean:message key="repos.jsp.channelSummary" arg0="${fn:escapeXml(repo_name)}"/></p>
</div>


<rl:listset name="keySet">
  <rhn:csrf />
  <rhn:submitted />
  <rl:list dataset="pageList"
         width="100%"
         name="keysList"
         styleclass="list"
         emptykey="repos.jsp.noChannels">

    <rl:decorator name="PageSizeDecorator"/>

    <rl:column sortable="true" headerkey="channel.edit.jsp.name"
        sortattr= "label" defaultsort="asc">
      <c:out value="<a href=\"/rhn/channels/ChannelDetail.do?cid=${current.id}\">${current.name}</a>" escapeXml="false" />
    </rl:column>
  </rl:list>
</rl:listset>

</body>
</html>
