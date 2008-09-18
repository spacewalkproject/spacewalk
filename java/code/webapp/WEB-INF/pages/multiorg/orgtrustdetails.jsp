<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html:html xhtml="true">
  <body>    
    <rhn:toolbar base="h1" img="/img/rhn-icon-org.gif" >
      ${org}
    </rhn:toolbar>
    <h2><bean:message key="orgtrustdetails.jsp.header1"/></h2>    
    <table class="details">
      <tr>
        <th><bean:message key="orgtrustdetails.jsp.created"/></th>
        <td></td>
      </tr>
      <tr>
        <th><bean:message key="orgtrustdetails.jsp.trusted"/></th>
        <td></td>
      </tr>      
    </table>
<h2><bean:message key="orgtrustdetails.jsp.header2"/></h2>    
    <table class="details">
      <tr>
        <th><bean:message key="orgtrustdetails.jsp.channelsprovided"/></th>
        <td></td>
      </tr>
      <tr>
        <th><bean:message key="orgtrustdetails.jsp.channelsconsumed"/></th>
        <td></td>
      </tr>      
    </table>
<h2><bean:message key="orgtrustdetails.jsp.header3"/></h2>    
    <table class="details">
      <tr>
        <th><bean:message key="orgtrustdetails.jsp.sysmigratedto"/></th>
        <td></td>
      </tr>
      <tr>
        <th><bean:message key="orgtrustdetails.jsp.sysmigratedfrom"/></th>
        <td></td>
      </tr>      
    </table>
          
  </body>
</html:html>
