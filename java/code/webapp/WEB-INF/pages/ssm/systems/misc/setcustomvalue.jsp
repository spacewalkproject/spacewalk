<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>


<html:html >
<body>
<%@ include file="/WEB-INF/pages/common/fragments/ssm/header.jspf" %>
  <h2><bean:message key="ssm.misc.setcustom.title"/></h2>
  <p><bean:message key="ssm.misc.setcustom.summary"/></p>

  <form action="/rhn/systems/ssm/misc/SetCustomValue.do?cikid=${cikid}" name="edit_token" method="post">
    <rhn:csrf />
    <table class="table">
      <tr>
        <th><bean:message key="system.jsp.customkey.keylabel"/>:</th>
        <td>${label}</td>
      </tr>

      <tr>
        <th><bean:message key="system.jsp.customkey.description"/>:</th>
        <td>${description}</td>
      </tr>

      <tr>
        <th><bean:message key="system.jsp.customkey.value"/>:</th>
        <td>
		<textarea wrap="virtual" rows="6" cols="50" name="value">${value}</textarea>
        </td>
      </tr>

    </table>

    <p><bean:message key="ssm.misc.setcustom.provisioning"/></p>

    <div class="text-right">

      <input class="btn btn-default" type="submit" name="set" value="<bean:message key='ssm.misc.setcustom.setvalues'/>" />
      <input class="btn btn-default" type="submit" name="remove" value="<bean:message key='ssm.misc.setcustom.removevalues'/>" />

      <rhn:submitted/>
    </div>
  </form>

</div>

  </body>
</html:html>
