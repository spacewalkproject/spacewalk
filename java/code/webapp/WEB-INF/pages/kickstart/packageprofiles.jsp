<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

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

    <form method="post" name="rhn_list" action="/rhn/kickstart/KickstartPackageProfileEditSubmit.do">
      <rhn:submitted />
      <rhn:list pageList="${pageList}" noDataText="kickstart.packageprofiles.jsp.noprofiles">
          
  <rhn:listdisplay   set="${requestScope.set}" hiddenvars="${requestScope.newset}">
    <rhn:set type="radio" value="${current.id}" buttons="false"/>

        <rhn:column header="kickstart.packageprofiles.jsp.description">
            ${current.name}
        </rhn:column>
      </rhn:listdisplay>      
      </rhn:list>
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

    </form>
</div>

</body>
</html:html>

