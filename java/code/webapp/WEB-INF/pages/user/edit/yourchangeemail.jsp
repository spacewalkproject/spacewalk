<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<html:xhtml/>
<html>
<body>
<rhn:toolbar base="h1" img="/img/rhn-icon-users.gif"
                 helpUrl="/rhn/help/reference/en-US/s1-sm-your-rhn.jsp#s2-sm-your-rhn-account"
                 imgAlt="users.jsp.imgAlt">
    <bean:message key="yourchangeemail.jsp.title"/>
</rhn:toolbar>

<p>
${pageinstructions}
</p>
<html:form action="/account/ChangeEmailSubmit">
  <html:text property="email" size="32" />
  <html:submit value="${button_label}" />
</html:form>

</body>
</html>
