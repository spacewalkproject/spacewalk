<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>

<html:html xhtml="true">
<body>
<br>



<div>
  <div class="toolbar-h1">
    <div class="toolbar">
      <span class="toolbar">
        <a href="/rhn/systems/customdata/DeleteCustomKey.do?cikid=${cikid}">
        <img src="/img/action-del.gif" alt="delete key" title="delete key" />delete key</a>
      </span>
    </div>
    <img src="/img/rhn-icon-keyring.gif" alt="" />
    <bean:message key="system.jsp.customkey.updatetitle"/>

    <a href="/rhn/help/reference/en-US/s1-sm-systems.jsp#s2-sm-system-cust-info" target="_new" class="help-title">
      <img src="/img/rhn-icon-help.gif" alt="Help Icon" />
    </a>
  </div>

  <div class="page-summary">
    <p><bean:message key="system.jsp.customkey.updatemsg"/></p>
  </div>

  <hr />
    <rl:listset name="systemListSet" legend="system">
  <rhn:csrf />
  <rhn:submitted/>

    <table class="details">
      <tr>
        <th><bean:message key="system.jsp.customkey.keylabel"/>:</th>
        <td>${label}</td>
      </tr>

      <tr>
        <th><bean:message key="system.jsp.customkey.description"/>:</th>
        <td>
          <textarea wrap="virtual" rows="6" cols="50" name="description"><c:out value="${description}" /></textarea>
        </td>
      </tr>

      <tr>
        <th><bean:message key="system.jsp.customkey.created"/>:</th>
        <td>${created} by ${creator}</td>
      </tr>

      <tr>
        <th><bean:message key="system.jsp.customkey.modified"/>:</th>
        <td>${modified} by ${modifier}</td>
      </tr>
    </table>

    <div align="right">
      <hr />

      <input type="submit" name="dispatch" value="${rhn:localize('system.jsp.customkey.updatebutton')}" />

      <input type="hidden" name="cikid" value="${param.cikid}" />
    </div>
</div>
<div>
  <h2><bean:message key="system.jsp.customkey.updateheader"/></h2>

        <rl:list
            emptykey="system.jsp.customkey.noservers"
            alphabarcolumn="name">
          <rl:decorator name="PageSizeDecorator"/>

          <!-- Name Column -->
          <rl:column sortable="true"
              bound="false"
              headerkey="systemlist.jsp.system"
              sortattr="name"
              filterattr="name"
              defaultsort="asc">
            <a href="/rhn/systems/details/Overview.do?sid=${current.id}">${current.name}</a>
          </rl:column>

          <!-- Values Column -->
            <rl:column sortable="false"
                bound="false"
                headerkey="system.jsp.customkey.value">
              <c:out value="${current.value}" />
            </rl:column>

          <!-- Last Checkin Column -->
          <rl:column sortable="false"
                bound="false"
                headerkey="system.jsp.customkey.last_checkin">
              <c:out value="${current.last_checkin}" />
          </rl:column>
        </rl:list>
      </rl:listset>
</div>
  </body>
</html:html>
