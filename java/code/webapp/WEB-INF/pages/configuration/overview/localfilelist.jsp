<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://rhn.redhat.com/tags/config-managment" prefix="cfg" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>


<html>
<body>
<rhn:toolbar base="h1" icon="header-configuration"
 helpUrl="">
  <bean:message key="localfilelist.jsp.toolbar"/>
</rhn:toolbar>

<form method="post" role="form" name="rhn_list" action="/rhn/configuration/file/LocalConfigFileList.do">
  <rhn:csrf />
  <rhn:submitted />
  <div class="panel panel-default">
    <div class="panel-heading">
        <h4><bean:message key="localfilelist.jsp.summary"/></h4>
    </div>
    <div class="panel-body">
      <rhn:list pageList="${requestScope.pageList}" noDataText="localfilelist.jsp.noFiles">
        <rhn:listdisplay filterBy="localfilelist.jsp.path">
          <rhn:column header="localfilelist.jsp.path">
            <cfg:file id="${current.id}"
                      path="${current.path}"
                      type="${current.type}" />
          </rhn:column>

          <rhn:column header="localfilelist.jsp.system"
                      url="/rhn/systems/details/configuration/Overview.do?sid=${current.serverId}">
             <rhn:icon type="header-system-physical" title="system.common.systemAlt" />
                  ${fn:escapeXml(current.serverName)}
          </rhn:column>
        </rhn:listdisplay>
      </rhn:list>
    </div>
  </div>
</form>

</body>
</html>

