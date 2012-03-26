<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright 2012 Red Hat Inc., Durham, North Carolina. All Rights Reserved.

This library is free software; you can redistribute it and/or modify it under
the terms of the GNU Lesser General Public License as published by the Free
Software Foundation; either version 2.1 of the License.

This library is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more
details.

You should have received a copy of the GNU Lesser General Public License along
with this library; if not, write to the Free Software Foundation, Inc., 59
Temple Place, Suite 330, Boston, MA  02111-1307 USA

Authors:
     Simon Lukasik <slukasik@redhat.com>
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:cdf="http://checklists.nist.gov/xccdf/1.1">
    <xsl:output method="xml" encoding="UTF-8"/>

    <xsl:template match="/">
        <benchmark-resume>
            <xsl:apply-templates select="cdf:Benchmark"/>
        </benchmark-resume>
    </xsl:template>

    <xsl:template match="cdf:Benchmark">
        <xsl:copy-of select="@id"/>
        <xsl:attribute name="version">
            <xsl:value-of select="normalize-space(cdf:version/text())"/>
        </xsl:attribute>

        <xsl:variable name="profileId" select="cdf:TestResult[1]/cdf:profile/@idref"/>
        <xsl:apply-templates select="cdf:Profile[@id = $profileId]"/>
        <xsl:apply-templates select="cdf:TestResult[1]"/>
    </xsl:template>

    <xsl:template match="cdf:Profile">
        <profile>
            <xsl:attribute name="title">
                <xsl:value-of select="normalize-space(cdf:title/text())"/>
            </xsl:attribute>
            <xsl:copy-of select="@id"/>
            <xsl:attribute name="description">
                <xsl:value-of select="normalize-space(cdf:description[@xml:lang='en-US']/text())"/>
            </xsl:attribute>
        </profile>
    </xsl:template>

    <xsl:template match="cdf:TestResult">
        <TestResult>
            <xsl:copy-of select="@id"/>
            <xsl:copy-of select="@start-time"/>
            <xsl:copy-of select="@end-time"/>
            <pass>
                    <xsl:apply-templates select="cdf:rule-result[cdf:result = 'pass']"/>
            </pass>
            <fail>
                    <xsl:apply-templates select="cdf:rule-result[cdf:result = 'fail']"/>
            </fail>
            <error>
                    <xsl:apply-templates select="cdf:rule-result[cdf:result = 'error']"/>
            </error>
            <unknown>
                    <xsl:apply-templates select="cdf:rule-result[cdf:result = 'unknown']"/>
            </unknown>
            <notapplicable>
                    <xsl:apply-templates select="cdf:rule-result[cdf:result = 'notapplicable']"/>
            </notapplicable>
            <notchecked>
                    <xsl:apply-templates select="cdf:rule-result[cdf:result = 'notchecked']"/>
            </notchecked>
            <notselected>
                    <xsl:apply-templates select="cdf:rule-result[cdf:result = 'notselected']"/>
            </notselected>
            <informational>
                   <xsl:apply-templates select="cdf:rule-result[cdf:result = 'informational']"/>
            </informational>
            <fixed>
                    <xsl:apply-templates select="cdf:rule-result[cdf:result = 'fixed']"/>
            </fixed>
        </TestResult>
    </xsl:template>

    <xsl:template match="cdf:rule-result">
        <rr>
            <xsl:attribute name="id">
                <xsl:value-of select="normalize-space(@idref)"/>
            </xsl:attribute>
            <xsl:apply-templates select="cdf:ident"/>
        </rr>
    </xsl:template>

    <xsl:template match="cdf:ident">
        <ident>
            <xsl:copy-of select="@system"/>
            <xsl:value-of select="normalize-space(text())"/>
        </ident>
    </xsl:template>
</xsl:stylesheet>
