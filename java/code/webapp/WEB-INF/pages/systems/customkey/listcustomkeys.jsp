<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>


<html:html xhtml="true">
<body>

<html:errors />
<html:messages id="message" message="true">
  <rhn:messages><c:out escapeXml="false" value="${message}" /></rhn:messages>
</html:messages>


<BR>




<div>

    <div class="toolbar-h1"><div class="toolbar">
    	<span class="toolbar">
		<a href="/rhn/systems/customdata/CreateCustomKey.do">
    			<img src="/img/action-add.gif" alt="create new key" title="add new key" />
    			<bean:message key="system.jsp.customkey.createlink"/>
    		</a>
    	</span>
    </div><img src="/img/rhn-icon-keyring.gif" alt="keyring" />  
	<bean:message key="system.jsp.customkey.title"/>
</div>
    
    <bean:message key="system.jsp.customkey.message" arg0="<a href=\"/rhn/systems/Search.do\">" arg1="</a>"/>
    <br><br>
    <bean:message key="system.jsp.customkey.message2"/>


    <rl:listset name="keySet">


	<rl:list dataset="pageList"
	         name="keyList"
                emptykey=" "
                alphabarcolumn="label"
                filter="com.redhat.rhn.frontend.taglibs.list.filters.CustomKeyOverviewFilter">


                 <rl:column sortable="true"
                                   bound="false"
                           headerkey="system.jsp.customkey.keylabel"
                           sortattr="label"
					defaultsort="asc"
                           styleclass="first-column">

                        <a href="/network/systems/custominfo/edit.pxt?cikid=${current.id}">
                        <c:out value="${current.label}" />
                        </a>
                </rl:column>


                 <rl:column sortable="false"
                                   bound="false"
                           headerkey="system.jsp.customkey.description"
                          >
<<<<<<< HEAD:java/code/webapp/WEB-INF/pages/systems/customkey/listcustomkeys.jsp
                        ${current.description}
                </rl:column>



            <rl:column sortable="false"
=======
                       <c:out value="${current.description}" />
                </rl:column>     
                
                
                
            <rl:column sortable="false" 
>>>>>>> converted two perl pages
bugzilla:none:java/code/webapp/WEB-INF/pages/systems/customkey/listcustomkeys.jsp
                           bound="false"
                          headerkey="system.jsp.customkey.systemcount"
                          >
<<<<<<< HEAD:java/code/webapp/WEB-INF/pages/systems/customkey/listcustomkeys.jsp
                        ${current.serverCount}
                </rl:column>


                 <rl:column sortable="true"
=======
                        <c:out value="${current.serverCount}" />
                </rl:column>                    
                
                
                 <rl:column sortable="true" 
>>>>>>> converted two perl pages
bugzilla:none:java/code/webapp/WEB-INF/pages/systems/customkey/listcustomkeys.jsp
                                   bound="false"
                           sortattr="lastModified"
                           headerkey="system.jsp.customkey.modified"
                           styleclass="last-column"
                          >
                        ${current.lastModified}
                </rl:column>


        </rl:list>

	<rl:csv dataset="pageList"
<<<<<<< HEAD:java/code/webapp/WEB-INF/pages/systems/customkey/listcustomkeys.jsp
		        name="packageList"
		        exportColumns="id, label, description, serverCount, modified" />
=======
		        name="keyList"
		        exportColumns="id, label, description, serverCount, lastModified" />
>>>>>>> converted two perl pages
bugzilla:none:java/code/webapp/WEB-INF/pages/systems/customkey/listcustomkeys.jsp

    </rl:listset>
<<<<<<< HEAD:java/code/webapp/WEB-INF/pages/systems/customkey/listcustomkeys.jsp


=======
    	
    		
>>>>>>> converted two perl pages
bugzilla:none:java/code/webapp/WEB-INF/pages/systems/customkey/listcustomkeys.jsp

</div>

</body>
</html:html>
