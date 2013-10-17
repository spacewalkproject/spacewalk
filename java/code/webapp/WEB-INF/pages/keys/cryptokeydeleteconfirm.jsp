<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html:xhtml/>
<html>
<body>
<rhn:toolbar base="h1" icon="icon-rocket" imgAlt="kickstarts.alt.img">
	<bean:message key="keydelete.jsp.toolbar"/>
</rhn:toolbar>

<bean:message key="keydelete.jsp.summary"/>

<h2><bean:message key="keydelete.jsp.header2"/></h2>

<div>
    <html:form action="/keys/CryptoKeyDelete?csrf_token=${csrfToken}" enctype="multipart/form-data">
    <rhn:csrf />
    <rhn:submitted />
    <%@ include file="key-form-disabled.jspf" %>
    </html:form>
</div>

</body>
</html>

