<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn"%>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl"%>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean"%>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html"%>
<html>
<body>
<rhn:toolbar
   base="h1"
   icon="icon-group"
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
<p><bean:message key="org.trust.summary" arg0="${org.name}" /></p>
</div>
<rl:listset name="trustedOrgs">
   <rhn:csrf />
   <rl:list
      dataset="pageList"
      width="100%"
      name="trustedOrgs"
      styleclass="list"
      decorator="SelectableDecorator"
      filter="com.redhat.rhn.frontend.action.multiorg.TrustListFilter"
      emptykey="org.trust.empty">
      <rl:selectablecolumn
         value="${current.selectionKey}"
         selected="${current.selected}"/>
      <rl:column
         bound="false"
         sortable="true"
         headerkey="org.trust.org"
         sortattr="orgName">
            <a href="OrgDetails.do?oid=${current.org.id}"> ${current.org.name} </a>
      </rl:column>
      <rl:column
	         bound="false"
	         sortable="false"
	         headerkey="org.trust.trusts">
        ${current.numTrusted}
      </rl:column>
   </rl:list>
   <hr/>
   <div align="right">
     <rhn:submitted/>
     <input type="submit" name ="confirm" value="${rhn:localize('org.trust.modify')}" />
   </div>
</rl:listset>
</body>
</html>
