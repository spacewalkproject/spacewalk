<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<html:xhtml/>
<html>
<body>

<rhn:toolbar base="h1" img="/img/rhn-icon-info.gif" imgAlt="info.alt.img">
  <bean:message key="subscriptionmanagement.jsp.subscriptionmanagement"/>
</rhn:toolbar>
                                                                                
<h2><bean:message key="subscriptionmanagement.jsp.renew"/></h2>

<p><bean:message key="subscriptionmanagement.jsp.renew.description"/></p>
<br />
<h2><bean:message key="subscriptionmanagement.jsp.purchase"/></h2>
<p><bean:message key="subscriptionmanagement.jsp.purchase.description1"/></p>
<p><bean:message key="subscriptionmanagement.jsp.purchase.description2"/></p>
<p><bean:message key="subscriptionmanagement.jsp.purchase.description3"/></p>
<br />
<h2><bean:message key="subscriptionmanagement.jsp.entitlements"/></h2>
<p><bean:message key="subscriptionmanagement.jsp.entitlements.description1"/></p>
<p><bean:message key="subscriptionmanagement.jsp.entitlements.description2"/></p>
</body>
</html>

