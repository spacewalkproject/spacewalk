<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html:xhtml/>
<html>
<body>
<div class="toolbar-h1">
  <div class="toolbar">
    <span class="toolbar">
      <a href="TreeCreate.do"><img src="/img/action-add.gif" alt="<bean:message key="kickstart.kickstartable_distro_create_new.jsp" />" title="<bean:message key="kickstart.kickstartable_distro_create_new.jsp" />" /><bean:message key="kickstart.kickstartable_distro_create_new.jsp" /></a>
     </span>
   </div><img alt="<bean:message key="kickstarts.alt.img"/>" src="/img/rhn-kickstart_profile.gif" />  
  <bean:message key="kickstart.kickstartable_distributions.jsp" />    
</div>


<div class="page-summary">
  <p>
    <bean:message key="kickstart.kickstartable_distributions_text.jsp" />
  </p>
  <div>
  <form name="distribForm"  method="POST" action="/rhn/kickstart/ViewTrees.do">
    <c:set var="pageList" value="${requestScope.pageList}" />  
    <rhn:list pageList="${requestScope.pageList}" noDataText="kickstart.distributions.jsp.nolists">          
      <rhn:listdisplay renderDisabled="true" set="${requestScope.set}" hiddenvars="${requestScope.newset}">
        <rhn:column header="kickstart.jsp.label">
            <a href="/rhn/kickstart/TreeEdit.do?kstid=${current.id}">${current.kickstartlabel}</a>
        </rhn:column>
        <rhn:column header="softwareedit.jsp.basechannel">
          ${current.channellabel}
        </rhn:column>
      </rhn:listdisplay>      
    </rhn:list>
  </form>  
  </div>
</div>
</body>
</html>
