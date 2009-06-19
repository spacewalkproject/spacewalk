<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>

<html:xhtml/>
<html>

<body>
<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

  <h2>
    <img src="/img/rhn-icon-package_del.gif" />
    <bean:message key="install_patchset.jsp.header" />
  </h2>

  <div class="page-summary">
    <p>
      <bean:message key="install_patchset.jsp.installpagesummary" />
    </p>
  </div>

  <table class="details">
    <tr>
      <th><bean:message key="packagedetails.description"/></th>
      <td><pre>${package.description}</pre></td>
    </tr>
  </table>
<form method="POST" name="install_patchset" action="/rhn/systems/details/packages/patchsets/InstallPatchSetSubmit.do">
    <input type="hidden" name="sid" value="${param.sid}" />
    <input type="hidden" name="pid" value="${param.pid}" />

    <div align="right">
      <hr />
        <html:submit property="dispatch">
          <bean:message key="install_patchset.jsp.installbutton" />
        </html:submit>
    </div>

  </form>

</body>
</html>
