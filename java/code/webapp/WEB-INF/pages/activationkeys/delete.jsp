<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<html:html xhtml="true">
<body>
<rhn:toolbar base="h1" img="/img/rhn-icon-keyring.gif"
			imgAlt="activation-keys.common.alt"
			helpUrl="/rhn/help/reference/en-US/s1-sm-systems.jsp#s2-sm-systems-activation-keys"
			>
  <bean:message key ="activation-key.jsp.delete.title"/>	
</rhn:toolbar>

<div class="page-summary">
    <p>
        <bean:message key="activation-key.jsp.delete.para" arg0="/rhn/activationkeys/List.do"/>
    </p>
</div>


<hr/>
<table class="details">
    <tr>
        <th>
            <bean:message key="kickstart.activationkeys.jsp.description"/>
        </th>
        <td>
        	<c:out value="${requestScope.activationkey.note}"/>
        </td>
    </tr>
    <tr>
        <th>
            <bean:message key="kickstart.activationkeys.jsp.key"/>
        </th>
        <td>
        	<c:out value="${requestScope.activationkey.key}"/>
        </td>
    </tr>
</table>

<div align="right">
<hr/>
    <form action="/rhn/activationkeys/Delete.do"
    	 id ="delete_confirm" name = "delete_confirm" method="POST">
    	 <input type="hidden" name="tid" value="${param.tid}"/>
	 <input type="submit"  name="dispatch"
    	 			value="${rhn:localize('activation-key.jsp.delete-key')}" align="top" />
    	 <rhn:submitted/>
    </form>
</div>
</body>
</html:html>
