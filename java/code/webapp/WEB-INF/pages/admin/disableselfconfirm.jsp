<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<html:xhtml/>
<html>
<body>
<rhn:toolbar base="h1" icon="fa-user">
<bean:message key="disableselfconfirm.jsp.warning_question" />
</rhn:toolbar>
<div class="page-summary">
        <p>
          <bean:message key="disableselfconfirm.jsp.warning" />
        </p>
    </div>

    <hr />
    <form method="POST" name="rhn_list" action="/rhn/account/AccountDeactivationConfirm.do">
    <rhn:csrf />
    <div class="text-right">
    <html:submit>
        <bean:message key="disableself.jsp.deactivate"/>
    </html:submit>
    </div>
    <html:hidden property="submitted" value="true" />
    </form>
</body>
</html>
