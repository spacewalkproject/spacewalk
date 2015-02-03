<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/config-managment" prefix="cfg" %>


<html>
<body>
<rhn:toolbar base="h1" icon="header-configuration" helpUrl="">
  <bean:message key="globalfilelist.jsp.toolbar"/>
</rhn:toolbar>

<form method="post" role="form" name="rhn_list" action="/rhn/configuration/file/GlobalConfigFileList.do">
  <rhn:csrf />
  <rhn:submitted />

  <div class="panel panel-default">
    <div class="panel-heading">
        <h4><bean:message key="globalfilelist.jsp.summary"/> </h4>
    </div>
    <div class="panel-body">
      <rhn:list pageList="${requestScope.pageList}" noDataText="globalfilelist.jsp.noFiles">
        <rhn:listdisplay filterBy="globalfilelist.jsp.path">
          <rhn:column header="globalfilelist.jsp.path">
            <cfg:file id="${current.id}" path="${current.path}" type="${current.type}" />
          </rhn:column>

          <rhn:column header="config.common.configChannel">
            <cfg:channel id="${current.configChannelId}" name="${current.configChannelName}" type="global" />
          </rhn:column>

          <rhn:column header="globalfilelist.jsp.subscribed"
                      url="/rhn/configuration/channel/ChannelSystems.do?ccid=${current.configChannelId}"
                      renderUrl="${current.systemCount > 0}">
            <c:if test="${current.systemCount == 0}">
              <bean:message key="none.message"/>
            </c:if>
            <c:if test="${current.systemCount == 1}">
              <bean:message key="system.common.onesystem"/>
            </c:if>
            <c:if test="${current.systemCount > 1}">
              <bean:message key="system.common.numsystems" arg0="${current.systemCount}"/>
            </c:if>
          </rhn:column>

          <rhn:column header="globalfilelist.jsp.overriding"
                                  url="/rhn/configuration/channel/ChannelSystems.do?ccid=${current.configChannelId}"
                      renderUrl="${current.overrideCount > 0}">
              <c:if test="${current.overrideCount == 0}">
                <bean:message key="none.message"/>
              </c:if>
              <c:if test="${current.overrideCount == 1}">
                <bean:message key="system.common.onesystem"/>
              </c:if>
              <c:if test="${current.overrideCount > 1}">
                <bean:message key="system.common.numsystems" arg0="${current.overrideCount}"/>
              </c:if>
          </rhn:column>
        </rhn:listdisplay>
      </rhn:list>
    </div>
    <div class="panel-footer"><bean:message key="globalfilelist.jsp.note"/></div>
  </div>
</form>

</body>
</html>

