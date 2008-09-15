<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>

<html:xhtml/>
<html>

<body>

<html:messages id="message" message="true">
    <rhn:messages><c:out escapeXml="false" value="${message}" /></rhn:messages>
</html:messages>

<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>
    <h2>
      <img src="/img/rhn-icon-packages.gif" />
      <bean:message key="removeconfirm.jsp.confirmpackageremoval" />
    </h2>
    <rhn:systemtimemessage server="${system}" />

    <form method="POST" name="rhn_list" action="/rhn/systems/details/packages/RemoveConfirmSubmit.do">
       <rhn:list pageList="${requestScope.pageList}" noDataText="packagelist.jsp.nopackages">
       <rhn:listdisplay filterBy="packagelist.jsp.packagename" button="removeconfirm.jsp.runremotecommand"
                        buttonAcl="system_feature(ftr_remote_command); client_capable(script.run)"
                        mixins="com.redhat.rhn.common.security.acl.SystemAclHandler"
                        button2="removeconfirm.jsp.confirm">
          <rhn:column header="packagelist.jsp.packagename" width="95%"
                url="/network/software/packages/details.pxt?sid=${param.sid}&id_combo=${current.idCombo}">
            ${current.nvre}
          </rhn:column>
      </rhn:listdisplay>
      </rhn:list>
    <input type="hidden" name="sid" value="${param.sid}" />
    </form>
</body>
</html>
