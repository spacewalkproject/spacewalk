<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn"%>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean"	prefix="bean"%>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html"	prefix="html"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<html:xhtml/>
<html>
<head>
  <script src="/javascript/channel_tree.js" type="text/javascript"></script>
</head>
<body onLoad="onLoadStuff(1);">
<h1><img src="/img/rhn-icon-cd.gif" alt="compact disc" /><bean:message key="common.download.header"/> <rhn-help href="s1-sm-channels-packages.html#S2-SM-CHANNEL-ISO"/></h1>

<p><strong><bean:message key="isodownload.hosted-only.warn"/></strong></p>

</body>
</html>

