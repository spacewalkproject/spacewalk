<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn"%>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl"%>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean"%>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html"%>
<html:html xhtml="true">
<body>

 <c:choose>
  <c:when test="${requestScope.id > 0}">
   <rhn:toolbar base="h1" img="/img/rhn-icon-info.gif"
    deletionUrl="/rhn/admin/iss/RemoveMasterConfirm.do?mid=${requestScope.id}"
    deletionType="master" deletionAcl="user_role(satellite_admin)">
    <bean:message key="iss.editmaster.jsp.toolbar" />
   </rhn:toolbar>
  </c:when>
  <c:otherwise>
   <rhn:toolbar base="h1" img="/img/rhn-icon-info.gif">
    <bean:message key="iss.editmaster.jsp.toolbar" />
   </rhn:toolbar>
  </c:otherwise>
 </c:choose>

 <p>
  <bean:message key="iss.editmaster.jsp.explanation" />
 </p>

 <rhn:dialogmenu mindepth="0" maxdepth="1"
  definition="/WEB-INF/nav/iss_config.xml"
  renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

 <html:form action="/admin/iss/UpdateMaster.do">
  <rhn:csrf />
  <html:hidden property="id" />
  <rhn:submitted />
  <h2>
   <c:choose>
    <c:when test="${requestScope.id > 0}">
     <bean:message key="iss.editmaster.jsp.details.header" arg0="${requestScope.master}" />
    </c:when>
    <c:otherwise>
     <bean:message key="iss.editmaster.jsp.newmaster.details.header" />
    </c:otherwise>
   </c:choose>
  </h2>
  <table class="details" align="center">
    <c:choose>
    <c:when test="${empty requestScope.id or requestScope.id < 0}">
    <tr>
     <th><label for="label"><rhn:required-field  key="iss.master.label" /></label></th>
     <td><html:text property="label" styleId="label" /></td>
    </tr>
   </c:when>
   <c:otherwise>
     <html:hidden property="label" />
   </c:otherwise>
   </c:choose>

   <tr>
    <th><label for="defaultMaster">
      <bean:message key="iss.master.isDefault" /></label></th>
    <td><html:checkbox property="defaultMaster"
      styleId="defaultMaster" /></td>
   </tr>
   <tr>
    <th><label for="caCert"><bean:message
       key="iss.master.cacert" /></label></th>
    <td><html:text property="caCert" styleId="caCert" maxlength="1024" size="50" />
    <div>
    </div>
    <span class="small-text">
      <bean:message key="iss.master.cacert.note"/>
    </span>
    </div>
    </td>
   </tr>
  </table>

  <c:choose>
   <c:when test="${requestScope.id > 0}">
    <h2>
     <bean:message key="iss.editmaster.jsp.maporgs.header" arg0="${requestScope.master}" />
    </h2>
    <p>
      <bean:message key="iss.editmaster.jsp.maporgs.explanation" />
    </p>
    <rl:listset name="issMasterListSet">
     <rl:list dataset="all" name="issMasterList"
      emptykey="iss.editmaster.jsp.nomasterorgs">
      <rl:column sortable="true" headerkey="iss.master.org.name"
       sortattr="sourceOrgName">
       <c:out value="${current.masterOrgName}" />
      </rl:column>
      <rl:column headerkey="iss.slave.orgs" styleclass="center"
       headerclass="center">
       <select name="${current.id}">
        <c:forEach var="localOrg" items="${requestScope.slave_org_list}">
         <c:choose>
          <c:when test="${localOrg.id == current.localOrg.id}">
           <option value="${localOrg.id}" selected>
          </c:when>
          <c:otherwise>
           <option value="${localOrg.id}">
          </c:otherwise>
         </c:choose>
         <c:out value="${localOrg.name}" />
         </option>
        </c:forEach>
       </select>
      </rl:column>
     </rl:list>

     <div align="right">
      <hr />
      <input type="submit" name="dispatch"
       value='<bean:message key="iss.master.update"/>' />
     </div>
    </rl:listset>
   </c:when>
   <c:otherwise>
    <div align="right">
     <hr />
     <html:submit><bean:message key="iss.master.create" /></html:submit>
    </div>
   </c:otherwise>
  </c:choose>

 </html:form>
</body>
</html:html>
