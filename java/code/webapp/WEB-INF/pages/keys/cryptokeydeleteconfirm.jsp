<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html:xhtml/>
<html>
<body>
<rhn:toolbar base="h1" img="/img/rhn-kickstart_profile.gif" imgAlt="kickstarts.alt.img">
	<bean:message key="keydelete.jsp.toolbar"/>
</rhn:toolbar>

<bean:message key="keydelete.jsp.summary"/>

<h2><bean:message key="keydelete.jsp.header2"/></h2>

<div>
    <html:form action="/keys/CryptoKeyDelete" enctype="multipart/form-data">
    <%@ include file="key-form-disabled.jspf" %>
    </html:form>
</div>

</body>
</html>

