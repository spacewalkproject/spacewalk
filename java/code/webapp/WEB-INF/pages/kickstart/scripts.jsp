<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>

<html:html >
<body>
<c:if test="${! empty kickstart_scripts}">
    <rhn:toolbar base="h1" icon="header-kickstart"
               creationUrl="/rhn/kickstart/KickstartScriptCreate.do?ksid=${ksdata.id}"
               creationType="kickstartscript"
               miscUrl="/rhn/kickstart/KickstartScriptOrder.do?ksid=${ksdata.id}"
               miscText="toolbar.misc.kickstartscript"
               miscImg="action-order.gif"
               miscAlt="toolbar.misc.kickstartscriptalt"
               iconAlt="kickstarts.alt.img">
      <bean:message key="kickstartdetails.jsp.header1" arg0="${fn:escapeXml(ksdata.label)}"/>
    </rhn:toolbar>
</c:if>
<c:if test="${empty kickstart_scripts}">
    <rhn:toolbar base="h1" icon="header-kickstart"
               creationUrl="/rhn/kickstart/KickstartScriptCreate.do?ksid=${ksdata.id}"
               creationType="kickstartscript"
               imgAlt="kickstarts.alt.img">
      <bean:message key="kickstartdetails.jsp.header1" arg0="${fn:escapeXml(ksdata.label)}"/>
    </rhn:toolbar>
</c:if>

<rhn:dialogmenu mindepth="0" maxdepth="1"
    definition="/WEB-INF/nav/kickstart_details.xml"
    renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

<h2><bean:message key="kickstartscript.jsp.header"/></h2>

<div>
    <p>
    <bean:message key="kickstartscript.jsp.summary1"/>
    </p>
    <p>
    <bean:message key="kickstartscript.jsp.summary2"/>
    </p>

    <rl:listset name="kickstartScriptsSet">
        <rhn:csrf />
        <rl:list dataset="kickstart_scripts"
                width="100%"
                name="kickstartPreScripts"
                styleclass="list"
                emptykey="kickstartscript.jsp.noscripts">

            <rl:column bound="false"
                    sortable="false"
                    headerkey="kickstartscript.jsp.type">
                ${current.prettyScriptType}
            </rl:column>

            <rl:column bound="false"
                    sortable="false"
                    headerkey="kickstartscript.jsp.scriptname">
                <c:if test="${current.editable}">
                <a href="/rhn/kickstart/KickstartScriptEdit.do?kssid=${current.id}&amp;ksid=${ksdata.id}">
                <c:out value="${current.scriptName}" escapeXml="true" />
                </a>
                </c:if>
                <c:if test="${not current.editable}">
                <c:out value="${current.scriptName}" escapeXml="true" />
                </c:if>
            </rl:column>

            <rl:column bound="false"
                    sortable="false"
                    headerkey="kickstartscript.jsp.language">
                ${current.prettyInterpreter}
            </rl:column>
        </rl:list>
    </rl:listset>
</div>

</body>
</html:html>

