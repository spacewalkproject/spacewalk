<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html:html xhtml="true">
<head>
<script language="javascript" type="text/javascript">
//<!--
function reloadForm(ctl) {
  var submittedFlag = document.getElementById("editFormSubmitted");
  submittedFlag.value = "false";
  var changedField = document.getElementById("fieldChanged");
  changedField.value = ctl.id;
  var form = document.getElementById("kickstartSoftwareForm");
  form.submit();
}

function toggleKSTree(what) {
   var form = document.getElementById("kickstartSoftwareForm");
   if(what.checked) {
       form.tree.disabled=1;
   } else {
       form.tree.disabled=0;
   }
}

function clickNewestRHTree() {
   var form = document.getElementById("kickstartSoftwareForm");
   if(form.useNewestRHTree.checked) {
       form.useNewestTree.checked = false;
   }
}

function clickNewestTree() {
   var form = document.getElementById("kickstartSoftwareForm");
   if(form.useNewestTree.checked) {
       form.useNewestRHTree.checked = false;
   }
}
//-->
</script>
</head>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/kickstart/kickstart-toolbar.jspf" %>

<rhn:dialogmenu mindepth="0" maxdepth="1"
    definition="/WEB-INF/nav/kickstart_table.xml"
    renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

<h2><bean:message key="softwareedit.jsp.header2"/></h2>

<div>
  <p>
    <bean:message key="softwareedit.jsp.summary1"/>
  </p>

    <html:form method="post" action="/kickstart/KickstartSoftwareEdit.do">
      <rhn:csrf />
      <table class="table">
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
                  <bean:message key="softwareedit.jsp.child_channels"/>:</th>
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
                      <c:if test="${usingNewest == true or usingNewestRH == true}">
                        <html:select property="tree" onchange="reloadForm(this);" styleId="kstree" disabled="true">
                          <html:options collection="trees"
                            property="id"
                            labelProperty="label" />
                        </html:select>
                      </c:if>
                      <c:if test="${not (usingNewest == true or usingNewestRH == true)}">
                        <html:select property="tree" onchange="reloadForm(this);" styleId="kstree">
                          <html:options collection="trees"
                            property="id"
                            labelProperty="label" />
                        </html:select>
                      </c:if>
                      <c:if test="${redHatTreesAvailable != null}">
                          <br />
                          <input type="checkbox" name="useNewestRHTree" value="0"
                              onclick="toggleKSTree(this); clickNewestRHTree()"
                              <c:if test="${usingNewestRH == true}">checked=1</c:if> />
                          <bean:message key="kickstart.jsp.create.wizard.kstree.always_new_RH"/>
                      </c:if>
                      <br />
                      <input type="checkbox" name="useNewestTree" value="0"
                          onclick="toggleKSTree(this); clickNewestTree()"
                          <c:if test="${usingNewest == true}">checked=1</c:if> />
                      <bean:message key="kickstart.jsp.create.wizard.kstree.always_new"/>
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
            <td align="right" colspan="2"><html:submit><bean:message key="kickstarttable.jsp.updatekickstart"/></html:submit></td>
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

