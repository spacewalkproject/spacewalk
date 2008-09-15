<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html:html xhtml="true">
<body>

<html:errors />
<html:messages id="message" message="true">
  <rhn:messages><c:out escapeXml="false" value="${message}" /></rhn:messages>
</html:messages>

<rhn:toolbar base="h1" img="/img/rhn-kickstart_profile.gif" imgAlt="kickstarts.alt.img"> 
  <bean:message key="kickstartranges.jsp.toolbar"/>
</rhn:toolbar>

<div>
    <bean:message key="kickstartranges.jsp.summary"/>
    <p>
    ${urlrange}
    </p>
    <form method="post" name="rhn_list" action="/rhn/kickstart/KickstartIpRanges.do">
      
      <rhn:list pageList="${requestScope.pageList}" noDataText="kickstartranges.jsp.noranges">
          
      <rhn:listdisplay   
          set="${requestScope.set}">
        
        <rhn:column header="kickstartranges.jsp.range">
          <a href="/rhn/kickstart/KickstartIpRangeEdit.do?ksid=${current.id}">${current.iprange.range}</a>
        </rhn:column>
        <rhn:column header="kickstartranges.jsp.profile">
            <a href="/rhn/kickstart/KickstartDetailsEdit.do?ksid=${current.id}">${current.name}</a>
        </rhn:column>        
      </rhn:listdisplay>      
      </rhn:list>
    </form>
</div>

</body>
</html:html>

