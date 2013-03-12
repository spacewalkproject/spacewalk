<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>

<html>
<head>
<script type="text/javascript" src="/javascript/highlander.js"></script>
</head>
<body>

    <h1><img src="/img/rhn-icon-help-h1.gif" alt="help" /><bean:message key="help.jsp.chat"/></h1>

    <ul>

        <div><bean:message key="help.jsp.chatinfo"/></div>
        <br/><br/>
        <div><bean:message key="help.jsp.chatlink"/></div>

    </ul>

</body>
</html>
