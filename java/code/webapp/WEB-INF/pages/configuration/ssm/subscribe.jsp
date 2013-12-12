<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>


<html>
<body>

<%@ include file="/WEB-INF/pages/common/fragments/ssm/header.jspf" %>
<h2>
  <rhn:icon type="header-configuration" title="<bean:message key='config.common.channelsAlt' />" />
  <bean:message key="ssm.config.subscribe.jsp.header"/>
</h2>
<h3><bean:message key="ssm.config.subscribe.jsp.step"/></h3>
<div class="page-summary">
  <p>
    <bean:message key="ssm.config.subscribe.jsp.summary"/>
  </p>
<noscript>
	<p><bean:message key="common.config.rank.jsp.warning.noscript"/></p>
</noscript>
</div>
<html:form method="post" action="/systems/ssm/config/SubscribeSubmit.do">
  <rhn:csrf />
  <rhn:list pageList="${requestScope.pageList}"
            noDataText="ssm.config.subscribe.jsp.noChannels">
    <rhn:listdisplay filterBy="config.common.configChannel"
                     set="${requestScope.set}"
                     button="ssm.config.subscribe.jsp.continue">
      <rhn:set value="${current.id}"/>

      <rhn:column header="config.common.configChannel"
                  url="/rhn/configuration/ChannelOverview.do?ccid=${current.id}">
        <rhn:icon type="header-channel" title="<bean:message key='config.common.globalAlt' />" />
        ${current.name}
      </rhn:column>

      <rhn:column header="ssm.config.subscribe.jsp.files">
        ${current.filesAndDirsDisplayString}
      </rhn:column>

      <rhn:column header="ssm.config.subscribe.jsp.systems"
                  url="/rhn/systems/ssm/config/ChannelSystems.do?ccid=${current.id}">
        <c:choose>
          <c:when test="${current.systemCount == 1}">
            <bean:message key="system.common.onesystem" />
          </c:when>
          <c:otherwise>
            <bean:message key="system.common.numsystems" arg0="${current.systemCount}"/>
          </c:otherwise>
        </c:choose>
      </rhn:column>
    </rhn:listdisplay>
  </rhn:list>
	  <rhn:noscript/>
	<rhn:submitted/>
</html:form>
</body>
</html>
