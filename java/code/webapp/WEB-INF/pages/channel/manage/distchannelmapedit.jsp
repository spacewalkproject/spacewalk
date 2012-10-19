<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html:html xhtml="true">
<body>
<c:choose>
	<c:when test="${empty dcm}">
      <rhn:toolbar base="h1" img="/img/rhn-icon-subscribe_replace.png" imgAlt="info.alt.img">
        <bean:message key="distchannelmap.jsp.create"/>
      </rhn:toolbar>
      <h2><bean:message key="distchannelmap.jsp.create"/></h2>
	</c:when>
	<c:otherwise>
      <rhn:toolbar base="h1" img="/img/rhn-icon-subscribe_replace.png" imgAlt="info.alt.img"
		           deletionUrl="DistChannelMapDelete.do?dcm=${dcm}"
                   deletionType="distchannelmap">
        <bean:message key="distchannelmap.jsp.update"/>
      </rhn:toolbar>
      <h2><bean:message key="distchannelmap.jsp.update"/></h2>
	</c:otherwise>
</c:choose>

<div class="page-summary">
  <p><bean:message key="distchannelmap.jsp.edit.summary"/></p>
</div>


<html:form action="/channels/manage/DistChannelMapEdit">
  <rhn:csrf />
  <rhn:submitted/>
  <table class="details">
    <tr>
      <th>
        <label for="os">
          <rhn:required-field key = "Operating System"/>
        </label>
      </th>
      <td>
        <html:text property="os" styleId="os"/>
      </td>
    </tr>
    <tr>
      <th>
        <label for="release">
          <rhn:required-field key = "column.release"/>
        </label>
      </th>
      <td>
        <c:choose>
          <c:when test="${empty dcm}">
            <html:text property="release" styleId="release" disabled="${not empty dcm}"/>
          </c:when>
          <c:otherwise>
            <c:out value="${release}"/>
            <html:hidden property="release" value="${release}"/>
          </c:otherwise>
        </c:choose>
      </td>
    </tr>
    <tr>
      <th>
	    <rhn:required-field key = "column.architecture"/>
      </th>
      <td>
        <c:choose>
          <c:when test="${empty dcm}">
            <html:select property="architecture">
                <html:options collection="channelArches"
                  property="value" labelProperty="label" />
            </html:select>
          </c:when>
          <c:otherwise>
            <c:out value="${architecture}"/>
            <html:hidden property="architecture" value="${architecture}"/>
          </c:otherwise>
        </c:choose>
      </td>
    </tr>
    <tr>
      <th>
	    <rhn:required-field key = "channel.edit.jsp.label"/>
      </th>
      <td>
        <html:select property="channel_label">
          <html:options collection="channels"
            property="value" labelProperty="label" />
        </html:select>
      </td>
    </tr>
  </table>

  <div align="right">
  <hr />
    <c:choose>
	  <c:when test="${empty dcm}">
	    <html:submit><bean:message key="distchannelmap.jsp.create.submit"/></html:submit>
      </c:when>
      <c:otherwise>
	    <html:submit><bean:message key="distchannelmap.jsp.update.submit"/></html:submit>
      </c:otherwise>
	</c:choose>

    <html:hidden property="dcm" value="${dcm}" />
</html:form>

</body>
</html:html>
