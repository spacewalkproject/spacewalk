<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html:html xhtml="true">
  <body>
    <rhn:toolbar base="h1" img="/img/rhn-icon-org.gif" >
      ${orgtrust}
    </rhn:toolbar>
    <rhn:dialogmenu mindepth="0" maxdepth="3"
                    definition="/WEB-INF/nav/org_trust.xml"
                    renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />
    <h2><bean:message key="orgtrustdetails.jsp.header1"/></h2>
    <table class="details">
      <tr>
        <th><bean:message key="orgtrustdetails.jsp.created"/></th>
        <td>${created}</td>
      </tr>
      <tr>
        <th><bean:message key="orgtrustdetails.jsp.trusted"/></th>
        <td>${since}</td>
      </tr>
    </table>
<h2><bean:message key="orgtrustdetails.jsp.header2"/></h2>
    <table class="details">
      <tr>
        <th><bean:message key="orgtrustdetails.jsp.channelsprovided"/></th>
        <c:choose>
        <c:when test="${channelsfrom > 0}">
          <td><a href="/rhn/multiorg/channels/Provided.do?oid=${param.oid}">${channelsfrom}</a> (<bean:message key="orgtrustdetails.jsp.systemconsume1" arg0="${sysleech}"/>)</td>
        </c:when>
        <c:otherwise>
          <td>${channelsfrom} (<bean:message key="orgtrustdetails.jsp.systemconsume1" arg0="${sysleech}"/>)</td>
        </c:otherwise>
        </c:choose>
      </tr>
      <tr>
        <th><bean:message key="orgtrustdetails.jsp.channelsconsumed"/></th>
        <c:choose>
        <c:when test="${channelsto > 0}">
          <td><a href="/rhn/multiorg/channels/Consumed.do?oid=${param.oid}">${channelsto}</a> (<bean:message key="orgtrustdetails.jsp.systemconsume2" arg0="${orgtrust}" arg1="${sysseed}"/>)</td>
        </c:when>
        <c:otherwise>
          <td>${channelsto} (<bean:message key="orgtrustdetails.jsp.systemconsume2" arg0="${orgtrust}" arg1="${sysseed}" />)</td>
        </c:otherwise>
        </c:choose>
      </tr>
    </table>
<h2><bean:message key="orgtrustdetails.jsp.header3"/></h2>
    <table class="details">
      <tr>
        <th><bean:message key="orgtrustdetails.jsp.sysmigratedto"/></th>
        <td>${migrationsto}</td>
      </tr>
      <tr>
        <th><bean:message key="orgtrustdetails.jsp.sysmigratedfrom"/></th>
        <td>${migrationsfrom}</td>
      </tr>
    </table>

  </body>
</html:html>
