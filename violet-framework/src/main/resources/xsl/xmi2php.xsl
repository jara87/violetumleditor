<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet [
  <!ENTITY nl "&#xa;">
]>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xmi="http://schema.omg.org/spec/XMI/2.5.1"
    xmlns:uml = "http://schema.omg.org/spec/UML/2.5"
>
	<!-- *************************************************************************************** -->
	<!--                                                                                         -->
    <!-- Include basic xmi conversion                                                            -->
    <!--                                                                                         -->
    <!-- *************************************************************************************** -->
	
    
    <xsl:include href="xsl/xmi_base.xsl" />
    
    
    <!-- *************************************************************************************** -->
	<!--                                                                                         -->
    <!-- PHP template definition                                                                 -->
    <!--                                                                                         -->
    <!-- *************************************************************************************** -->
    
    <xsl:variable name="primitive_types">^(string|int|integer|float|double|boolean|void)$</xsl:variable>
    
	<!-- file name template -->
	<xsl:template name="file_name">
		<xsl:param name="path" />
		<xsl:param name="name" />
		<xsl:value-of select="concat($path, $name, '.php')" />
	</xsl:template>
	
	
    <!-- file header -->
	<xsl:template name="file_header">
        <xsl:param name="class_name"   />
        <xsl:param name="description"  />
        <xsl:param name="project_name" />
        <xsl:param name="author"       />
        <xsl:param name="copyright"    />
        <xsl:param name="url"          />
        
		<xsl:text>&lt;?php&nl;</xsl:text>
        <xsl:text>&nl;</xsl:text>
        <xsl:text>/**&nl;</xsl:text>
        <xsl:text> * </xsl:text><xsl:value-of select="$class_name" /><xsl:text>&nl;</xsl:text>
        <xsl:text> *&nl;</xsl:text>
        <xsl:text> * </xsl:text><xsl:value-of select="$description" /><xsl:text>&nl;</xsl:text>
        <xsl:text> *&nl;</xsl:text>
        <xsl:text> * PHP version 7&nl;</xsl:text>
        <xsl:text> *&nl;</xsl:text>
        <xsl:text> * LICENSE: This program is free software: you can redistribute it and/or modify&nl;</xsl:text>
        <xsl:text> * it under the terms of the GNU General Public License as published by&nl;</xsl:text>
        <xsl:text> * the Free Software Foundation, either version 3 of the License, or&nl;</xsl:text>
        <xsl:text> * (at your option) any later version.&nl;</xsl:text>
        <xsl:text> * This program is distributed in the hope that it will be useful,&nl;</xsl:text>
        <xsl:text> * but WITHOUT ANY WARRANTY; without even the implied warranty of&nl;</xsl:text>
        <xsl:text> * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the&nl;</xsl:text>
        <xsl:text> * GNU General Public License for more details.&nl;</xsl:text>
        <xsl:text> * You should have received a copy of the GNU General Public License&nl;</xsl:text>
        <xsl:text> * along with this program. If not, see &lt;http://www.gnu.org/licenses/&gt;.&nl;</xsl:text>
        <xsl:text> *&nl;</xsl:text>
        <xsl:text> * Project:   </xsl:text><xsl:value-of select="$project_name" /><xsl:text>&nl;</xsl:text>
        <xsl:text> * @author    </xsl:text><xsl:value-of select="$author" /><xsl:text>&nl;</xsl:text>
        <xsl:text> * @copyright </xsl:text><xsl:value-of select="$author" /><xsl:text> </xsl:text><xsl:value-of select="$copyright" /><xsl:text>&nl;</xsl:text>
        <xsl:text> * @version   ${build.version} [REV: ${build.revision}]&nl;</xsl:text>
        <xsl:text> * @link      </xsl:text><xsl:value-of select="$url" /><xsl:text>&nl;</xsl:text>
        <xsl:text> *&nl;</xsl:text>
        <xsl:text> * $Id$&nl;</xsl:text>
        <xsl:text> */&nl;</xsl:text>
        <xsl:text>&nl;</xsl:text>
	</xsl:template>
	
    <!-- file footer -->
	<xsl:template name="file_footer">
		<xsl:text>&nl;&nl;?&gt;</xsl:text>
	</xsl:template>
    
    <!-- package definition -->
    <xsl:template name="package_definition">
        <xsl:param name="package_name" />
        <xsl:if test="not($package_name eq '')">
            <xsl:text>namespace </xsl:text><xsl:value-of 
                select="substring(translate($package_name, '/', '\'), 1, string-length($package_name) - 1)" 
            /><xsl:text>;&nl;</xsl:text>
        </xsl:if>
    </xsl:template>
    
    <!-- Use/Include definition -->
    <xsl:template name="include_definition">
        <xsl:param name="classes" />
        <xsl:if test="not($classes eq '')">
            <xsl:for-each select="tokenize($classes,', ?')">
                <xsl:text>use </xsl:text><xsl:value-of select="translate(., '/', '\')"/>
                <xsl:text>;&nl;</xsl:text>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
	
    <!-- Class header definition -->
	<xsl:template name="class_header">
        <xsl:param name="class_name"  />
        <xsl:param name="description" />
        
        <xsl:text>&nl;</xsl:text>
        <xsl:text>/**&nl;</xsl:text>
        <xsl:text> *&nl;</xsl:text>
        <xsl:text> * </xsl:text><xsl:value-of select="$class_name" /><xsl:text>&nl;</xsl:text>
        <xsl:text> *&nl;</xsl:text>
        <xsl:call-template name="applyDescription">
            <xsl:with-param name="description" select="$description" />
        </xsl:call-template>
        <xsl:text> */&nl;</xsl:text>
	</xsl:template>
    
    <!-- Class definition -->
    <xsl:template name="class_definition">
        <xsl:param name="class_name" />
        <xsl:param name="type"       />
        <xsl:param name="abstract"   />
        <xsl:param name="extends"    />
        <xsl:param name="implements" />
        
        <xsl:if test="$abstract eq 'true'">
            <xsl:text>abstract </xsl:text>
        </xsl:if>
        <xsl:value-of select="$type" />
        <xsl:text> </xsl:text>
        <xsl:value-of select="$class_name" />
        <xsl:if test="not($extends eq '')">
            <xsl:text> extends </xsl:text><xsl:value-of select="$extends" />
        </xsl:if>
        <xsl:if test="not($implements eq '')">
            <xsl:text> implements </xsl:text><xsl:value-of select="$implements" />
        </xsl:if>
        <xsl:text> {&nl;</xsl:text>
	</xsl:template>
    
    <!-- Class footer definition -->
	<xsl:template name="class_footer">
		<xsl:text>&nl;}&nl;</xsl:text>
	</xsl:template>
	
    <!-- Attribute definition -->
	<xsl:template name="attribute_definition">
        <xsl:param name="name"        />
        <xsl:param name="type"        />
        <xsl:param name="description" />
        <xsl:param name="static"      />
        <xsl:param name="visibility" select="private" />
		
        <xsl:text>&nl;</xsl:text>
        <xsl:text>    /**&nl;</xsl:text>
        <xsl:text>     *&nl;</xsl:text>
        <xsl:call-template name="applyDescription">
            <xsl:with-param name="description" select="$description" />
        </xsl:call-template>
        <xsl:if test="not($type eq '')">
            <xsl:text>     * @var </xsl:text><xsl:value-of select="$type" /><xsl:text>&nl;</xsl:text>
        </xsl:if>
        <xsl:text>     */&nl;</xsl:text>
        <xsl:text>    </xsl:text>
        <xsl:if test="not($visibility eq '')">
            <xsl:value-of select="$visibility" /><xsl:text> </xsl:text>
        </xsl:if>
        <xsl:if test="$static   = 'true'"><xsl:text>static </xsl:text></xsl:if>
        <xsl:text>$</xsl:text><xsl:value-of select="$name" />
        <xsl:text>;&nl;</xsl:text>
	</xsl:template>
	
    <!-- Method definition -->
	<xsl:template name="method_definition">
        <xsl:param name="name"        />
        <xsl:param name="return"      />
        <xsl:param name="params"      />
        <xsl:param name="abstract"    />
        <xsl:param name="static"      />
        <xsl:param name="description" />
        <xsl:param name="visibility" select="public" />
        <xsl:param name="type"       select="class" />
        
		<xsl:text>&nl;</xsl:text>
        <xsl:text>    /**&nl;</xsl:text>
        <xsl:text>     *&nl;</xsl:text>
        <xsl:call-template name="applyDescription">
            <xsl:with-param name="description" select="$description" />
        </xsl:call-template>
        <xsl:call-template name="applyParameterDoc">
            <xsl:with-param name="params" select="$params" />
        </xsl:call-template>
        <xsl:if test="not($return eq '')">
            <xsl:text>     * @return </xsl:text><xsl:value-of select="$return" /><xsl:text>&nl;</xsl:text>
        </xsl:if>
        <xsl:text>     */&nl;</xsl:text>
        <xsl:text>    </xsl:text>
        <xsl:value-of select="$visibility" />
		<xsl:text> </xsl:text>
        <xsl:if test="$abstract = 'true'"><xsl:text>abstract </xsl:text></xsl:if>
        <xsl:if test="$static   = 'true'"><xsl:text>static </xsl:text></xsl:if>
        <xsl:text>function </xsl:text>
        <xsl:value-of select="$name" />
        <xsl:text>(</xsl:text>
        <xsl:call-template name="applyParameter">
            <xsl:with-param name="params" select="$params" />
        </xsl:call-template>
        <xsl:text>)</xsl:text>
		<xsl:choose>
            <xsl:when test="$type = 'interface'">
                <xsl:text>;</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text> {&nl;</xsl:text>
                <xsl:text>        // TODO: Auto generated method&nl;</xsl:text>
                <xsl:text>    }</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>&nl;</xsl:text>
	</xsl:template>
    
    <!-- *************************************************************************************** -->
	<!--                                                                                         -->
    <!-- Helper definition                                                                       -->
    <!--                                                                                         -->
    <!-- *************************************************************************************** -->
    
    <xsl:template name="applyDescription">
        <xsl:param name="description" />
        
        <xsl:if test="not($description eq '')">
            <xsl:for-each select="tokenize($description, '\r?\n')">
                <xsl:text>     * </xsl:text><xsl:sequence select="."/><xsl:text>&nl;</xsl:text>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="applyParameterDoc">
        <xsl:param name="params" />
        
        <xsl:if test="not($params eq '')">
            <xsl:for-each select="tokenize($params,', ?')">
                <xsl:text>     * @param </xsl:text>
                <xsl:value-of select="concat(substring-after(., ':'), ' $', substring-before(., ':'))"/>
                <xsl:text>&nl;</xsl:text>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="applyParameter">
        <xsl:param name="params" />
        
        <xsl:if test="not($params eq '')">
            <xsl:for-each select="tokenize($params,', ?')">
                <xsl:if test="not(matches(substring-after(., ':'), $primitive_types, 'i'))"><xsl:value-of select="concat(substring-after(., ':'), ' ')"/></xsl:if>
                <xsl:value-of select="concat('$', substring-before(., ':'))"/>
                <xsl:if test="position() != last()">, </xsl:if>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
	
</xsl:stylesheet>
