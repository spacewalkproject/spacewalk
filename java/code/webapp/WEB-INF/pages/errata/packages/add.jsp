<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>

<html:xhtml/>
<html>
<head>
    <meta name="page-decorator" content="none" />
    <!-- disables the enter key from submitting the form -->
    <script type="text/javascript" language="JavaScript">
		function key(e) {
		var pkey = e ? e.which : window.event.keyCode;
		return pkey != 13;
		}
		document.onkeypress = key;
		if (document.layers) document.captureEvents(Event.KEYPRESS);
    </script>
</head>
<body>
<rhn:toolbar base="h1" img="/img/rhn-icon-errata.gif" imgAlt="errata.common.errataAlt"
	           helpUrl="/rhn/help/channel-mgmt/en-US/channel-mgmt-Custom_Errata_Management-Managed_Errata_Details.jsp">
    <bean:message key="errata.edit.toolbar"/> <c:out value="${advisory}" />
  </rhn:toolbar>

  <rhn:dialogmenu mindepth="0" maxdepth="1" definition="/WEB-INF/nav/manage_errata.xml"
                  renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

  <h2><bean:message key="errata.edit.packages.addpackages"/></h2>

  <p><bean:message key="errata.edit.packages.add.instructions"/></p>

    <rl:listset name="groupSet">




  <p>
      <bean:message key="errata.edit.packages.add.viewlabel"/>
      <select name="view_channel">
          <c:forEach items="${viewoptions}" var="option">
              <option value="<c:out value="${option.value}"/>"
                      <c:if test="${option.value == param.view_channel}">selected="1"</c:if>>
                  <c:out value="${option.label}"/>
              </option>
          </c:forEach>
      </select>
      <html:submit property="view_click">
          <bean:message key="errata.edit.packages.add.viewsubmit"/>
      </html:submit>
  </p>



        <input type="hidden" name="eid" value="<c:out value="${param.eid}"/>" />

        <rl:list dataset="pageList"
                 width="100%"
                 styleclass="list"
                 emptykey="packagelist.jsp.nopackages">

            <rl:decorator name="PageSizeDecorator"/>
            <rl:decorator name="SelectableDecorator"/>
            <rl:decorator name="ElaborationDecorator"/>

            <rl:selectablecolumn value="${current.selectionKey}"
                                 selected="${current.selected}"
                                 disabled="${not current.selectable}"
                                 styleclass="first-column"/>

            <rl:column headerkey="errata.edit.packages.add.package" bound="false"
                       sortattr="packageNvre" sortable="true" filterattr="packageNvre">
                <a href="/rhn/software/packages/Details.do?pid=${current.id}">
                    <c:out value="${current.packageNvre}" escapeXml="false"/>
                </a>
            </rl:column>

            <rl:column headerkey="errata.edit.packages.add.channels" bound="false"
                       styleclass="last-column">
                <c:choose>
                  <c:when test="${current.packageChannels != null}">
                    <c:forEach items="${current.packageChannels}" var="channel">
                      <c:out value="${channel}"/> <br />
                    </c:forEach>
                  </c:when>
                  <c:otherwise>
                    (none)
                  </c:otherwise>
                </c:choose>
            </rl:column>
        </rl:list>

        <div align="right">
            <rhn:submitted/>
            <hr/>
            <input type="submit"
                   name="dispatch"
                   value='<bean:message key="errata.edit.packages.add.addpackages"/>'/>
        </div>

    </rl:listset>

</body>
</html>
