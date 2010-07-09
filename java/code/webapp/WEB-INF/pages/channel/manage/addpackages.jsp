<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>

<html:xhtml/>
<html>
<head>
    <meta name="page-decorator" content="none" />
    <!-- disables the enter key from submitting the form -->
    <script type="text/javascript" language="JavaScript">
		function key(e) {
		var pkey = e ? e.which : window.event.keyCode;
		return pkey != 13;
		}
		document.onkeypress = key;
		if (document.layers) document.captureEvents(Event.KEYPRESS);
    </script>
</head>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/channel/manage/manage_channel_header.jspf" %>
<BR>

<rl:listset name="packageSet">
<input type="hidden" name="cid" value="${cid}">
<bean:message key="channel.jsp.package.addmessage"/>
<h2><img src="/img/rhn-icon-packages.gif"> <bean:message key="channel.jsp.package.addtitle"/></h2>


<table class="details" width="80%">

			  <tr> <th width="10%">Channel:</th><td width="40%">
			  <select name="selected_channel">
			  		<option value="all_managed_packages" <c:if test="${all_selected eq true}">selected = "selected"</c:if>>All managed packages</option>
			  		<option value="orphan_packages" <c:if test="${orphan_selected eq true}">selected = "selected"</c:if>>Packages in no channels.</option>
				    <optgroup>
			   		<c:forEach var="option" items="${channel_list}">
			   			<c:choose>
			   				<c:when test="${option.baseChannel}">
			   				    </optgroup>
			   					<option value="${option.id}"  <c:if test="${option.selected eq true}">selected = "selected"</c:if>    >${option.name}	</option>
			   					<optgroup>
			   				</c:when>
			   				<c:otherwise>
								<option value="${option.id}"   <c:if test="${option.selected eq true}">selected = "selected"</c:if> >${option.name}</option>
							</c:otherwise>
						</c:choose>		
					</c:forEach>  	
					</optgroup>	
			  </select>

			  </td>
			   		  <td>
							  <input type="submit" name="view"  value="<bean:message key="channel.jsp.package.viewpackages"/>">
		  			  </td>
		  	     </tr>



  </table>




		  <rl:list dataset="pageList" name="packageList"
		  decorator="SelectableDecorator"
		  			emptykey="channel.jsp.package.addemptylist"
		  			alphabarcolumn="nvrea"
		  			 filter="com.redhat.rhn.frontend.taglibs.list.filters.PackageFilter"
		  			>
		  		
		  		<rl:decorator name="ElaborationDecorator"/>
		  		<rl:decorator name="PageSizeDecorator"/>
		  		
				<rl:selectablecolumn value="${current.selectionKey}"
					selected="${current.selected}"
	    				styleclass="first-column"/>
		  		
		  		
                 <rl:column sortable="true"
                                   bound="false"
                           headerkey="download.jsp.package"
                           sortattr="nvrea"
					defaultsort="asc"
                           >

                        <a href="/rhn/software/packages/Details.do?pid=${current.id}">${current.nvrea}</a>
                </rl:column>


                 <rl:column sortable="false"
                                   bound="false"
                           headerkey="packagesearch.jsp.summary"
                          >
                        ${current.summary}
                </rl:column>

                 <rl:column sortable="false"
                                   bound="false"
                           headerkey="package.jsp.provider"
                           styleclass="last-column"
                          >
                        ${current.provider}
                </rl:column>

						
				
			  </rl:list>


  			<p align="right">
			<input type="submit" name="confirm"  value="<bean:message key="channel.jsp.package.addconfirmbutton"/>"
            <c:choose>
                <c:when test="${empty pageList}">disabled</c:when>
            </c:choose>
            >
			</p>
     <rhn:submitted/>
</rl:listset>
</body>
</html>

