<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/config-managment" prefix="cfg" %>
<html:xhtml/>
<html>
<head>
<script src="/javascript/rank_options.js" type="text/javascript"></script>
</head>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/kickstart/kickstart-toolbar.jspf" %>



<rhn:dialogmenu mindepth="0" maxdepth="1"
    definition="/WEB-INF/nav/kickstart_details.xml"
    renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

<h2><bean:message key="kickstartscript.order.header"/></h2>

<div>
  <p>
    <bean:message key="kickstartscript.order.summary"/>
  </p>

    <html:form method="post" action="/kickstart/KickstartScriptOrder.do">
      <rhn:csrf />
      <rhn:submitted />

      <noscript>
          <p><bean:message key="kickstartscript.order.noscript"/></p>
      </noscript>
      <table style="width:100%;">
          <tr>
            <td colspan="2">
              <h2><bean:message key="kickstartscript.order.prescripts"/></h2>
            </td>
            <td colspan="2">
              <h2><bean:message key="kickstartscript.order.postscripts"/></h2>
            </td>
          </tr>
          <tr>
            <td style="width:40%;">
              <c:if test="${empty kickstartScriptOrderForm.map.preScripts}">
              <html:select name="kickstartScriptOrderForm"
	             property="selectedPre"
	             disabled="true"
	             size="15" styleId="preRanksWidget" style="width:100%;">
                <html:optionsCollection name="kickstartScriptOrderForm"
	                        property="preScripts"/>
              </html:select>
              </c:if>
              <c:if test="${not empty kickstartScriptOrderForm.map.preScripts}">
              <html:select name="kickstartScriptOrderForm"
	             property="selectedPre"
	             size="15" styleId="preRanksWidget" style="width:100%;">
                <html:optionsCollection name="kickstartScriptOrderForm"
	                        property="preScripts"/>
              </html:select>
              </c:if>
            </td>
            <td valign="top">
              <table>
	            <tr>
                  <td><html:image src="/img/button-up.gif"
                    altKey="ssm.config.rank.jsp.up"
                    property="dispatch"
                    value="up"
                    onclick="return move_selected_up('preRanksWidget');"
                    styleClass="button"/>
	            </td></tr>
	            <tr>
	            <td><html:image src="/img/button-down.gif"
	                altKey="ssm.config.rank.jsp.down"
	                property="dispatch"
	                value="down"
	                onclick="return move_selected_down('preRanksWidget');"
	                styleClass="button"/>
                </td></tr>
              </table>
              <rhn:noscript/>
            </td>
            <td style="width:40%;">
              <c:if test="${empty kickstartScriptOrderForm.map.postScripts}">
              <html:select name ="kickstartScriptOrderForm"
	             property="selectedPost"
	             disabled="true"
	             size="15" styleId="postRanksWidget" style="width:100%;">
                <html:optionsCollection name="kickstartScriptOrderForm"
	                        property="postScripts"/>
              </html:select>
              </c:if>
              <c:if test="${not empty kickstartScriptOrderForm.map.postScripts}">
              <html:select name ="kickstartScriptOrderForm"
	             property="selectedPost"
	             size="15" styleId="postRanksWidget" style="width:100%;">
                <html:optionsCollection name="kickstartScriptOrderForm"
	                        property="postScripts"/>
              </html:select>
              </c:if>
            </td>
            <td valign="top">
              <table>
	            <tr>
                  <td><html:image src="/img/button-up.gif"
                    altKey="ssm.config.rank.jsp.up"
                    property="dispatch"
                    value="up"
                    onclick="return move_selected_up('postRanksWidget');"
                    styleClass="button"/>
	            </td></tr>
	            <tr>
	            <td><html:image src="/img/button-down.gif"
	                altKey="ssm.config.rank.jsp.down"
	                property="dispatch"
	                value="down"
	                onclick="return move_selected_down('postRanksWidget');"
	                styleClass="button"/>
                </td></tr>
              </table>
              <rhn:noscript/>
            </td>
          </tr>
      </table>
      <html:hidden property="ksid" value="${ksdata.id}"/>
      <html:hidden property="submitted" value="true"/>
      <html:hidden property="dispatch" value="${rhn:localize('kickstartscript.order.update')}"/>
      <html:hidden name="kickstartScriptOrderForm" property="rankedPreValues" styleId="rankedPreValues"/>
      <html:hidden name="kickstartScriptOrderForm" property="rankedPostValues" styleId="rankedPostValues"/>
      <div align="right">
            <input type="submit" name="dispatcher"
			value="${rhn:localize('kickstartscript.order.update')}"
                   onclick="handle_ranking('preRanksWidget','rankedPreValues','kickstartScriptOrderForm'); handle_ranking_dispatch('postRanksWidget','rankedPostValues','kickstartScriptOrderForm');"/>
      </div>
    </html:form>
</div>
</body>
</html>