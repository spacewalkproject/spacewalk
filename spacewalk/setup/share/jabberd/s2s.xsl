<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" indent="yes" omit-xml-declaration="yes" />

<xsl:template match="@*|node()">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="/s2s/local">
  <xsl:copy>
    <xsl:if test="not(resolver)">
    <xsl:text>
    </xsl:text>
    <xsl:comment>
    Helper DNS resolver component - if this component is not
    connected, dialback connections will fail
    (default: resolver) </xsl:comment>
    <xsl:text>
    </xsl:text>
    <resolver>resolver</resolver>
    <xsl:text>
    </xsl:text>
    </xsl:if>
    <xsl:apply-templates select="@*|node()" />
  </xsl:copy>
</xsl:template>

<xsl:template match="/s2s/check/interval">
  <xsl:copy>3</xsl:copy>
</xsl:template>

</xsl:stylesheet>
