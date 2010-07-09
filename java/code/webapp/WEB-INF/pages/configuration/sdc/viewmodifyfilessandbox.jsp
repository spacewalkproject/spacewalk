<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://rhn.redhat.com/tags/config-managment" prefix="cfg" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<head>
    <meta name="name" value="sdc.config.jsp.header" />
</head>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>
<h2><img class="h2-image" src="${cfg:channelHeaderIcon('sandbox')}"/>
<bean:message key="sdc.config.header.overview"/></h2>        					
<p><bean:message key="sdc.config.file_list.sandbox_description"
				arg0="${requestScope.system.name}"
				arg1="${rhn:localize('sdc.config.file_list.copy_to_global')}"/></p>

<rl:listset name="fileSet">
	<!-- Start of Files list -->
	<rl:list decorator="SelectableDecorator"
             width = "100%"
             filter="com.redhat.rhn.frontend.action.configuration.sdc.ViewModifyPathsFilter"
             emptykey = "channelfiles.jsp.noFiles"
	         >
	    <rl:selectablecolumn value="${current.selectionKey}"
						selected="${current.selected}"
	    					styleclass="first-column"/>
		
		<!-- File name column -->
		<rl:column bound = "false"
				   sortable="true"
		           headerkey="sdc.config.file_list.name"
		           sortattr="path"
					>		
		     <cfg:file path="${current.path}"
		     		type ="${current.configFileType}" nolink = "true"/>					
		</rl:column>
		
		<!-- Actions -->
		<rl:column bound="false"
		           headerkey="sdc.config.file_list.actions">
			<bean:message key="sdc.config.file_list.edit_or_compare"
         					arg0 ="${cfg:fileUrl(current.configFileId)}"
         				    arg1="${cfg:fileCompareUrl(current.configFileId)}"/>
		</rl:column>
		<!-- Current Revision -->
		<rl:column bound="false"
		           headerkey="sdc.config.file_list.current_revision"
					>
			       		<c:set var = "revisionLook">
					       		<bean:message key="sdcconfigfiles.jsp.filerev"
					       					arg0="${current.configRevision}"/>		
			       		</c:set>
						<cfg:file path ="${revisionLook}"
								type ="${current.configFileType}"
								id = "${current.configFileId}"
								revisionId = "${current.configRevisionId}"
								/>
		</rl:column>
		<!-- Last Modified Date Column -->
		<rl:column bound="true"
		           sortable="true"
		           headerkey="sdc.config.file_list.last_modified"
		           attr="lastModifiedDateString"
		           sortattr="lastModifiedDate"
    		       styleclass="last-column"/>
	</rl:list>
	<c:import url="/WEB-INF/pages/common/fragments/configuration/sdc/viewmodifyfileactions.jspf"/>
</rl:listset>
</body>
</html>