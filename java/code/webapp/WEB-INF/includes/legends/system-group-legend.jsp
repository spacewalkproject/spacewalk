<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>

<div class="sideleg">
  <h4><bean:message key="system-group-legend.jsp.title"/></h4>
  <ul>
    <li><rhn:icon type="system-ok" /><bean:message key="system-group-legend.jsp.fully"/></li>
    <li><rhn:icon type="system-crit"><bean:message key="system-group-legend.jsp.updates"/></li>
    <li><rhn:icon type="system-warn"><bean:message key="system-group-legend.jsp.critical"/></li>
  </ul>
</div>
