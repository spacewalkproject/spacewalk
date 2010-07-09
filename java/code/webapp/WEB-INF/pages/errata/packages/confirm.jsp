<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>

<html:xhtml/>
<html>
<head>
    <meta name="page-decorator" content="none" />
</head>
<body>
<rhn:toolbar base="h1" img="/img/rhn-icon-errata.gif"
	           helpUrl="/rhn/help/channel-mgmt/en-US/channel-mgmt-Custom_Errata_Management-Managed_Errata_Details.jsp">
    <bean:message key="errata.edit.toolbar"/> <c:out value="${advisory}" />
  </rhn:toolbar>

  <rhn:dialogmenu mindepth="0" maxdepth="1" definition="/WEB-INF/nav/manage_errata.xml"
                  renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

  <h2><img src="/img/rhn-icon-packages.gif">
      <bean:message key="errata.edit.packages.confirm.confirmpackageaddition"/></h2>

  <p><bean:message key="errata.edit.packages.confirm.instructions"/></p>

  <rl:listset name="groupSet">

      <input type="hidden" name="eid" value="<c:out value="${param.eid}"/>" />

      <rl:list dataset="pageList"
               width="100%"
               styleclass="list"
               emptykey="packagelist.jsp.nopackages">

          <rl:decorator name="PageSizeDecorator"/>

          <rl:column headerkey="errata.edit.packages.add.package" bound="false"
				styleclass="first-column last-column"
                     sortattr="nvrea" sortable="true" filterattr="nvrea">
              <a href="/rhn/software/packages/Details.do?pid=${current.id}">
                  <c:out value="${current.nvrea}" escapeXml="false"/>
              </a>
          </rl:column>

      </rl:list>

      <div align="right">
          <rhn:submitted/>
          <hr/>
          <input type="submit"
                 name="dispatch"
                 value='<bean:message key="errata.edit.packages.confirm.confirm"/>'/>
      </div>

  </rl:listset>


</body>
</html>
