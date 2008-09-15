<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://rhn.redhat.com/tags/config-managment" prefix="cfg" %>

<html:xhtml/>
<html>
<body>

<html:errors />
<html:messages id="message" message="true">
  <rhn:messages><c:out escapeXml="false" value="${message}" /></rhn:messages>
</html:messages>

<rhn:toolbar base="h1" img="/img/rhn-icon-quota.gif" imgAlt="config.common.quotaAlt">
  <bean:message key="quota.jsp.toolbar" />
</rhn:toolbar>

<div class="page-summary">
  <p>
  <bean:message key="quota.jsp.total" arg0="${requestScope.total}"/>
  <bean:message key="quota.jsp.used" arg0="${requestScope.used}" arg1="${requestScope.left}"/>
  </p>
</div>

<form method="post" name="rhn_list" action="/rhn/configuration/Quota.do">

  <rhn:list pageList="${requestScope.pageList}" noDataText="quota.jsp.noFiles">
    <rhn:listdisplay filterBy="quota.jsp.filename">
      <rhn:column header="quota.jsp.filename">
        <cfg:file id="${current.id}" revisionId="${current.latestConfigRevisionId}" path="${current.path}" type="${current.type}" />
      </rhn:column>
      
      <rhn:column header="config.common.configChannel">
        <cfg:channel id="${current.configChannelId}" name="${current.channelNameDisplay}" type="${current.configChannelType}" />
      </rhn:column>
      
      <rhn:column header="quota.jsp.revisions"
                  url="/rhn/configuration/file/ManageRevision.do?cfid=${current.id}">
        <c:if test="${current.latestConfigRevision == 1}">
          <bean:message key="quota.jsp.onerevision"/>
        </c:if>
        
        <c:if test="${current.latestConfigRevision != 1}">
          <bean:message key="quota.jsp.numrevisions" arg0="${current.latestConfigRevision}"/>
        </c:if>
      </rhn:column>
      
      <rhn:column header="quota.jsp.spaceUsed">
        ${current.totalFileSizeDisplay}
      </rhn:column>
    </rhn:listdisplay>
  </rhn:list>
  
</form>
  
  <bean:message key="quota.jsp.note"/>

</body>
</html>

