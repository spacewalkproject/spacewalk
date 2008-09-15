<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html:xhtml/>
<html>
<body>

<html:errors />
<html:messages id="message" message="true">
  <rhn:messages><c:out escapeXml="false" value="${message}" /></rhn:messages>
</html:messages>

<rhn:toolbar base="h1" img="/img/rhn-kickstart_profile.gif" imgAlt="system.common.kickstartAlt">
  <bean:message key="kickstartdelete.jsp.header1" arg0="${ksdata.name}"/>
</rhn:toolbar>

<rhn:dialogmenu mindepth="0" maxdepth="1" 
    definition="/WEB-INF/nav/kickstart_details.xml" 
    renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

<h2><bean:message key="kickstartdelete.jsp.header2"/></h2>

<div>
  <p>
    <bean:message key="kickstartdelete.jsp.summary1"/>
    <html:form method="POST" action="/kickstart/KickstartDelete.do">
      <table class="details">

          <tr>
            <th><bean:message key="kickstartdetails.jsp.label" />:</th>
            <td><strong>${ksdata.label}</strong></td> 
          </tr>
          <tr>
            <th><bean:message key="kickstartdetails.jsp.install_type" /></th>
            <td><strong><c:out value="${ksdata.ksdefault.kstree.channel.name}"/></strong></td>
          </tr>
          <tr>
            <th><bean:message key="kickstartdetails.jsp.active"/></th>
            <td><strong>
                <c:if test="${ksdata.active}">
                <bean:message key="kickstart.jsp.active"/>
          		</c:if>
         		<c:if test="${not ksdata.active}">
            	<bean:message key="kickstart.jsp.inactive"/>
          		</c:if></strong>
          	</td>	 
          </tr>
          <tr>
            <th><bean:message key="kickstartdetails.jsp.comments"/></th>
            <td><html:textarea disabled="true" property="comments" cols="80" rows="6"
                value="${ksdata.comments}" />
            </td>
          </tr>          

          <tr>          
            <td align="right" colspan="2">
            <html:submit>
            <bean:message key="kickstartdatadelete.jsp.confirmdelete"/>
            </html:submit>
            </td>
          </tr>

      <html:hidden property="ksid" value="${ksdata.id}"/>
      <html:hidden property="submitted" value="true"/>
      </table>
    </html:form>
  </p>
</div>

</body>
</html>

