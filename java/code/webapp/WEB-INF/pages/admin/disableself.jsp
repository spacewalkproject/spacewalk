<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<html:xhtml/>
<html>
<body>
<rhn:toolbar base="h1" img="/img/rhn-icon-users.gif" imgAlt="users.jsp.imgAlt">
<bean:message key="disableself.jsp.account_deactivation" />
</rhn:toolbar>
<div class="page-summary">
        <p>
          <bean:message key="disableself.jsp.message" />
        </p>
    </div>

    <form method="post" name="rhn_list" action="/rhn/account/AccountDeactivationSubmit.do">
    <div align="right">
    <html:submit>
        <bean:message key="disableself.jsp.deactivate"/>
    </html:submit>
    </div>
    </form>
</body>
</html>
