<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html:html xhtml="true">
<body>

<html:errors />
<html:messages id="message" message="true">
  <rhn:messages><c:out escapeXml="false" value="${message}" /></rhn:messages>
</html:messages>

<%@ include file="/WEB-INF/pages/common/fragments/kickstart/kickstart-toolbar.jspf" %>

<rhn:dialogmenu mindepth="0" maxdepth="1" 
    definition="/WEB-INF/nav/kickstart_details.xml" 
    renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

<h2><bean:message key="kickstartdetails.jsp.header2"/></h2>



<div>
    <bean:message key="kickstartdetails.jsp.summary1"/>
    <html:form method="post" action="/kickstart/KickstartDetailsEdit.do">
      <html:hidden property="ksid" value="${ksdata.id}"/>
      <html:hidden property="submitted" value="true"/>
      <table class="details">

          <tr>
            <th><bean:message key="kickstartdetails.jsp.label" /><span class="required-form-field">*</span>:</th>
            <td><html:text property="label" maxlength="64" size="32" /><br/> 
            <span class="small-text"><bean:message key="kickstartdetails.jsp.labelwarning" /></span></td>
          </tr>
          <tr>
            <th><bean:message key="kickstartdetails.jsp.install_type" /></th>
            <td><strong><c:out value="${ksdata.kickstartDefaults.kstree.channel.name}"/></strong> 
            <a href="/rhn/kickstart/KickstartSoftwareEdit.do?ksid=${ksdata.id}">(<bean:message key="kickstartdetails.jsp.changeos"/>)</a></td>
          </tr>
          <tr>
            <th><bean:message key="kickstartdetails.jsp.virtualization_type" /></th>
            <td colspan="2" align="left">
              <html:select property="virtualizationTypeLabel">
                <html:optionsCollection property="virtualizationTypes" label="formattedName" value="label" />
              </html:select><br/>
              <span class="small-text"><bean:message key="kickstartdetails.jsp.virtTypeChangeWarning" arg0="${ksdata.id}"/></span>
            </td>
          </tr>
          
          
          <c:if test="${is_virt}">
          	 <%@ include file="/WEB-INF/pages/common/fragments/kickstart/virtoptions.jspf" %>
          </c:if> 
          
          
          
          <tr>
            <th><bean:message key="kickstartdetails.jsp.active"/></th>
            <td>
                <table>
                    <tr>
                        <td>
                            <html:checkbox property="active" />
                        </td>
                        <td>
                            <span class="small-text"><bean:message key="kickstartdetails.jsp.activeDescription"/></span>
                        </td>
                    </tr>
                </table>
            </td>
          </tr>
          <tr>
            <th><bean:message key="kickstartdetails.jsp.postlog"/></th>
            <td><table><tr><td><html:checkbox property="post_log" /></td><td><bean:message key="kickstartdetails.jsp.postlog.msg"  /></td></tr></table></td>
          </tr>          
          <tr>
            <th><bean:message key="kickstartdetails.jsp.prelog"/></th>
            <td><table><tr><td><html:checkbox property="pre_log" /></td><td><bean:message key="kickstartdetails.jsp.prelog.msg"  /></td></tr></table></td>
          </tr>
          <tr>
            <th><bean:message key="kickstartdetails.jsp.kscfg"/></th>
            <td><table><tr><td><html:checkbox property="ksCfg" /></td><td><bean:message key="kickstartdetails.jsp.kscfg.msg"  /></td></tr></table></td>
          </tr>
          <tr>
            <th><bean:message key="kickstartdetails.jsp.org_default" /></th>
            <td><table><tr><td><html:checkbox property="org_default" /></td><td><bean:message key="kickstartdetails.jsp.summary2" arg0="${ksurl}" /></td></tr></table></td>
          </tr>
          <tr>
            <th><bean:message key="kickstartdetails.jsp.kernel_options"/></th>
            <td><html:text property="kernel_options" maxlength="64" size="32" /></td>
          </tr>                 
          
         <tr>
            <th><bean:message key="kickstartdetails.jsp.post_kernel_options"/></th>
            <td><html:text property="post_kernel_options" maxlength="64" size="32" /></td>
          </tr>
                      
          <tr>
            <th><bean:message key="kickstartdetails.jsp.comments"/></th>
            <td><html:textarea property="comments" cols="80" rows="6"/></td>
          </tr>
                    
          <tr>          
            <td align="right" colspan="2"><html:submit><bean:message key="kickstartdetails.jsp.updatekickstart"/></html:submit></td>
          </tr>
      </table>
    </html:form>
</div>

</body>
</html:html>

