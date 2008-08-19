<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>

<html:html xhtml="true">
<body>

<html:messages id="message" message="true">
  <rhn:messages><c:out escapeXml="false" value="${message}" /></rhn:messages>
</html:messages>
  
<rhn:toolbar base="h1" img="/img/rhn-icon-errata.gif"
             helpUrl="/rhn/help/channel-mgmt/en/channel-mgmt-Custom_Errata_Management-Cloning_Errata.jsp">
   <bean:message key="cloneerrata.jsp.erratamanagement" />
</rhn:toolbar>
<h2><bean:message key="cloneerrata.jsp.cloneerrata"/></h2>
<div class="page-summary">
<p><bean:message key="cloneerrata.jsp.pagesummary"/></p>
</div>
<br />
<html:form action="/errata/manage/CloneErrataSubmit">
  <bean:message key="cloneerrata.jsp.viewapplicableerrata" />:
  <html:select property="channel">
    <html:options collection="clonablechannels" property="value" labelProperty="label"/> 
  </html:select>
  <html:submit>
        <bean:message key="cloneerrata.jsp.view"/>
  </html:submit>
  <br />
  <html:checkbox property="showalreadycloned" value="1" /> <bean:message key="cloneerrata.jsp.showclonederrata" />

<rhn:list pageList="${requestScope.pageList}"
          noDataText="cloneerrata.jsp.noerrata"
          legend="errata">

  <rhn:listdisplay set="${requestScope.set}" hiddenvars="${requestScope.newset}"
                   button="cloneerrata.jsp.cloneerrata">
    <rhn:set value="${current.id}" />
    <rhn:column header="cloneerrata.jsp.type">
       ${current.advisoryType}
    </rhn:column>
    <rhn:column header="cloneerrata.jsp.advisory">
      <a href="/rhn/errata/details/Details.do?eid=${current.id}">${current.advisoryName}</a>
    </rhn:column>
    <rhn:column header="cloneerrata.jsp.synopsis">
      ${current.synopsis}
    </rhn:column>
    <rhn:column header="cloneerrata.jsp.updated">
      ${current.updateDate}
    </rhn:column>
    <rhn:column header="cloneerrata.jsp.potentialchannels">
      <c:forEach items="${current.channelMap}" var="map">
      <a href="/network/software/channels/manage/index.pxt?cid=${map.id}">${map.name}</a><br/>
      </c:forEach>
    </rhn:column>
    <rhn:column header="cloneerrata.jsp.alreadycloned">
      <c:choose>
      <c:when test="${current.alreadyCloned}">
      	<bean:message key="yes"/>
      </c:when>
      <c:otherwise>
      	<bean:message key="no"/>
      </c:otherwise>
      </c:choose>
    </rhn:column>
  </rhn:listdisplay>
 </rhn:list>
<input type="hidden" name="submitted" value="true"/>
</html:form>
</body>
</html:html>
