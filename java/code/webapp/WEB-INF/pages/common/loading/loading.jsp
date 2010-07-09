<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<html:xhtml/>
<html>
<head>

    <meta name="page-decorator" content="none" />
</head>
<body>
<table border="0" cellpadding="0" cellspacing="0" width="408">
<tr>
<td>
<table align="left" border="0" cellpadding="0" cellspacing="0" width="408">
<tr>
<td><img name="left" src="/img/left.jpg" width="144" height="169" border="0" alt="" /></td>
<td><table align="left" border="0" cellpadding="0" cellspacing="0" width="264">
<tr>
<td>

<table align="left" border="0" cellpadding="0" cellspacing="0" width="264">
<tr>
<td><img name="anim_arrows" src="/img/anim_arrows.gif" width="117" height="135" border="0" alt="" /></td>
<td><img name="globe" src="/img/globe.jpg" width="147" height="135" border="0" alt="" /></td>
</tr>
</table>
</td>
</tr>
<tr>
<td width="264" height="34" style="text-align: right;">

<!-- Message for the objects you're loading... -->

Loading
<strong><c:out value="${param.pagesize}" /></strong>
<bean:message key="${param.what}" />....

</td>
</tr>
</table>
</td>
</tr>
</table>
</td>
</tr>
<tr>
<td width="408" height="56" style="text-align: center; font-size: 8pt;">

<!-- Here's where the progress bar goes -->

<br />
<img src="/img/progress_bar.gif" />
<br />
Just a moment...


</td>
</tr>
</table>
</body>
</html>
