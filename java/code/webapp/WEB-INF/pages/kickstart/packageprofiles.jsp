<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>


<html:html xhtml="true">
<body>
<%@ include file="/WEB-INF/pages/common/fragments/kickstart/kickstart-toolbar.jspf" %>

<rhn:dialogmenu mindepth="0" maxdepth="1"
    definition="/WEB-INF/nav/kickstart_details.xml"
    renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

<h2><bean:message key="kickstartdetails.jsp.header2"/></h2>

<div>
  <p>
    <bean:message key="kickstart.packageprofiles.jsp.summary" arg0="${ksdata.id}"/>
  </p>
<c:set var="pageList" value="${requestScope.pageList}" />

<rl:listset name="profiles" >
  <rl:list emptykey="kickstart.packageprofiles.jsp.noprofiles">
		<rl:decorator name = "PageSizeDecorator"/>
		<rl:radiocolumn value="${current.id}" styleclass="first-column" useDefault='false'/>

        <rl:column headerkey="kickstart.packageprofiles.jsp.description" filterattr="name">
            ${current.name}
        </rl:column>
        </rl:list>
		<p>
		<bean:message key="kickstart.packageprofiles.jsp.tip" arg0="${ksdata.id}"/>
		</p>
		<hr />
		<input type="hidden" name="ksid" value="<c:out value="${param.ksid}"/>" />
		<div align="right">
		  <html:submit property="dispatch">
		    <bean:message key="kickstart.packageprofile.jsp.clear"/>
		  </html:submit>
		  <html:submit property="dispatch">
		    <bean:message key="kickstart.packageprofile.jsp.submit"/>
		  </html:submit>

		</div>
		<rhn:submitted />
	</rl:listset>
</div>

</body>
</html:html>

