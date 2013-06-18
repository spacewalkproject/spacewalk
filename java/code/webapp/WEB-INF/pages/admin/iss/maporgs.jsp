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

 <c:if test="${requestScope.mid > 0}">
  <rhn:toolbar base="h1" img="/img/rhn-icon-info.gif"
   deletionUrl="/rhn/admin/iss/RemoveMasterConfirm.do?mid=${requestScope.mid}"
   deletionType="master" deletionAcl="user_role(satellite_admin)">
   <bean:message key="iss.maporgs.jsp.toolbar" />
  </rhn:toolbar>
 </c:if>

  <p>
   <bean:message key="iss.maporgs.jsp.explanation" />
  </p>

 <rhn:dialogmenu mindepth="0" maxdepth="1"
  definition="/WEB-INF/nav/iss_config.xml"
  renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

 <h2>
  <bean:message key="iss.maporgs.jsp.header2" arg0="${requestScope.master}"/>
 </h2>

 <html:form action="/admin/iss/MapOrgs.do?mid=${requestScope.mid}">
  <rhn:csrf />
 <rl:listset name="issMasterListSet">
  <rhn:csrf />
  <rhn:submitted />
  <rl:list dataset="all" name="issMasterList"
   emptykey="iss.maporgs.jsp.nomasterorgs">
   <rl:column sortable="true" headerkey="iss.master.org.name"
    sortattr="sourceOrgName">
    <c:out value="${current.masterOrgName}" />
   </rl:column>
    <rl:column headerkey="iss.slave.orgs" styleclass="center" headerclass="center">
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
  <rhn:submitted />
  <hr />
  <input type="submit" name="dispatch"
   value='<bean:message key="iss.update.org.mapping"/>' />
 </div>
 </rl:listset>

 </html:form>
</body>
</html>
