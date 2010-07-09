<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<html:xhtml/>
<html>
<body>


<c:if test="${requestScope.pageList != null}">
	<div class="site-alert">
		     <bean:message key="distro-delete.jsp.cantdelete"/>
	</div>
</c:if>

<rhn:toolbar base="h1" img="/img/rhn-kickstart_profile.gif" imgAlt="system.common.kickstartAlt">
  <bean:message key="distro-delete.jsp.header1" arg0="${kstree.label}"/>
</rhn:toolbar>

<h2><bean:message key="distro-delete.jsp.header2"/></h2>



<div>
  <p>
    <html:form method="post" action="/kickstart/TreeDelete.do?kstid=${kstree.id}">
        <p>
        <c:choose>
          <c:when test="${requestScope.pageList != null}">
            <bean:message key="distro-delete.jsp.profilesusing"/>
            <rhn:list pageList="${requestScope.pageList}" noDataText="kickstart.jsp.nokickstarts">
              <rhn:listdisplay>
                <rhn:column header="kickstart.jsp.label">
                  <a href="/rhn/kickstart/KickstartSoftwareEdit.do?ksid=${current.id}">
                    ${fn:escapeXml(current.label)}
                  </a>
                </rhn:column>
              </rhn:listdisplay>
            </rhn:list>
          </c:when>
          <c:otherwise>
            <bean:message key="distro-delete.jsp.summary1"/>
            <div style="text-align: right;">
                    <html:submit>
                        <bean:message key="distro-delete.jsp.confirmdelete"/>
                </html:submit>
            </div>
          </c:otherwise>
        </c:choose>
       </p>
       <html:hidden property="kstid" value="${kstree.id}"/>
       <html:hidden property="submitted" value="true"/>

    </html:form>
  </p>
</div>

</body>
</html>

