<!--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

-->

<!--
    Main structure of the page, determines where
    header, footer, body, navigation are structurally rendered.
    Rendering of the header, footer, trail and alerts

    Author: art.lowel at atmire.com
    Author: lieven.droogmans at atmire.com
    Author: ben at atmire.com
    Author: Alexey Maslov

-->

<xsl:stylesheet xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
                xmlns:dri="http://di.tamu.edu/DRI/1.0/"
                xmlns:mets="http://www.loc.gov/METS/"
                xmlns:xlink="http://www.w3.org/TR/xlink/"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
                xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:confman="org.dspace.core.ConfigurationManager"
                exclude-result-prefixes="i18n dri mets xlink xsl dim xhtml mods dc confman">

    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>

    <!--
        Requested Page URI. Some functions may alter behavior of processing depending if URI matches a pattern.
        Specifically, adding a static page will need to override the DRI, to directly add content.
    -->
    <xsl:variable name="request-uri" select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='URI']"/>

    <!--
        The starting point of any XSL processing is matching the root element. In DRI the root element is document,
        which contains a version attribute and three top level elements: body, options, meta (in that order).

        This template creates the html document, giving it a head and body. A title and the CSS style reference
        are placed in the html head, while the body is further split into several divs. The top-level div
        directly under html body is called "ds-main". It is further subdivided into:
            "ds-header"  - the header div containing title, subtitle, trail and other front matter
            "ds-body"    - the div containing all the content of the page; built from the contents of dri:body
            "ds-options" - the div with all the navigation and actions; built from the contents of dri:options
            "ds-footer"  - optional footer div, containing misc information

        The order in which the top level divisions appear may have some impact on the design of CSS and the
        final appearance of the DSpace page. While the layout of the DRI schema does favor the above div
        arrangement, nothing is preventing the designer from changing them around or adding new ones by
        overriding the dri:document template.
    -->
    <xsl:template match="dri:document">

        <xsl:choose>
            <xsl:when test="not($isModal)">


            <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;
            </xsl:text>
            <xsl:text disable-output-escaping="yes">&lt;!--[if lt IE 7]&gt; &lt;html class=&quot;no-js lt-ie9 lt-ie8 lt-ie7&quot; lang=&quot;en&quot;&gt; &lt;![endif]--&gt;
            &lt;!--[if IE 7]&gt;    &lt;html class=&quot;no-js lt-ie9 lt-ie8&quot; lang=&quot;en&quot;&gt; &lt;![endif]--&gt;
            &lt;!--[if IE 8]&gt;    &lt;html class=&quot;no-js lt-ie9&quot; lang=&quot;en&quot;&gt; &lt;![endif]--&gt;
            &lt;!--[if gt IE 8]&gt;&lt;!--&gt; &lt;html class=&quot;no-js&quot; lang=&quot;en&quot;&gt; &lt;!--&lt;![endif]--&gt;
            </xsl:text>

                <!-- First of all, build the HTML head element -->

                <xsl:call-template name="buildHead"/>

                <!-- Then proceed to the body -->
                <body>
                    <!-- Prompt IE 6 users to install Chrome Frame. Remove this if you support IE 6.
                   chromium.org/developers/how-tos/chrome-frame-getting-started -->
                    <!--[if lt IE 7]><p class=chromeframe>Your browser is <em>ancient!</em> <a href="http://browsehappy.com/">Upgrade to a different browser</a> or <a href="http://www.google.com/chromeframe/?redirect=true">install Google Chrome Frame</a> to experience this site.</p><![endif]-->
                    <xsl:choose>
                        <xsl:when
                                test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='framing'][@qualifier='popup']">
                            <xsl:apply-templates select="dri:body/*"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="buildHeader"/>
                            <xsl:call-template name="buildTrail"/>
                            <!--javascript-disabled warning, will be invisible if javascript is enabled-->
                            <div id="no-js-warning-wrapper" class="hidden">
                                <div id="no-js-warning">
                                    <div class="notice failure">
                                        <xsl:text>JavaScript is disabled for your browser. Some features of this site may not work without it.</xsl:text>
                                    </div>
                                </div>
                            </div>

                            <div id="main-container" class="container">

                                <div class="row row-offcanvas row-offcanvas-right">
                                    <div class="horizontal-slider clearfix">
                                        <div class="col-xs-12 col-sm-12 col-md-9 main-content">
                                            <xsl:apply-templates select="*[not(self::dri:options)]"/>

                                            <div class="visible-xs visible-sm">
                                                <xsl:call-template name="buildFooter"/>
                                            </div>
                                        </div>
                                        <div class="col-xs-6 col-sm-3 sidebar-offcanvas" id="sidebar" role="navigation">
                                            <xsl:apply-templates select="dri:options"/>
                                        </div>

                                    </div>
                                </div>

                                <!--
                            The footer div, dropping whatever extra information is needed on the page. It will
                            most likely be something similar in structure to the currently given example. -->
                            <div class="hidden-xs hidden-sm">
                            <xsl:call-template name="buildFooter"/>
                             </div>
                         </div>


                        </xsl:otherwise>
                    </xsl:choose>
                    <!-- Javascript at the bottom for fast page loading -->
                    <xsl:call-template name="addJavascript"/>
                </body>
                <xsl:text disable-output-escaping="yes">&lt;/html&gt;</xsl:text>

            </xsl:when>
            <xsl:otherwise>
                <!-- This is only a starting point. If you want to use this feature you need to implement
                JavaScript code and a XSLT template by yourself. Currently this is used for the DSpace Value Lookup -->
                <xsl:apply-templates select="dri:body" mode="modal"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- The HTML head element contains references to CSS as well as embedded JavaScript code. Most of this
    information is either user-provided bits of post-processing (as in the case of the JavaScript), or
    references to stylesheets pulled directly from the pageMeta element. -->
    <xsl:template name="buildHead">
        <head>
            <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>

            <!-- Use the .htaccess and remove these lines to avoid edge case issues.
             More info: h5bp.com/i/378 -->
            <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1"/>

            <!-- Mobile viewport optimized: h5bp.com/viewport -->
            <meta name="viewport" content="width=device-width,initial-scale=1"/>

            <link rel="shortcut icon">
                <xsl:attribute name="href">
                    <xsl:value-of select="$theme-path"/>
                    <xsl:text>images/favicon.ico</xsl:text>
                </xsl:attribute>
            </link>
            <link rel="apple-touch-icon">
                <xsl:attribute name="href">
                    <xsl:value-of select="$theme-path"/>
                    <xsl:text>images/apple-touch-icon.png</xsl:text>
                </xsl:attribute>
            </link>

            <meta name="Generator">
                <xsl:attribute name="content">
                    <xsl:text>Repositorio Tecnm Orizaba</xsl:text>
                    <xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='dspace'][@qualifier='version']">
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='dspace'][@qualifier='version']"/>
                    </xsl:if>
                </xsl:attribute>
            </meta>

            <xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='ROBOTS'][not(@qualifier)]">
                <meta name="ROBOTS">
                    <xsl:attribute name="content">
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='ROBOTS']"/>
                    </xsl:attribute>
                </meta>
            </xsl:if>

            <!-- Add stylesheets -->

            <!--TODO figure out a way to include these in the concat & minify-->
            <xsl:for-each select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='stylesheet']">
                <link rel="stylesheet" type="text/css">
                    <xsl:attribute name="media">
                        <xsl:value-of select="@qualifier"/>
                    </xsl:attribute>
                    <xsl:attribute name="href">
                        <xsl:value-of select="$theme-path"/>
                        <xsl:value-of select="."/>
                    </xsl:attribute>
                </link>
            </xsl:for-each>

            <link rel="stylesheet" href="{concat($theme-path, 'styles/main.css')}"/>

            <!-- Add syndication feeds -->
            <xsl:for-each select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='feed']">
                <link rel="alternate" type="application">
                    <xsl:attribute name="type">
                        <xsl:text>application/</xsl:text>
                        <xsl:value-of select="@qualifier"/>
                    </xsl:attribute>
                    <xsl:attribute name="href">
                        <xsl:value-of select="."/>
                    </xsl:attribute>
                </link>
            </xsl:for-each>

            <!--  Add OpenSearch auto-discovery link -->
            <xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='opensearch'][@qualifier='shortName']">
                <link rel="search" type="application/opensearchdescription+xml">
                    <xsl:attribute name="href">
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='scheme']"/>
                        <xsl:text>://</xsl:text>
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='serverName']"/>
                        <xsl:text>:</xsl:text>
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='serverPort']"/>
                        <xsl:value-of select="$context-path"/>
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='opensearch'][@qualifier='autolink']"/>
                    </xsl:attribute>
                    <xsl:attribute name="title" >
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='opensearch'][@qualifier='shortName']"/>
                    </xsl:attribute>
                </link>
            </xsl:if>

            <!-- The following javascript removes the default text of empty text areas when they are focused on or submitted -->
            <!-- There is also javascript to disable submitting a form when the 'enter' key is pressed. -->
            <script>
                //Clear default text of empty text areas on focus
                function tFocus(element)
                {
                if (element.value == '<i18n:text>xmlui.dri2xhtml.default.textarea.value</i18n:text>'){element.value='';}
                }
                //Clear default text of empty text areas on submit
                function tSubmit(form)
                {
                var defaultedElements = document.getElementsByTagName("textarea");
                for (var i=0; i != defaultedElements.length; i++){
                if (defaultedElements[i].value == '<i18n:text>xmlui.dri2xhtml.default.textarea.value</i18n:text>'){
                defaultedElements[i].value='';}}
                }
                //Disable pressing 'enter' key to submit a form (otherwise pressing 'enter' causes a submission to start over)
                function disableEnterKey(e)
                {
                var key;

                if(window.event)
                key = window.event.keyCode;     //Internet Explorer
                else
                key = e.which;     //Firefox and Netscape

                if(key == 13)  //if "Enter" pressed, then disable!
                return false;
                else
                return true;
                }
            </script>

            <xsl:text disable-output-escaping="yes">&lt;!--[if lt IE 9]&gt;
                &lt;script src="</xsl:text><xsl:value-of select="concat($theme-path, 'vendor/html5shiv/dist/html5shiv.js')"/><xsl:text disable-output-escaping="yes">"&gt;&#160;&lt;/script&gt;
                &lt;script src="</xsl:text><xsl:value-of select="concat($theme-path, 'vendor/respond/dest/respond.min.js')"/><xsl:text disable-output-escaping="yes">"&gt;&#160;&lt;/script&gt;
                &lt;![endif]--&gt;</xsl:text>

            <!-- Modernizr enables HTML5 elements & feature detects -->
            <script src="{concat($theme-path, 'vendor/modernizr/modernizr.js')}">&#160;</script>
             
            <!-- include css and javascript for video playback -->
           <link type="text/css" rel="stylesheet">
            <xsl:attribute name="href">http://vjs.zencdn.net/c/video-js.css</xsl:attribute>
            </link>
            <script src="http://vjs.zencdn.net/c/video.js">&#160;</script>

            <!-- Add the title in -->
            <xsl:variable name="page_title" select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='title'][last()]" />
            <title>
                <xsl:choose>
                    <xsl:when test="starts-with($request-uri, 'page/politicas')">
                         <i18n:text>xmlui.mirage2.page-structure.aboutThisRepository</i18n:text>

                    </xsl:when>
                    <xsl:when test="not($page_title)">
                        <xsl:text>  </xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="$page_title/node()" />
                    </xsl:otherwise>
                </xsl:choose>
            </title>
            <xsl:variable name="page_title" select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='title'][last()]" />
           <title>
                <xsl:choose>
                    <xsl:when test="starts-with($request-uri, 'page/enlaces')">
                         <i18n:text>xmlui.mirage2.page-structure.aboutThisRepository</i18n:text>
                    </xsl:when>
                    <xsl:when test="not($page_title)">
                        <xsl:text>Enlaces De Interes</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="$page_title/node()" />
                    </xsl:otherwise>
                </xsl:choose>
            </title>

            <xsl:variable name="page_title" select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='title'][last()]" />
           <title>
                <xsl:choose>
                    <xsl:when test="starts-with($request-uri, 'page/derechosautor')">
                         <i18n:text>xmlui.mirage2.page-structure.aboutThisRepository</i18n:text>
                    </xsl:when>
                    <xsl:when test="not($page_title)">
                        <xsl:text>Derechos De Autor</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="$page_title/node()" />
                    </xsl:otherwise>
                </xsl:choose>
            </title>


            <xsl:variable name="page_title" select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='title'][last()]" />
           <title>
                <xsl:choose>
                    <xsl:when test="starts-with($request-uri, 'page/preguntas')">
                         <i18n:text>xmlui.mirage2.page-structure.aboutThisRepository</i18n:text>
                    </xsl:when>
                    <xsl:when test="not($page_title)">
                        <xsl:text>Preguntas Frecuentes</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="$page_title/node()" />
                    </xsl:otherwise>
                </xsl:choose>
            </title>
            <!-- Head metadata in item pages -->
            <xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='xhtml_head_item']">
                <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='xhtml_head_item']"
                              disable-output-escaping="yes"/>
            </xsl:if>

            <!-- Add all Google Scholar Metadata values -->
            <xsl:for-each select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[substring(@element, 1, 9) = 'citation_']">
                <meta name="{@element}" content="{.}"></meta>
            </xsl:for-each>

            <!-- Add MathJAX JS library to render scientific formulas-->
            <xsl:if test="confman:getProperty('webui.browse.render-scientific-formulas') = 'true'">
                <script type="text/x-mathjax-config">
                    MathJax.Hub.Config({
                      tex2jax: {
                        ignoreClass: "detail-field-data|detailtable|exception"
                      },
                      TeX: {
                        Macros: {
                          AA: '{\\mathring A}'
                        }
                      }
                    });
                </script>
                <script type="text/javascript" src="//cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.1/MathJax.js?config=TeX-AMS-MML_HTMLorMML">&#160;</script>
            </xsl:if>

        </head>
    </xsl:template>


    <!-- The header (distinct from the HTML head element) contains the title, subtitle, login box and various
        placeholders for header images -->
    <xsl:template name="buildHeader">


        <header>
            <div class="navbar navbar-default navbar-static-top" role="navigation">
                <div class="container">
                    <div class="navbar-header">

                        <button type="button" class="navbar-toggle" data-toggle="offcanvas">
                            <span class="sr-only">
                                <i18n:text>xmlui.mirage2.page-structure.toggleNavigation</i18n:text>
                            </span>
                            <span class="icon-bar"></span>
                            <span class="icon-bar"></span>
                            <span class="icon-bar"></span>
                        </button>

                        <a href="https://www.facebook.com/tecorizaba/" target="_blank" class="navbar-brand" ><img src="{$theme-path}/images/fb.png" />
                            
                        </a>

                        
                        <button type="button" class="navbar-toggle" data-toggle="offcanvas">
                            <span class="sr-only">
                                <i18n:text>xmlui.mirage2.page-structure.toggleNavigation</i18n:text>
                            </span>
                            <span class="icon-bar"></span>
                            <span class="icon-bar"></span>
                            <span class="icon-bar"></span>
                        </button>

                        <a href="https://twitter.com/tecnmorizaba" target="_blank" class="navbar-brand" ><img src="{$theme-path}/images/twitter.png" />
                            
                        </a>


                        <button type="button" class="navbar-toggle" data-toggle="offcanvas">
                            <span class="sr-only">
                                <i18n:text>xmlui.mirage2.page-structure.toggleNavigation</i18n:text>
                            </span>
                            <span class="icon-bar"></span>
                            <span class="icon-bar"></span>
                            <span class="icon-bar"></span>
                        </button>

                        <a href="https://www.youtube.com/channel/UC7xWuznXuLVGRnBXSS4DY5g/featured?view_as=subscriber" target="_blank" class="navbar-brand" ><img src="{$theme-path}/images/you.png" />
                            
                        </a>
                        <div class="navbar-header pull-right visible-xs hidden-sm hidden-md hidden-lg">
                        <ul class="nav nav-pills pull-left ">

                        

                            <xsl:if test="count(/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='page'][@qualifier='supportedLocale']) &gt; 1">
                                <li id="ds-language-selection-xs" class="dropdown">
                                    <xsl:variable name="active-locale" select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='page'][@qualifier='currentLocale']"/>
                                    <button id="language-dropdown-toggle-xs" href="#" role="button" class="dropdown-toggle navbar-toggle navbar-link" data-toggle="dropdown">
                                        <b class="visible-xs glyphicon glyphicon-globe" aria-hidden="true"/>
                                    </button>
                                    <ul class="dropdown-menu pull-right" role="menu" aria-labelledby="language-dropdown-toggle-xs" data-no-collapse="true">
                                        <xsl:for-each
                                                select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='page'][@qualifier='supportedLocale']">
                                            <xsl:variable name="locale" select="."/>
                                            <li role="presentation">
                                                <xsl:if test="$locale = $active-locale">
                                                    <xsl:attribute name="class">
                                                        <xsl:text>disabled</xsl:text>
                                                    </xsl:attribute>
                                                </xsl:if>
                                                <a>
                                                    <xsl:attribute name="href">
                                                        <xsl:value-of select="$current-uri"/>
                                                        <xsl:text>?locale-attribute=</xsl:text>
                                                        <xsl:value-of select="$locale"/>
                                                    </xsl:attribute>
                                                    <xsl:value-of
                                                            select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='supportedLocale'][@qualifier=$locale]"/>
                                                </a>
                                            </li>
                                        </xsl:for-each>
                                    </ul>
                                </li>
                            </xsl:if>

                            <xsl:choose>
                                <xsl:when test="/dri:document/dri:meta/dri:userMeta/@authenticated = 'yes'">
                                    <li class="dropdown">
                                        <button class="dropdown-toggle navbar-toggle navbar-link" id="user-dropdown-toggle-xs" href="#" role="button"  data-toggle="dropdown">
                                            <b class="visible-xs glyphicon glyphicon-user" aria-hidden="true"/>
                                        </button>
                                        <ul class="dropdown-menu pull-right" role="menu"
                                            aria-labelledby="user-dropdown-toggle-xs" data-no-collapse="true">
                                            <li>
                                                <a href="{/dri:document/dri:meta/dri:userMeta/
                            dri:metadata[@element='identifier' and @qualifier='url']}">
                                                    <i18n:text>xmlui.EPerson.Navigation.profile</i18n:text>
                                                </a>
                                            </li>
                                            <li>
                                                <a href="{/dri:document/dri:meta/dri:userMeta/
                            dri:metadata[@element='identifier' and @qualifier='logoutURL']}">
                                                    <i18n:text>xmlui.dri2xhtml.structural.logout</i18n:text>
                                                </a>
                                            </li>
                                        </ul>
                                    </li>
                                </xsl:when>
                                <xsl:otherwise>
                                    <li>
                                        <form style="display: inline" action="{/dri:document/dri:meta/dri:userMeta/
                            dri:metadata[@element='identifier' and @qualifier='loginURL']}" method="get">
                                            <button class="navbar-toggle navbar-link">
                                            <b class="visible-xs glyphicon glyphicon-user" aria-hidden="true"/>
                                            </button>
                                        </form>
                                    </li>
                                </xsl:otherwise>
                            </xsl:choose>
                        </ul>


                              </div>
                    </div>

                    <div class="navbar-header pull-right hidden-xs">
                        <ul class="nav navbar-nav pull-left">
                              <xsl:call-template name="languageSelection"/>
                        </ul>
                        <ul class="nav navbar-nav pull-left">
                            <xsl:choose>
                                <xsl:when test="/dri:document/dri:meta/dri:userMeta/@authenticated = 'yes'">
                                    <li class="dropdown">
                                        <a id="user-dropdown-toggle" href="#" role="button" class="dropdown-toggle"
                                           data-toggle="dropdown">
                                            <span class="hidden-xs">
                                                <xsl:value-of select="/dri:document/dri:meta/dri:userMeta/
                            dri:metadata[@element='identifier' and @qualifier='firstName']"/>
                                                <xsl:text> </xsl:text>
                                                <xsl:value-of select="/dri:document/dri:meta/dri:userMeta/
                            dri:metadata[@element='identifier' and @qualifier='lastName']"/>
                                                &#160;
                                                <b class="caret"/>
                                            </span>
                                        </a>
                                        <ul class="dropdown-menu pull-right" role="menu"
                                            aria-labelledby="user-dropdown-toggle" data-no-collapse="true">
                                            <li>
                                                <a href="{/dri:document/dri:meta/dri:userMeta/
                            dri:metadata[@element='identifier' and @qualifier='url']}">
                                                    <i18n:text>xmlui.EPerson.Navigation.profile</i18n:text>
                                                </a>
                                            </li>
                                            <li>
                                                <a href="{/dri:document/dri:meta/dri:userMeta/
                            dri:metadata[@element='identifier' and @qualifier='logoutURL']}">
                                                    <i18n:text>xmlui.dri2xhtml.structural.logout</i18n:text>
                                                </a>
                                            </li>
                                        </ul>
                                    </li>
                                </xsl:when>
                                <xsl:otherwise>
                                    <li>
                                        <a href="{/dri:document/dri:meta/dri:userMeta/
                            dri:metadata[@element='identifier' and @qualifier='loginURL']}">
                                            <span class="hidden-xs">
                                                <i18n:text>xmlui.dri2xhtml.structural.login</i18n:text>
                                            </span>
                                        </a>
                                    </li>
                                </xsl:otherwise>
                            </xsl:choose>
                        </ul>

                        <button data-toggle="offcanvas" class="navbar-toggle visible-sm" type="button">
                            <span class="sr-only"><i18n:text>xmlui.mirage2.page-structure.toggleNavigation</i18n:text></span>
                            <span class="icon-bar"></span>
                            <span class="icon-bar"></span>
                            <span class="icon-bar"></span>
                        </button>
                    </div>
                </div>
            </div>

        </header>

    </xsl:template>


    <!-- The header (distinct from the HTML head element) contains the title, subtitle, login box and various
        placeholders for header images -->
    <xsl:template name="buildTrail">
        <div class="trail-wrapper hidden-print">
            <div class="container">
                <div class="row">
                    <!--TODO-->
                    <div class="col-xs-12">
                        <xsl:choose>
                            <xsl:when test="count(/dri:document/dri:meta/dri:pageMeta/dri:trail) > 1">
                                <div class="breadcrumb dropdown visible-xs">
                                    <a id="trail-dropdown-toggle" href="#" role="button" class="dropdown-toggle"
                                       data-toggle="dropdown">
                                        <xsl:variable name="last-node"
                                                      select="/dri:document/dri:meta/dri:pageMeta/dri:trail[last()]"/>
                                        <xsl:choose>
                                            <xsl:when test="$last-node/i18n:*">
                                                <xsl:apply-templates select="$last-node/*"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:apply-templates select="$last-node/text()"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                        <xsl:text>&#160;</xsl:text>
                                        <b class="caret"/>
                                    </a>
                                    <ul class="dropdown-menu" role="menu" aria-labelledby="trail-dropdown-toggle">
                                        <xsl:apply-templates select="/dri:document/dri:meta/dri:pageMeta/dri:trail"
                                                             mode="dropdown"/>
                                    </ul>
                                </div>
                                <ul class="breadcrumb hidden-xs">
                                    <xsl:apply-templates select="/dri:document/dri:meta/dri:pageMeta/dri:trail"/>
                                </ul>
                            </xsl:when>
                            <xsl:when test="./@target">
                    <a role="menuitem">
                        <xsl:attribute name="href">
                            <xsl:value-of select="./@target"/>
                        </xsl:attribute>
                        <xsl:if test="position()=1">
                            <i class="glyphicon glyphicon-home" aria-hidden="true"/>&#160;
                        </xsl:if>
                        <xsl:apply-templates />
                    </a>
                </xsl:when>
                          <xsl:when test="starts-with($request-uri, 'page/enlaces')">
                                <ul class="breadcrumb">
                                    <xsl:text>Enlaces De Interés</xsl:text>
                                </ul>
                            </xsl:when>
                            <xsl:when test="./@target">
                    <a role="menuitem">
                        <xsl:attribute name="href">
                            <xsl:value-of select="./@target"/>
                        </xsl:attribute>
                        <xsl:if test="position()=1">
                            <i class="glyphicon glyphicon-home" aria-hidden="true"/>&#160;
                        </xsl:if>
                        <xsl:apply-templates />
                    </a>
                </xsl:when>
                            <xsl:when test="starts-with($request-uri, 'page/derechosautor')">
                                <ul class="breadcrumb">
                                    <xsl:text>Derechos De Autor</xsl:text>
                                </ul>
                            </xsl:when>
                            <xsl:when test="starts-with($request-uri, 'page/preguntas')">
                                <ul class="breadcrumb">
                                    <xsl:text>Preguntas Frecuentes</xsl:text>
                                </ul>
                            </xsl:when>

                            <xsl:otherwise>
                                <ul class="breadcrumb">
                                    <xsl:apply-templates select="/dri:document/dri:meta/dri:pageMeta/dri:trail"/>
                                </ul>
                            </xsl:otherwise>
                        </xsl:choose>
                    </div>
                </div>
            </div>
        </div>


    </xsl:template>

    <!--The Trail-->
    <xsl:template match="dri:trail">
        <!--put an arrow between the parts of the trail-->
        <li>
            <xsl:if test="position()=1">
                <i class="glyphicon glyphicon-home" aria-hidden="true"/>&#160;
            </xsl:if>
            <!-- Determine whether we are dealing with a link or plain text trail link -->
            <xsl:choose>
                <xsl:when test="./@target">
                    <a>
                        <xsl:attribute name="href">
                            <xsl:value-of select="./@target"/>
                        </xsl:attribute>
                        <xsl:apply-templates />
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="class">active</xsl:attribute>
                    <xsl:apply-templates />
                </xsl:otherwise>
            </xsl:choose>
        </li>
    </xsl:template>

    <xsl:template match="dri:trail" mode="dropdown">
        <!--put an arrow between the parts of the trail-->
        <li role="presentation">
            <!-- Determine whether we are dealing with a link or plain text trail link -->
            <xsl:choose>
                <xsl:when test="./@target">
                    <a role="menuitem">
                        <xsl:attribute name="href">
                            <xsl:value-of select="./@target"/>
                        </xsl:attribute>
                        <xsl:if test="position()=1">
                            <i class="glyphicon glyphicon-home" aria-hidden="true"/>&#160;
                        </xsl:if>
                        <xsl:apply-templates />
                    </a>
                </xsl:when>
                <xsl:when test="position() > 1 and position() = last()">
                    <xsl:attribute name="class">disabled</xsl:attribute>
                    <a role="menuitem" href="#">
                        <xsl:apply-templates />
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="class">active</xsl:attribute>
                    <xsl:if test="position()=1">
                        <i class="glyphicon glyphicon-home" aria-hidden="true"/>&#160;
                    </xsl:if>
                    <xsl:apply-templates />
                </xsl:otherwise>
            </xsl:choose>
        </li>
    </xsl:template>

    <!--The License-->
    <xsl:template name="cc-license">
        <xsl:param name="metadataURL"/>
        <xsl:variable name="externalMetadataURL">
            <xsl:text>cocoon:/</xsl:text>
            <xsl:value-of select="$metadataURL"/>
            <xsl:text>?sections=dmdSec,fileSec&amp;fileGrpTypes=THUMBNAIL</xsl:text>
        </xsl:variable>

        <xsl:variable name="ccLicenseName"
                      select="document($externalMetadataURL)//dim:field[@element='rights']"
                />
        <xsl:variable name="ccLicenseUri"
                      select="document($externalMetadataURL)//dim:field[@element='rights'][@qualifier='uri']"
                />
        <xsl:variable name="handleUri">
            <xsl:for-each select="document($externalMetadataURL)//dim:field[@element='identifier' and @qualifier='uri']">
                <a>
                    <xsl:attribute name="href">
                        <xsl:copy-of select="./node()"/>
                    </xsl:attribute>
                    <xsl:copy-of select="./node()"/>
                </a>
                <xsl:if test="count(following-sibling::dim:field[@element='identifier' and @qualifier='uri']) != 0">
                    <xsl:text>, </xsl:text>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>

        <xsl:if test="$ccLicenseName and $ccLicenseUri and contains($ccLicenseUri, 'creativecommons')">
            <div about="{$handleUri}" class="row">
            <div class="col-sm-3 col-xs-12">
                <a rel="license"
                   href="{$ccLicenseUri}"
                   alt="{$ccLicenseName}"
                   title="{$ccLicenseName}"
                        >
                    <xsl:call-template name="cc-logo">
                        <xsl:with-param name="ccLicenseName" select="$ccLicenseName"/>
                        <xsl:with-param name="ccLicenseUri" select="$ccLicenseUri"/>
                    </xsl:call-template>
                </a>
            </div> <div class="col-sm-8">
                <span>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.cc-license-text</i18n:text>
                    <xsl:value-of select="$ccLicenseName"/>
                </span>
            </div>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="cc-logo">
        <xsl:param name="ccLicenseName"/>
        <xsl:param name="ccLicenseUri"/>
        <xsl:variable name="ccLogo">
             <xsl:choose>
                  <xsl:when test="starts-with($ccLicenseUri,
                                           'http://creativecommons.org/licenses/by/')">
                       <xsl:value-of select="'cc-by.png'" />
                  </xsl:when>
                  <xsl:when test="starts-with($ccLicenseUri,
                                           'http://creativecommons.org/licenses/by-sa/')">
                       <xsl:value-of select="'cc-by-sa.png'" />
                  </xsl:when>
                  <xsl:when test="starts-with($ccLicenseUri,
                                           'http://creativecommons.org/licenses/by-nd/')">
                       <xsl:value-of select="'cc-by-nd.png'" />
                  </xsl:when>
                  <xsl:when test="starts-with($ccLicenseUri,
                                           'http://creativecommons.org/licenses/by-nc/')">
                       <xsl:value-of select="'cc-by-nc.png'" />
                  </xsl:when>
                  <xsl:when test="starts-with($ccLicenseUri,
                                           'http://creativecommons.org/licenses/by-nc-sa/')">
                       <xsl:value-of select="'cc-by-nc-sa.png'" />
                  </xsl:when>
                  <xsl:when test="starts-with($ccLicenseUri,
                                           'http://creativecommons.org/licenses/by-nc-nd/')">
                       <xsl:value-of select="'cc-by-nc-nd.png'" />
                  </xsl:when>
                  <xsl:when test="starts-with($ccLicenseUri,
                                           'http://creativecommons.org/publicdomain/zero/')">
                       <xsl:value-of select="'cc-zero.png'" />
                  </xsl:when>
                  <xsl:when test="starts-with($ccLicenseUri,
                                           'http://creativecommons.org/publicdomain/mark/')">
                       <xsl:value-of select="'cc-mark.png'" />
                  </xsl:when>
                  <xsl:otherwise>
                       <xsl:value-of select="'cc-generic.png'" />
                  </xsl:otherwise>
             </xsl:choose>
        </xsl:variable>
        <img class="img-responsive">
             <xsl:attribute name="src">
                <xsl:value-of select="concat($theme-path,'/images/creativecommons/', $ccLogo)"/>
             </xsl:attribute>
             <xsl:attribute name="alt">
                 <xsl:value-of select="$ccLicenseName"/>
             </xsl:attribute>
        </img>
    </xsl:template>

    <!-- Like the header, the footer contains various miscellaneous text, links, and image placeholders -->
    <xsl:template name="buildFooter">
        <footer>
                <div class="row">
                    <hr/>
                    <div class="col-xs-7 col-sm-8">
                        <div>
                            <a href="http://repositorios.orizaba.tecnm.mx:8080/xmlui/" target="_blank">Repositorio Tecnm Orizaba</a> copyright&#160;&#169;&#160;2020&#160; 
                        </div>
                        <div class="hidden-print">
                            <a>
                                <xsl:attribute name="href">
                                    <xsl:value-of
                                            select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                                    <xsl:text>/contact</xsl:text>
                                </xsl:attribute>
                                <i18n:text>xmlui.dri2xhtml.structural.contact-link</i18n:text>
                            </a>
                            <xsl:text> | </xsl:text>
                            <a>
                                <xsl:attribute name="href">
                                    <xsl:value-of
                                            select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                                    <xsl:text>/feedback</xsl:text>
                                </xsl:attribute>
                                <i18n:text>xmlui.dri2xhtml.structural.feedback-link</i18n:text>
                            </a>
                        </div>
                    </div>
                    <div class="col-xs-5 col-sm-4 hidden-print">
                        <div class="pull-right">
                            <!-- <span class="theme-by">Theme by&#160;</span>
                            <br/>
                            <a title="Atmire NV" target="_blank" href="http://atmire.com">
                                <img alt="Atmire NV" src="{concat($theme-path, 'images/atmire-logo-small.svg')}"/>
                            </a>-->
                        </div>

                    </div>
                </div>
                <!--Invisible link to HTML sitemap (for search engines) -->
                <a class="hidden">
                    <xsl:attribute name="href">
                        <xsl:value-of
                                select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                        <xsl:text>/htmlmap</xsl:text>
                    </xsl:attribute>
                    <xsl:text>&#160;</xsl:text>
                </a>
            <p>&#160;</p>
        </footer>
    </xsl:template>


    <!--
            The meta, body, options elements; the three top-level elements in the schema
    -->




    <!--
        The template to handle the dri:body element. It simply creates the ds-body div and applies
        templates of the body's child elements (which consists entirely of dri:div tags).
    -->
    <xsl:template match="dri:body">
        <div>
            <xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='alert'][@qualifier='message']">
                <div class="alert alert-warning">
                    <button type="button" class="close" data-dismiss="alert">&#215;</button>
                    <xsl:copy-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='alert'][@qualifier='message']/node()"/>
                </div>
            </xsl:if>

            <!-- Check for the custom pages -->
            <xsl:choose>
                <xsl:when test="starts-with($request-uri, 'page/politicas')">
                    <div class="hero-unit">
                        <h2 class="">
                <span class="strong_underline">Políticas</span>
                <span class="uca_listdate"></span>
            </h2>

        
        
        </div>
        
        <div class="single_content">
            <div class="pf-content">
<p style="padding-left: 30px;"><a href="#contenidos">Política de contenidos y colecciones</a><br />
<a href="#servicios">Política de servicios</a><br />
<a href="#metadatos">Política de metadatos</a><br />
<a href="#depositos">Política de depósitos</a><br />
<a href="#edicion">Política de edición, preservación, sustitución y eliminación de registros</a><br />
<a href="#estadisticas">Política de estadísticas</a><br />
<a href="#digital">Política de preservación digital</a><br />
<a href="#formatos">Política de soporte de formatos</a><br />
<a href="#privacidad">Política de privacidad</a></p>
<p>Para más información contacte con    <img src="https://www.pikpng.com/pngl/m/33-337043_icono-gmail-gratis-de-address-book-providers-in.png" alt="" class="iconoenlinea alignnone wp-image-1356 size-full" width="25" height="25" /><a href="mailto:soporte.repositorio@orizaba.tecnm.mx">soporte.repositorio@orizaba.tecnm.mx</a></p>
<hr />
<h3><a id="contenidos"></a>Política de contenidos y colecciones</h3>
<p>El Repositorio Orizaba TecNM es un repositorio multidisciplinar cuyo objetivo es permitir el acceso abierto a la documentación producto de la actividad científica, docente e institucional del Instituto Tecnológico De Orizaba, aumentando la visibilidad de los contenidos y garantizando la preservación de los mismos.</p>
<p>El Repositorio recoge todo tipo de materiales digitales: artículos de revistas, comunicaciones a congresos, tesis doctorales, documentos de trabajo, materiales docentes y objetos de aprendizaje, así como los productos digitales del patrimonio bibliográfico del Instituto Tecnológico De Orizaba, siempre y cuando este material:</p>


    
    <b>1.Sea producido por miembros en activo de la comunidad universitaria: significa que el autor o coautor de un trabajo esté vinculado a uno de los centros, departamentos, institutos o servicios del Instituto Tecnológico De Orizaba. <br />
    2.Pertenezca al ámbito de la investigación, de la docencia, de la administración o del patrimonio cultural del Instituto Tecnológico De Orizaba.<br />
    3.Esté en formato digital. <br />
    4.Esté completo para su distribución y archivo.<br />
5.El autor/titular del copyright del trabajo pueda y quiera conceder al Instituto Tecnológico De Orizaba. La licencia no exclusiva para preservar y difundir el trabajo en cuestión a través del repositorio institucional. Este apartado es particularmente importante porque hace referencia a los derechos de autor. El autor debe saber qué tipo de datos se pueden publicar en el repositorio y conocer los derechos de explotación para cada tipo de documento.</b><br /><br/>

<p>El Repositorio del Instituto Tecnológico De Orizaba admite el depósito del siguiente material:</p><br/>

1. Artículos preprints y postprints. Los preprints son las versiones que envían los autores para ser evaluadas por un comité de pares de revistas científicas. Los postprints pueden ser de autor o de editor y hacen referencia a los artículos que han pasado la evaluación de los pares. Los postprints de autor son las versiones de los artículos en los que el autor ha incorporado las sugerencias del comité de pares para mejorar el texto mientras que los postprints de editor son las versiones finales que aparecen publicadas en las revistas científicas, con el logo del editor.<br/>
2.Comunicaciones de congresos, jornadas, seminarios y otras reuniones científicas, así como presentaciones y pósters.<br/>
3.Tesis doctorales, Trabajos Fin de Máster, Trabajos Fin de Grado y Proyectos Fin de Carrera.<br/>
4.Libros y partes de libros.<br/>
5.Conjuntos de datos.<br/> 
6.Material didáctico, trabajos de divulgación.<br/>
7.Grabaciones sonoras y audiovisuales.<br/>
8.Material digitalizado: siempre y cuando se cumpla con los permisos oportunos en cuanto a derechos de autor se admiten copias digitalizadas de trabajos que por su antigüedad carezcan de una versión electrónica disponible en internet.<br/>
9.Informes técnicos.<br/>
10.Patentes.<br/>
11.Mapas.<br/>
12.Imágenes.<br/><br/>

<p>El Repositorio del Instituto Tecnológico De Orizaba  acepta material científico en cualquier idioma, siendo el español y el inglés los más representativos.</p><br/>

<p>El Repositorio del Instituto Tecnológico De Orizaba  acepta documentos en los formatos comúnmente utilizados, pero por razones de accesibilidad y preservación digital es recomendable un formato fácilmente legible en el entorno web (como es el PDF). En líneas generales, se prefieren formatos abiertos como RTF, TIFF y JPG frente a formatos propietarios (Word, GIF, etc).</p><br/>

<p>Esta política de contenidos podrá ser revisada por el equipo de gestión de el Repositorio del Instituto Tecnológico De Orizaba.</p><br/>
<hr/><br/>
<h3><a id="servicios"></a>Política de servicios</h3><br/>

<p>El Repositorio del Instituto Tecnológico De Orizaba  pone a disposición de sus usuarios una serie de servicios para promover un uso fácil y eficiente del repositorio. El equipo de gestión de el Repositorio del Instituto Tecnológico De Orizaba :</p><br/>

1.Define la misión, objetivos, los servicios y desarrollo del repositorio.<br/>
2.Ofrece servicios de consultas y apoyo técnico sobre el funcionamiento cotidiano del repositorio.<br/>
3.Organiza e imparte cursos de formación sobre el funcionamiento del Instituto Tecnológico De Orizaba y temáticas relativas al acceso abierto.<br/>
4.Lleva a cabo campañas de difusión y promoción del Repositorio entre la comunidad universitaria.<br/>
5.Crea recursos de formación y tutoriales.<br/>
6.Elabora estudios e informes sobre la gestión y uso del Repositorio.<br/>
7.Fomenta el intercambio de conocimientos e información mediante nuevos canales de comunicación.<br/>
8.Asesora en cuestiones de derechos de autor.<br/>
9.Crea nuevas colecciones para atender las necesidades de Grupos de Investigación, Departamentos o Unidades del Instituto Tecnológico De Orizaba.<br/>
10.Incorpora nuevas funcionalidades en el repositorio, ofreciendo así más y mejores servicios.<br/>
<br/>
<p>Esta política de servicios podrá ser revisada por el equipo de gestión de  el Repositorio del Instituto Tecnológico De Orizaba.</p><br/>
<hr/><br/>
<h3><a id="metadatos"></a>Política de metadados</h3><br/>

<p>Los metadatos son la información mínima necesaria para identificar un documento. Son toda aquella información descriptiva sobre el contexto, calidad, condición o características de un recurso, dato u objeto con la finalidad de facilitar su recuperación, autentificación, evaluación, preservación y/o interoperabilidad.</p><br/><br/>
<p>Hay diversos tipos y modelos de metadatos. Dublin Core (DC) es el esquema de metadatos usado en El Repositorio del Instituto Tecnológico De Orizaba. Cualquier usuario puede acceder a los metadatos de el Repositorio del Instituto Tecnológico De Orizaba Estos metadatos pueden ser reutilizados sin necesidad de permisos explícitos siempre y cuando se haga mención al registro originario de los metadatos en el Repositorio del Instituto Tecnológico De Orizaba.</p><br/>
<hr/><br/>
<h3><a id="depositos"></a>Política de depósitos</h3><br/><br/>
<p>Esta sección define quién puede depositar en el Repositorio del Instituto Tecnológico De Orizaba y cómo hacerlo.</p><br/><br/>
<p>El Repositorio del Instituto Tecnológico De Orizaba se basa en un modelo distribuido de trabajo mediante el cual los miembros pueden auto-archivar sus trabajos, es decir, cada autor deposita, bajo su propia responsabilidad, los documentos en el repositorio. El investigador que deposita un documento se responsabiliza de la autoría del mismo y de no haber transferido o cedido en exclusiva los derechos de explotación de esa obra a terceros (por ejemplo a una editorial o una revista científica).</p><br/><br/>
<p>Todos los miembros del Personal Docente e Investigador del Instituto Tecnológico De Orizaba y todo el Personal de Administración y Servicios pueden depositar documentos de docencia o investigación en el repositorio, accediendo con sus credenciales universitarias. Para los alumnos es necesario estar registrado en el repositorio y tener los permisos para ello. Si el autor tiene cuenta en el repositorio pero no tiene permisos de autoarchivo debe enviar un correo a <img src="https://www.pikpng.com/pngl/m/33-337043_icono-gmail-gratis-de-address-book-providers-in.png" alt="" class="iconoenlinea alignnone wp-image-1356 size-full" width="25" height="25" /><a href="mailto:soporte.repositorio@orizaba.tecnm.mx">soporte.repositorio@orizaba.tecnm.mx</a> solicitandolos.</p>.<br/><br/>
<p>Cuando se finaliza el proceso de envío, El Repositorio del Instituto Tecnológico De Orizaba revisa los metadatos y el documento se publica.</p><br/><br/>
<p>El autor recibirá un mensaje de correo electrónico informándole al respecto. Este correo contiene la URL persistente asignada al documento. En el caso de que el equipo de gestión del repositorio detecte alguna incidencia (por ejemplo, el archivo subido no corresponde con el documento descrito o no está completo), rechazará el envío y lo comunicará por correo electrónico. Se pueden realizar las modificaciones oportunas y volver a enviarlo.</p><br/><br/>
<p>El último paso para el depósito de un trabajo es la concesión de una licencia de distribución no exclusiva por la que el autor autoriza a El Repositorio del Instituto Tecnológico De Orizaba a archivar, difundir en abierto y preservar dicho trabajo. Esta licencia no es incompatible con otros usos ni vías de difusión que el autor considere oportunos para su obra.</p><br/><br/>
<p>Para comprobar el estado del envío el autor debe acceder a “Mi Cuenta”. Los autores que depositen en el repositorio no están autorizados a modificar los trabajos que hayan depositado. Las modificaciones corren a cargo del equipo de gestión de el repositorio, por lo que si el autor desea realizar algún cambio deberá ponerse en contacto con los mismos. El equipo de gestión de el repositorio también es el encargado de realizar mapeos, cambiar colecciones de registros y borrar registros completos.</p><br/><br/>
<hr/><br/>
<h3><a id="edicion"></a>Política de edición, preservación, sustitución y eliminación de registros</h3><br/>
<p>El Repositorio del Instituto Tecnológico De Orizaba  recoge, difunde y preserva la producción digital generada por los miembros de la comunidad universitaria en materia de cultura, docencia, colecciones digitalizadas e investigación. Por tanto, no se contempla la eliminación de registros, a excepción de los casos descritos más abajo.</p><br/><br/>
<p>Si un autor revisa sustancialmente el contenido de un trabajo suyo y desea depositar una nueva versión, deberá hacerlo como un registro y un documento nuevos, a menos que desee mantener el mismo identificador HANDLE. El equipo de gestión del repositorio podrá enlazar, si el autor así lo desea, ambas versiones del trabajo e incluir información sobre qué versión es la preferida, pero en líneas generales la política de el repositorio es conservar la versión más actual de los trabajos depositados.</p><br/><br/>
<p>El Repositorio del Instituto Tecnológico De Orizaba conservará los depósitos de los trabajos de autores miembros del Instituto Tecnológico De Orizaba incluso aunque cambien de afiliación institucional. Excepcionalmente, los gestores del repositorio eliminarán, sin pedir el consentimiento previo al autor del trabajo, los registros que:</p><br/><br/>

<p>No sean pertinentes con la naturaleza de el Repositorio del Instituto Tecnológico De Orizaba.</p><br/>
<p>Soporten un formato cuyo archivo o visualización sea absolutamente insatisfactorio en el Repositorio del Instituto Tecnológico De Orizaba.</p><br/>
<p>Contengan un virus o presenten cualquier otro problema técnico.</p><br/>
<p>Infrinjan los derechos de autor: en el caso de que se detecte que se ha depositado por error una publicación sin permisos para el depósito en un repositorio abierto, éste se eliminará inmediatamente y se contactará con la persona que haya realizado el depósito para pedir una versión del trabajo que sí sea susceptible de ser depositado.</p><br/>
<p>Sean plagios de trabajos de otros autores.</p><br/>
<p>Los trabajos duplicados en el Repositorio del Instituto Tecnológico De Orizaba.</p><br/>
<p>Los registros eliminados no serán borrados definitivamente. El Repositorio del Instituto Tecnológico De Orizaba almacenará una copia privada. En estos casos, la dirección electrónica (URL) permanente del elemento continuará vigente.</p><br/><br/>
<hr/><br/>
<h3><a id="estadisticas"></a>Política de estadísticas</h3><br/>
<p>El Repositorio del Instituto Tecnológico De Orizaba  genera automáticamente estadísticas que usa como herramienta de análisis de la producción científica, institucional y cultural del Instituto Tecnológico De Orizaba y del grado de su difusión, su visibilidad y su accesibilidad internacionales. El módulo de estadísticas también analiza el ritmo de crecimiento de contenidos y la tipología del material disponible en el repositorio, así como las pautas de visitas y descargas. Estas estadísticas son accesibles gratuitamente en la sección pública de el Repositorio del Instituto Tecnológico De Orizaba y ayudan a gestionar el repositorio de un modo eficiente, identificando pautas de uso y de desarrollo.</p><br/><br/>
<hr/><br/>
<h3><a id="digital"></a>Política de preservación digital</h3><br/>
<p>Con el objeto de asegurar la disponibilidad del contenido de El Repositorio del Instituto Tecnológico De Orizaba y que pueda ser leído o reproducido:</p><br/><br/>
<p>El contenido será comprobado regularmente para preservar su integridad, seguridad y durabilidad.</p><br/>
<p>El contenido será transformado en nuevos formatos cuando se considere necesario (en base a esos mismos criterios de seguridad y durabilidad).</p><br/>
<p>Se proporcionarán, cuando sea posible, emulaciones de software para el acceso a formatos que no puedan ser migrados.</p><br/>
<p>Se realizan copias de seguridad regulares del contenido completo de El Repositorio del Instituto Tecnológico De Orizaba, incluyendo datos y metadatos.</p><br/>
<p>A efectos de preservación digital, El Repositorio del Instituto Tecnológico De Orizaba también recomienda el depósito de documentos con formatos fácilmente legibles (como es el PDF).</p><br/><br/>
<hr/><br/>
<h3><a id="formatos"></a>Política de soporte de formatos</h3><br/>
<p>El Repositorio del Instituto Tecnológico De Orizaba intenta sostener el mayor número posible de formatos. Sin embargo, en el caso de formatos específicos de naturaleza propietaria esta garantía no es total, debido a las características de su software. La política de soporte de formatos es particularmente importante porque está estrechamente ligada a la accesibilidad y a la preservación digital a largo plazo. Mientras que la accesibilidad electrónica de todos los archivos en el repositorio está garantizada a través de identificadores únicos y permanentes, la preservación y el soporte a largo plazo dependen en gran medida de los formatos de los documentos.</p><br/><br/>
<p>Cuando los formatos de los archivos depositados poseen las siguientes características las probabilidades de éxito para garantizar una preservación digital a largo plazo son mucho más altas:</p><br/><br/>
<b><p>Documentación completa y abierta.</p><br/>
<p>Software no propietario.</p><br/>
<p>Sin protección por medio de contraseña.</p><br/>
<p>Sin cifrado total o parcial.</p><br/>
<p>Sin archivos, programas o scripts incrustados.</p><br/>
<p>Se recomienda, por tanto, depositar en el repositorio archivos cuyo formato es abierto como RTF, TIFF, JPG, o formatos propietarios de gran popularidad mundial.</p></b><br/><br/>
<p>No se permite el depósito de elementos protegidos mediante contraseña, cifrados total o parcialmente, o que contengan código malicioso.</p><br/><br/>
<hr/><br/>
<h3><a id="privacidad"></a>Política de privacidad</h3><br/>
<p>El Repositorio del Instituto Tecnológico De Orizaba respeta la privacidad de sus usuarios, de modo que toda la información que recibe se usa únicamente para darse de alta en la intranet del repositorio a aquéllos que desean y están autorizados a depositar documentos y para activar el servicio personalizado de alertas. Cualquier usuario dado de alta en El Repositorio del Instituto Tecnológico De Orizaba puede suscribirse a este servicio de alertas que informa a diario de los nuevos depósitos realizados a nivel de colección.</p><br/><br/>
<p>En conformidad con la adecuación de la Ley Orgánica de Protección de Datos de Carácter Personal, El Repositorio del Instituto Tecnológico De Orizaba  no hace pública la información de sus usuarios relativa a visitas individuales al repositorio ni los datos personales necesarios para dar de alta en el sistema.</p><br/><br/>







</div>
                    </div>


            <xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='alert'][@qualifier='message']">
            
                    <button type="button" class="close" data-dismiss="alert">&#215;</button>
                    <xsl:copy-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='alert'][@qualifier='message']/node()"/>
                
            </xsl:if>
                </xsl:when>
               <!-- SECCION ENLACES -->
                <xsl:when test="starts-with($request-uri, 'page/enlaces')">
                    <div class="hero-unit">
                        <h2 class="">
                <span class="strong_underline">Enlaces de Interes</span>
                <span class="uca_listdate"></span>
            </h2><br/><br/>

<h3>Entidades de Gobierno</h3>
<p>El Repositorio del Instituto Tecnológico De Orizaba participa en proyectos nacionales e internacionales aumentando la visibilidad y el impacto de los documentos y sus autores.</p><br/><br/>
<hr />

<p><a href="https://www.tecnm.mx/" target="_blank" rel="noopener noreferrer"><img src="https://upload.wikimedia.org/wikipedia/commons/9/9d/TecNM_logo.png" alt=""  width="250" height="105"/></a></p><br/><br/>
<p>El Tecnológico Nacional de México, TecNM, es un sistema educativo que engloba un conjunto de establecimientos de educación superior pública de la República Mexicana.</p><br/>

<p>Los primeros institutos tecnológicos de México se crearon en 1948, siendo los de Chihuahua y Durango, luego en 1951 se crea de Saltillo y en 1953 el de Orizaba. En 2014 se decretó la conformación del Tecnológico Nacional de México, integrado por 266 instituciones dispuestas en las 32 entidades federativas del país.</p><br/><br/>
<hr />

<p><a href="https://www.conacyt.gob.mx/" target="_blank" rel="noopener noreferrer"><img src="https://www.ecured.cu/images/thumb/b/b8/CONACYT.jpg/260px-CONACYT.jpg" alt=""  width="250" height="105"/></a></p><br/><br/>
<p>El Consejo Nacional de Ciencia y Tecnología (Conacyt) es un organismo público descentralizado del gobierno federal mexicano; es la institución dedicada a promover el avance de la investigación científica, así como la innovación, el desarrollo y la modernización tecnológica del país.</p><br/>

<p>Tiene a su cargo diseñar, planear, ejecutar y coordinar las políticas públicas en materia de ciencia y tecnología. Para tales efectos, sus responsabilidades incluyen, operar en coordinación con la Secretaría de Educación Pública, los planes, programas y proyectos educativos que fomenten la formación científica, innovación e inventiva tecnológica en todos los niveles académicos; promover la integración y organización de grupos de investigadores en todas las variantes de las ciencias (exactas, naturales, de la salud, de humanidades y de la conducta, sociales, biotecnología y agropecuarias); impulsar la innovación y generación de desarrollos tecnológicos, procurando que el enfoque de esto se dirija al fortalecimiento de las capacidades técnicas de todos los sectores de la economía; asesorar a otros organismos públicos, dependencias federales, secretarías de estado, y cualquier otra instancia de gobierno, cuando en el ejercicio de sus funciones, esté de por medio la aplicación de las ciencias o el desarrollo tecnológico; colaborar con la Secretaría de Hacienda, para verificar el grado de integración, emitiendo los criterios a seguir, de proyectos tecnológicos o investigación científica en los presupuestos de todas las instituciones de la Administración Pública Federal, esto incluye delinear los estímulos fiscales que se harán a los sectores públicos y privados para el impulso de la ciencia y la tecnología; administrar el Sistema Nacional de Investigadores (SNI); colaborar en los programas de investigación científica y desarrollo tecnológico de las instituciones de educación superior; fomentar la producción de material en los medios de comunicación que estén destinados a la promoción de la ciencia y la tecnología; y otorgar los recursos públicos para el apoyo de estudiantes e investigadores que se encuentren en procesos o proyectos de investigación e innovación.</p><br/><br/>
<hr />
<p><a href="https://www.gob.mx/sep" target="_blank" rel="noopener noreferrer"><img src="https://www.gob.mx/cms/uploads/article/main_image/97619/cover_educacion.JPG" alt=""  width="250" height="105"/></a></p><br/><br/>
<p>La Secretaría de Educación Pública es una de las secretarías de estado que integran el denominado gabinete legal del Presidente de México. Es el despacho del poder ejecutivo federal encargado de la administración, regulación y fomento de la Educación.</p><br/>
<p>Su función es la de diseñar, ejecutar y coordinar las políticas públicas en materia de Educación. Lo anterior incluye elaborar los programas, planes y proyectos educativos que habrán de aplicarse en las escuelas públicas y privadas de todos los niveles formativos (básico, medio superior, normal, superior, técnica, industrial, comercial, agrícola, militar, profesional, deportiva, científica, de artes y oficios, incluyendo la educación que se imparta a los adultos) y gubernamentales (federal, estatal y municipal), pero sin perjuicio de la autonomía que guardan al respecto entidades federativas, universidades, las Fuerzas armadas e instituciones privadas de cualquier nivel.</p><br/><br/>
<hr />

<p><a href="http://www.veracruz.gob.mx/" target="_blank" rel="noopener noreferrer"><img src="https://www.segobver.gob.mx/juridico/img/Escudo%20heraldico-01.png" alt=""  width="250" height="105"/></a></p><br/><br/>
<p>El gobierno del estado de Veracruz, es decir, el poder público del Estado Libre y Soberano de Veracruz de Ignacio de la Llave, se establece en la constitución política correspondiente, y se divide, para su ejercicio, en tres poderes de gobierno: el Ejecutivo, el Legislativo y el Judicial.</p><br/><br/>
<hr />
<h3>Entidades Académicas</h3><br/><br/>
<p><a href="https://scholar.google.es/schhp?hl=es" target="_blank" rel="noopener noreferrer"><img src="https://upload.wikimedia.org/wikipedia/commons/a/a9/Google_Scholar_logo_2015.PNG" alt=""  width="250" height="105"/></a></p><br/><br/>
<p>Google Académico (en inglés, Google Scholar) es un buscador de Google enfocado y especializado en la búsqueda de contenido y bibliografía científico-académica.1​ El sitio indexa editoriales, bibliotecas, repositorios, bases de datos bibliográficas, entre otros; y entre sus resultados se pueden encontrar citas, enlaces a libros, artículos de revistas científicas, comunicaciones y congresos, informes científico-técnicos, tesis, tesinas y archivos depositados en repositorios.</p><br/><br/>
<hr />
<p><a href="http://oad.simmons.edu/oadwiki/Main_Page" target="_blank" rel="noopener noreferrer"><img src="http://oad.simmons.edu/oadwiki/images/thumb/0/09/Oad2.jpeg/180px-Oad2.jpeg" alt=""  width="250" height="105"/></a></p><br/><br/>
<p>OAD (Open Access Directory) es una wiki en la que se recogen las principales cuestiones sobre el acceso abierto a la información científica, mantenida por la Comunidad Open Access en general. Incluye una lista de Repositorios por disciplinas y de Repositorios de datos.</p><br/><br/>
<hr />
<p><a href="https://creativecommons.org/" target="_blank" rel="noopener noreferrer"><img src="https://geografosubjetivo.wordpress.com/files/2006/11/creative-commons.jpg" alt=""  width="250" height="105"/></a></p><br/><br/>
<p>Creative Commons es una organización americana sin ánimo de lucro que ha desarrollado un conjunto de “modelos de contratos de licenciamiento” o licencias de derechos de autor (licencias Creative Commons o licencias “CC”) que ofrecen al autor de una obra una forma simple y estandarizada de otorgar permiso al público en general de compartir y usar su trabajo creativo bajo los términos y condiciones de su elección. Las licencias Creative Commons no reemplazan a los derechos de autor, sino que se apoyan en estos para permitir modificar los términos y condiciones de la licencia de su obra de la forma que mejor satisfaga sus necesidades.</p><br/><br/>
<hr />
<p><a href="https://orcid.org/" target="_blank" rel="noopener noreferrer"><img src="https://www.cial.uam-csic.es/pagperso/foodomics/assets/img/Miguel/orcid.jpg" alt=""  width="250" height="105"/></a></p><br/><br/>
<p>ORCID (Open Researcher and Contributor ID) es una organización internacional sin ánimo de lucro que proporciona un identificador basado en la norma ISO 27729:2012, Information and documentation – International Standard Name Identifier (ISNI), que permite a los investigadores disponer de un código de autor persistente e inequívoco para distinguir claramente su producción académica. Esta iniciativa pretende garantizar la distinción inequívoca de la producción académica de los investigadores y ser un método efectivo para poder enlazar las actividades de investigación referenciadas en diferentes sistemas de información.</p><br/><br/>
<hr />
    
        </div>
                </xsl:when>
                    <!-- SECCION DERECHOS DE AUTOR -->

                 <xsl:when test="starts-with($request-uri, 'page/derechosautor')">
                    <div class="hero-unit">
                        <h2 class="">
                <span class="strong_underline">Derechos De Autor</span>
                <span class="uca_listdate"></span>
            </h2><br/><br/>


<p>Desde el mismo momento de la creación de una obra, la ley reconoce unos derechos al autor de la misma. Estos derechos de autor se dividen en derechos morales y derechos de explotación o patrimoniales. Los derechos morales de autoría e integridad de la obra son irrenunciables e inalienables. Los derechos de explotación de su obra en cualquier forma y, en especial, los derechos de reproducción, distribución, comunicación pública y transformación no podrán ser realizadas sin el permiso del autor.</p><br/><br/>

<p>Los derechos morales otorgan al autor el derecho a ser reconocido como tal y son intransferibles. Sin embargo los derechos de explotación pueden ser cedidos a terceros como ocurre con las obras publicadas:</p><br/>

<p align="center"><img src="{$theme-path}/images/derechosautor.jpg" width="550" height="305"/></p><br/><br/>
<hr />
<h3>Derechos de autor y autoarchivo</h3><br/><br/>

<p>Cuando un autor quiere depositar una obra en el repositorio, debe estar en condiciones de garantizar que dichos contenidos están libres de restricciones de derechos de copia. Para ello, hay que distinguir si la obra es inédita o ha sido ya publicada.</p><br/>

<p><b>– Obras inéditas:</b> En este caso el autor conserva los derechos de explotación de su obra y simplemente tiene que autorizar al Instituto Tecnológico De Orizaba a difundir su documento a través del Repositorio, mediante la aceptación de una Licencia de Distribución No Exclusiva, es decir, un contrato entre el autor y el nstituto Tecnológico De Orizaba, que permite  distribuir y preservar su trabajo, pero el autor conserva todos los derechos sobre su obra.</p><br/><br/>

<p>En algunos casos las editoriales no aceptan trabajos ya difundidos a través de repositorios, por este motivo es aconsejable por parte del autor conocer los contratos y las políticas de autoarchivo de las editoriales, para su posterior publicación.</p><br/><br/>


<p><b>– Obras ya publicadas:</b> Antes de incluir una obra ya publicada en el Repositorio TecNM Orizaba, el autor debe conocer las condiciones de cesión de los derechos de explotación de su obra y la política de autoarchivo de la editorial. Aunque la mayoría de los editores permiten el archivo del pre-print (el borrador del texto a publicar antes de la revisión por pares) se recomienda consultar la política de los editores.</p><br/><br/>

<p>En caso de que el autor desconozca en qué condiciones ha transferido sus derechos de explotación (reproducción, distribución o comunicación pública) a un editor, puede consultar la hoja de aceptación de las normas de publicación o la hoja de cesión de derechos, en el caso de revistas o congresos, o el contrato de edición en el caso de monografías.</p><br/><br/>

<h3>Licencias Creative Commons</h3><br/><br/>

<p>En el momento de autoarchivar su obra, el autor puede decidir sobre el uso que podrán hacer de ella mediante una Licencia Creative Commons, las cuales le permiten mantener sus derechos como autor a la vez que concede a terceros ciertos usos bajo determinadas condiciones.</p><br/><br/>

<p>Todas las licencias Creative Commons obligan al reconocimiento del autor de la obra, facilitando el uso, y al mismo tiempo salvaguardando la atribución de la obra al autor e impidiendo una posible utilización comercial sin permiso. Las licencias Creative Commons ofrecen algunos derechos a terceras personas bajo cuatro condiciones: Reconocimiento, No comercial, Sin obras derivadas y Compartir igual, con las que se generan seis modelos de licencias:</p><br/><br/>

<p align="center"><img src="{$theme-path}/images/commons.jpg" width="550" height="305"/></p><br/><br/>
<p>Existen dos licencias Creative Commons para el dominio público, es decir, para que los trabajos puedan ser redistribuidos y manipulados de manera completamente libre y sin restricciones, ya sea comercial o no comercialmente: CC0, por la que el autor de esta obra ha renunciado a sus derechos de autor a la misma, pasando a formar parte del dominio público; y la etiqueta de Dominio público, que resalta que el trabajo ya se encuentra bajo el dominio público.</p><br/><br/>
<p>Desde la administración de el Repositorio TecNM Orizaba se recomienda la modalidad de licencia <b>Reconocimiento – No comercial – Sin obra derivada</b>, por la que el autor permite copiar, reproducir, distribuir y comunicar públicamente la obra, siempre y cuando se cite y reconozca al autor original. No se permite, sin embargo, generar una obra derivada de la misma ni utilizarla con finalidades comerciales.</p><br/><br/>
<p>Asignar una licencia Creative Commons a las obras depositadas en el Repositorio TecNM Orizaba es opcional.</p><br/>
    
        </div>
                </xsl:when>





     <!-- SECCION PREGUNTAS FRECUENTES -->

                 <xsl:when test="starts-with($request-uri, 'page/preguntas')">
                    <div class="hero-unit">
                        <h2 class="">
                <span class="strong_underline">Preguntas Frecuentes</span>
                <span class="uca_listdate"></span>
            </h2><br/><br/>

<hr />
<h3>Acerca de</h3><br/><br/>

<div class="panel panel-default panel-modal">
<div data-target="#NUMERO1" class="panel-body" data-toggle="modal" style="cursor: pointer;"><b>¿Qué es el Repositorio TecNM Orizaba? ¿Cuáles son sus objetivos?</b> <span class="glyphicon glyphicon-zoom-in"></span></div>
</div>
<div id="NUMERO1" class="modal fade" role="dialog">
<div class="modal-dialog modal-lg modal-custom">
<div class="modal-content">
<div class="modal-header"><button type="button" class="close" data-dismiss="modal">×</button></div>
<div class="modal-body">
<h3>¿Qué es Repositorio TecNM Orizaba?</h3>
<p>Es el Repositorio de Objetos de Docencia e Investigación del Instituto Tecnológico De Orizaba, cuya finalidad es la creación de un archivo o depósito digital para almacenar, preservar y difundir la documentación producto de la actividad científica, docente e institucional.</p>
<p>El Repositorio TecNM Orizaba permite el acceso libre a la producción científica y académica generada por el Instituto Tecnológico De Orizaba, la preservación de la producción intelectual de la comunidad científica, la divulgación del trabajo desarrollado por docentes e investigadores, y el control y organización de la producción académica.</p>
<h3>¿Cuáles son sus objetivos?</h3>
<p>Dentro del movimiento internacional cada vez más extendido de permitir el acceso abierto a la literatura científica, y a los resultados de la investigación generada con fondos públicos, el Repositorio del Intituto Tecnológico De Orizaba tiene como objetivos:</p>
<ul>
<li>Incorporar la documentación científica, docente e institucional generada por los investigadores y unidades del ITO</li>
<li>Asegurar su preservación, organización y libre acceso, garantizando el reconocimiento de los derechos de autor</li>
<li>Incrementar su visibilidad y difusión dentro de la comunidad científica</li>
</ul>
</div>
</div>
</div>
</div>
    
        </div>
                </xsl:when>
                <!-- Otherwise use default handling of body -->
                <xsl:otherwise>
                    <xsl:apply-templates />
                </xsl:otherwise>
            </xsl:choose>




            </div>

           
    </xsl:template>

   


    <!-- Currently the dri:meta element is not parsed directly. Instead, parts of it are referenced from inside
        other elements (like reference). The blank template below ends the execution of the meta branch -->
    <xsl:template match="dri:meta">
    </xsl:template>

    <!-- Meta's children: userMeta, pageMeta, objectMeta and repositoryMeta may or may not have templates of
        their own. This depends on the meta template implementation, which currently does not go this deep.
    <xsl:template match="dri:userMeta" />
    <xsl:template match="dri:pageMeta" />
    <xsl:template match="dri:objectMeta" />
    <xsl:template match="dri:repositoryMeta" />
    -->

    <xsl:template name="addJavascript">

        <script type="text/javascript"><xsl:text>
                         if(typeof window.publication === 'undefined'){
                            window.publication={};
                          };
                        window.publication.contextPath= '</xsl:text><xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/><xsl:text>';</xsl:text>
            <xsl:text>window.publication.themePath= '</xsl:text><xsl:value-of select="$theme-path"/><xsl:text>';</xsl:text>
        </script>
        <!--TODO concat & minify!-->

        <script>
            <xsl:text>if(!window.DSpace){window.DSpace={};}window.DSpace.context_path='</xsl:text><xsl:value-of select="$context-path"/><xsl:text>';window.DSpace.theme_path='</xsl:text><xsl:value-of select="$theme-path"/><xsl:text>';</xsl:text>
        </script>

        <!--inject scripts.html containing all the theme specific javascript references
        that can be minified and concatinated in to a single file or separate and untouched
        depending on whether or not the developer maven profile was active-->
        <xsl:variable name="scriptURL">
            <xsl:text>cocoon://themes/</xsl:text>
            <!--we can't use $theme-path, because that contains the context path,
            and cocoon:// urls don't need the context path-->
            <xsl:value-of select="$pagemeta/dri:metadata[@element='theme'][@qualifier='path']"/>
            <xsl:text>scripts-dist.xml</xsl:text>
        </xsl:variable>
        <xsl:for-each select="document($scriptURL)/scripts/script">
            <script src="{$theme-path}{@src}">&#160;</script>
        </xsl:for-each>

        <!-- Add javascript specified in DRI -->
        <xsl:for-each select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='javascript'][not(@qualifier)]">
            <script>
                <xsl:attribute name="src">
                    <xsl:value-of select="$theme-path"/>
                    <xsl:value-of select="."/>
                </xsl:attribute>&#160;</script>
        </xsl:for-each>

        <!-- add "shared" javascript from static, path is relative to webapp root-->
        <xsl:for-each select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='javascript'][@qualifier='static']">
            <!--This is a dirty way of keeping the scriptaculous stuff from choice-support
            out of our theme without modifying the administrative and submission sitemaps.
            This is obviously not ideal, but adding those scripts in those sitemaps is far
            from ideal as well-->
            <xsl:choose>
                <xsl:when test="text() = 'static/js/choice-support.js'">
                    <script>
                        <xsl:attribute name="src">
                            <xsl:value-of select="$theme-path"/>
                            <xsl:text>js/choice-support.js</xsl:text>
                        </xsl:attribute>&#160;</script>
                </xsl:when>
                <xsl:when test="not(starts-with(text(), 'static/js/scriptaculous'))">
                    <script>
                        <xsl:attribute name="src">
                            <xsl:value-of
                                    select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                            <xsl:text>/</xsl:text>
                            <xsl:value-of select="."/>
                        </xsl:attribute>&#160;</script>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>

        <!-- add setup JS code if this is a choices lookup page -->
        <xsl:if test="dri:body/dri:div[@n='lookup']">
            <xsl:call-template name="choiceLookupPopUpSetup"/>
        </xsl:if>

        <xsl:call-template name="addJavascript-google-analytics" />
    </xsl:template>

    <xsl:template name="addJavascript-google-analytics">
        <!-- Add a google analytics script if the key is present -->
        <xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='google'][@qualifier='analytics']">
            <script><xsl:text>
                (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
                (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
                m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
                })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

                ga('create', '</xsl:text><xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='google'][@qualifier='analytics']"/><xsl:text>', '</xsl:text><xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='serverName']"/><xsl:text>');
                ga('send', 'pageview');
            </xsl:text></script>
        </xsl:if>
    </xsl:template>

    <!--The Language Selection
        Uses a page metadata curRequestURI which was introduced by in /xmlui-mirage2/src/main/webapp/themes/Mirage2/sitemap.xmap-->
    <xsl:template name="languageSelection">
        <xsl:variable name="curRequestURI">
            <xsl:value-of select="substring-after(/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='curRequestURI'],/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='URI'])"/>
        </xsl:variable>

        <xsl:if test="count(/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='page'][@qualifier='supportedLocale']) &gt; 1">
            <li id="ds-language-selection" class="dropdown">
                <xsl:variable name="active-locale" select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='page'][@qualifier='currentLocale']"/>
                <a id="language-dropdown-toggle" href="#" role="button" class="dropdown-toggle" data-toggle="dropdown">
                    <span class="hidden-xs">
                        <xsl:value-of
                                select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='supportedLocale'][@qualifier=$active-locale]"/>
                        <xsl:text>&#160;</xsl:text>
                        <b class="caret"/>
                    </span>
                </a>
                <ul class="dropdown-menu pull-right" role="menu" aria-labelledby="language-dropdown-toggle" data-no-collapse="true">
                    <xsl:for-each
                            select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='page'][@qualifier='supportedLocale']">
                        <xsl:variable name="locale" select="."/>
                        <li role="presentation">
                            <xsl:if test="$locale = $active-locale">
                                <xsl:attribute name="class">
                                    <xsl:text>disabled</xsl:text>
                                </xsl:attribute>
                            </xsl:if>
                            <a>
                                <xsl:attribute name="href">
                                    <xsl:value-of select="$curRequestURI"/>
                                    <xsl:call-template name="getLanguageURL"/>
                                    <xsl:value-of select="$locale"/>
                                </xsl:attribute>
                                <xsl:value-of
                                        select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='supportedLocale'][@qualifier=$locale]"/>
                            </a>
                        </li>
                    </xsl:for-each>
                </ul>
            </li>
        </xsl:if>
    </xsl:template>

    <!-- Builds the Query String part of the language URL. If there already is an existing query string
like: ?filtertype=subject&filter_relational_operator=equals&filter=keyword1 it appends the locale parameter with the ampersand (&) symbol -->
    <xsl:template name="getLanguageURL">
        <xsl:variable name="queryString" select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='queryString']"/>
        <xsl:choose>
            <!-- There allready is a query string so append it and the language argument -->
            <xsl:when test="$queryString != ''">
                <xsl:text>?</xsl:text>
                <xsl:choose>
                    <xsl:when test="contains($queryString, '&amp;locale-attribute')">
                        <xsl:value-of select="substring-before($queryString, '&amp;locale-attribute')"/>
                        <xsl:text>&amp;locale-attribute=</xsl:text>
                    </xsl:when>
                    <!-- the query string is only the locale-attribute so remove it to append the correct one -->
                    <xsl:when test="starts-with($queryString, 'locale-attribute')">
                        <xsl:text>locale-attribute=</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$queryString"/>
                        <xsl:text>&amp;locale-attribute=</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>?locale-attribute=</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
