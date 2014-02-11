<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/config-managment" prefix="cfg" %>


<html>
<head>
    <meta name="name" value="sdc.config.jsp.header" />
</head>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

<rhn:toolbar base="h2" icon="header-channel-configuration">
  <bean:message key="sdc.configlist.jsp.header"/>
</rhn:toolbar>
  <div class="page-summary">
    <p><bean:message key="sdc.configlist.jsp.para1"/></p>
  </div>

<form method="post" name="rhn_list" action="/rhn/systems/details/configuration/ConfigChannelListUnsubscribeSubmit.do?sid=${param.sid}">
<rhn:csrf />
<c:choose>
<c:when test="${not empty requestScope.pageList}">
  <rhn:list pageList="${requestScope.pageList}"
  		noDataText="">
    <rhn:listdisplay set="${requestScope.set}"
    			filterBy="sdc.configlist.jsp.name">
	  <rhn:set value="${current.id}"/>
      <rhn:column header="sdc.configlist.jsp.name"
                  url="/rhn/configuration/ChannelOverview.do?ccid=${current.id}">
        <rhn:icon type="header-channel" title="config.common.globalAlt" />
        ${current.name}
      </rhn:column>

      <rhn:column header="sdc.configlist.jsp.label">
        ${current.label}
      </rhn:column>

      <rhn:column header="sdc.configlist.jsp.files">
		${current.fileCountsMessage}
      </rhn:column>

      <rhn:column header="sdc.configlist.jsp.deployablefiles">
        <c:if test="${current.deployableFileCount == 1}">
          <bean:message key="config.common.onefile" />
        </c:if>
        <c:if test="${current.deployableFileCount != 1}">
          <bean:message key="config.common.numfiles" arg0="${current.deployableFileCount}"/>
        </c:if>
      </rhn:column>
      <rhn:column header="sdc.configlist.jsp.rank">
        ${current.position}
      </rhn:column>
    </rhn:listdisplay>
     <div class="text-right">
         <hr />
         <html:submit styleClass="btn btn-default" property="dispatch">
         <bean:message key="sdc.configlist.jsp.unsubscribe"/>
         </html:submit>
     </div>
  </rhn:list>
</c:when>
<c:otherwise>
<p><strong> <bean:message key="sdc.configlist.jsp.noChannels"
	arg0="/rhn/systems/details/configuration/SubscriptionsSetup.do?sid=${param.sid}"/></strong>
</p>
</c:otherwise>
</c:choose>
</form>
<p><span class="small-text"><bean:message key="sdc.configlist.jsp.note"/></span></p>
</body>
</html>
