<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn"%>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl"%>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean"%>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html"%>
<html>
<body>
<html:errors />
<html:messages id="message" message="true">
<rhn:messages>
   <c:out escapeXml="false" value="${message}" />
</rhn:messages>
</html:messages>
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
      dataset="added"
      width="100%"
      name="added"
      styleclass="list list-doubleheader"
      title="org.trust.added"
      emptykey="org.trust.nothingadded">
      <rl:column
         bound="false"
         sortable="true"
         styleclass="first-column"
         headerkey="org.trust.org"
         sortattr="trustedOrgName">
            <a href="OrgDetails.do?oid=${current.id}"> ${current.name} </a>
      </rl:column>
      <rl:column
         bound="false"
         sortable="false"
         headerkey="org.trust.trusts">
            ${fn:length(current.trustedOrgs)}
      </rl:column>
   </rl:list>
   <rl:list
      dataset="removed"
      width="100%"
      name="added"
      styleclass="list list-doubleheader"
      title="org.trust.removed"
      emptykey="org.trust.nothingremoved">
      <rl:column
         bound="false"
         sortable="true"
         styleclass="first-column"
         headerkey="org.trust.org"
         sortattr="name">
            <a href="OrgDetails.do?oid=${current.id}"> ${current.name} </a>
      </rl:column>
      <rl:column
         bound="false"
         sortable="false"
         headerkey="org.trust.trusts">
            ${fn:length(current.trustedOrgs)}
      </rl:column>
   </rl:list>
   <hr/>
   <div align="right">
     <rhn:submitted/>
     <input type="submit" name ="dispatch" value="${rhn:localize('org.trust.update')}" />
   </div>
</rl:listset>
</body>
</html>