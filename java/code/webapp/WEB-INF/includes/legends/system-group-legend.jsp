<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>

<div class="sideleg">
  <h4><bean:message key="system-group-legend.jsp.title"/></h4>
  <ul>
    <li><i class="icon-ok-sign spacewalk-icon-green icon-1-5x"></i><bean:message key="system-group-legend.jsp.fully"/></li>
    <li><i class="icon-exclamation-sign spacewalk-icon-yellow icon-1-5x"></i><bean:message key="system-group-legend.jsp.updates"/></li>
    <li><i class="icon-warning-sign spacewalk-icon-red icon-1-5x"></i><bean:message key="system-group-legend.jsp.critical"/></li>
  </ul>
</div>
