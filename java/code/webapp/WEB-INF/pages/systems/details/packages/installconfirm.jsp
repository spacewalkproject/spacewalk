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
      <bean:message key="installconfirm.jsp.header" />
    </h2>
    <rhn:systemtimemessage server="${system}" />

    <form method="POST" name="rhn_list" action="/rhn/systems/details/packages/InstallConfirmSubmit.do">
       <rhn:list pageList="${requestScope.pageList}" noDataText="packagelist.jsp.nopackages">
       <rhn:listdisplay filterBy="packagelist.jsp.packagename">
          <rhn:column header="packagelist.jsp.packagename" width="95%"
                url="/network/software/packages/details.pxt?sid=${param.sid}&id_combo=${current.idCombo}">
            ${current.nvre}
          </rhn:column>
      </rhn:listdisplay>
      </rhn:list>
          <div align="right">
      <hr />
      
      <rhn:require mixins="com.redhat.rhn.common.security.acl.SystemAclHandler" acl="system_feature(ftr_remote_command); client_capable(script.run)">
          <html:submit property="dispatch">
          <bean:message key="installconfirm.jsp.runremotecommand"/>
          </html:submit>
      </rhn:require>
      
      <html:submit property="dispatch">
      <bean:message key="installconfirm.jsp.confirm"/>
      </html:submit>
    </div>
    <input type="hidden" name="sid" value="${param.sid}" />
    </form>
</body>
</html>
