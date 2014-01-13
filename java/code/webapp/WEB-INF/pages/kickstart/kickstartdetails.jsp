<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html:html >
<body>
<%@ include file="/WEB-INF/pages/common/fragments/kickstart/kickstart-toolbar.jspf" %>

<rhn:dialogmenu mindepth="0" maxdepth="1"
    definition="/WEB-INF/nav/kickstart_details.xml"
    renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

<h2><bean:message key="kickstartdetails.jsp.header2"/></h2>
<div>
<c:choose><c:when test="${empty requestScope.invalid}">
    <bean:message key="kickstartdetails.jsp.summary1"/>
    <html:form method="post" action="/kickstart/KickstartDetailsEdit.do" styleClass="form-horizontal">
      <rhn:csrf />
      <html:hidden property="ksid" value="${ksdata.id}"/>
      <html:hidden property="submitted" value="true"/>
      <div class="form-group">
          <label class="col-lg-3 control-label"><rhn:required-field key="kickstartdetails.jsp.label"/>:</label>
          <div class="col-lg-6"><html:text property="label" maxlength="64" size="32" styleClass="form-control" /><br/>
            <span class="small-text"><bean:message key="kickstartdetails.jsp.labelwarning" /></span>
          </div>
      </div>

      <div class="form-group">
          <label class="col-lg-3 control-label"><bean:message key="kickstartdetails.jsp.install_type" /></label>
          <div class="col-lg-6"><strong><c:out value="${ksdata.kickstartDefaults.kstree.channel.name}"/></strong>
            <a href="/rhn/kickstart/KickstartSoftwareEdit.do?ksid=${ksdata.id}">(<bean:message key="kickstartdetails.jsp.changeos"/>)</a></div>
      </div>

		<%@ include file="/WEB-INF/pages/common/fragments/kickstart/virtoptions.jspf" %>

      <div class="form-group">
          <label class="col-lg-3 control-label"><bean:message key="kickstartdetails.jsp.active"/></label>
          <div class="col-lg-6"><table><tr><td><html:checkbox property="active" /></td><td class="col-lg-12"><span class="small-text"><bean:message key="kickstartdetails.jsp.activeDescription"/></span></td></tr></table></div>
      </div>

      <div class="form-group">
          <label class="col-lg-3 control-label"><bean:message key="kickstartdetails.jsp.postlog"/></label>
          <div class="col-lg-6"><table><tr><td><html:checkbox property="post_log" /></td><td class="col-lg-12"><bean:message key="kickstartdetails.jsp.postlog.msg"  /></td></tr></table></div>
      </div>

      <div class="form-group">
          <label class="col-lg-3 control-label"><bean:message key="kickstartdetails.jsp.prelog"/></label>
          <div class="col-lg-6"><table><tr><td><html:checkbox property="pre_log" /></td><td class="col-lg-12"><bean:message key="kickstartdetails.jsp.prelog.msg"  /></td></tr></table></div>
      </div>

      <div class="form-group">
          <label class="col-lg-3 control-label"><bean:message key="kickstartdetails.jsp.kscfg"/></label>
          <div class="col-lg-6"><table><tr><td><html:checkbox property="ksCfg" /></td><td class="col-lg-12"><bean:message key="kickstartdetails.jsp.kscfg.msg"  /></td></tr></table></div>
      </div>

      <div class="form-group">
          <label class="col-lg-3 control-label"><bean:message key="kickstartdetails.jsp.org_default" /></label>
          <div class="col-lg-6"><table><tr><td><html:checkbox property="org_default" /></td><td class="col-lg-12"><bean:message key="kickstartdetails.jsp.summary2" arg0="${ksurl}" /></td></tr></table></div>
      </div>

      <div class="form-group">
          <label class="col-lg-3 control-label"><bean:message key="kickstartdetails.jsp.kernel_options"/></label>
          <div class="col-lg-6"><html:text property="kernel_options" maxlength="1024" size="32" /></div>
      </div>

      <div class="form-group">
          <label class="col-lg-3 control-label"><bean:message key="kickstartdetails.jsp.post_kernel_options"/></label>
          <div class="col-lg-6"><html:text property="post_kernel_options" maxlength="1024" size="32" /></div>
      </div>

      <div class="form-group">
          <label class="col-lg-3 control-label"><bean:message key="kickstartdetails.jsp.comments"/></label>
          <div class="col-lg-6"><html:textarea property="comments" cols="80" rows="6"/></div>
      </div>

      <div class="form-group">
          <div class="col-lg-6" align="right"><html:submit><bean:message key="kickstartdetails.jsp.updatekickstart"/></html:submit></div>
      </div>
    </html:form>
    </c:when>
    <c:otherwise>
    <p><bean:message key="kickstartdetails.invalid.jsp.summary"/>
		<bean:message key="kickstartdetails.invalid.jsp.summary-option1"
				 arg0="${ksdata.tree.label}"
				 arg1="/rhn/kickstart/TreeEdit.do?kstid=${ksdata.tree.id}"/></p>
        <p><bean:message key="kickstartdetails.invalid.jsp.summary-option2"
				arg0="/rhn/kickstart/KickstartSoftwareEdit.do?ksid=${ksdata.id}"/></p>
    </c:otherwise>
    </c:choose>
</div>

</body>
</html:html>

