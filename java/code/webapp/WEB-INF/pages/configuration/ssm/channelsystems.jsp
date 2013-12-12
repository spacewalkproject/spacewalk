<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://rhn.redhat.com/tags/config-managment" prefix="cfg" %>


<html>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/ssm/header.jspf" %>
<h2>
  <rhn:icon type="header-configuration" title="<bean:message key='ssmdiff.jsp.imgAlt' />" />
  <bean:message key="ssmchannelsystems.jsp.header" />
</h2>

  <div class="page-summary">
    <p>
      <c:set var="beanarg" scope="request">
        <cfg:channel id="${channel.id}"
                     name="${channel.displayName}"
                     type="${channel.configChannelType.label}" />
      </c:set>
      <bean:message key="ssmchannelsystems.jsp.summary"
                    arg0="${beanarg}" />
    </p>
  </div>

<form method="post" name="rhn_list" action="/rhn/systems/ssm/config/ChannelSystems.do?ccid=${param.ccid}">
  <rhn:csrf />
  <rhn:submitted />
  <rhn:list pageList="${requestScope.pageList}"
            noDataText="ssmchannelsystems.jsp.noSystems">
    <rhn:listdisplay filterBy="ssmchannelsystems.jsp.system">
      <rhn:column header="ssmchannelsystems.jsp.system"
                  url="/rhn/systems/details/configuration/Overview.do?system_detail_navi_node=selected_configfiles&sid=${current.id}">
        <rhn:icon type="header-system-physical" title="<bean:message key='system.common.systemAlt' />" />
        ${current.name}
      </rhn:column>

      <rhn:column header="ssmchannelsystems.jsp.files">
        <c:choose>
          <c:when test="${current.configFileCount == 1}">
            <bean:message key="ssmchannelsystems.jsp.onefile" />
          </c:when>
          <c:otherwise>
            <bean:message key="ssmchannelsystems.jsp.numfiles" arg0="${current.configFileCount}"/>
          </c:otherwise>
        </c:choose>
      </rhn:column>
    </rhn:listdisplay>
  </rhn:list>
</form>

</body>
</html>
