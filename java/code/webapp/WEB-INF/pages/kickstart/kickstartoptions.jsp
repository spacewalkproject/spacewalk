<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html:html xhtml="true">
<body>
<%@ include file="/WEB-INF/pages/common/fragments/kickstart/kickstart-toolbar.jspf" %>

<rhn:dialogmenu mindepth="0" maxdepth="1"
    definition="/WEB-INF/nav/kickstart_details.xml"
    renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

<h2><bean:message key="kickstartoptions.jsp.header1"/></h2>

<div>
  <p>
    <bean:message key="kickstartoptions.jsp.summary"/>
  </p>
    <form method="post" action="/rhn/kickstart/KickstartOptionsEdit.do">
      <table class="details">

          <c:forEach items="${options}" var="option">
            <tr>
              <c:if test="${option.required}">
              <th><rhn:required-field>${option.name}</rhn:required-field>:</th>
              </c:if>
              <c:if test="${not option.required}">
              <th>${option.name}:</th>
              </c:if>
              <c:choose>
                <c:when test="${option.enabled}">
                  <c:set var="enabled" value="checked=\"checked\""/>
                </c:when>
                <c:otherwise>
                  <c:set var="enabled" value="" />
                </c:otherwise>
              </c:choose>

              <c:choose>
                <c:when test="${option.hasArgs}">
                  <td><input type="checkbox" name="${option.name}" value="${option.name}" ${enabled} /></td>
                  <td>
                      <input type="text" name="<c:out value="${option.name}" />_txt" value="${option.arg}" size="64"/><br/>
                      <c:if test="${option.additionalNotesKey != null}">
                          <bean:message key="${option.additionalNotesKey}"/>
                      </c:if>
                  </td>
                </c:when>
                <c:otherwise>
                  <td colspan="2"><input type="checkbox" name="${option.name}" value="${option.name}" ${enabled} /></td>
                </c:otherwise>
              </c:choose>
            </tr>
          </c:forEach>

         <tr>
         		<th><bean:message key="kickstartoptions.jsp.customoptions"/></th>
         		<td></td>
			<td><textarea rows="8" cols="64" name="customOptions"><c:forEach items="${customOptions}" var="option"><c:out value="${option.arguments}" /></c:forEach></textarea>
            <BR><bean:message key="kickstartoptions.jsp.customoptionsnote"/>
            <BR><bean:message key="kickstartoptions.jsp.customoptionstip"/></td>
         </tr>

          <tr>
            <td align="right" colspan="3"><input type="submit" value="<bean:message key="kickstartoptions.jsp.updatekickstart"/>"/></td>
          </tr>

      </table>
      <input type="hidden" name="ksid" value="${ksdata.id}"/>
      <input type="hidden" name="submitted" value="true"/>
    </form>
</div>

</body>
</html:html>

