<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn"%>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl"%>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean"%>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html"%>
<html>
<body>
<rhn:toolbar
   base="h1"
   img="/img/rhn-icon-org.gif"
   miscUrl="${url}"
   miscAcl="user_role(org_admin)"
   miscText="${text}"
   miscImg="${img}"
   miscAlt="${text}"
   imgAlt="users.jsp.imgAlt">
   <c:out escapeXml="true" value="${orgA.name}/${orgB.name}" />
</rhn:toolbar>
<rhn:dialogmenu
   mindepth="0"
   maxdepth="2"
   definition="/WEB-INF/nav/org_tabs.xml"
   renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />
<div class="page-summary" style="padding-top: 10px;">
<p>
<bean:message key="org.trust.affectedsystems.summary"
                        arg0="${orgA.name}"
                        arg1="${orgB.name}" />
</p>
</div>
<rl:listset name="pageSet">
   <rl:list
      dataset="sysA"
      width="100%"
      name="removed"
      styleclass="list list-doubleheader"
      emptykey="org.trust.no.systems.affected"
      title="${orgA.name}" >
      <rl:column
         bound="false"
         sortable="true"
         styleclass="first-column"
         headerkey="org.trust.system"
         sortattr="name">
            <c:choose>
                <c:when test="${usrOrg.id == orgA.id}">
                    <a href="/rhn/systems/details/Overview.do?sid=${current.id}"> ${current.name} </a>
                </c:when>
                <c:otherwise>${current.name}</c:otherwise>
            </c:choose>
      </rl:column>
   </rl:list>
   <rl:list
      dataset="sysB"
      width="100%"
      name="removed"
      styleclass="list list-doubleheader"
      emptykey="org.trust.no.systems.affected"
      title="${orgB.name}" >
      <rl:column
         bound="false"
         sortable="true"
         styleclass="first-column"
         headerkey="org.trust.system"
         sortattr="name">
            <c:choose>
                <c:when test="${usrOrg.id == orgB.id}">
                    <a href="/rhn/systems/details/Overview.do?sid=${current.id}"> ${current.name} </a>
                </c:when>
                <c:otherwise>${current.name}</c:otherwise>
            </c:choose>
      </rl:column>
   </rl:list>
</rl:listset>
</body>
</html>