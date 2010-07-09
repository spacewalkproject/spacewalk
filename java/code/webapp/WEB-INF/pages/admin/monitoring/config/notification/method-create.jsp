<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html:xhtml/>
<html>
<body>

<%@ include file="/WEB-INF/pages/common/fragments/user/user-header.jspf" %>
<h2><bean:message key="method-create.jsp.header2"/></h2>

<div>
  <p>
    <bean:message key="method-create.jsp.summary"/>
  </p>

<html:form action="/monitoring/config/notification/MethodCreate" method="POST">
    <table class="details">
    <tr>
        <th>
            <rhn:required-field key="method-form.jspf.name"/>
        </th>
        <td>
            <html:text property="name" maxlength="20" size="20" />
        </td>
        <tr>
            <th>
                <bean:message key="method-form.jspf.email"/>
            </th>
            <td>
                <html:text property="email" maxlength="25" size="50" />
            </td>
        </tr>
        <tr>
            <th>
                <bean:message key="method-form.jspf.type"/>
            </th>
            <td>
                <html:select property="type">
                    <html:options collection="method_types"
                        property="value"
                        labelProperty="label" />
                </html:select>
            </td>
        </tr>
        <tr>
          <td></td>
          <td align="right"><html:submit><bean:message key="method-form.jspf.savemethod"/></html:submit></td>
        </tr>
    </tr>
    </table>

    <html:hidden property="uid" value="${requestScope.targetuser.id}"/>
    <html:hidden property="cmid" value="${method.id}"/>
    <html:hidden property="submitted" value="true"/>


</html:form>
</div>

</body>
</html>

