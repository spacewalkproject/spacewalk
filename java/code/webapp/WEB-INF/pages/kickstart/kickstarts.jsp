<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>


<html:html >
<body>
<rhn:toolbar base="h1" icon="header-kickstart"
               creationUrl="/rhn/kickstart/CreateProfileWizard.do"
               creationType="kickstart"
               imgAlt="kickstarts.alt.img"
               uploadUrl="/rhn/kickstart/AdvancedModeCreate.do"
               uploadType="kickstart"
               uploadAcl="user_role(config_admin)"
               >
  <bean:message key="kickstarts.jsp.toolbar"/>
</rhn:toolbar>

<div>
    <bean:message key="kickstart.jsp.summary"/>
      <rl:listset name="ksSet">
      <rhn:csrf />
      <rhn:submitted />
        <rl:list dataset="pageList" name="ksList" emptykey="kickstart.jsp.nokickstarts"
                        alphabarcolumn="label"
                filter="com.redhat.rhn.frontend.action.kickstart.KickstartProfileFilter">
                <rl:decorator name="ElaborationDecorator"/>
                <rl:decorator name="PageSizeDecorator"/>
                        <rl:column
                        bound="false"
                        headerkey="kickstart.jsp.label"
                        sortattr="label"
                        defaultsort="asc">
                                <c:choose>
                                        <c:when test="${current.advancedMode}">
                                                <a href="/rhn/kickstart/AdvancedModeEdit.do?ksid=${current.id}"><c:out value="${current.label}" escapeXml="true" /></a>
                                        </c:when>
                                        <c:when test="${current.cobbler}">
                                                <c:out value="${current.label}" escapeXml="true" />
                                        </c:when>
                                        <c:otherwise>
                                                <a href="/rhn/kickstart/KickstartDetailsEdit.do?ksid=${current.id}"><c:out value="${current.label}" escapeXml="true" /></a>
                                        </c:otherwise>
                                </c:choose>

                                        <c:if test="${current.orgDefault}">
                            **
                          </c:if>
                </rl:column>
                <rl:column  bound="false" headerkey="kickstart.jsp.active"  sortattr="active">
                <c:if test="${current.active}">
                    <rhn:icon type="item-enabled" title="kickstart.jsp.active" />
                </c:if>
                <c:if test="${not current.active}">
                    <rhn:icon type="item-disabled" title="kickstart.jsp.inactive" />
                </c:if>
                </rl:column>
                <rl:column headerkey="kickstart.distro.label.jsp" sortattr="treeLabel">
                    <c:out value="${current.treeLabel}"/>
                </rl:column>
                <rl:column headerkey="kickstart.distro.sw_managed.jsp" sortattr="cobbler">
                <c:choose>
                    <c:when test="${current.cobbler}">
                        <rhn:icon type="item-disabled" />
                    </c:when>
                    <c:otherwise>
                        <rhn:icon type="item-enabled" />
                    </c:otherwise>
                </c:choose>
            </rl:column>
         </rl:list>

      </rl:listset>
</div>
  <p><rhn:tooltip>* - <bean:message key="kickstarts.distro.cobbler-only.tooltip"/></rhn:tooltip></p>
  <c:if test="${not empty requestScope.orgDefaultExists}">
        <p><rhn:tooltip>** - <bean:message key="kickstart.list.jsp.orgdefault"/></rhn:tooltip></p>
  </c:if>
</body>
</html:html>

