<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>

<html:xhtml/>
<html>
<body>

<%@ include file="/WEB-INF/pages/common/fragments/user/user-header.jspf" %>
<html:form action="/users/EditAddressSubmit">
<html:hidden property="type"/>
<h2><bean:message key="message.Update"/> ${editAddressForm.map.typedisplay}</h2>

    <div class="page-summary">
    <p>
      <bean:message key="edit_address.jsp.summary"/>
    </p>
    </div>

<%@ include file="/WEB-INF/pages/common/fragments/user/edit_address_form.jspf" %>

<div align="right">
<hr />
    <html:hidden property="uid" />
    <rhn:submit valueKey="message.Update" />
</div>

</html:form>
</body>
</html>
