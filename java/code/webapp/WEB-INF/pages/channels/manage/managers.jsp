<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html>
<body>

<rhn:toolbar base="h1" img="/img/rhn-icon-channels.gif">
  <bean:message key="channel.edit.jsp.toolbar" arg0="${channel_name}"/>
</rhn:toolbar>


<rhn:dialogmenu mindepth="0" maxdepth="1"
    definition="/WEB-INF/nav/channel_detail.xml"
    renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

    <%@ include file="/WEB-INF/pages/common/fragments/manage/managers.jspf" %>

</body>
</html>
