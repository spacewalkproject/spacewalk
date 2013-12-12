<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>

<html:html >
<body>

<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

<div class="toolbar-h2">
  <rhn:icon type="header-info" title="" />
  <bean:message key="system.jsp.customkey.updatetitle"/>
</div>

  <hr />

    <rl:listset name="keySet">
        <rhn:csrf />
        <rhn:submitted />

        <rl:list dataset="pageList"
            name="keyList"
            emptykey="system.jsp.customkey.empty"
            alphabarcolumn="label"
            filter="com.redhat.rhn.frontend.taglibs.list.filters.CustomKeyOverviewFilter">

          <rl:column sortable="true"
              bound="false"
              headerkey="system.jsp.customkey.keylabel"
              sortattr="label"
              defaultsort="asc">

            <a href="/rhn/systems/details/UpdateCustomData.do?sid=${system.id}&cikid=${current.id}">
              <c:out value="${current.label}" />
            </a>
          </rl:column>

           <rl:column sortable="false"
               bound="false"
               headerkey="system.jsp.customkey.description">
             <c:out value="${current.description}" />
          </rl:column>

        </rl:list>

    </rl:listset>
  </body>
</html:html>
