<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>


<html>
<head>
    <meta name="name" value="sdc.config.jsp.header" />
</head>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

<rhn:toolbar base="h2" icon="header-system" >
  <bean:message key="sdcimportconfirm.jsp.header" />
</rhn:toolbar>

  <div class="page-summary">
    <p>
    <bean:message key="sdcimportconfirm.jsp.summary"
                  arg0="${system.name}"/>
    </p>
  </div>

<html:form method="post"
		action="/systems/details/configuration/addfiles/ImportFileConfirmSubmit.do?sid=${system.id}">
  <rhn:csrf />
  <rhn:list pageList="${requestScope.pageList}"
            noDataText="sdcimportconfirm.jsp.noFiles">

      <rhn:listdisplay>
        <rhn:column header="sdcimportconfirm.jsp.filename">
			${current.path}
      	</rhn:column>

      	<rhn:column header="sdcimportconfirm.jsp.channel"
                  url="/rhn/configuration/ChannelOverview.do?ccid=${current.configChannelId}"
                  renderUrl="${not empty current.configChannelType}">
          <c:choose>
            <c:when test="${empty current.configChannelType}">
              <i><bean:message key="sdcimportconfirm.jsp.new" /></i>
            </c:when>
            <c:when test="${current.configChannelType == 'normal'}">
              <rhn:icon type="header-channel" title="config.common.globalAlt" />
    	      ${current.channelNameDisplay}
            </c:when>
            <c:when test="${current.configChannelType == 'local_override'}">
              <rhn:icon type="header-system-physical" title="config.common.localAlt" />
              ${current.channelNameDisplay}
            </c:when>
            <c:otherwise>
              <rhn:icon type="header-sandbox" title="config.common.sandboxAlt" />
              ${current.channelNameDisplay}
            </c:otherwise>
          </c:choose>
        </rhn:column>

      </rhn:listdisplay>
    </rhn:list>

    <c:if test="${not empty requestScope.pageList}">
      <p><bean:message key="sdcimportconfirm.jsp.widgetsummary" /></p>
      <jsp:include page="/WEB-INF/pages/common/fragments/datepicker-with-label.jsp">
        <jsp:param name="widget" value="date" />
        <jsp:param name="label_text" value="sdcimportconfirm.jsp.usedate" />
      </jsp:include>
      <div class="text-right">
        <hr />
          <html:submit styleClass="btn btn-default" property="dispatch">
            <bean:message key="sdcimportconfirm.jsp.confirm" />
          </html:submit>
      </div>
    </c:if>

</html:form>

</body>
</html>
