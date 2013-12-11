<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>

<div class="sideleg">
  <h4><bean:message key="errata-legend.jsp.title"/></h4>
  <ul>
  <li><rhn:icon type="errata-security" /><bean:message key="errata-legend.jsp.security"/></li>
  <li><rhn:icon type="errata-bugfix" /><bean:message key="errata-legend.jsp.bugfix"/></li>
  <li><rhn:icon type="errata-enhance" /><bean:message key="errata-legend.jsp.enhancement"/></li>
  </ul>
</div>
