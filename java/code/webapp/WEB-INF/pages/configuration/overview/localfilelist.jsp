<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://rhn.redhat.com/tags/config-managment" prefix="cfg" %>

<html:xhtml/>
<html>
<body>
<rhn:toolbar base="h1" img="/img/rhn-config_files.gif" imgAlt="config.common.filesAlt"
 helpUrl="/rhn/help/reference/en-US/s1-sm-configuration.jsp#configuration-files-local">
  <bean:message key="localfilelist.jsp.toolbar"/>
</rhn:toolbar>

<div class="page-summary">
  <bean:message key="localfilelist.jsp.summary"/>
</div> <br />

<form method="post" name="rhn_list" action="/rhn/configuration/file/LocalConfigFileList.do">

  <rhn:list pageList="${requestScope.pageList}" noDataText="localfilelist.jsp.noFiles">
    <rhn:listdisplay filterBy="localfilelist.jsp.path">
      <rhn:column header="localfilelist.jsp.path">
        <cfg:file id="${current.id}"
                  path="${current.path}"
                  type="${current.type}" />
      </rhn:column>

      <rhn:column header="localfilelist.jsp.system"
                  url="/rhn/systems/details/configuration/Overview.do?sid=${current.serverId}">
    	  <img src="/img/rhn-listicon-system.gif"
    	       alt="<bean:message key='system.common.systemAlt' />" />
    	  ${current.serverName}
      </rhn:column>
    </rhn:listdisplay>
  </rhn:list>

</form>

</body>
</html>

