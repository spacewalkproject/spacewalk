<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>

<html>
    <head>
        <script type="text/javascript" src="/javascript/highlander.js"></script>
    </head>
    <body>
        <rhn:toolbar base="h1" icon="header-search"
                     helpUrl="/rhn/help/reference/en-US/s1-sm-channels-packages.jsp#s2-sm-software-search">
            <bean:message key="packagesearch.jsp.toolbar"/>
        </rhn:toolbar>
        <p><bean:message key="packagesearch.jsp.pagesummary"/></p>
        <p><bean:message key="packagesearch.jsp.instructions"/></p>
        <html:form action="/channels/software/Search.do" styleClass="form-horizontal">
            <rhn:csrf />
            <div class="form-group">
                <label class="col-lg-3 control-label">
                    <bean:message key="packagesearch.jsp.searchfor"/>
                </label>
                <div class="col-lg-6">
                    <div class="input-group">
                        <html:text property="search_string" styleClass="form-control"
                                   name="search_string" value="${search_string}" accesskey="4"/>
                        <span class="input-group-btn">
                            <button type="submit" class="btn btn-default">
                                <rhn:icon type="header-search" />
                            </button>
                        </span>
                    </div>
                </div>
            </div>
            <div class="form-group">
                <label class="col-lg-3 control-label">
                    <bean:message key="packagesearch.jsp.whatsearch"/>
                </label>
                <div class="col-lg-6">
                    <html:select property="view_mode" value="${view_mode}" styleClass="form-control" >
                        <html:options collection="searchOptions"
                                      property="value"
                                      labelProperty="display" />
                    </html:select>
                </div>
            </div>
            <div class="form-group">
                <label class="col-lg-3 control-label">
                    <bean:message key="packagesearch.jsp.wheresearch"/>
                </label>
                <div class="col-lg-6">
                    <div class="checkbox">
                        <label>
                            <input type="radio" name="whereCriteria"
                                   value="relevant" <c:if test="${whereCriteria eq 'relevant'}">checked</c:if> />
                            <bean:message key="packagesearch.jsp.relevant"/>
                        </label>
                    </div>
                </div>
            </div>
            <div class="form-group">
                <div class="col-lg-offset-3 col-lg-6">
                    <div class="checkbox">
                        <label>
                            <input type="radio" name="whereCriteria"
                                   value="channel" <c:if test="${whereCriteria eq 'channel'}">checked</c:if> />
                            <bean:message key="packagesearch.jsp.specificchannel"/>
                        </label>
                    </div>
                </div>
            </div>
            <div class="form-group">
                <div class="col-lg-offset-3 col-lg-6">
                    <html:select property="channel_filter" styleClass="form-control">
                        <html:options collection="allChannels"
                                      property="id"
                                      labelProperty="name" />
                    </html:select>
                </div>
            </div>
            <div class="form-group">
                <div class="col-lg-offset-3 col-lg-6">
                    <div class="checkbox">
                        <label>
                            <input type="radio" name="whereCriteria"
                                   value="architecture" <c:if test="${whereCriteria eq 'architecture'}">checked</c:if> />
                            <bean:message key="packagesearch.jsp.specificarch"/>
                        </label>
                    </div>
                </div>
            </div>
            <div class="form-group">
                <div class="col-lg-offset-3 col-lg-6">
                    <html:select property="channel_arch" multiple="multiple"
                                 styleClass="form-control"
                                 size="5" onclick="javascript:highlander(this);">
                        <html:options collection="channelArches"
                                      property="value"
                                      labelProperty="display" />
                    </html:select>
                    <span class="help-block">
                        <bean:message key="packagesearch.jsp.searchwherelegend"/>
                    </span>
                </div>
            </div>
            <div class="form-group">
                <div class="col-lg-offset-3 col-lg-6">
                    <label>
                        <html:checkbox property="fineGrained" styleId="fineGrainedlabel" />
                        <bean:message key="systemsearch.jsp.finegrained"/>
                    </label>
                </div>
            </div>
        </html:form>

        <c:if test="${search_string != null && search_string != ''}">
            <c:set var="pageList" value="${requestScope.pageList}" />
            <!-- collapse the params into a string -->
            <c:forEach items="${requestScope.channel_arch}" var="item">
                <c:set var="archparams" value="${archparams}&channel_arch=${item}"/>
            </c:forEach>
            <rl:listset name="searchSet">
                <rhn:csrf />
                <rl:list name="searchResults" dataset="pageList"
                         emptykey="packagesearch.jsp.nopackages" width="100%"
                         filter="com.redhat.rhn.frontend.action.channel.PackageNameFilter">
                    <rl:decorator name="PageSizeDecorator"/>
                    <rl:column bound="false" sortable="false" headerkey="packagesearch.jsp.name">
                        <a href="/rhn/software/packages/NameOverview.do?package_name=${current.urlEncodedPackageName}${archparams}&search_subscribed_channels=${requestScope.relevant}&channel_filter=${requestScope.channel_filter}">
                            <rhn:highlight tag="strong" text="${search_string}">
                                ${current.packageName}
                            </rhn:highlight>
                        </a>
                    </rl:column>
                    <rl:column bound="false" sortable="false" headerkey="packagesearch.jsp.summary">
                        <c:choose>
                            <c:when test="${param.view_mode != 'search_name'}">
                                <rhn:highlight tag="strong" text="${search_string}">
                                    ${current.summary}
                                </rhn:highlight>
                            </c:when>
                            <c:otherwise>
                                ${current.summary}
                            </c:otherwise>
                        </c:choose>
                    </rl:column>
                </rl:list>
                <rl:csv dataset="pageList"
                        name="searchResults"
                        exportColumns="packageName,summary"/>
                <!-- there are two forms here, need to keep the formvars around for pagination -->
                <html:hidden property="search_string" name="search_string" value="${search_string}" />
                <html:hidden property="view_mode" value="${view_mode}" />
                <html:hidden property="whereCriteria" value="${whereCriteria}" />
                <html:hidden property="channel_filter" value="${channel_filter}" />
                <html:hidden property="fineGrained" value="${fineGrained}" />
                <c:forEach items="${requestScope.channel_arch}" var="item">
                    <html:hidden property="channel_arch" value="${item}" />
                </c:forEach>
            </rl:listset>
        </c:if>
    </body>
</html>
