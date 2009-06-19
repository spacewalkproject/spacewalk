<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<html:xhtml/>
<html>
<head>
    <meta name="page-decorator" content="none" />
</head>
<body>
<rhn:toolbar base="h1" img="/img/rhn-icon-users.gif" imgAlt="user.common.userAlt">
<bean:message key="Addresses"/>
</rhn:toolbar>
<html:form action="/account/EditAddressSubmit">
<html:hidden property="type"/>

<div class="page-summary">
<p>
    <bean:message key="your_edit_address.jsp.summary" />
</p>
</div>

<h2>
    ${editAddressForm.map.typedisplay}
    <bean:message key="your_edit_address_record.displayname"/>
</h2>

<%@ include file="/WEB-INF/pages/common/fragments/user/edit_address_form.jspf" %>

<div align="right">
<hr />

    <html:submit value="Update" />
</div>

<html:hidden property="uid" value="${param.uid}"/>

</html:form>
</body>
</html>
