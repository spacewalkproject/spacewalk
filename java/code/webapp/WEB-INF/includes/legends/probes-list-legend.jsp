<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>

<div class="sideleg">
  <h4><bean:message key="probes-list-legend.jsp.title"/></h4>
  <ul>
  <li><i class="fa fa-1-5x spacewalk-icon-health text-success"></i>
    <bean:message key="probes-list-legend.jsp.ok"/>
  </li>
  <li><i class="fa fa-1-5x spacewalk-icon-health text-warning"></i>
    <bean:message key="probes-list-legend.jsp.warning"/>
  </li>
  <li><i class="fa fa-1-5x spacewalk-icon-health text-danger"></i>
    <bean:message key="probes-list-legend.jsp.critical"/>
  </li>
  <li><i class="fa fa-1-5x spacewalk-icon-health-unknown"></i>
    <bean:message key="probes-list-legend.jsp.unknown"/>
  </li>
  <li><i class="fa fa-1-5x spacewalk-icon-health-pending"></i>
    <bean:message key="probes-list-legend.jsp.pending"/>
  </li>
  </ul>
</div>

