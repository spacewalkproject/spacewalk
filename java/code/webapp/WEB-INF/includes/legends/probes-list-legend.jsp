<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>

<div class="sideleg">
  <h4><bean:message key="probes-list-legend.jsp.title"/></h4>
  <ul>
  <li><rhn:icon type="monitoring-ok" />
    <bean:message key="probes-list-legend.jsp.ok"/>
  </li>
  <li><rhn:icon type="monitoring-warn" />
    <bean:message key="probes-list-legend.jsp.warning"/>
  </li>
  <li><rhn:icon type="monitoring-crit" />
    <bean:message key="probes-list-legend.jsp.critical"/>
  </li>
  <li><rhn:icon type="monitoring-unknown" />
    <bean:message key="probes-list-legend.jsp.unknown"/>
  </li>
  <li><rhn:icon type="monitoring-pending" />
    <bean:message key="probes-list-legend.jsp.pending"/>
  </li>
  </ul>
</div>

