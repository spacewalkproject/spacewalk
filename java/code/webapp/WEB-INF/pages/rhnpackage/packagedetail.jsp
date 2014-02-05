<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>


<html:html >
<body>
    <%@ include file="/WEB-INF/pages/common/fragments/package/package_header.jspf" %>
    <div class="form-horizontal">
        <div class="panel panel-default">
            <div class="panel-heading">
                <h2><bean:message key="channel.jsp.details.title"/></h2>
            </div>
            <div class="panel-body">
                <div class="form-group">
                    <label class="col-lg-3 control-label">
                        <bean:message key="package.jsp.description"/>:
                    </label>
                    <div class="col-lg-6">
                        ${description}
                    </div>
                </div>
                <div class="form-group">
                    <label class="col-lg-3 control-label">
                        <bean:message key="package.jsp.arch"/>:
                    </label>
                    <div class="col-lg-6">
                        <c:out value="${pack.packageArch.label}" />
                    </div>
                </div>
                <div class="form-group">
                    <label class="col-lg-3 control-label">
                        <bean:message key="package.jsp.availarch"/>:
                    </label>
                    <div class="col-lg-6">
                        ${pack.packageArch.name}
                        <c:forEach items="${packArches}" var="tmpPack">
                            <a class="btn btn-info" href="/rhn/software/packages/Details.do?pid=${tmpPack.id}">
                                ${tmpPack.packageArch.name}
                            </a>
                        </c:forEach>
                    </div>
                </div>
                <div class="form-group">
                    <label class="col-lg-3 control-label">
                        <bean:message key="package.jsp.availfrom"/>:
                    </label>
                    <div class="col-lg-6">
                        <c:forEach items="${pack.channels}" var="channel">
                            <a href="/rhn/channels/ChannelDetail.do?cid=${channel.id}">
                                ${channel.name}
                            </a><br/>
                        </c:forEach>
                    </div>
                </div>
                <div class="form-group">
                    <label class="col-lg-3 control-label">
                        <bean:message key="package.jsp.vendor"/>:
                    </label>
                    <div class="col-lg-6">
                        <c:out value="${pack.vendor}" />
                    </div>
                </div>
                <div class="form-group">
                    <label class="col-lg-3 control-label">
                        <bean:message key="package.jsp.key"/>:
                    </label>
                    <c:if test="${package_key !=  null}">
                        <div class="col-lg-6">
                            <c:out value="${package_key}" />
                        </div>
                    </c:if>
                    <c:if test="${package_key ==  null}">
                        <div class="col-lg-6">
                            <bean:message key="package.jsp.key.unkown"/>
                        </div>
                    </c:if>
                </div>
                <div class="form-group">
                    <label class="col-lg-3 control-label">
                        <c:out value="${pack.checksum.checksumType.description}"/>:
                    </label>
                    <div class="col-lg-6">
                        <c:out value="${pack.checksum.checksum}" />
                    </div>
                </div>
                <div class="form-group">
                    <label class="col-lg-3 control-label">
                        <bean:message key="package.jsp.path"/>:
                    </label>
                    <div class="col-lg-6">
                        <c:out value="${pack.path}" />
                    </div>
                </div>
                <div class="form-group">
                    <label class="col-lg-3 control-label">
                        <bean:message key="package.jsp.packagesize"/>:
                    </label>
                    <div class="col-lg-6">
                        <c:out value="${pack.packageSizeString}" />
                    </div>
                </div>
            </div>
        </div>
        <!-- Patch stuff -->
        <rhn:require acl="package_type_capable(solaris_patch)"
                     mixins="com.redhat.rhn.common.security.acl.PackageAclHandler">
            <div class="panel panel-default">
                <div class="panel-heading"><h3>Solaris Patch</h3></div>
                <div class="panel-body">
                    <div class="form-group">
                        <label class="col-lg-3 control-label">
                            <bean:message key="package.jsp.solarisrelease"/>:
                        </label>
                        <div class="col-lg-6">
                            <c:out value="${pack.solarisRelease}" />
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-lg-3 control-label">
                            <bean:message key="package.jsp.sunosrelease"/>:
                        </label>
                        <div class="col-lg-6">
                            <c:out value="${pack.sunosRelease}" />
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-lg-3 control-label">
                            <bean:message key="package.jsp.patchtype"/>:
                        </label>
                        <div class="col-lg-6">
                            <c:out value="${pack.patchType.name}" />
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-lg-3 control-label">
                            <thbean:message key="package.jsp.patchinfo"/>:
                        </label>
                        <div class="col-lg-6">
                            <c:out value="${pack.patchInfo}" />
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-lg-3 control-label">
                            <bean:message key="package.jsp.readme"/>:
                        </label>
                        <div class="col-lg-6">
                            <a class="btn btn-info" href="<c:out value="${readme_url}" />">
                                <bean:message key="package.jsp.readmedownload"/>
                            </a>
                        </div>
                    </div>
                    <!-- Patch Set stuff -->
                    <rhn:require acl="package_type_capable(solaris_patchset)"
                                 mixins="com.redhat.rhn.common.security.acl.PackageAclHandler">
                        <div class="form-group">
                            <label class="col-lg-3 control-label">
                                <bean:message key="package.jsp.readme"/>:
                            </label>
                            <div class="col-lg-6">
                                <a class="btn btn-info" href="<c:out value="${readme_url}" />">
                                    <bean:message key="package.jsp.readmedownload"/>
                                </a>
                            </div>
                        </div>
                    </rhn:require>
                </div>
            </div>
        </rhn:require>
        <!-- RPM stuff -->
        <rhn:require acl="package_type_capable(rpm)"
                     mixins="com.redhat.rhn.common.security.acl.PackageAclHandler">
            <div class="panel panel-default">
                <div class="panel-heading"><h3>RPM package</h3></div>
                <div class="panel-body">
                    <div class="form-group">
                        <label class="col-lg-3 control-label">
                            <bean:message key="package.jsp.payloadsize"/>:
                        </label>
                        <div class="col-lg-6">
                            <c:out value="${pack.payloadSizeString}" />
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-lg-3 control-label">
                            <bean:message key="package.jsp.buildhost"/>:
                        </label>
                        <div class="col-lg-6">
                            <c:out value="${pack.buildHost}" />
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-lg-3 control-label">
                            <bean:message key="package.jsp.builddate"/>:
                        </label>
                        <div class="col-lg-6">
                            <c:out value="${pack.buildTime}" />
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-lg-3 control-label">
                            <bean:message key="package.jsp.license"/>:
                        </label>
                        <div class="col-lg-6">
                            <c:out value="${pack.copyright}" />
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-lg-3 control-label">
                            <bean:message key="package.jsp.group"/>:
                        </label>
                        <div class="col-lg-6">
                            <c:out value="${pack.packageGroup.name}" />
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-lg-3 control-label">
                            <bean:message key="package.jsp.rpmversion"/>:
                        </label>
                        <div class="col-lg-6">
                            <c:out value="${pack.rpmVersion}" />
                        </div>
                    </div>
                </div>
            </div>
        </rhn:require>
        <div class="panel panel-default">
            <div class="panel-heading"><h3>Download</h3></div>
            <div class="panel-body">
                <div class="form-group">
                    <label class="col-lg-3 control-label">
                        <bean:message key="package.jsp.download"/>:
                    </label>
                    <div class="col-lg-6">
                        <c:if test="${url !=  null}">
                            <div class="input-group">
                                <div class="form-control">${pack.file}</div>
                                <span class="input-group-btn btn-lg">
                                    <a class="btn btn-info" href="${url}">Download ${pack.packageSizeString}</a>
                                </span>
                            </div>
                        </c:if>
                        <c:if test="${url eq null}">
                            <div class="input-group">
                                <div class="form-control">${pack.file}</div>
                                <span class="input-group-btn">
                                    <button class="btn btn-info" disabled="disabled">Download</button>
                                </span>
                            </div>
                            <span class="help-block"><bean:message key="package.jsp.missingfile"/></span>
                        </c:if>
                    </div>
                </div>
                <div class="form-group">
                    <label class="col-lg-3 control-label">
                        <bean:message key="package.jsp.source"/>:
                    </label>
                    <div class="col-lg-6">
                        <c:if test="${srpm_url !=  null}">
                            <div class="input-group">
                                <div class="form-control">${srpm_path}</div>
                                <span class="input-group-btn">
                                    <a class="btn btn-info" href="${srpm_url}">Download</a>
                                </span>
                            </div>
                        </c:if>
                        <c:if test="${srpm_url eq null}">
                            <div alert="alert alert-warning"><bean:message key="package.jsp.unavailable"/></div>
                        </c:if>
                    </div>
                </div>
            </div>
        </div>
        <div class="panel panel-default">
            <div class="panel-heading"><h3>Misc</h3></div>
            <div class="panel-body">
                <rhn:require acl="package_type_capable(rpm)"
                             mixins="com.redhat.rhn.common.security.acl.PackageAclHandler">
                    <c:if test="${not isDebuginfo}" >
                        <div class="form-group">
                            <label class="col-lg-3 control-label">
                                <bean:message key="debuginfo.header" />:
                            </label>
                            <div class="col-lg-6">
                            <c:if test="${debugUrl != null}">
                                <a class="btn btn-info" href="${debugUrl}"><bean:message key="package.jsp.download"/></a>
                                <c:if test="${debugFtp}" >
                                    <span class="help-block">
                                        <bean:message key="debuginfo.external" />
                                    </span>
                                </c:if>
                            </c:if>
                            <c:if test="${debugUrl == null}">
                                <bean:message key="package.jsp.unavailable" />
                                <span class="help-block">
                                    <bean:message key="debuginfo.unavailable" />
                                </span>
                            </c:if>
                            </div>
                        </div>
                    </c:if>
                </rhn:require>
                <div class="form-group">
                    <label class="col-lg-3 control-label">
                        <bean:message key="package.jsp.errata" />:
                    </label>
                    <div class="col-lg-6">
                        <c:forEach items="${erratum}" var="tmpErrata">
                            <a href="/rhn/errata/details/Details.do?eid=${tmpErrata.id}"><c:out value="${tmpErrata.advisory}" /></a></br>
                        </c:forEach>
                        <c:if test="${erratumEmpty == true}">
                            <bean:message key="package.jsp.errataunavailable" />
                        </c:if>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html:html>
