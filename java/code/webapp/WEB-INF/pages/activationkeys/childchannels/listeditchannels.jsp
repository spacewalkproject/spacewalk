<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html>

<head>
  <meta name="name" value="activationkeys.jsp.header" />
</head>

<body>
<%@ include file="/WEB-INF/pages/common/fragments/activationkeys/common-header.jspf" %>

<html:form action="/activationkeys/channels/ChildChannels">

  <div class="page-summary">
    <p>
      <bean:message key="activation-key.childchannels.jsp.summary"/>
    </p>
    <c:if test='${not empty baseChannel}'>
      <bean:message key="activation-key.childchannels.jsp.blurb" arg0="${baseChannel}"/>
    </c:if>

    <table class="details">
      <tr>
        <td>
          <select multiple="multiple" name="childChannels" size="6">
          <c:set var="first" scope="session" value="yes"/>
          <c:forEach items="${channels}" var="channel" varStatus="loop">
            <c:choose>
              <c:when test="${first == 'yes'}">
                <c:set var="first" scope="session" value="no"/>
                <c:set var="last_parent" scope="session" value="${channel.parent}"/>
                <c:if test="${empty baseChannel}">
                  <optgroup label="${channel.parent}">
                </c:if>
              </c:when>
              <c:otherwise>
                <c:if test="${(channel.parent != last_parent) && empty baseChannel}">
                  </optgroup>
                  <optgroup label="${channel.parent}">
                </c:if>
              </c:otherwise>
            </c:choose>
            <option value="${channel.id}" ${channel.s}>${channel.name}</option>
            <c:set var="last_parent" scope="session" value="${channel.parent}"/>
          </c:forEach>
          <c:if test="${empty baseChannel}">
            </optgroup>
          </c:if>
        </select>
        </td>
      </tr>
    </table>

    <div align="right">
      <rhn:submitted/>
      <hr/>
      <input type="submit" name ="dispatch" value='<bean:message key="keyedit.jsp.submit"/>'/>
    </div>

    <html:hidden property="submitted" value="true" />
    <c:if test='${not empty param.tid}'>
      <html:hidden property="tid" value="${param.tid}" />
    </c:if>

  </div>
</html:form>

</body>
</html>

