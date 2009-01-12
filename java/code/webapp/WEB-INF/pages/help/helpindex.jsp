<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>

<html>
<head>
<script type="text/javascript" src="/javascript/highlander.js"></script>
</head>
<body>

    <h1><img src="/img/rhn-icon-help-h1.gif" alt="help" /><bean:message key="help.jsp.helpdesk"/></h1>


    <ul id="help-url-list">

      <li>
        <a style="font-size:12pt" href="https://www.redhat.com/docs/manuals/satellite">
          <bean:message key="help.jsp.refguide"/>
	</a>

        <strong><bean:message key="help.jsp.translation"/></strong>
        <br />
        <bean:message key="help.jsp.detailed"/>
      </li>





      <li>
        <a href="https://www.redhat.com/docs/manuals/satellite" style="font-size:12pt;"> <bean:message key="help.jsp.install.title"/></a> <strong>(Translations available)</strong>

        <br />
         <bean:message key="help.jsp.install"/>
      </li>

      <li>
        <a href="https://www.redhat.com/docs/manuals/satellite" style="font-size:12pt;"><bean:message key="help.jsp.proxy.title"/></a> 
        <br />
                 <bean:message key="help.jsp.proxy"/>
      </li>

      <li>

        <a href="https://www.redhat.com/docs/manuals/satellite" style="font-size:12pt;"><bean:message key="help.jsp.clients.title"/>  </a> 
        <strong><bean:message key="help.jsp.translation"/></strong>
        <br />
                  <bean:message key="help.jsp.clients"/>       
      </li>

      <li>
        <a href="https://www.redhat.com/docs/manuals/satellite" style="font-size:12pt;"><bean:message key="help.jsp.channel.title"/></a>
        <strong><bean:message key="help.jsp.translation"/></strong>

        <br />
        <bean:message key="help.jsp.channel"/>     
      </li>



      <li>
        <a href="https://www.redhat.com/docs/manuals/satellite" style="font-size:12pt;"><bean:message key="help.jsp.release.title"/> </a>
        <strong><bean:message key="help.jsp.translation"/></strong><br />
   
      </li>

      <li>
        <a href="https://www.redhat.com/docs/manuals/satellite" style="font-size:12pt;"><bean:message key="help.jsp.proxyrelease.title"/></a>
        <strong><bean:message key="help.jsp.translation"/></strong><br />
    
      </li>



    </ul>

  

	</td>
      </tr>
    </table>


</body>
</html>
