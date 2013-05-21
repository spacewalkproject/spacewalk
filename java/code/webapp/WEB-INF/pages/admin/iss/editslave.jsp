<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn"%>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl"%>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean"%>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html"%>
<html:xhtml />

<html>
<body>

 <html:errors />
 <html:messages id="message" message="true">
  <rhn:messages>
   <c:out escapeXml="false" value="${message}" />
  </rhn:messages>
 </html:messages>

 <c:choose>
 <c:when test="${requestScope.sid > 0}">
  <rhn:toolbar base="h1" img="/img/rhn-icon-info.gif"
   deletionUrl="/rhn/admin/iss/RemoveSlaveConfirm.do?sid=${requestScope.sid}"
   deletionType="slave" deletionAcl="user_role(satellite_admin)">
   <bean:message key="iss.editslave.jsp.toolbar" />
  </rhn:toolbar>
 </c:when>
 <c:otherwise>
  <rhn:toolbar base="h1" img="/img/rhn-icon-info.gif">
   <bean:message key="iss.editslave.jsp.toolbar" />
  </rhn:toolbar>
 </c:otherwise>
 </c:choose>

 <p>
  <bean:message key="iss.editslave.jsp.explanation" />
 </p>

 <rhn:dialogmenu mindepth="0" maxdepth="1"
  definition="/WEB-INF/nav/iss_config.xml"
  renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

 <h2>
  <bean:message key="iss.editslave.jsp.header2" />
 </h2>

 <html:form action="/admin/iss/UpdateSlave">
  <rhn:csrf />
  <html:hidden property="submitted" value="true" />
  <html:hidden property="id" />
  <table class="details" align="center">
   <tr>
    <th><label for="slave"><rhn:required-field key="iss.slave.name" />:</label></th>
    <td><html:text property="slave" size="45" maxlength="256"
      styleId="slave" /></td>
   </tr>
   <tr>
    <th><label for="enabled"><bean:message key="iss.slave.isEnabled" /></label>
    </th>
    <td><html:checkbox property="enabled" styleId="enabled" /></td>
   </tr>
   <tr>
    <th><label for="allowAllOrgs"><bean:message key="iss.slave.toAll" /></label></th>
    <td><html:checkbox property="allowAllOrgs"
      styleId="allowAllOrgs" /> </td>
   </tr>
  </table>
  <div align="right">

   <html:submit>
    <c:choose>
    <c:when test="${requestScope.sid > 0}">
    <bean:message key="iss.slave.edit" />
    </c:when>
    <c:otherwise>
    <bean:message key="iss.slave.create" />
    </c:otherwise>
    </c:choose>
   </html:submit>
  </div>

 </html:form>
 <c:if test="${requestScope.sid > 0}">
 <h2>
  <bean:message key="iss.editslave.jsp.allowed.orgs.header" />
 </h2>
 <rl:listset name="localOrgsListSet">
  <rhn:csrf />
  <rhn:submitted />
  <rl:list dataset="localOrgsList" name="localOrgsList"
   emptykey="editslave.jsp.nolocalorgs">
   <rl:decorator name="SelectableDecorator" />
   <rl:selectablecolumn value="${current.selectionKey}"
    selected="${current.selected}" />
   <rl:column sortable="true" headerkey="iss.localorg.name" sortattr="name">
     <c:out value="${current.name}" />
   </rl:column>
  </rl:list>
   <div align="right">
    <rhn:submitted />
    <hr />
    <input type="submit" name="dispatch"
     value='<bean:message key="iss.slave.associate"/>' />
   </div>
 </rl:listset>
 </c:if>

</body>
</html>

