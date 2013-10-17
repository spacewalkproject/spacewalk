<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<html:xhtml/>
<html>
<body>
<rhn:toolbar base="h1" icon="icon-user" imgAlt="users.jsp.imgAlt">
<bean:message key="disableself.jsp.account_deactivation" />
</rhn:toolbar>
<div class="page-summary">
        <p>
          <bean:message key="disableself.jsp.message" />
        </p>
    </div>

    <form method="post" name="rhn_list" action="/rhn/account/AccountDeactivationSubmit.do">
    <rhn:csrf />
    <div align="right">
    <html:submit>
        <bean:message key="disableself.jsp.deactivate"/>
    </html:submit>
    </div>
    </form>
</body>
</html>
