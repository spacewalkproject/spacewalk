<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html:html xhtml="true">
<head>
<script language="javascript" type="text/javascript">
//<!--
function reloadForm(ctl) {
  var submittedFlag = document.getElementById("editFormSubmitted");
  submittedFlag.value = "false";
  var changedField = document.getElementById("fieldChanged");
  changedField.value = ctl.id;
  var form = document.getElementById("editForm");
  form.submit();
}
//-->
</script>
</head>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/kickstart/kickstart-toolbar.jspf" %>

<rhn:dialogmenu mindepth="0" maxdepth="1"
    definition="/WEB-INF/nav/kickstart_details.xml"
    renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

<h2><bean:message key="softwareedit.jsp.header2"/></h2>

<div>
  <p>
    <bean:message key="softwareedit.jsp.summary1"/>
  </p>

    <html:form method="post" action="/kickstart/KickstartSoftwareEdit.do" styleId="editForm">
      <table class="details">
          <tr>
            <th><rhn:required-field key="softwareedit.jsp.basechannel"/>:</th>
            <td>
              <html:select property="channel" onchange="reloadForm(this);" styleId="channel">
                  <html:options collection="channels"
                    property="value"
                    labelProperty="label" />
              </html:select>
                <br><span class="small-text"><bean:message key="softwareedit.jsp.tip" /></span><br>
            </td>
          </tr>
          <tr>
              <th>
                  <rhn:required-field key="softwareedit.jsp.child_channels"/>:</th>
              <td>
                  <c:choose>
                    <c:when test="${empty nochildchannels}">
                      <c:forEach items="${avail_child_channels}" var="child">
						   <input name="child_channels" value="${child.id}" type="checkbox" id="${child.id}"
                      		<c:if test="${not empty stored_child_channels[child.id]}">checked=1</c:if>
                      		/>
                       <label for="${child.id}">${child.label}</label><br/>
					</c:forEach>
                    </c:when>
                    <c:otherwise>
                      <br><b><bean:message key="softwareedit.jsp.nochildchannels" /></b><br>
                    </c:otherwise>
                  </c:choose>
                  <br><span class="small-text"><bean:message key="softwareedit.jsp.warning" arg0="${ksdata.id}"/></span><br>
              </td>
          </tr>
          <tr>
              <th>
                  <rhn:required-field key="softwareedit.jsp.avail_trees"/>:
              </th>
              <td>
                  <c:choose>
                    <c:when test="${notrees == null}">
                      <html:select property="tree" onchange="reloadForm(this);" styleId="kstree">
                      <html:options collection="trees"
                        property="id"
                        labelProperty="label" />
                      </html:select>
                    </c:when>
                    <c:otherwise>
                      <b><bean:message key="kickstart.edit.software.notrees.jsp" /></b>
                    </c:otherwise>
                  </c:choose>
              </td>
          </tr>
          <tr>
            <th><bean:message key="softwareedit.jsp.url" />:</th>
            <td>
            	<c:choose>
	            	<c:when test="${nourl == null}">
	                	<b><bean:write name="kickstartSoftwareForm" property="url" /></b><br /><br />
					</c:when>
					<c:otherwise>
						<b><bean:message key="kickstart.edit.software.nofiles.jsp" /></b>
					</c:otherwise>
				</c:choose>
            </td>
          </tr>
          <c:if test = "${not empty kickstartSoftwareForm.map.possibleRepos}">
          <tr>
            <th><bean:message key="softwareedit.jsp.repos" />:</th>
            <td>
			
      <c:forEach items="${kickstartSoftwareForm.map.possibleRepos}" var="item">
    		<html:multibox property="selectedRepos" disabled="${item.disabled}"
    						value = "${item.value}" styleId="type_${item.value}"/>
			<label for="type_${item.value}"><c:out value="${item.label}"/></label>
    		<br />
    	</c:forEach>
    <br/><rhn:tooltip key="softwareedit.jsp.repos-tooltip"/>
            </td>
          </tr>
         </c:if>
          <tr>
            <td align="right" colspan="2"><html:submit><bean:message key="kickstartdetails.jsp.updatekickstart"/></html:submit></td>
          </tr>
      </table>
      <html:hidden property="url" value="${kickstartSoftwareForm.map.url}"/>
      <html:hidden property="ksid" value="${ksdata.id}"/>
      <html:hidden property="submitted" value="true" styleId="editFormSubmitted"/>
      <html:hidden property="fieldChanged" value="" styleId="fieldChanged" />
	</br>

    </html:form>
</div>

</body>
</html:html>

