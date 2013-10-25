<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html:html xhtml="true">
<body>
<%@ include file="/WEB-INF/pages/common/fragments/kickstart/kickstart-toolbar.jspf" %>

<rhn:dialogmenu mindepth="0" maxdepth="1"
    definition="/WEB-INF/nav/kickstart_table.xml"
    renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

<h2><bean:message key="kickstarttable.jsp.header2"/></h2>
<div>
<c:choose><c:when test="${empty requestScope.invalid}">
    <bean:message key="kickstarttable.jsp.summary1"/>
    <html:form method="post" action="/kickstart/KickstartDetailsEdit.do">
      <rhn:csrf />
      <html:hidden property="ksid" value="${ksdata.id}"/>
      <html:hidden property="submitted" value="true"/>
      <table class="table">
          <tr>
            <th><rhn:required-field key="kickstarttable.jsp.label"/>:</th>
            <td><html:text property="label" maxlength="64" size="32" /><br/>
            <span class="small-text"><bean:message key="kickstarttable.jsp.labelwarning" /></span></td>
          </tr>
          <tr>
            <th><bean:message key="kickstarttable.jsp.install_type" /></th>
            <td><strong><c:out value="${ksdata.kickstartDefaults.kstree.channel.name}"/></strong>
            <a href="/rhn/kickstart/KickstartSoftwareEdit.do?ksid=${ksdata.id}">(<bean:message key="kickstarttable.jsp.changeos"/>)</a></td>
          </tr>

		<%@ include file="/WEB-INF/pages/common/fragments/kickstart/virtoptions.jspf" %>

          <tr>
            <th><bean:message key="kickstarttable.jsp.active"/></th>
            <td>
                <table>
                    <tr>
                        <td>
                            <html:checkbox property="active" />
                        </td>
                        <td>
                            <span class="small-text"><bean:message key="kickstarttable.jsp.activeDescription"/></span>
                        </td>
                    </tr>
                </table>
            </td>
          </tr>
          <tr>
            <th><bean:message key="kickstarttable.jsp.postlog"/></th>
            <td><table><tr><td><html:checkbox property="post_log" /></td><td><bean:message key="kickstarttable.jsp.postlog.msg"  /></td></tr></table></td>
          </tr>
          <tr>
            <th><bean:message key="kickstarttable.jsp.prelog"/></th>
            <td><table><tr><td><html:checkbox property="pre_log" /></td><td><bean:message key="kickstarttable.jsp.prelog.msg"  /></td></tr></table></td>
          </tr>
          <tr>
            <th><bean:message key="kickstarttable.jsp.kscfg"/></th>
            <td><table><tr><td><html:checkbox property="ksCfg" /></td><td><bean:message key="kickstarttable.jsp.kscfg.msg"  /></td></tr></table></td>
          </tr>
          <tr>
            <th><bean:message key="kickstarttable.jsp.org_default" /></th>
            <td><table><tr><td><html:checkbox property="org_default" /></td><td><bean:message key="kickstarttable.jsp.summary2" arg0="${ksurl}" /></td></tr></table></td>
          </tr>
          <tr>
            <th><bean:message key="kickstarttable.jsp.kernel_options"/></th>
            <td><html:text property="kernel_options" maxlength="1024" size="32" /></td>
          </tr>

         <tr>
            <th><bean:message key="kickstarttable.jsp.post_kernel_options"/></th>
            <td><html:text property="post_kernel_options" maxlength="1024" size="32" /></td>
          </tr>

          <tr>
            <th><bean:message key="kickstarttable.jsp.comments"/></th>
            <td><html:textarea property="comments" cols="80" rows="6"/></td>
          </tr>

          <tr>
            <td align="right" colspan="2"><html:submit><bean:message key="kickstarttable.jsp.updatekickstart"/></html:submit></td>
          </tr>
      </table>
    </html:form>
    </c:when>
    <c:otherwise>
    <p><bean:message key="kickstarttable.invalid.jsp.summary"/>
		<bean:message key="kickstarttable.invalid.jsp.summary-option1"
				 arg0="${ksdata.tree.label}"
				 arg1="/rhn/kickstart/TreeEdit.do?kstid=${ksdata.tree.id}"/></p>
        <p><bean:message key="kickstarttable.invalid.jsp.summary-option2"
				arg0="/rhn/kickstart/KickstartSoftwareEdit.do?ksid=${ksdata.id}"/></p>
    </c:otherwise>
    </c:choose>
</div>

</body>
</html:html>

