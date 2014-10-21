<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" indent="yes" omit-xml-declaration="yes" />

<xsl:template match="@*|node()">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="/s2s/router/ip">
  <xsl:copy>
    <xsl:text>@localhost@</xsl:text>
  </xsl:copy>
</xsl:template>

<xsl:template match="/s2s/router/pass">
  <xsl:copy>
    <xsl:text>@password@</xsl:text>
  </xsl:copy>
</xsl:template>

<xsl:template match="/s2s/local/ip">
  <xsl:copy>
     <xsl:text>@ipaddress@</xsl:text>
  </xsl:copy>
</xsl:template>

<xsl:template match="/s2s/check/interval">
  <xsl:copy>3</xsl:copy>
</xsl:template>

<xsl:template match="/s2s/lookup[not(resolve-ipv6)]/comment()[contains(., '&lt;resolve-ipv6')]">
  <xsl:value-of select="." disable-output-escaping="yes" />
</xsl:template>

<xsl:template match="/s2s/lookup[not(resolve-ipv6) and not(comment()[contains(., '&lt;resolve-ipv6')])]">
  <xsl:copy>
  <xsl:text>
     </xsl:text>
     <resolve-ipv6/>
  <xsl:text>
</xsl:text>
  <xsl:apply-templates select="@*|node()" />
  </xsl:copy>
</xsl:template>

</xsl:stylesheet>
