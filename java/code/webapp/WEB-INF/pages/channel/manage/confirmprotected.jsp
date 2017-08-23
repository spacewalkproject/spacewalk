<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>



<html>
<head>
</head>
<body>

<%@ include file="/WEB-INF/pages/common/fragments/channel/manage/manage_channel_header.jspf" %>

<br/>
<h2>
  <rhn:icon type="header-package" />
  <bean:message key="confirmprivate.jsp.title"/>
</h2>
<p><bean:message key="confirmprotected.jsp.confirmmsg"/></p>
<p><bean:message key="confirmprotected.jsp.confirmmsg.deux"/></p>

<!-- %@ include
    file="/WEB-INF/pages/common/fragments/multiorg/orgsubscribedsystemlist.jspf"
    % -->

<rl:listset name="pageSet">
   <rhn:csrf />
   <rl:list dataset="pageList"
            width="100%"
            name="trustedOrgList"
            styleclass="list"
            emptykey="org.trust.empty">

      <rl:column
         bound="false"
         sortable="true"
         headerkey="org.trust.org"
         sortattr="name">
            <a href="/rhn/multiorg/OrgTrustDetails.do?oid=${current.org.id}"> ${fn:escapeXml(current.org.name)}
</a>
      </rl:column>
      <rl:column
         bound="false"
         sortable="false"
         headerkey="org.trust.systems.affected">
            ${fn:length(current.subscribed)}
      </rl:column>
   </rl:list>
   <hr/>
   <div class="text-right">
     <rhn:submitted/>
     <input type="button" class="btn btn-default"
                value="${rhn:localize('org.trust.cancel')}"
                onClick="location.href='${parentUrl}'" />
     <input type="submit" name ="deny" value="${rhn:localize('button.denyaccess.confirm')}" class="btn btn-danger" />
     <input type="submit" name ="grant" value="${rhn:localize('button.grantaccess.confirm')}" class="btn btn-success" />
   </div>

   <!-- need to pass along the form -->
   <rhn:hidden name="name" value="${name}" />
   <rhn:hidden name="label" value="${label}" />
   <rhn:hidden name="parent" value="${parent}" />
   <rhn:hidden name="arch" value="${arch}" />
   <rhn:hidden name="arch_name" value="${arch_name}" />
   <rhn:hidden name="summary" value="${summary}" />
   <rhn:hidden name="checksum" value="${checksum}" />
   <rhn:hidden name="description" value="${description}" />
   <rhn:hidden name="maintainer_name" value="${maintainer_name}" />
   <rhn:hidden name="maintainer_email" value="${maintainer_email}" />
   <rhn:hidden name="maintainer_phone" value="${maintainer_phone}" />
   <rhn:hidden name="support_policy" value="${support_policy}" />
   <rhn:hidden name="per_user_subscriptions" value="${per_user_subscriptions}" />
   <rhn:hidden name="org_sharing" value="${org_sharing}" />
   <rhn:hidden name="gpg_key_url" value="${gpg_key_url}" />
   <rhn:hidden name="gpg_key_id" value="${gpg_key_id}" />
   <rhn:hidden name="gpg_key_fingerprint" value="${gpg_key_fingerprint}" />
</rl:listset>

</body>
</html>
