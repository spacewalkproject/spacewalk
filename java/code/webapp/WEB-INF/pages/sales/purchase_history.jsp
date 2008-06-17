<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<html:xhtml/>
<html>
<body>

<rhn:toolbar base="h1" img="/img/rhn-icon-info.gif" imgAlt="info.alt.img">
  <bean:message key="purchasehistory.jsp.purchasehistory"/>
</rhn:toolbar>

<h2><bean:message key="purchasehistory.jsp.view"/></h2>

<p><bean:message key="purchasehistory.jsp.description1"/></p>

<ul>
<li><strong><bean:message key="purchasehistory.jsp.item1"/></strong></li>
<li><strong><bean:message key="purchasehistory.jsp.item2"/></strong></li>
<li><strong><bean:message key="purchasehistory.jsp.item3"/></strong></li>
<li><strong><bean:message key="purchasehistory.jsp.item4"/></strong></li>
</ul>
<p><img src="/img/external-link.gif"  alt="<bean:message key="purchasehistory.jsp.externallink"/>"/><bean:message key="purchasehistory.jsp.description2"/></p>
</body>
</html>
