<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn"%>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean"	prefix="bean"%>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html"	prefix="html"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<html:xhtml/>
<html>
<head>
  <script src="/javascript/iso_download.js" type="text/javascript"> </script>
</head>
<body>
<rhn:toolbar base="h1" img="/img/rhn-icon-channels.gif"  imgAlt="common.download.channelAlt">
<c:choose>
  <c:when test="${empty channel}">
    <decorator:getProperty property="meta.name" />
  </c:when>
  <c:otherwise>
    ${fn:escapeXml(channel.name)}
  </c:otherwise>
</c:choose>
</rhn:toolbar>

<c:choose>
  <c:when test="${empty channel}">
    <bean:message key="isodownload.no-access"/>
  </c:when>
  <c:otherwise>
<rhn:dialogmenu mindepth="0" maxdepth="3" definition="/WEB-INF/nav/channel_detail.xml" renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />
<p><strong><bean:message key="isodownload.hosted-only.warn"/></strong></p>

  </c:otherwise>
</c:choose>
</body>
</html>
