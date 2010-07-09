<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<html:html xhtml="true">
<body>
<rhn:toolbar base="h1" img="/img/rhn-kickstart_profile.gif"
               creationUrl="/rhn/kickstart/KickstartScriptCreate.do?ksid=${ksdata.id}"
               creationType="kickstartscript"
               imgAlt="kickstarts.alt.img">
  <bean:message key="kickstartdetails.jsp.header1" arg0="${fn:escapeXml(ksdata.label)}"/>
</rhn:toolbar>

<rhn:dialogmenu mindepth="0" maxdepth="1"
    definition="/WEB-INF/nav/kickstart_details.xml"
    renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

<h2><bean:message key="kickstartscript.jsp.header"/></h2>

<div>
    <p>
    <bean:message key="kickstartscript.jsp.summary1"/>
    </p>
    <p>
    <bean:message key="kickstartscript.jsp.summary2"/>
    </p>
    <form method="post" name="rhn_list" action="/rhn/kickstart/Scripts.do">

      <rhn:list pageList="${requestScope.pageList}" noDataText="kickstartscript.jsp.noscripts">

      <rhn:listdisplay renderDisabled="true"
          set="${requestScope.set}">

        <rhn:column header="kickstartscript.jsp.type" style="text-align: center;">
        ${current.scriptType}
        </rhn:column>
        <rhn:column header="kickstartscript.jsp.scriptnum">
          <a href="/rhn/kickstart/KickstartScriptEdit.do?kssid=${current.id}&amp;ksid=${ksdata.id}"><bean:message key="kickstartscript.jsp.script"/> ${current.position}</a>
        </rhn:column>
        <rhn:column header="kickstartscript.jsp.language">
        ${current.interpreter}
        </rhn:column>

      </rhn:listdisplay>
      </rhn:list>
    </form>
</div>

</body>
</html:html>

