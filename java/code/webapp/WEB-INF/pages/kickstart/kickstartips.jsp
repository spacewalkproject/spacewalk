<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html:html xhtml="true">
<body>

<html:errors />
<html:messages id="message" message="true">
  <rhn:messages><c:out escapeXml="false" value="${message}" /></rhn:messages>
</html:messages>

<%@ include file="/WEB-INF/pages/common/fragments/kickstart/kickstart-toolbar.jspf" %>

<rhn:dialogmenu mindepth="0" maxdepth="1" 
    definition="/WEB-INF/nav/kickstart_details.xml" 
    renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

<h2><bean:message key="kickstartips.jsp.baremetal"/></h2>
<div>  
    <bean:message key="kickstartips.jsp.baremetal_summary"/>
    <p>
    ${url}
    </p>
  <p>
    <bean:message key="kickstartips.jsp.resource"/>
  </p>
</div>

<h2><bean:message key="kickstartips.jsp.baremetal2"/></h2>
<div>
  <p>        
    <bean:message key="kickstartips.jsp.baremetal_summary2"/>
  </p>
    <p>
    ${urlRange}
    </p>
  <p>
    <bean:message key="kickstartips.jsp.tip"/>
  </p>
</div>

<h2><bean:message key="kickstartips.jsp.ranges"/></h2>
<div>
  <p>        
    <bean:message key="kickstartips.jsp.ranges_summary"/>
  </p>
  
        <table class="details">          
          <c:forEach items="${ranges}" var="ip_range">                        
            <tr>                            
              <th><bean:message key="kickstartips.jsp.label" />:</th>                            
              <td>${ip_range.range}</td>
              <td><a href="/rhn/kickstart/KickstartIpRangeDelete.do?ksid=${ksdata.id}&min=${ip_range.min.number}&max=${ip_range.max.number}">delete</a></td>            
            </tr>
          </c:forEach>         
        </table>
      
      <html:form method="post" action="/kickstart/KickstartIpRangeEdit.do">
        <table class="details">
          <tr>
            <th><bean:message key="kickstartips.jsp.label" />:</th>
            <td><html:text property="octet1a" maxlength="3" size="3" />.
            <html:text property="octet1b" maxlength="3" size="3" />.
            <html:text property="octet1c" maxlength="3" size="3" />.
            <html:text property="octet1d" maxlength="3" size="3" /> - 
            <html:text property="octet2a" maxlength="3" size="3" />.
            <html:text property="octet2b" maxlength="3" size="3" />.
            <html:text property="octet2c" maxlength="3" size="3" />.
            <html:text property="octet2d" maxlength="3" size="3" /></td>                                                                        
          </tr>
          <tr>          
            <td align="right" colspan="2"><html:submit><bean:message key="kickstartips.jsp.addrange"/></html:submit></td>
          </tr>
        </table>
      <html:hidden property="ksid" value="${ksdata.id}"/>
      <html:hidden property="submitted" value="true"/>
      </html:form>
</div>
</body>
</html:html>

