<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>

<div class="sideleg">
  <h4><bean:message key="probes-list-legend.jsp.title"/></h4>
  <ul>
  <li><i class="spacewalk-icon-health spacewalk-icon-green icon-1-5x"></i>
    <bean:message key="probes-list-legend.jsp.ok"/>
  </li>
  <li><i class="spacewalk-icon-health spacewalk-icon-yellow icon-1-5x"></i>
    <bean:message key="probes-list-legend.jsp.warning"/>
  </li>
  <li><i class="spacewalk-icon-health spacewalk-icon-red icon-1-5x"></i>
    <bean:message key="probes-list-legend.jsp.critical"/>
  </li>
  <li><i class="spacewalk-icon-health-unknown icon-1-5x"></i>
    <bean:message key="probes-list-legend.jsp.unknown"/>
  </li>
  <li><i class="spacewalk-icon-health-pending icon-1-5x"></i>
    <bean:message key="probes-list-legend.jsp.pending"/>
  </li>
  </ul>
</div>

