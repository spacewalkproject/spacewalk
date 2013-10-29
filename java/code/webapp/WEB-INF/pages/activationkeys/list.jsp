<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html"%>
<html:xhtml/>
<html>
<head>
    <meta name="name" value="activationkeys.jsp.header" />
</head>
<body>
<rhn:toolbar base="h1" icon="fa-key"
			imgAlt="activation-keys.common.alt"
			creationUrl="/rhn/activationkeys/Create.do"
 			creationType="activationkeys"
 			creationAcl = "user_role(activation_key_admin)"
            helpUrl="/rhn/help/reference/en-US/s1-sm-systems.jsp#s2-sm-systems-activation-keys"
			>
  <bean:message key="activation-keys.jsp.header"/>
</rhn:toolbar>


<p><bean:message key="activation-keys.jsp.para1"/></p>
<h2><bean:message key="activation-key.jsp.universal-default"/></h2>
<p><bean:message key="activation-keys.jsp.universal-default-text"/></p>
<c:choose>
  <c:when test="${not empty requestScope['default']}">
  <table class="table">
    <tr>
        <td>
            <bean:message key="kickstart.activationkeys.jsp.description"/>
        </td>
        <td>
			<c:choose>
               <c:when test="${requestScope['default'].note != null}">
				<a href="/rhn/activationkeys/Edit.do?tid=${requestScope['default'].id}">
					     <c:out value="${requestScope['default'].note}"/></a>            					
               </c:when>
               <c:otherwise>
				<a href="/rhn/activationkeys/Edit.do?tid=${requestScope['default'].id}">
					     <bean:message key="kickstart.activationkeys.jsp.description.none"/></a>
               </c:otherwise>
            </c:choose>
            <br/><rhn:tooltip key="activation-keys.jsp.description-tooltip"/>

        </td>
    </tr>
    <tr>
        <td>
            <bean:message key="kickstart.activationkeys.jsp.key"/>
        </td>
        <td>
        	<c:out value="${requestScope['default'].token}"/>
        </td>
    </tr>

    <tr>
        <td>
            <bean:message key="kickstart.activationkeys.jsp.usagelimit"/>
        </td>
        <td>
			<c:choose>
               <c:when test="${requestScope['default'].usageLimit != null}">
					<c:out value="${requestScope['default'].usageLimit}"/>            					
               </c:when>
               <c:otherwise>
					<bean:message key="kickstart.activationkeys.jsp.nousagelimit"/>
               </c:otherwise>
            </c:choose>

        </td>
    </tr>
    <tr>
        <td>
            <bean:message key="Status"/>
        </td>
        <td>
			<c:choose>
               <c:when test="${not requestScope['default'].disabled}">
					<bean:message key="Enabled"/>            					
               </c:when>
               <c:otherwise>
					<bean:message key="Disabled"/>
               </c:otherwise>
            </c:choose>
        </td>
    </tr>

</table>
	</c:when>
   <c:otherwise>
		<bean:message key="activation-keys.jsp.no-universal-default"/>
   </c:otherwise>
</c:choose>

</p>

<h2><bean:message key="activation-keys.jsp.all-keys"/></h2>
<p>
	<bean:message key="activation-keys.jsp.para2"/>
</p>
<rl:listset name="activationKeysSet">
    <rhn:csrf />
	<!-- Start of Files list -->
	<rl:list dataset="pageList"
	         name="activationKeys"
	         decorator="SelectableDecorator"
             width="100%"
             emptykey = "kickstart.activationkeys.jsp.nokeys"
             alphabarcolumn="note"
	         >

      <rl:selectablecolumn value="${current.selectionKey}"
						selected="${current.selected}"
						headerkey="activation-keys.jsp.enabled"/>
		<!-- Description column -->
		<rl:column  headerkey="kickstart.activationkeys.jsp.description" filterattr="note">
			<c:choose>
               <c:when test="${current.note != null}">
				<a href="/rhn/activationkeys/Edit.do?tid=${current.id}">
					     <c:out value="${current.note}"/></a>            					
               </c:when>
               <c:otherwise>
				<a href="/rhn/activationkeys/Edit.do?tid=${current.id}">
					     <bean:message key="kickstart.activationkeys.jsp.description.none"/></a>
               </c:otherwise>
            </c:choose>
			<c:if test="${current.orgDefault}"><c:out value=" *"/></c:if>
		</rl:column>
		
		<!-- Key -->
		<rl:column bound="true"
		           headerkey="kickstart.activationkeys.jsp.key"
		           attr="token"
					/>
		

		<!-- Usage Limit -->
		<rl:column bound="false"
		           headerkey="kickstart.activationkeys.jsp.usagelimit"
					>
			<c:choose>
               <c:when test="${current.usageLimit != null}">
					    ${current.systemCount}/${current.usageLimit}   					
               </c:when>
               <c:otherwise>
					    ${current.systemCount}/<bean:message key="kickstart.activationkeys.jsp.nousagelimit"/>
               </c:otherwise>
            </c:choose>
					
		</rl:column>				
	</rl:list>
<hr/>
<div class="small-text">*<strong><bean:message key="Tip"/>:</strong> <bean:message key="activation-keys.jsp.is-default-key-tip"/></div>
<c:if test = "${not empty requestScope.pageList}">
<div class="text-right">
   <rhn:submitted/>
    <input type="submit"
		name ="dispatch"
    class="btn btn-default"
    	value="${rhn:localize('kickstart.activationkeys.jsp.submit')}"/>
</div>
</c:if>
</rl:listset>
</body>
</html>
