<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html:html>
  <body>
    <%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

    <h2><bean:message key="sdc.details.activation.header"/></h2>
    <div class="page-summary">
      <p><bean:message key="sdc.details.activation.summary"/></p>
    </div>

    <c:if test="${requestScope.key != null}">
      <table class="details">
        <tr>
          <th><bean:message key="sdc.details.activation.key"/></th>
          <td>&nbsp;&nbsp;${requestScope.key}</td>
        </tr>
      </table>
    </c:if>

    <html:form method="post" action="/systems/details/Activation.do?sid=${system.id}">
      <rhn:csrf />
      <html:hidden property="submitted" value="true"/>

        <div class="text-right">
          <c:if test="${requestScope.key != null}">
            <input type="submit" name="delete" class="btn"
               value='<bean:message key="sdc.details.activation.deletekey"/>'/>
          </c:if>
          <input type="submit" name="generate" class="btn btn-default"
             value='<bean:message key="sdc.details.activation.generatekey"/>'/>
        </div>
    </html:form>

  </body>
</html:html>
