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
  <rhn:icon type="header-errata" />
  <bean:message key="confirmprivate.jsp.title"/>
</h2>
<p><bean:message key="confirmprivate.jsp.confirmmsg"/></p>
<p><bean:message key="confirmprivate.jsp.confirmmsg.deux"/></p>

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
            <a href="/rhn/multiorg/OrgTrustDetails.do?oid=${current.org.id}"> ${current.org.name}
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
     <input type="button"
                value="${rhn:localize('org.trust.cancel')}"
                onClick="location.href='${parentUrl}'" />
     <input type="submit" name ="dispatch" value="${rhn:localize('confirm')}" />
   </div>

   <!-- need to pass along the form -->
   <input type="hidden" name="name" value="${name}" />
   <input type="hidden" name="label" value="${label}" />
   <input type="hidden" name="parent" value="${parent}" />
   <input type="hidden" name="arch" value="${arch}" />
   <input type="hidden" name="arch_name" value="${arch_name}" />
   <input type="hidden" name="checksum" value="${checksum}" />
   <input type="hidden" name="summary" value="${summary}" />
   <input type="hidden" name="description" value="${description}" />
   <input type="hidden" name="maintainer_name" value="${maintainer_name}" />
   <input type="hidden" name="maintainer_email" value="${maintainer_email}" />
   <input type="hidden" name="maintainer_phone" value="${maintainer_phone}" />
   <input type="hidden" name="support_policy" value="${support_policy}" />
   <input type="hidden" name="per_user_subscriptions" value="${per_user_subscriptions}" />
   <input type="hidden" name="org_sharing" value="${org_sharing}" />
   <input type="hidden" name="gpg_key_url" value="${gpg_key_url}" />
   <input type="hidden" name="gpg_key_id" value="${gpg_key_id}" />
   <input type="hidden" name="gpg_key_fingerprint" value="${gpg_key_fingerprint}" />
</rl:listset>

</body>
</html>
