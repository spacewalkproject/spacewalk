<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html:html >
<body>
  <rhn:toolbar base="h1" icon="fa-retweet" iconAlt="info.alt.img">
    <bean:message key="distchannelmap.jsp.delete"/>
  </rhn:toolbar>
  <h2><bean:message key="distchannelmap.jsp.delete"/></h2>

  <div class="page-summary">
    <c:choose>
      <c:when test="${empty dcmap.org}">
        <p><bean:message key="distchannelmap.jsp.delete.default.summary"/></p>
      </c:when>
      <c:otherwise>
        <p><bean:message key="distchannelmap.jsp.delete.summary"/></p>
      </c:otherwise>
    </c:choose>
  </div>

<html:form method="post" action="/channels/manage/DistChannelMapDelete">
  <rhn:csrf />
  <rhn:submitted/>
  <table class="details">
    <tr>
      <th>
        <bean:message key="Operating System"/>
      </th>
      <td>
        <c:out value="${dcmap.os}"/>
      </td>
    </tr>
    <tr>
      <th>
          <bean:message key="column.release"/>
      </th>
      <td>
       <c:out value="${dcmap.release}"/>
      </td>
    </tr>
    <tr>
      <th>
	    <bean:message key = "column.architecture"/>
      </th>
      <td>
        <c:out value="${dcmap.channelArch.name}"/>
      </td>
    </tr>
    <tr>
      <th>
	    <bean:message key = "channel.edit.jsp.label"/>
      </th>
      <td>
        <c:out value="${dcmap.channel.label}"/>
      </td>
    </tr>
  </table>

  <div class="text-right">
  <hr />
    <html:submit disabled="${empty dcmap.org}"><bean:message key="distchannelmap.jsp.delete.submit"/></html:submit>
    <html:hidden property="dcm" value="${dcmap.id}" />
</html:form>

</body>
</html:html>
