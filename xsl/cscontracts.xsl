<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
	version="2.0" 
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:fo="http://www.w3.org/1999/XSL/Format" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:xsd="http://www.w3.org/2001/XMLSchema"
	xmlns:x="urn:microsoft:xwadl"
	xmlns:codegen="urn:napic:codegen"
>
	
	<xsl:include href="common.xsl" />
	
	<xsl:output method="text" encoding="UTF-8" media-type="text/plain" />
	
	<!-- Output types namespace -->
	<xsl:param name="ns">Sample</xsl:param>
	<!-- Path to Schema-to-CLR types map -->
	<xsl:param name="typeMapPath"></xsl:param>
	<!-- Custom usings -->
	<xsl:param name="nss"></xsl:param>
	
	<xsl:variable name="typeMap" select="document($typeMapPath)" />
	<xsl:variable name="representationNs" select="xs:schema/@targetNamespace" />
	
	<xsl:variable name="t"><xsl:text>    </xsl:text></xsl:variable>
	<xsl:variable name="n"><xsl:text>&#13;&#10;</xsl:text></xsl:variable>
	
	<xsl:template match="/">
		<xsl:apply-templates select="xs:schema/xs:simpleType[xs:restriction/xs:enumeration and (fn:not(@codegen:ignore) or @codegen:ignore != 'true')]" />
		<xsl:apply-templates select="xs:schema/xs:complexType[fn:not(@codegen:ignore) or @codegen:ignore != 'true']" />
	</xsl:template>
		
	<xsl:template match="xs:complexType">
		<xsl:variable name="name">
			<xsl:call-template name="pascalize">
				<xsl:with-param name="input" select="@name" />
			</xsl:call-template>
			<xsl:text>Contract</xsl:text>
		</xsl:variable>
		<xsl:variable name="file" select="concat($name, '.cs')" />
		<xsl:result-document href="{$file}" method="text" encoding="UTF-8" media-type="text/plain">
			<xsl:call-template name="header">
				<xsl:with-param name="file" select="$file" />
			</xsl:call-template>
			<xsl:value-of select="concat($t, '[DataContract(Name = &quot;', @name, '&quot;, Namespace = &quot;', $representationNs ,'&quot;)]', $n)" />
			<xsl:value-of select="concat($t, 'public class ', $name)" />
			<xsl:variable name="extension" select="xs:complexContent/xs:extension" />
			<xsl:if test="$extension">
				<xsl:text> : </xsl:text>
				<xsl:call-template name="pascalize">
					<xsl:with-param name="input" select="$extension/@base" />
				</xsl:call-template>
				<xsl:text>Contract</xsl:text>
			</xsl:if>
			<xsl:value-of select="concat($n, $t, '{', $n)" />
			<xsl:choose>
				<xsl:when test="$extension">
					<xsl:apply-templates select="$extension/xs:sequence/xs:element" />
				</xsl:when>
				<xsl:otherwise>
			<xsl:apply-templates select="xs:sequence/xs:element" />
				</xsl:otherwise>
			</xsl:choose>
			<xsl:value-of select="concat($t, '}', $n)" />
			<xsl:call-template name="footer" />
		</xsl:result-document>
	</xsl:template>
	
	<xsl:template match="xs:simpleType">
		<xsl:variable name="name">
			<xsl:call-template name="pascalize">
				<xsl:with-param name="input" select="@name" />
			</xsl:call-template>
			<xsl:text>Contract</xsl:text>
		</xsl:variable>
		<xsl:variable name="file" select="fn:concat($name, '.cs')" />
		<xsl:result-document href="{$file}" method="text" encoding="UTF-8" media-type="text/plain">
			<xsl:call-template name="header">
				<xsl:with-param name="file" select="$file" />
			</xsl:call-template>
			<xsl:if test="@codegen:flags = 'true'">
				<xsl:value-of select="concat($t, '[Flags]', $n)" />
			</xsl:if>
			<xsl:value-of select="concat($t, '[DataContract(Name = &quot;', @name, '&quot;, Namespace = &quot;', $representationNs ,'&quot;)]', $n)" />
			<xsl:value-of select="concat($t, 'public enum ', $name, $n)" />
			<xsl:value-of select="concat($t, '{', $n)" />
			<xsl:apply-templates select="xs:restriction/xs:enumeration" />
			<xsl:value-of select="concat($t, '}', $n)" />
			<xsl:call-template name="footer" />
		</xsl:result-document>
	</xsl:template>
	
	<xsl:template match="xs:element" priority="3">
		<xsl:variable name="name">
			<xsl:call-template name="pascalize">
				<xsl:with-param name="input" select="@name" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:value-of select="concat($t, $t, '[DataMember(Name = &quot;', @name, '&quot;, EmitDefaultValue=false)]', $n)" />
		<xsl:value-of select="concat($t, $t, 'public ')" />
		<xsl:choose>
			<xsl:when test="@minOccurs and @maxOccurs">
				<xsl:text>IEnumerable&lt;</xsl:text>
				<xsl:call-template name="typeName">
					<xsl:with-param name="qname" select="@type" />
					<xsl:with-param name="nillable" select="@nillable" />
				</xsl:call-template>
				<xsl:text>&gt;</xsl:text>				
			</xsl:when>
			<xsl:when test="@x:typeref">
				<xsl:call-template name="typeName">
					<xsl:with-param name="qname" select="@type" />
					<xsl:with-param name="nillable" select="@nillable" />
				</xsl:call-template>				
				<xsl:text>&lt;</xsl:text>
				<xsl:call-template name="typeName">
					<xsl:with-param name="qname" select="@x:typeref" />
					<xsl:with-param name="nillable" select="@nillable" />
				</xsl:call-template>
				<xsl:text>&gt;</xsl:text>					
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="typeName">
					<xsl:with-param name="qname" select="@type" />
					<xsl:with-param name="nillable" select="@nillable" />
				</xsl:call-template>				
			</xsl:otherwise>
		</xsl:choose>
		<xsl:value-of select="concat(' ', $name, ' { get; ')" />
		<xsl:if test="@x:access = 'readonly'">
			<xsl:text>internal </xsl:text>
		</xsl:if>
		<xsl:value-of select="concat('set; }', $n, $n)" />
	</xsl:template>
	
	<xsl:template match="xs:enumeration">
		<xsl:variable name="name">
			<xsl:call-template name="pascalize">
				<xsl:with-param name="input" select="@value" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:value-of select="concat($t, $t, '[EnumMember(Value = &quot;', @value, '&quot;)]', $n)" />
		<xsl:value-of select="concat($t, $t, $name)" />
		<xsl:if test="@codegen:value">
			<xsl:value-of select="concat(' = ', @codegen:value)" />
		</xsl:if>
		<xsl:if test="fn:position() != fn:last()">
			<xsl:text>,</xsl:text>
		</xsl:if>
		<xsl:value-of select="concat($n, $n)" />
	</xsl:template>
	
	<xsl:template name="typeName">
		<xsl:param name="qname"/>
		<xsl:param name="nillable" />
		<xsl:variable name="prefix" select="substring-before($qname,':')"/>
		<xsl:variable name="ns-uri" select="./namespace::*[name()=$prefix]"/>
		<xsl:variable name="localname" select="substring-after($qname, ':')"/>
		<xsl:variable name="mappedType" >
			<xsl:choose>
				<xsl:when test="$ns-uri and $representationNs and ($ns-uri = $representationNs or fn:starts-with($ns-uri, $representationNs))">
					<xsl:choose>
						<xsl:when test="/xs:schema/xs:simpleType[@name=$localname and fn:not(xs:restriction/xs:enumeration)]">
							<xsl:variable name="innerMappedType">
								<xsl:call-template name="typeName">
									<xsl:with-param name="qname" select="/xs:schema/xs:simpleType[@name=$localname]/xs:restriction/@base" />
								</xsl:call-template>
							</xsl:variable>
							<xsl:value-of select="$innerMappedType" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="pascalize">
								<xsl:with-param name="input" select="$localname" />
							</xsl:call-template>
							<xsl:text>Contract</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="($ns-uri='http://www.w3.org/2001/XMLSchema' or $ns-uri='http://www.w3.org/2001/XMLSchema-instance') and $typeMap//map/item[@from=$localname]" >
					<xsl:value-of select="$typeMap//map/item[@from=$localname]/@to" />
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:value-of select="$mappedType" />
		<xsl:if test="$nillable and ($mappedType != 'string')">
			<xsl:text>?</xsl:text>
		</xsl:if>
	</xsl:template>	
	
	<xsl:template name="header">
		<xsl:param name="file" />
		<xsl:call-template name="codegen-warn" />
		<xsl:value-of select="concat('namespace ', $ns, $n)" />
		<xsl:value-of select="concat('{', $n)" />
		<xsl:value-of select="concat($t, 'using System;', $n)" />
		<xsl:value-of select="concat($t, 'using System.Collections.Generic;', $n)" />
		<xsl:value-of select="concat($t, 'using System.Runtime.Serialization;', $n)" />
		<xsl:for-each select="fn:tokenize($nss, ',')">
			<xsl:value-of select="concat($t, 'using ', ., ';', $n)" />
		</xsl:for-each>
		<xsl:value-of select="$n" />
	</xsl:template>
	
	<xsl:template name="footer">
		<xsl:text>}</xsl:text>
	</xsl:template>
	
</xsl:stylesheet>
