<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>

<div class="sideleg">
  <h4><bean:message key="system-group-legend.jsp.title"/></h4>
  <ul>
    <li><i class="fa fa-check-circle fa-1-5x text-success"></i><bean:message key="system-group-legend.jsp.fully"/></li>
    <li><i class="fa fa-exclamation-circle fa-1-5x text-danger"></i><bean:message key="system-group-legend.jsp.updates"/></li>
    <li><i class="fa fa-exclamation-triangle fa-1-5x text-warning"></i><bean:message key="system-group-legend.jsp.critical"/></li>
  </ul>
</div>
