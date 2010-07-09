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
   <c:out escapeXml="true" value="${org.name}" />
</rhn:toolbar>
<rhn:dialogmenu
   mindepth="0"
   maxdepth="2"
   definition="/WEB-INF/nav/org_tabs.xml"
   renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />
<div class="page-summary" style="padding-top: 10px;">
<p><bean:message key="org.trust.confirm.summary" arg0="${org.name}" /></p>
</div>
<rl:listset name="pageSet">
   <rl:list
      dataset="removed"
      width="100%"
      name="removed"
      styleclass="list"
      filter="com.redhat.rhn.frontend.action.multiorg.TrustListFilter"
      emptykey="org.trust.empty">
      <rl:column
         bound="false"
         sortable="true"
         styleclass="first-column"
         headerkey="org.trust.org"
         sortattr="name">
            <a href="OrgDetails.do?oid=${current.org.id}"> ${current.org.name} </a>
      </rl:column>
      <rl:column
         bound="false"
         sortable="false"
         headerkey="org.trust.systems.affected">
            <a href="OrgTrusts.do?affectedSystems=1&oid=${org.id}&oid=${current.org.id}">
               ${fn:length(current.subscribed)}
            </a>
      </rl:column>
   </rl:list>
   <hr/>
   <div align="right">
     <rhn:submitted/>
     <input type="button"
                value="${rhn:localize('org.trust.cancel')}"
                onClick="location.href='${parentUrl}'" />
     <input type="submit" name ="dispatch" value="${rhn:localize('confirm')}" />
   </div>
</rl:listset>
</body>
</html>